# Cubase Video Episode Batch Export / Cubase 短剧分集视频批量导出脚本

## English

AutoHotkey v2 helper for episodic video export workflows in Cubase 13 Pro.

This script is intended for projects where:

- each episode is a separate video event on a single video track
- multiple audio tracks are edited inside one long Cubase project
- final delivery requires exporting each video event as an individual episode

Main automation flow:

1. Set locators to the currently selected video event
2. Open `File -> Export -> Video`
3. Click `Replace Audio`
4. Move to the next video event
5. Repeat for the requested episode count

### Requirements

- Windows
- Cubase 13 Pro
- [AutoHotkey v2](https://www.autohotkey.com/)

### Main File

- `CubaseVideoEpisodeBatchExport.ahk`

### Calibration Hotkeys

Because this is GUI automation, you must calibrate UI positions on your own machine.

- `Ctrl + Alt + Shift + 1`: capture the "Append to Video File Name" input box
- `Ctrl + Alt + Shift + 2`: capture the `Replace Audio` button
- `Ctrl + Alt + Shift + 3`: capture the `File` menu
- `Ctrl + Alt + Shift + 4`: capture the `Export` menu
- `Ctrl + Alt + Shift + 5`: capture the `Video` menu

### Runtime Hotkeys

- `Ctrl + Alt + Shift + T`: test one episode
- `Ctrl + Alt + Shift + B`: start batch export
- `Ctrl + Alt + Shift + S`: stop batch export
- `Ctrl + Alt + Shift + H`: show help

### Notes

- This is a GUI automation script, not a Cubase plugin.
- Different display scaling, window layouts, or menu positions require recalibration.
- Test with 1-2 episodes first.
- Machine-specific calibration and logs should not be committed.

## 中文

这是一个用于 `Cubase 13 Pro` 的 `AutoHotkey v2` 图形界面自动化脚本，适合短剧分集视频导出场景。

适用项目结构：

- 一个视频轨里放了多集视频块
- 多条音频轨在同一个长工程里统一编辑
- 最终需要把每个视频块单独导出成交付视频

主要自动化流程：

1. 把 locator 设到当前选中的视频块
2. 打开 `文件 -> 导出 -> 视频`
3. 点击 `Replace Audio`
4. 切到下一个视频块
5. 按设定集数继续循环

### 运行环境

- Windows
- Cubase 13 Pro
- [AutoHotkey v2](https://www.autohotkey.com/)

### 主文件

- `CubaseVideoEpisodeBatchExport.ahk`

### 校准热键

因为这是 GUI 自动化脚本，所以需要在你的电脑上先记录界面位置。

- `Ctrl + Alt + Shift + 1`：记录“添加到视频文件名”输入框
- `Ctrl + Alt + Shift + 2`：记录 `Replace Audio` 按钮
- `Ctrl + Alt + Shift + 3`：记录 `文件` 菜单
- `Ctrl + Alt + Shift + 4`：记录 `导出` 菜单
- `Ctrl + Alt + Shift + 5`：记录 `视频` 菜单

### 运行热键

- `Ctrl + Alt + Shift + T`：单集测试
- `Ctrl + Alt + Shift + B`：开始批量导出
- `Ctrl + Alt + Shift + S`：停止批量导出
- `Ctrl + Alt + Shift + H`：显示帮助

### 注意事项

- 这是 GUI 自动化脚本，不是 Cubase 官方插件。
- 分辨率、缩放、窗口布局变化后需要重新校准。
- 第一次建议只测试 1-2 集。
- 不要把你本机专用的校准文件和日志一起提交到 GitHub。

## Files Not Recommended For Public Upload / 不建议公开上传的文件

- `batch_export_video_calibration.ini`
- `batch_export_debug.log`
- `ahk-v2.exe`

## Legal / Legal Notes

### English

- This repository is an unofficial community automation script and is not affiliated with, endorsed by, or supported by Steinberg.
- `Steinberg` and `Cubase` are trademarks of their respective owner.
- Do not upload Steinberg installers, manuals, screenshots from official documentation, or machine-specific calibration/log files unless you have the right to share them.
- The script itself should generally be safe to publish if it is your own original code and documentation.

### 中文

- 本仓库是非官方的社区自动化脚本，与 Steinberg 无隶属、无官方背书、无官方支持关系。
- `Steinberg` 和 `Cubase` 属于其各自权利人商标。
- 不要上传 Steinberg 安装包、官方手册、官方文档截图，或你本机专用的校准文件和日志，除非你确实有权分享。
- 如果脚本代码和说明文档是你自己的原创内容，通常公开发布本身问题不大。

## License / 许可证

MIT

