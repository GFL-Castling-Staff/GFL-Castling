# 随工具附带的第三方程序

这里的程序不是本项目编写的，只是为了让工具“拿到就能用”而原样附带。脚本会优先使用这里的版本。

| 程序 | 版本 | 用途 | 许可证 | 来源 |
|---|---|---|---|---|
| `sox/sox.exe` 及同目录的 DLL | SoX 14.4.2（win32） | 音效重采样、统一成 16 位 PCM | GPL v2（见 `sox/LICENSE.GPL.txt`）；附带的库为 LGPL 等各自的许可 | <https://sourceforge.net/projects/sox/files/sox/14.4.2/>（`sox-14.4.2-win32.zip`，SHA1 `825b218c275687a38e96bf838dcfdd2e9bd55a25`） |
| `texconv.exe` | DirectXTex May 2026 | 贴图转 DXT 压缩的 DDS | MIT | <https://github.com/microsoft/DirectXTex/releases/tag/may2026>（SHA256 `dcfdec10244e02cf5037fba089c55fb7e1326b1c8181742d77d15fa5cb5eef06`） |

说明：

- SoX 的文件原样取自官方发布包，没有修改；包里与音频处理无关的 `wget.exe`、PDF 手册没有放进来。
  SoX 的源代码可以在上面的项目页面获取。
- 想换成自己机器上的版本：`--sox <路径>` / `--texconv <路径>`，或设置环境变量 `SOX` / `TEXCONV`。
- 不想用 SoX 时，音效脚本也支持 `--ffmpeg <路径>`。
