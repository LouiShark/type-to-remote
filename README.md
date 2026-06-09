# Type To Remote

作者：GitHub [LouiShark](https://github.com/LouiShark)  
小红书：`Sassy_as_Tommo`

把 Windows 本机上的文本通过“键盘输入”的方式逐字符打进远程窗口。

它不是粘贴，也不是传文件，而是模拟真实按键。所以只要目标环境能接收键盘输入，就可以用在远程 Linux 服务器、虚拟机、堡垒机、远程桌面，或者其他操作系统窗口里。

服务器端不需要安装任何东西。

## 怎么用

1. 在 Windows 本机 OCR 图片，或者准备一段文本。
2. 检查文本内容，把它复制到 Windows 剪贴板。
3. 在目标窗口里，把光标放到你想输入文本的位置。
4. 双击 `Type To Remote.bat`。
5. 选择速度，倒计时内切回目标窗口。
6. 等它打完即可。

输入过程中按住 `Esc` 可以停止。

## 入口

- `Type To Remote.bat`：主菜单。
- `type-normal.bat`：普通速度，25 ms/字符。
- `type-slow.bat`：慢速，60 ms/字符，远程卡顿时用。
- `type-fast.bat`：快速，10 ms/字符。
- `type-from-file.bat`：从本地文本文件输入。

## 常用建议

- 输入前把 Windows 输入法切到英文。
- 如果远程窗口丢字符，用慢速。
- 如果用 `vim`，先执行 `:set paste`，再按 `i` 进入插入模式。
- OCR 结果请先人工检查，工具不会自动修改中英文符号或代码内容。

## 命令行

从剪贴板输入：

```powershell
powershell -NoProfile -STA -ExecutionPolicy Bypass -File .\type-to-remote.ps1 -Clipboard -DelayMs 25 -StartDelaySec 3
```

从文件输入：

```powershell
powershell -NoProfile -STA -ExecutionPolicy Bypass -File .\type-to-remote.ps1 -File C:\path\to\text.txt -DelayMs 25
```

## English

Author: GitHub [LouiShark](https://github.com/LouiShark)  
Xiaohongshu: `Sassy_as_Tommo`

Type local text into a remote window one character at a time.

This is not clipboard paste or file transfer. It simulates keyboard input, so it can work with remote Linux servers, virtual machines, bastion hosts, remote desktops, or windows from other operating systems, as long as the target accepts keyboard input.

No server-side installation is required.

### Quick Use

1. OCR an image or prepare text on Windows.
2. Check the text and copy it to the Windows clipboard.
3. Put the cursor exactly where you want the text to be typed.
4. Double-click `Type To Remote.bat`.
5. Choose a speed and focus the target window before the countdown ends.
6. Wait for typing to finish.

Hold `Esc` during typing to stop.

### Tips

- Switch the Windows input method to English before typing.
- Use slow mode if characters are dropped.
- For `vim`, run `:set paste`, then press `i`.
- OCR output should be checked manually. The tool does not rewrite punctuation or code content.
