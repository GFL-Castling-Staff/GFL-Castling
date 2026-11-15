# -*- coding: utf-8 -*-
"""音效规范化：packages/GFL_Castling/sounds/*.wav

游戏按固定布局读普通音效：固定读 44 字节文件头，把整段数据原样交给 OpenAL，
只区分单/双声道和 8/16 位，不做降采样或解压；音效加载时预载并常驻内存。
所以：采样率直接决定内存占用；文件头不是标准 44 字节布局的（32 位浮点、24 位、
带额外 chunk 等）会被当成 16 位数据误读。

本脚本把不符合规范的文件转成：
  RIFF/WAVE、PCM、16 位、fmt 16 字节、data 紧随其后（数据从偏移 44 开始）、
  采样率不高于上限（默认 32000 Hz）。声道数、时长、文件名不变。

转换用本目录自带的 SoX（bin/sox/sox.exe，SoX 14.4.2），不需要另外安装任何东西。
没有自带的 SoX 时会退回去找 ffmpeg；也可以用 --sox / --ffmpeg 指定路径。

用法：
  python optimize_sounds.py                 处理 sounds/ 下全部 .wav
  python optimize_sounds.py a.wav b.wav     只处理指定文件
  python optimize_sounds.py --check         只检查不修改；有需要处理的文件时退出码为 1
  python optimize_sounds.py --rate 44100    改用别的采样率上限
"""
import argparse
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common  # noqa: E402

DEFAULT_RATE = 32000


def read_header(path):
    """按游戏的读法看前 44 字节。返回 dict；ok=False 时 why 说明哪里不合规。"""
    with open(path, 'rb') as f:
        h = f.read(44)
    size = os.path.getsize(path)
    info = dict(ok=False, why='', rate=0, ch=0, bits=0, data=0, size=size)
    if len(h) < 44 or h[:4] != b'RIFF' or h[8:12] != b'WAVE':
        info['why'] = '不是 RIFF/WAVE 文件'
        return info
    tag, ch, rate = struct.unpack('<HHI', h[20:28])
    bits = struct.unpack('<H', h[34:36])[0]
    info.update(rate=rate, ch=ch, bits=bits, data=struct.unpack('<I', h[40:44])[0])
    if h[12:16] != b'fmt ':
        info['why'] = 'fmt 块不在标准位置'
    elif struct.unpack('<I', h[16:20])[0] != 16:
        info['why'] = 'fmt 块不是 16 字节（扩展格式）'
    elif tag != 1:
        info['why'] = '不是 PCM（格式标签 %d，例如 32 位浮点）' % tag
    elif h[36:40] != b'data':
        info['why'] = 'data 块不在偏移 36（前面有额外的块）'
    elif bits not in (8, 16):
        info['why'] = '位深 %d，游戏只认 8/16 位' % bits
    elif ch not in (1, 2):
        info['why'] = '声道数 %d，游戏只认 1/2 声道' % ch
    elif info['data'] > size - 44:
        info['why'] = '文件头里的数据长度超过文件实际大小'
    else:
        info['ok'] = True
    return info


def needs_work(info, cap):
    if not info['ok']:
        return info['why']
    if info['rate'] > cap:
        return '采样率 %d Hz 高于上限 %d Hz' % (info['rate'], cap)
    return ''


def probe_rate(path, ffmpeg):
    """用 ffmpeg 读出音频流的真实采样率；读不出返回 0。"""
    r = subprocess.run([ffmpeg, '-hide_banner', '-i', path], capture_output=True)
    m = re.search(r'Audio:.*?(\d+) Hz', r.stderr.decode('utf-8', 'replace'))
    return int(m.group(1)) if m else 0


def run_sox(sox, path, cap, tmp):
    """用 SoX 转换到 tmp。SoX 14.4.2 用 ANSI 接口打开文件，中文等文件名不稳妥，
    所以先复制成纯 ASCII 的临时文件名再处理。返回 (是否成功, 错误信息)。"""
    work = tempfile.mkdtemp(prefix='castling_sox_')
    try:
        a_in = os.path.join(work, 'in.wav')
        a_out = os.path.join(work, 'out.wav')
        shutil.copyfile(path, a_in)
        # 文件头不合规时头里的采样率不可信，以 SoX 解码出的真实采样率为准
        p = subprocess.run([sox, '--i', '-r', a_in], capture_output=True)
        try:
            real = int(p.stdout.decode('ascii', 'replace').strip())
        except ValueError:
            return False, '读不出采样率：' + p.stderr.decode('utf-8', 'replace').strip()[-120:]
        # -D：不加抖动噪声，静音段保持数字静音；只降不升：高于上限才重采样（rate -v 为最高质量）
        cmd = [sox, '-D', a_in, '-b', '16', '-e', 'signed-integer', a_out]
        if real > cap:
            cmd += ['rate', '-v', str(cap)]
        r = subprocess.run(cmd, capture_output=True)
        if r.returncode != 0 or not os.path.exists(a_out) or os.path.getsize(a_out) <= 44:
            return False, r.stderr.decode('utf-8', 'replace').strip()[-160:]
        shutil.copyfile(a_out, tmp)
        return True, ''
    finally:
        shutil.rmtree(work, ignore_errors=True)


def run_ffmpeg(ffmpeg, path, cap, tmp):
    """备用：用 ffmpeg 转换到 tmp。返回 (是否成功, 错误信息)。"""
    real = probe_rate(path, ffmpeg)
    base = [ffmpeg, '-v', 'error', '-y', '-i', path, '-map_metadata', '-1', '-fflags', '+bitexact',
            '-flags:a', '+bitexact', '-c:a', 'pcm_s16le']
    if real > cap or real == 0:
        r = subprocess.run(base + ['-af', 'aresample=%d:resampler=soxr' % cap, tmp], capture_output=True)
        if r.returncode != 0 or os.path.getsize(tmp) <= 44:
            r = subprocess.run(base + ['-ar', str(cap), tmp], capture_output=True)
    else:
        r = subprocess.run(base + [tmp], capture_output=True)
    if r.returncode != 0 or os.path.getsize(tmp) <= 44:
        return False, r.stderr.decode('utf-8', 'replace').strip()[-160:]
    return True, ''


def find_engine(sox=None, ffmpeg=None):
    """优先用 SoX（本目录 bin/sox 里自带），没有再找 ffmpeg。返回 (名称, 路径)。"""
    if ffmpeg and not sox:
        return 'ffmpeg', common.find_tool('ffmpeg', ffmpeg, None)
    p = common.find_tool('sox', sox, 'SOX', bundled=os.path.join('sox', 'sox.exe'), required=False)
    if p:
        return 'sox', p
    p = common.find_tool('ffmpeg', None, 'FFMPEG', required=False)
    if p:
        return 'ffmpeg', p
    sys.exit('找不到 SoX（应在 tools/asset_optimize/bin/sox/sox.exe），也找不到 ffmpeg。\n'
             '请确认 bin 目录完整，或用 --sox / --ffmpeg 指定路径。')


def convert(path, cap, engine):
    """转换单个文件：写到临时文件，核对无误后替换原文件。返回 (是否成功, 说明)。"""
    before = read_header(path)
    d = os.path.dirname(path)
    fd, tmp = tempfile.mkstemp(suffix='.wav', prefix='.opt_', dir=d)
    os.close(fd)
    try:
        kind, exe = engine
        ok, err = (run_sox if kind == 'sox' else run_ffmpeg)(exe, path, cap, tmp)
        if not ok:
            return False, '%s 转换失败：%s' % (kind, err)
        after = read_header(tmp)
        if not after['ok']:
            return False, '转换结果仍不合规：' + after['why']
        if after['rate'] > cap:
            return False, '转换后采样率仍高于上限'
        if before['ok']:
            if after['ch'] != before['ch']:
                return False, '声道数被改变'
            dur0 = before['data'] / float(before['rate'] * before['ch'] * (before['bits'] // 8))
            dur1 = after['data'] / float(after['rate'] * after['ch'] * 2)
            if abs(dur0 - dur1) > 0.02:
                return False, '时长变化超过 20 毫秒（%.3f → %.3f 秒）' % (dur0, dur1)
        os.replace(tmp, path)
        tmp = None
        return True, '%d Hz %d 位 %d 声道 → %d Hz 16 位 %d 声道' % (before['rate'], before['bits'], before['ch'], after['rate'], after['ch'])
    finally:
        if tmp and os.path.exists(tmp):
            os.remove(tmp)


def collect(args_files, sounds_dir):
    if not args_files:
        return sorted(os.path.join(sounds_dir, f) for f in os.listdir(sounds_dir) if f.lower().endswith('.wav'))
    out = []
    for a in args_files:
        p = a if os.path.isfile(a) else os.path.join(sounds_dir, a)
        if not os.path.isfile(p):
            sys.exit('找不到文件：%s' % a)
        out.append(os.path.abspath(p))
    return out


def scan(files, cap):
    """返回 [(路径, 文件头信息, 需要处理的原因或空串)]。供 check_assets.py 调用。"""
    out = []
    for f in files:
        info = read_header(f)
        out.append((f, info, needs_work(info, cap)))
    return out


def main(argv=None):
    common.setup_stdout()
    common.start_log('sounds')
    ap = argparse.ArgumentParser(description='音效规范化：采样率封顶、统一为 44 字节头的 16 位 PCM。')
    ap.add_argument('files', nargs='*', help='只处理这些 wav；不给则处理 sounds/ 下全部')
    ap.add_argument('--check', action='store_true', help='只检查不修改；有需要处理的文件时退出码为 1')
    ap.add_argument('--rate', type=int, default=DEFAULT_RATE, help='采样率上限，默认 %d' % DEFAULT_RATE)
    ap.add_argument('--sox', help='sox.exe 的路径（默认用本目录 bin/sox 里自带的）')
    ap.add_argument('--ffmpeg', help='改用 ffmpeg，并指定它的路径')
    ap.add_argument('-j', '--jobs', type=int, default=8, help='并行数，默认 8')
    a = ap.parse_args(argv)
    mod = common.require_mod()
    files = collect(a.files, os.path.join(mod, 'sounds'))
    items = scan(files, a.rate)
    todo = [(f, info, why) for f, info, why in items if why]
    payload = sum(min(info['data'], info['size']) for f, info, why in items)
    print('音效：共检查 %d 个文件（数据合计 %.0f MB），%s %d 个。' % (
        len(items), payload / 2 ** 20, '需要处理' if a.check else '待处理', len(todo)))
    if a.check:
        for f, info, why in todo[:40]:
            print('  %s：%s' % (common.rel(f), why))
        if len(todo) > 40:
            print('  ……其余 %d 个略。' % (len(todo) - 40))
        return 1 if todo else 0
    if not todo:
        return 0
    engine = find_engine(a.sox, a.ffmpeg)
    print('  使用 %s：%s' % engine)
    failed = []
    done = 0

    def work(item):
        return item[0], convert(item[0], a.rate, engine)

    with ThreadPoolExecutor(a.jobs) as ex:
        for f, (ok, msg) in ex.map(work, todo):
            if ok:
                done += 1
                if len(todo) <= 40:
                    print('  已转换 %s：%s' % (common.rel(f), msg))
            else:
                failed.append((f, msg))
    after = sum(min(i['data'], i['size']) for i in (read_header(f) for f in files))
    print('  已转换 %d 个；数据合计 %.0f MB → %.0f MB。' % (done, payload / 2 ** 20, after / 2 ** 20))
    for f, msg in failed:
        print('  [失败，未修改] %s：%s' % (common.rel(f), msg))
    return 2 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
