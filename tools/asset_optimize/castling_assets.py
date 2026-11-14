# -*- coding: utf-8 -*-
"""资源优化工具的统一入口（打包成 exe 的就是这个文件）。

  castling_assets check [参数]      检查全部资源（只读）
  castling_assets models [参数]     模型精简
  castling_assets sounds [参数]     音效规范化
  castling_assets textures [参数]   贴图压缩
  castling_assets all               依次执行 模型 → 音效 → 贴图 → 检查

不带任何参数运行（例如直接双击 exe）会进入菜单。
每次运行的完整输出都会保存到 logs/ 目录。各子命令的参数用 “<子命令> -h” 查看。
"""
import multiprocessing
import os
import sys
import traceback

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common  # noqa: E402
import check_assets  # noqa: E402
import optimize_models  # noqa: E402
import optimize_sounds  # noqa: E402
import optimize_textures  # noqa: E402

COMMANDS = {
    'check': ('检查全部资源（只读，不修改任何文件）', check_assets.main),
    'models': ('模型精简：去垃圾字符、去内部体素', optimize_models.main),
    'sounds': ('音效规范化：采样率封顶 32000 Hz、标准 16 位 PCM', optimize_sounds.main),
    'textures': ('贴图压缩：载具/粒子贴图转 DXT', optimize_textures.main),
}
ORDER = ('check', 'models', 'sounds', 'textures')


def call(name, argv):
    """运行一个子命令，返回退出码；子命令里的 sys.exit 也转成返回值。"""
    try:
        return COMMANDS[name][1](argv) or 0
    except SystemExit as e:
        if isinstance(e.code, int):
            return e.code
        if e.code:
            print(e.code)
            return 2
        return 0


def run_all():
    worst = 0
    for name in ('models', 'sounds', 'textures'):
        print('\n===== %s =====' % COMMANDS[name][0])
        rc = call(name, [])
        worst = max(worst, rc)
        if rc >= 2:
            print('这一步有失败项，后面的步骤不再继续。')
            return rc
    print('\n===== 复查 =====')
    return max(worst, call('check', []))


def menu():
    print('GFL_Castling 资源优化工具')
    print('mod 目录：%s\n' % common.MOD)
    for i, name in enumerate(ORDER, 1):
        print('  %d. %s' % (i, COMMANDS[name][0]))
    print('  5. 全部执行（模型 → 音效 → 贴图 → 检查）')
    print('  0. 退出\n')
    try:
        c = input('请输入编号后回车：').strip()
    except EOFError:
        return 0
    if c == '0' or not c:
        return 0
    if c == '5':
        return run_all()
    if c in ('1', '2', '3', '4'):
        return call(ORDER[int(c) - 1], [])
    print('没有这个选项：%s' % c)
    return 2


def main():
    common.setup_stdout()
    argv = sys.argv[1:]
    interactive = not argv
    log = common.start_log('menu' if interactive else argv[0] if argv[0] in COMMANDS or argv[0] == 'all' else 'run')
    try:
        if interactive:
            rc = menu()
        elif argv[0] in ('-h', '--help', 'help'):
            print(__doc__)
            rc = 0
        elif argv[0] == 'all':
            rc = run_all()
        elif argv[0] in COMMANDS:
            rc = call(argv[0], argv[1:])
        else:
            print('未知的子命令：%s\n' % argv[0])
            print(__doc__)
            rc = 2
    except Exception:
        print('\n程序出错（没有处理完的文件保持原样）：')
        traceback.print_exc()
        rc = 3
    if log:
        print('\n本次运行的日志：%s' % log)
    if interactive:
        try:
            input('\n按回车键退出……')
        except EOFError:
            pass
    return rc


if __name__ == '__main__':
    multiprocessing.freeze_support()
    sys.exit(main())
