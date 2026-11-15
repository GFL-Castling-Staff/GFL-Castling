# -*- coding: utf-8 -*-
"""资源检查：一条命令检查模型、音效、贴图是否符合规范。只读，不修改任何文件。

检查内容
  模型  是否还有垃圾字符或可去掉的内部体素；模型数据本身的问题（重复坐标、重复绑定等）只给警告。
  音效  文件头是否是游戏能正确读取的标准布局；采样率是否超过上限。
  贴图  是否有符合条件却没转成 DDS 的；引用是否指向不存在的文件（例如贴图转了 DDS 但引用没改，
        或引用写了 .dds 但文件不存在）；有没有界面图标被做成了 DDS（只给警告）。

退出码：0 = 全部通过；1 = 有需要处理的问题；加 --strict 时警告也算问题。

用法：
  python check_assets.py
  python check_assets.py --only models sounds
  python check_assets.py --strict
"""
import argparse
import collections
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common  # noqa: E402
import optimize_models  # noqa: E402
import optimize_sounds  # noqa: E402
import optimize_textures  # noqa: E402

ANY_TEX = re.compile(r'(?<![\w\-\.\(\)])([\w\-\.\(\)]+\.(?:png|jpe?g|tga|dds))(?![\w\-])', re.I)
SHOW = 25


def show(items, fmt):
    for it in items[:SHOW]:
        print('    ' + fmt(it))
    if len(items) > SHOW:
        print('    ……其余 %d 项略，完整清单见日志文件。' % (len(items) - SHOW))


def check_models(mod, jobs):
    d = os.path.join(mod, 'models')
    files = sorted(os.path.join(d, f) for f in os.listdir(d) if f.lower().endswith('.xml'))
    res = optimize_models.run(files, write=False, do_hull=True, jobs=jobs)
    todo = [r for r in res if r['status'] == 'todo']
    fail = [r for r in res if r['status'] == 'fail']
    warn = [r for r in res if r['status'] in ('clean', 'todo') and r.get('note') and r['note'] != '没有体素']
    print('[模型] 检查 %d 个文件：需要精简 %d 个，无法处理 %d 个，数据有瑕疵 %d 个。' % (len(res), len(todo), len(fail), len(warn)))
    if todo:
        print('  需要精简（运行 optimize_models 即可）：')
        show(sorted(todo, key=lambda r: -r['removed']),
             lambda r: '%s：%s%s' % (common.rel(r['path']), '有垃圾字符；' if r['junk'] else '', '可去掉 %d 个内部体素' % r['removed'] if r['removed'] else ''))
    if fail:
        print('  无法处理：')
        show(fail, lambda r: '%s：%s' % (common.rel(r['path']), r['note']))
    if warn:
        print('  数据有瑕疵（不影响游戏运行，建议在建模工具里修正后重新导出）：')
        show(warn, lambda r: '%s：%s' % (common.rel(r['path']), r['note']))
    return len(todo) + len(fail), len(warn)


def check_sounds(mod, cap):
    d = os.path.join(mod, 'sounds')
    files = sorted(os.path.join(d, f) for f in os.listdir(d) if f.lower().endswith('.wav'))
    items = optimize_sounds.scan(files, cap)
    bad_header = [(f, why) for f, info, why in items if why and not info['ok']]
    too_high = [(f, why) for f, info, why in items if why and info['ok']]
    payload = sum(min(i['data'], i['size']) for f, i, w in items)
    print('[音效] 检查 %d 个文件（数据合计 %.0f MB）：文件头不合规 %d 个，采样率超过 %d Hz 的 %d 个。' % (
        len(items), payload / 2 ** 20, len(bad_header), cap, len(too_high)))
    if bad_header:
        print('  文件头不合规（游戏会把它们当成 16 位数据误读，可能是杂音；运行 optimize_sounds 即可）：')
        show(bad_header, lambda x: '%s：%s' % (common.rel(x[0]), x[1]))
    if too_high:
        print('  采样率过高（运行 optimize_sounds 即可）：')
        show(too_high, lambda x: '%s：%s' % (common.rel(x[0]), x[1]))
    return len(bad_header) + len(too_high), 0


def check_textures(mod, vanilla):
    info = optimize_textures.survey(mod, vanilla)
    todo = [r for k, r in sorted(info.items()) if not r['why']]
    # 现有的贴图文件（mod + 原版），用来查悬空引用
    have = collections.defaultdict(set)      # 不带扩展名的小写文件名 -> {扩展名}
    for root in (mod, vanilla):
        if not root:
            continue
        for d, ds, fs in os.walk(root):
            for f in fs:
                stem, ext = os.path.splitext(f.lower())
                if ext in common.IMAGE_EXT + ('.dds',):
                    have[stem].add(ext)
    mod_dds = set()
    for d, ds, fs in os.walk(mod):
        for f in fs:
            if f.lower().endswith('.dds'):
                mod_dds.add(f.lower())
    stale = []          # 引用的文件不存在，但同名的另一种格式存在
    ui_dds = []         # 界面图标引用了 DDS
    seen = set()
    for p in optimize_textures.walk_text_files(mod, optimize_textures.NO_SCAN_DIRS):
        if not p.lower().endswith(common.TEXT_EXT):
            continue
        t = optimize_textures.read_text(p)
        if t is None:
            continue
        ext = os.path.splitext(p)[1].lower()
        for m in ANY_TEX.finditer(t):
            name = m.group(1).lower()
            stem, e = os.path.splitext(name)
            if e not in have.get(stem, ()):
                others = sorted(have.get(stem, ()))
                if others and (p, name) not in seen:
                    seen.add((p, name))
                    stale.append((p, name, others))
            elif e == '.dds' and name in mod_dds:
                u = optimize_textures.classify(t, m, ext)
                if u and not (u[1] == 'texture_filename' or (u[0] in ('.material', '.particle') and u[1] == 'texture')):
                    if (p, name) not in seen:
                        seen.add((p, name))
                        ui_dds.append((p, name, u[1]))
    print('[贴图] mod 内 %d 张 PNG/JPG/TGA、%d 张 DDS：可转换未转换 %d 张，引用与文件不符 %d 处，界面图标用了 DDS %d 处。' % (
        len(info), len(mod_dds), len(todo), len(stale), len(ui_dds)))
    if not vanilla:
        print('  注意：没找到原版 vanilla 目录，“是否与原版同名”这一项没有检查（可用 --vanilla 指定）。')
    if todo:
        print('  可转换未转换（运行 optimize_textures 即可）：')
        show(todo, lambda r: '%s  %dx%d' % (r['rel'], r['dims'][0], r['dims'][1]))
    if stale:
        print('  引用与文件不符（引用里写的扩展名对应的文件不存在，游戏会找不到贴图）：')
        show(stale, lambda x: '%s 引用了 %s，但实际存在的是 %s' % (common.rel(x[0]), x[1], '、'.join(os.path.splitext(x[1])[0] + o for o in x[2])))
    if ui_dds:
        print('  界面图标用了 DDS（DXT 压缩会让图标发糊，建议改回 PNG）：')
        show(ui_dds, lambda x: '%s 的 %s 引用了 %s' % (common.rel(x[0]), x[2], x[1]))
    return len(todo) + len(stale), len(ui_dds)


def main(argv=None):
    common.setup_stdout()
    common.start_log('check')
    ap = argparse.ArgumentParser(description='检查模型、音效、贴图是否符合资源规范（只读）。')
    ap.add_argument('--only', nargs='+', choices=('models', 'sounds', 'textures'), help='只检查其中几类')
    ap.add_argument('--strict', action='store_true', help='警告也算问题')
    ap.add_argument('--rate', type=int, default=optimize_sounds.DEFAULT_RATE, help='音效采样率上限')
    ap.add_argument('--vanilla', help='原版 vanilla 包目录')
    ap.add_argument('-j', '--jobs', type=int, default=None)
    a = ap.parse_args(argv)
    mod = common.require_mod()
    which = a.only or ('models', 'sounds', 'textures')
    errors = warnings = 0
    if 'models' in which:
        e, w = check_models(mod, a.jobs)
        errors += e
        warnings += w
    if 'sounds' in which:
        e, w = check_sounds(mod, a.rate)
        errors += e
        warnings += w
    if 'textures' in which:
        e, w = check_textures(mod, common.find_vanilla(a.vanilla))
        errors += e
        warnings += w
    print('')
    if errors:
        print('结果：有 %d 项需要处理%s。' % (errors, '，另有 %d 项警告' % warnings if warnings else ''))
    elif warnings:
        print('结果：通过，有 %d 项警告。' % warnings)
    else:
        print('结果：全部通过。')
    return 1 if (errors or (a.strict and warnings)) else 0


if __name__ == '__main__':
    import multiprocessing
    multiprocessing.freeze_support()
    _rc = main()
    if common.start_log('check'):
        print('日志：%s' % common.start_log('check'))
    sys.exit(_rc)
