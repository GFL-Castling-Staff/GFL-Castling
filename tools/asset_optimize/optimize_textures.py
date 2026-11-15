# -*- coding: utf-8 -*-
"""贴图压缩：把符合条件的贴图从 PNG/JPG/TGA 转成 DXT 压缩的 DDS，并把引用改成 .dds。

为什么：贴图在 32 位进程里会多留一份系统内存副本；32 位贴图每像素 4 字节，
DXT1/DXT5 每像素 0.5/1 字节。载具贴图在载具出现时才加载、加载后常驻。

只转同时满足下面全部条件的贴图（任何一条不满足就保持原样）：
  - 不在 maps/、fonts/ 目录下（地形高度图和混合图会被游戏逐像素读取；字体压缩会糊）；
  - 所有引用都是这两种之一：.particle/.material 里的 texture 语句，
    或 texture_filename="..." 属性（载具、武器、投射物的模型贴图）；
    界面图标（hud_icon 等 filename="..." 引用）不转，压缩后明显发糊；
  - 长宽都是 2 的幂，最长边大于 128，不是灰度图，文件名不含 normal/bump；
  - 文件名在 mod 内唯一，且不与原版 vanilla 的贴图同名、不被原版文件引用
    （否则改名会让“覆盖原版贴图”失效）。

不透明的转 DXT1，带透明通道的转 DXT5，生成完整 mipmap 链。

需要 texconv（微软 DirectXTex 的命令行工具）：放在 PATH 里，或用 --texconv 指定，
或设置环境变量 TEXCONV。下载：https://github.com/microsoft/DirectXTex/releases
需要能找到原版 vanilla 包目录：用 --vanilla 指定，或设置环境变量 RWR_VANILLA；
常见的 Steam 安装路径会自动查找。

用法：
  python optimize_textures.py                 转换全部符合条件的贴图
  python optimize_textures.py a.png b.jpg     只在这些文件里挑符合条件的转
  python optimize_textures.py --check         只检查不修改；有可转换的贴图时退出码为 1
  python optimize_textures.py --explain a.png 说明某张贴图为什么能转或不能转
"""
import argparse
import collections
import os
import re
import struct
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common  # noqa: E402

SKIP_TOP_DIRS = ('maps', 'fonts')
# 扫描引用时不读的目录（体素模型和音效里不会出现贴图文件名，而且很大）
NO_SCAN_DIRS = ('models', 'sounds')
BINARY_EXT = common.IMAGE_EXT + ('.dds', '.wav', '.ogg', '.mesh', '.skeleton', '.dll', '.exe', '.ico', '.psd', '.zip',
                                  '.7z', '.rar', '.ttf', '.otf', '.pdf', '.xlsx', '.pptx', '.vox', '.backup')
NAME_RE = re.compile(r'(?<![\w\-\.\(\)])([\w\-\.\(\)]+\.(?:png|jpe?g|tga))(?![\w\-])', re.I)
ATTR_TAIL = re.compile(r'([\w:]+)\s*=\s*$')
DIRECTIVE = re.compile(r'[ \t]*(\w+)[ \t]+$')


def classify(t, m, ext):
    """判断一次文件名出现属于哪种引用方式；认不出返回 None。只看出现位置附近，耗时与文件大小成线性。"""
    s, e = m.start(1), m.end(1)
    # 属性式：attr="路径/name.png"
    if e < len(t) and t[e] == '"':
        q = t.rfind('"', max(0, s - 260), s)
        if q >= 0 and '\n' not in t[q:s]:
            a = ATTR_TAIL.search(t[max(0, q - 80):q])
            if a:
                return (ext, a.group(1))
    # 脚本式：行首的 指令 name.png（.material / .particle）
    if ext in ('.material', '.particle'):
        ls = t.rfind('\n', 0, s) + 1
        d = DIRECTIVE.fullmatch(t[ls:s])
        if d:
            return (ext, d.group(1).lower())
    return None


def image_info(path):
    """返回 (宽, 高, 模式)；模式为 RGB / RGBA / L / LA / P。读不出返回 None。"""
    try:
        with open(path, 'rb') as f:
            h = f.read(256 * 1024)
    except OSError:
        return None
    e = path.lower()
    try:
        if h[:8] == b'\x89PNG\r\n\x1a\n':
            w, hh = struct.unpack('>II', h[16:24])
            mode = {0: 'L', 2: 'RGB', 3: 'P', 4: 'LA', 6: 'RGBA'}.get(h[25], 'RGBA')
            if mode == 'RGB' and b'tRNS' in h[:h.find(b'IDAT')] if b'IDAT' in h else False:
                mode = 'RGBA'
            return w, hh, mode
        if h[:2] == b'\xff\xd8':
            i = 2
            while i < len(h) - 9:
                if h[i] != 0xFF:
                    i += 1
                    continue
                m = h[i + 1]
                if m in (0xC0, 0xC1, 0xC2):
                    hh, w = struct.unpack('>HH', h[i + 5:i + 9])
                    comps = h[i + 9]
                    return w, hh, 'L' if comps == 1 else 'RGB'
                i += 2 + struct.unpack('>H', h[i + 2:i + 4])[0]
            return None
        if e.endswith('.tga'):
            w, hh = struct.unpack('<HH', h[12:16])
            bpp = h[16]
            itype = h[2]
            if itype in (3, 11):
                return w, hh, 'L'
            return w, hh, 'RGBA' if bpp == 32 else 'RGB'
    except (struct.error, IndexError):
        return None
    return None


def walk_text_files(root, skip_dirs=()):
    for d, ds, fs in os.walk(root):
        rel = os.path.relpath(d, root).replace('\\', '/').lower()
        top = rel.split('/')[0]
        if top in skip_dirs or '/.history' in '/' + rel:
            ds[:] = []
            continue
        for f in fs:
            if f.lower().endswith(BINARY_EXT):
                continue
            yield os.path.join(d, f)


def read_text(path):
    try:
        raw = open(path, 'rb').read()
    except OSError:
        return None
    if b'\x00' in raw[:4096]:
        return None
    try:
        return raw.decode('utf-8')
    except UnicodeDecodeError:
        return None


def survey(mod, vanilla):
    """扫描 mod（和原版），返回 {小写文件名: 信息 dict}。"""
    images = collections.defaultdict(list)
    for d, ds, fs in os.walk(mod):
        for f in fs:
            if f.lower().endswith(common.IMAGE_EXT):
                images[f.lower()].append(os.path.join(d, f))
    uses = collections.defaultdict(collections.Counter)      # name -> {(扩展名, 用法): 次数}
    total = collections.Counter()
    for p in walk_text_files(mod, NO_SCAN_DIRS):
        t = read_text(p)
        if t is None:
            continue
        ext = os.path.splitext(p)[1].lower()
        for m in NAME_RE.finditer(t):
            name = m.group(1).lower()
            total[name] += 1
            u = classify(t, m, ext)
            if u:
                uses[name][u] += 1
    van_names = set()
    van_refs = set()
    if vanilla:
        for d, ds, fs in os.walk(vanilla):
            for f in fs:
                if f.lower().endswith(common.IMAGE_EXT):
                    van_names.add(f.lower())
        for p in walk_text_files(vanilla, NO_SCAN_DIRS):
            t = read_text(p)
            if t:
                van_refs.update(m.lower() for m in NAME_RE.findall(t))
    info = {}
    for name, paths in images.items():
        path = paths[0]
        rel = os.path.relpath(path, mod).replace('\\', '/')
        dims = image_info(path)
        u = uses.get(name, {})
        classified = sum(u.values())
        why = ''
        if len(paths) > 1:
            why = 'mod 内有 %d 个同名文件' % len(paths)
        elif rel.split('/')[0].lower() in SKIP_TOP_DIRS:
            why = '在 %s/ 目录下' % rel.split('/')[0]
        elif dims is None:
            why = '读不出图片尺寸'
        elif name in van_names:
            why = '与原版贴图同名（改名会让覆盖失效）'
        elif name in van_refs:
            why = '被原版文件引用'
        elif not u:
            why = '没有找到引用（可能是程序拼出来的文件名，或没被使用）'
        elif total[name] > classified:
            why = '存在无法识别的引用方式（例如脚本里的字符串）'
        elif not all(a == 'texture_filename' or (e in ('.material', '.particle') and a == 'texture') for (e, a) in u):
            bad = sorted(set('%s 里的 %s' % (e, a) for (e, a) in u
                             if not (a == 'texture_filename' or (e in ('.material', '.particle') and a == 'texture'))))
            why = '被当作界面图标等引用（%s）' % '、'.join(bad)
        elif not (common.is_pow2(dims[0]) and common.is_pow2(dims[1])):
            why = '尺寸 %dx%d 不是 2 的幂' % (dims[0], dims[1])
        elif max(dims[0], dims[1]) <= 128:
            why = '尺寸太小（%dx%d），压缩收益小' % (dims[0], dims[1])
        elif dims[2] in ('L', 'LA'):
            why = '灰度图'
        elif 'normal' in name or 'bump' in name:
            why = '法线贴图'
        elif os.path.exists(os.path.splitext(path)[0] + '.dds'):
            why = '同名 .dds 已存在'
        info[name] = dict(path=path, rel=rel, dims=dims, uses=dict(u), why=why,
                          fmt=None if dims is None else ('BC1_UNORM' if dims[2] == 'RGB' else 'BC3_UNORM'))
    return info


def update_refs(mod, names):
    """把文本文件里对 names 的引用改成 .dds，返回改动的文件数。"""
    def sub(m):
        g = m.group(1)
        return os.path.splitext(g)[0] + '.dds' if g.lower() in names else g

    n = 0
    for p in walk_text_files(mod, NO_SCAN_DIRS):
        if not p.lower().endswith(common.TEXT_EXT):
            continue
        try:
            raw = open(p, 'rb').read()
            t = raw.decode('utf-8')
        except (OSError, UnicodeDecodeError):
            continue
        t2 = NAME_RE.sub(sub, t)
        if t2 != t:
            with open(p, 'wb') as f:
                f.write(t2.encode('utf-8'))
            n += 1
    return n


def main(argv=None):
    common.setup_stdout()
    common.start_log('textures')
    ap = argparse.ArgumentParser(description='把符合条件的贴图转成 DXT 压缩的 DDS，并同步改引用。')
    ap.add_argument('files', nargs='*', help='只考虑这些贴图；不给则考虑全部')
    ap.add_argument('--check', action='store_true', help='只检查不修改；有可转换的贴图时退出码为 1')
    ap.add_argument('--explain', metavar='文件名', help='说明某张贴图为什么能转或不能转')
    ap.add_argument('--texconv', help='texconv.exe 的路径')
    ap.add_argument('--vanilla', help='原版 vanilla 包目录（…/RunningWithRifles/media/packages/vanilla）')
    ap.add_argument('--no-vanilla-check', action='store_true', help='找不到原版目录时仍然继续（不推荐）')
    a = ap.parse_args(argv)
    mod = common.require_mod()
    vanilla = common.find_vanilla(a.vanilla)
    if not vanilla and not a.no_vanilla_check:
        sys.exit('找不到原版 vanilla 包目录。请用 --vanilla 指定，或设置环境变量 RWR_VANILLA。\n'
                 '（需要它来判断贴图是否与原版同名或被原版引用；确实没有时可加 --no-vanilla-check，但不推荐。）')
    info = survey(mod, vanilla)
    if a.explain:
        k = os.path.basename(a.explain).lower()
        r = info.get(k)
        if not r:
            print('mod 里没有这张贴图：%s' % a.explain)
            return 0
        print('%s  %sx%s %s' % (r['rel'], r['dims'][0] if r['dims'] else '?', r['dims'][1] if r['dims'] else '?', r['dims'][2] if r['dims'] else ''))
        print('  引用方式：%s' % ('、'.join('%s 里的 %s ×%d' % (e, at, n) for (e, at), n in r['uses'].items()) or '无'))
        print('  结论：%s' % ('可以转换（%s）' % r['fmt'] if not r['why'] else '不转换，因为' + r['why']))
        return 0
    wanted = None
    if a.files:
        wanted = set(os.path.basename(f).lower() for f in a.files)
        for w in wanted:
            if w not in info:
                sys.exit('mod 里没有这张贴图：%s' % w)
    sel = [r for k, r in sorted(info.items()) if not r['why'] and (wanted is None or k in wanted)]
    dds = sum(1 for d, ds, fs in os.walk(mod) for f in fs if f.lower().endswith('.dds'))
    print('贴图：mod 内共 %d 张 PNG/JPG/TGA、%d 张 DDS；%s %d 张。' % (
        len(info), dds, '可转换' if a.check else '待转换', len(sel)))
    if wanted:
        for k in sorted(wanted):
            if info[k]['why']:
                print('  [不转换] %s：%s' % (info[k]['rel'], info[k]['why']))
    if a.check:
        for r in sel[:40]:
            print('  %s  %dx%d → %s' % (r['rel'], r['dims'][0], r['dims'][1], 'DXT1' if r['fmt'] == 'BC1_UNORM' else 'DXT5'))
        if len(sel) > 40:
            print('  ……其余 %d 张略。' % (len(sel) - 40))
        return 1 if sel else 0
    if not sel:
        return 0
    texconv = common.find_tool('texconv', a.texconv, 'TEXCONV',
                               '它应在 tools/asset_optimize/bin/texconv.exe；也可以用 --texconv 指定路径'
                               '（下载：https://github.com/microsoft/DirectXTex/releases）。',
                               bundled='texconv.exe')

    def conv(r):
        src = r['path']
        p = subprocess.run([texconv, '-nologo', '-y', '-dx9', '-m', '0', '-f', r['fmt'], '-ft', 'dds',
                            '-o', os.path.dirname(src), src], capture_output=True)
        out = os.path.splitext(src)[0] + '.dds'
        if p.returncode != 0 or not os.path.exists(out) or os.path.getsize(out) < 128:
            return r, p.stdout.decode('utf-8', 'replace').strip()[-160:]
        return r, ''

    done = []
    failed = []
    with ThreadPoolExecutor(8) as ex:
        for r, err in ex.map(conv, sel):
            (failed if err else done).append((r, err))
    names = set(os.path.basename(r['path']).lower() for r, e in done)
    nfiles = update_refs(mod, names) if names else 0
    for r, e in done:
        os.remove(r['path'])
    print('  已转换 %d 张，修改了 %d 个文件里的引用。' % (len(done), nfiles))
    for r, e in failed:
        print('  [失败，未修改] %s：%s' % (r['rel'], e))
    return 2 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
