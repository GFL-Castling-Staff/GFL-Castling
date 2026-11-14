@echo off
chcp 65001 >nul
rem 把资源优化工具打包成单个 castling_assets.exe（放在本目录）。
rem 需要 Python 3.8+ 和 PyInstaller；没有 PyInstaller 时会先询问是否安装。
setlocal
cd /d "%~dp0"

set "PY=python"
if not "%~1"=="" set "PY=%~1"

"%PY%" -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)" 2>nul
if errorlevel 1 (
    echo [错误] 找不到 Python 3.8 以上版本。可以把 python.exe 的路径作为参数传进来：build_exe.bat C:\path\to\python.exe
    exit /b 1
)

"%PY%" -m PyInstaller --version >nul 2>nul
if errorlevel 1 (
    echo 没有找到 PyInstaller。
    choice /m "现在用 pip 安装它吗"
    if errorlevel 2 exit /b 1
    "%PY%" -m pip install pyinstaller
    if errorlevel 1 (
        echo [错误] PyInstaller 安装失败。
        exit /b 1
    )
)

echo [1/2] 打包……
"%PY%" -m PyInstaller --noconfirm --clean --onefile --console --name castling_assets ^
    --distpath "%~dp0." --workpath "%~dp0build" --specpath "%~dp0build" castling_assets.py
if errorlevel 1 (
    echo [错误] 打包失败。
    exit /b 1
)

echo [2/2] 自检……
"%~dp0castling_assets.exe" --help >nul
if errorlevel 1 (
    echo [错误] 生成的 exe 无法运行。
    exit /b 1
)
echo 完成：%~dp0castling_assets.exe
endlocal
