# -*- coding: utf-8 -*-
"""体素模型精简：packages/GFL_Castling/models/*.xml

做两件事：
  1. 去掉标签之间的垃圾字符（旧工具在每个 > 后面注入的 1–2 个字符，如 <model>GG、<voxel .../>C）。
  2. 去掉“内部体素”：六个邻居（±x、±y、±z）都存在，并且都和它绑定在同一根骨段的体素。
     只在同一骨段内判断，是为了关节弯曲时不露洞。删除后 skeletonVoxelBindings 的 index 同步重排。

每个文件写入前都会自校验（骨架不变、每个体素恰好绑定一次、保留体素的属性/骨段/顺序不变、
被删体素没有暴露面……），任何一项不通过就保持原样并报告。

用法：
  python optimize_models.py                 处理 models/ 下全部 .xml
  python optimize_models.py a.xml b.xml     只处理指定文件（文件名或路径）
  python optimize_models.py --check         只检查、不修改；有需要处理的文件时退出码为 1
  python optimize_models.py --no-hull       只去垃圾字符，不动体素
"""
import argparse
import hashlib
import os
import re
import sys
import xml.etree.ElementTree as ET
from concurrent.futures import ProcessPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common  # noqa: E402

N6 = ((1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1))
COMMENT = re.compile(r'<!--.*?-->', re.S)
GAP = re.compile(r'>([^<]*)<')
# 按标签处理（有的文件整个写在一行）：删除一个体素 = 删掉它的标签和紧随其后的空白
VTAGFULL = re.compile(r'<voxel\b([^>]*)/>\s*')
BTAGFULL = re.compile(r'<voxel\b[^>]*\bindex="(\d+)"[^>]*/>\s*')
VTAG = re.compile(r'<voxel[\s/]')
WS = ' \t\r\n'


def strip_junk(t):
    """标签之间只保留空白；注释原样保留。"""
    out = []
    last = 0
    for m in COMMENT.finditer(t):
        out.append(GAP.sub(lambda g: '>' + ''.join(c for c in g.group(1) if c in WS) + '<', t[last:m.start()]))
        out.append(m.group(0))
        last = m.end()
    out.append(GAP.sub(lambda g: '>' + ''.join(c for c in g.group(1) if c in WS) + '<', t[last:]))
    r = ''.join(out)
    end = r.rfind('>') + 1            # 根元素结束之后的非空白
    return r[:end] + ''.join(c for c in r[end:] if c in WS)


def parse_model(text):
    """按 rwrsb xml_io.parse_xml 的读法解析（先清掉垃圾字符），返回便于比较的结构。"""
    raw = COMMENT.sub('', text)
    cleaned = re.sub(r'>([^\r\n<>]+)(?=[\r\n])', '>', raw).rstrip()
    cleaned = cleaned[:cleaned.rfind('>') + 1]
    root = ET.fromstring(cleaned)
    vox = [tuple(sorted(v.attrib.items())) for v in root.iterfind('voxels/voxel')]
    other = [(el.tag, tuple(sorted(el.attrib.items()))) for el in root.iter() if el.tag != 'voxel']
    groups = []
    bind = {}
    dup = 0
    for g in root.iterfind('skeletonVoxelBindings/group'):
        ci = g.get('constraintIndex')
        n = 0
        for v in g.iterfind('voxel'):
            i = int(v.get('index'))
            if i in bind:
                dup += 1
            bind[i] = ci
            n += 1
        groups.append((ci, n))
    sticks = len(root.findall('skeleton/stick'))
    return dict(root=root.tag, vox=vox, other=other, groups=groups, bind=bind, dup=dup, sticks=sticks)


def xyz(attrs):
    d = dict(attrs)
    return (int(float(d['x'])), int(float(d['y'])), int(float(d['z'])))


def hollow(k1, o):
    """返回 (新文本, 删除数, 未挖空的原因)。"""
    vend = k1.find('</voxels>')
    if vend < 0 or not o['vox']:
        return k1, 0, '没有体素'
    head, rest = k1[:vend], k1[vend:]
    spans = [(m.start(), m.end()) for m in VTAGFULL.finditer(head)]
    if len(spans) != len(o['vox']) or len(VTAG.findall(head)) != len(spans):
        return k1, 0, '体素标签写法不规范'
    try:
        pts = [xyz(v) for v in o['vox']]
    except (KeyError, ValueError):
        return k1, 0, '体素坐标无法解析'
    at = {}
    for i, p in enumerate(pts):
        at.setdefault(p, []).append(i)
    if any(len(v) > 1 for v in at.values()):
        return k1, 0, '存在重复坐标的体素'
    if o['dup']:
        return k1, 0, '存在被多个骨段同时绑定的体素'
    if o['bind'] and max(o['bind']) >= len(pts):
        return k1, 0, '绑定序号越界'
    nb = len(BTAGFULL.findall(rest))
    if nb != len(o['bind']) or len(VTAG.findall(rest)) != nb:
        return k1, 0, '绑定标签写法不规范'
    grp = o['bind']
    keep = []
    for i, (x, y, z) in enumerate(pts):
        gi = grp.get(i)
        interior = True
        for a, b, c in N6:
            j = at.get((x + a, y + b, z + c))
            if j is None or grp.get(j[0]) != gi:
                interior = False
                break
        keep.append(not interior)
    removed = keep.count(False)
    if not removed:
        return k1, 0, ''
    newidx = {}
    n = 0
    for i, k in enumerate(keep):
        if k:
            newidx[i] = n
            n += 1
    out = []
    prev = 0
    for i, (s, e) in enumerate(spans):
        out.append(head[prev:s])
        if keep[i]:
            out.append(head[s:e])
        prev = e
    out.append(head[prev:])

    def rb(m):
        i = int(m.group(1))
        if i not in newidx:
            return ''
        return re.sub(r'\bindex="\d+"', 'index="%d"' % newidx[i], m.group(0), count=1)

    return ''.join(out) + BTAGFULL.sub(rb, rest), removed, ''


def verify(o, n, new_text, removed):
    """新旧两份解析结果的自校验，返回问题列表（空 = 通过）。"""
    errs = []
    if re.search(r'>[^<]*[^\s<][^<]*<', COMMENT.sub('', new_text)):
        errs.append('仍有垃圾字符')
    if n['other'] != o['other']:
        errs.append('骨架或其他元素被改动')
    if [g[0] for g in n['groups']] != [g[0] for g in o['groups']]:
        errs.append('骨段顺序被改动')
    if n['dup']:
        errs.append('出现重复绑定')
    if removed == 0:
        if n['vox'] != o['vox'] or n['bind'] != o['bind']:
            errs.append('只去垃圾字符却改了数据')
        return errs
    if len(n['vox']) != len(o['vox']) - removed:
        errs.append('体素数量对不上')
    okeys = {xyz(v): i for i, v in enumerate(o['vox'])}
    seq = []
    for i, v in enumerate(n['vox']):
        oi = okeys.get(xyz(v))
        if oi is None or o['vox'][oi] != v:
            errs.append('保留体素的属性被改动')
            break
        if o['bind'].get(oi) != n['bind'].get(i):
            errs.append('保留体素的骨段被改动')
            break
        seq.append(oi)
    if seq != sorted(seq):
        errs.append('体素顺序被改动')
    if n['bind'] and max(n['bind']) >= len(n['vox']):
        errs.append('绑定序号越界')
    kept = set(xyz(v) for v in n['vox'])
    for p, i in okeys.items():
        if p in kept:
            continue
        gi = o['bind'].get(i)
        for a, b, c in N6:
            j = okeys.get((p[0] + a, p[1] + b, p[2] + c))
            if j is None or o['bind'].get(j) != gi:
                errs.append('删掉了有暴露面的体素')
                break
        if errs:
            break
    if [g for g in n['groups'] if g[1] == 0] != [g for g in o['groups'] if g[1] == 0]:
        errs.append('有骨段被删空')
    return errs


def process(path, write, do_hull):
    res = dict(path=path, status='', note='', removed=0, junk=False)
    try:
        raw = open(path, 'rb').read()
        bom = raw.startswith(b'\xef\xbb\xbf')
        t = raw[3:].decode('utf-8') if bom else raw.decode('utf-8')
    except UnicodeDecodeError:
        res.update(status='skip', note='不是 UTF-8 文本')
        return res
    try:
        o = parse_model(t)
    except ET.ParseError as e:
        res.update(status='skip', note='无法解析：%s' % str(e)[:60])
        return res
    if o['root'] != 'model':
        res.update(status='skip', note='不是模型文件（根元素 <%s>）' % o['root'])
        return res
    res['voxels_before'] = len(o['vox'])
    k1 = strip_junk(t)
    res['junk'] = (k1 != t)
    new, removed, why = (hollow(k1, o) if do_hull else (k1, 0, ''))
    res['removed'] = removed
    res['note'] = why
    if new == t:
        res['status'] = 'clean'
        return res
    try:
        n = parse_model(new)
    except ET.ParseError as e:
        res.update(status='fail', note='处理后无法解析：%s' % str(e)[:60])
        return res
    errs = verify(o, n, new, removed)
    if errs:
        res.update(status='fail', note='自校验未通过：' + '、'.join(errs))
        return res
    data = (b'\xef\xbb\xbf' if bom else b'') + new.encode('utf-8')
    res.update(status='todo', voxels_after=len(n['vox']), bytes_before=len(raw), bytes_after=len(data),
               sha=hashlib.sha256(data).hexdigest())
    if write:
        with open(path, 'wb') as f:
            f.write(data)
        res['status'] = 'done'
    return res


def _run(a):
    try:
        return process(*a)
    except Exception as e:      # 任何意外都不写文件
        return dict(path=a[0], status='fail', note='%s: %s' % (type(e).__name__, str(e)[:80]), removed=0, junk=False)


def collect(args_files, models_dir):
    if not args_files:
        return sorted(os.path.join(models_dir, f) for f in os.listdir(models_dir) if f.lower().endswith('.xml'))
    out = []
    for a in args_files:
        p = a if os.path.isfile(a) else os.path.join(models_dir, a)
        if not os.path.isfile(p):
            sys.exit('找不到文件：%s' % a)
        out.append(os.path.abspath(p))
    return out


def run(files, write, do_hull=True, jobs=None):
    """供 check_assets.py 调用：返回逐文件结果。"""
    with ProcessPoolExecutor(jobs) as ex:
        return list(ex.map(_run, [(f, write, do_hull) for f in files], chunksize=8))


def main(argv=None):
    common.setup_stdout()
    common.start_log('models')
    ap = argparse.ArgumentParser(description='体素模型精简：去垃圾字符、去同骨段内部体素。')
    ap.add_argument('files', nargs='*', help='只处理这些模型（文件名或路径）；不给则处理 models/ 下全部 .xml')
    ap.add_argument('--check', action='store_true', help='只检查不修改；有需要处理的文件时退出码为 1')
    ap.add_argument('--no-hull', action='store_true', help='只去垃圾字符，不去内部体素')
    ap.add_argument('-j', '--jobs', type=int, default=None, help='并行进程数，默认按 CPU 核数')
    a = ap.parse_args(argv)
    mod = common.require_mod()
    files = collect(a.files, os.path.join(mod, 'models'))
    results = run(files, write=not a.check, do_hull=not a.no_hull, jobs=a.jobs)

    changed = [r for r in results if r['status'] in ('todo', 'done')]
    failed = [r for r in results if r['status'] == 'fail']
    skipped = [r for r in results if r['status'] == 'skip']
    notes = [r for r in results if r['status'] in ('clean', 'todo', 'done') and r.get('note')]
    verb = '需要处理' if a.check else '已处理'
    print('模型：共检查 %d 个文件，%s %d 个（去垃圾字符 %d 个，去内部体素 %d 个文件 / %d 个体素）。' % (
        len(results), verb, len(changed), sum(1 for r in changed if r['junk']),
        sum(1 for r in changed if r['removed']), sum(r['removed'] for r in changed)))
    if changed:
        b0 = sum(r['bytes_before'] for r in changed)
        b1 = sum(r['bytes_after'] for r in changed)
        print('  这些文件合计 %.1f MiB → %.1f MiB。' % (b0 / 2 ** 20, b1 / 2 ** 20))
        for r in sorted(changed, key=lambda r: -r['removed'])[:15]:
            print('  %-46s 体素 %7d → %-7d%s' % (common.rel(r['path']), r['voxels_before'], r['voxels_after'], '  去垃圾字符' if r['junk'] else ''))
        if len(changed) > 15:
            print('  ……其余 %d 个略。' % (len(changed) - 15))
    for r in notes:
        print('  [未挖空] %s：%s' % (common.rel(r['path']), r['note']))
    for r in skipped:
        print('  [跳过] %s：%s' % (common.rel(r['path']), r['note']))
    for r in failed:
        print('  [失败，未修改] %s：%s' % (common.rel(r['path']), r['note']))
    if failed:
        return 2
    if a.check and changed:
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
