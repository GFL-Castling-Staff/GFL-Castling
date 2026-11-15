# -*- coding: utf-8 -*-
"""资源优化脚本的公共部分：定位仓库与 mod 目录、查找外部工具、统一的输出。

只依赖 Python 标准库（3.8 及以上）。
"""
import os
import shutil
import sys

# 打包成 exe 后 __file__ 指向临时解压目录，要以 exe 所在位置为准
if getattr(sys, 'frozen', False):
    HERE = os.path.dirname(os.path.abspath(sys.executable))
else:
    HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, '..', '..'))
LOG_DIR = os.path.join(HERE, 'logs')
# 默认处理本仓库的 mod；设置环境变量 CASTLING_MOD 可以指向别的 GFL_Castling 目录（例如测试用的副本）
MOD = os.path.normpath(os.environ.get('CASTLING_MOD') or os.path.join(REPO, 'packages', 'GFL_Castling'))

IMAGE_EXT = ('.png', '.jpg', '.jpeg', '.tga')
# 会引用贴图文件名的文本资源
TEXT_EXT = ('.xml', '.material', '.particle', '.weapon', '.carry_item', '.vehicle', '.base_vehicle', '.valuable', '.call',
            '.projectile', '.throwable', '.svg', '.cfg', '.models', '.resources', '.item', '.visual_item', '.character',
            '.fontdef', '.program', '.compositor', '.overlay', '.as')


def setup_stdout():
    """Windows 控制台默认编码可能不是 UTF-8，统一一下，避免中文文件名报错。"""
    for s in (sys.stdout, sys.stderr):
        try:
            s.reconfigure(encoding='utf-8', errors='replace')
        except Exception:
            pass


class _Tee(object):
    """同时写到控制台和日志文件。"""

    def __init__(self, stream, logfile):
        self.stream = stream
        self.logfile = logfile

    def write(self, s):
        try:
            self.stream.write(s)
        except Exception:
            pass
        try:
            self.logfile.write(s)
            self.logfile.flush()
        except Exception:
            pass
        return len(s)

    def flush(self):
        for f in (self.stream, self.logfile):
            try:
                f.flush()
            except Exception:
                pass

    def __getattr__(self, name):
        return getattr(self.stream, name)


_log_path = None


def start_log(name):
    """开始把本次运行的全部输出同时写入 logs/<name>-<时间>.log，返回日志路径。重复调用只生效一次。"""
    global _log_path
    if _log_path:
        return _log_path
    import datetime
    import platform
    try:
        os.makedirs(LOG_DIR, exist_ok=True)
        path = os.path.join(LOG_DIR, '%s-%s.log' % (name, datetime.datetime.now().strftime('%Y%m%d-%H%M%S')))
        f = open(path, 'w', encoding='utf-8', newline='\n')
    except OSError as e:
        print('（无法创建日志文件：%s）' % e)
        return None
    sys.stdout = _Tee(sys.stdout, f)
    sys.stderr = _Tee(sys.stderr, f)
    _log_path = path
    f.write('# %s  %s\n# 命令行: %s\n# Python %s  %s\n# mod 目录: %s\n\n' % (
        name, datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'), ' '.join(sys.argv),
        platform.python_version(), platform.platform(), MOD))
    f.flush()
    return path


def require_mod():
    if not os.path.isdir(MOD):
        sys.exit('找不到 mod 目录：%s\n请确认脚本位于仓库的 tools/asset_optimize/ 下。' % MOD)
    return MOD


BIN_DIR = os.path.join(HERE, 'bin')


def find_tool(name, cli_value=None, env=None, hint='', bundled=None, required=True):
    """按 命令行参数 > 环境变量 > 本目录自带的 bin/ > PATH 的顺序找外部工具。
    找不到时：required=True 给出提示并退出，否则返回 None。"""
    cands = []
    if cli_value:
        cands.append(cli_value)
    if env and os.environ.get(env):
        cands.append(os.environ[env])
    for c in cands:
        if os.path.isfile(c):
            return c
        sys.exit('指定的 %s 不存在：%s' % (name, c))
    if bundled:
        p = os.path.join(BIN_DIR, bundled)
        if os.path.isfile(p):
            return p
    p = shutil.which(name)
    if p:
        return p
    if required:
        sys.exit('找不到 %s。%s' % (name, hint))
    return None


def find_vanilla(cli_value=None):
    """定位原版 vanilla 包目录（贴图脚本用它判断“是否与原版同名/被原版引用”）。找不到返回 None。"""
    cands = []
    if cli_value:
        cands.append(cli_value)
    if os.environ.get('RWR_VANILLA'):
        cands.append(os.environ['RWR_VANILLA'])
    cands.append(os.path.join(REPO, '_ori_RunningWithRifles', 'media', 'packages', 'vanilla'))
    for base in (r'C:\Program Files (x86)\Steam', r'D:\Program_Files\Steam', r'D:\Steam', r'E:\Steam', r'C:\Steam'):
        cands.append(os.path.join(base, 'steamapps', 'common', 'RunningWithRifles', 'media', 'packages', 'vanilla'))
    for c in cands:
        if c and os.path.isdir(c):
            return os.path.normpath(c)
    return None


def rel(path):
    """相对 mod 目录的路径，用于输出。"""
    try:
        return os.path.relpath(path, MOD).replace('\\', '/')
    except ValueError:
        return path


def is_pow2(x):
    return x > 0 and (x & (x - 1)) == 0
