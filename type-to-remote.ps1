param(
    [string]$File,
    [int]$DelayMs = 25,
    [int]$StartDelaySec = 3,
    [switch]$Clipboard,
    [switch]$DryRun,
    [switch]$NoNormalizeNewlines
)

$ErrorActionPreference = "Stop"

if (-not $Clipboard -and [string]::IsNullOrWhiteSpace($File)) {
    $Clipboard = $true
}

if ($Clipboard) {
    Add-Type -AssemblyName System.Windows.Forms
    $text = [System.Windows.Forms.Clipboard]::GetText()
} else {
    $resolved = Resolve-Path -LiteralPath $File
    $text = Get-Content -LiteralPath $resolved -Raw
}

if ([string]::IsNullOrEmpty($text)) {
    Write-Host "No text to type. Put OCR text on the clipboard or pass -File path." -ForegroundColor Yellow
    exit 1
}

if (-not $NoNormalizeNewlines) {
    $text = $text -replace "`r`n", "`n" -replace "`r", "`n"
}

$source = if ($Clipboard) { "clipboard" } else { $File }
Write-Host "Typing $($text.Length) characters from $source."

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class KeyboardTyper {
    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT {
        public Int32 type;
        public InputUnion U;
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct InputUnion {
        [FieldOffset(0)]
        public MOUSEINPUT mi;
        [FieldOffset(0)]
        public KEYBDINPUT ki;
        [FieldOffset(0)]
        public HARDWAREINPUT hi;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct MOUSEINPUT {
        public Int32 dx;
        public Int32 dy;
        public UInt32 mouseData;
        public UInt32 dwFlags;
        public UInt32 time;
        public UIntPtr dwExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct KEYBDINPUT {
        public UInt16 wVk;
        public UInt16 wScan;
        public UInt32 dwFlags;
        public UInt32 time;
        public UIntPtr dwExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct HARDWAREINPUT {
        public UInt32 uMsg;
        public UInt16 wParamL;
        public UInt16 wParamH;
    }

    [DllImport("user32.dll", SetLastError=true)]
    public static extern UInt32 SendInput(UInt32 nInputs, INPUT[] pInputs, Int32 cbSize);

    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(Int32 vKey);

    [DllImport("user32.dll")]
    public static extern short VkKeyScan(char ch);

    [DllImport("user32.dll", SetLastError=true)]
    public static extern void keybd_event(byte bVk, byte bScan, UInt32 dwFlags, UIntPtr dwExtraInfo);

    const Int32 INPUT_KEYBOARD = 1;
    const UInt32 KEYEVENTF_KEYUP = 0x0002;
    const UInt32 KEYEVENTF_UNICODE = 0x0004;
    const Int32 VK_ESCAPE = 0x1B;
    const UInt32 KEYBD_EVENT_KEYUP = 0x0002;

    public static void SendUnicodeChar(char ch) {
        INPUT[] inputs = new INPUT[2];

        inputs[0].type = INPUT_KEYBOARD;
        inputs[0].U.ki.wVk = 0;
        inputs[0].U.ki.wScan = ch;
        inputs[0].U.ki.dwFlags = KEYEVENTF_UNICODE;
        inputs[0].U.ki.time = 0;
        inputs[0].U.ki.dwExtraInfo = UIntPtr.Zero;

        inputs[1].type = INPUT_KEYBOARD;
        inputs[1].U.ki.wVk = 0;
        inputs[1].U.ki.wScan = ch;
        inputs[1].U.ki.dwFlags = KEYEVENTF_UNICODE | KEYEVENTF_KEYUP;
        inputs[1].U.ki.time = 0;
        inputs[1].U.ki.dwExtraInfo = UIntPtr.Zero;

        UInt32 sent = SendInput(2, inputs, Marshal.SizeOf(typeof(INPUT)));
        if (sent != 2) {
            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
        }
    }

    public static bool IsEscapeDown() {
        return (GetAsyncKeyState(VK_ESCAPE) & 0x8000) != 0;
    }

    public static void PressVirtualKey(byte vk) {
        keybd_event(vk, 0, 0, UIntPtr.Zero);
        keybd_event(vk, 0, KEYBD_EVENT_KEYUP, UIntPtr.Zero);
    }

    public static bool SendKeyboardLayoutChar(char ch) {
        short scan = VkKeyScan(ch);
        if (scan == -1) {
            return false;
        }

        byte vk = (byte)(scan & 0xff);
        byte shiftState = (byte)((scan >> 8) & 0xff);

        if ((shiftState & 1) != 0) keybd_event(0x10, 0, 0, UIntPtr.Zero);
        if ((shiftState & 2) != 0) keybd_event(0x11, 0, 0, UIntPtr.Zero);
        if ((shiftState & 4) != 0) keybd_event(0x12, 0, 0, UIntPtr.Zero);

        keybd_event(vk, 0, 0, UIntPtr.Zero);
        keybd_event(vk, 0, KEYBD_EVENT_KEYUP, UIntPtr.Zero);

        if ((shiftState & 4) != 0) keybd_event(0x12, 0, KEYBD_EVENT_KEYUP, UIntPtr.Zero);
        if ((shiftState & 2) != 0) keybd_event(0x11, 0, KEYBD_EVENT_KEYUP, UIntPtr.Zero);
        if ((shiftState & 1) != 0) keybd_event(0x10, 0, KEYBD_EVENT_KEYUP, UIntPtr.Zero);

        return true;
    }
}
"@

if ($DryRun) {
    Write-Host "Dry run only. Keyboard API loaded, but no input was sent."
    exit 0
}

Write-Host "Focus the remote terminal/editor now. Starting in $StartDelaySec seconds..."

for ($i = $StartDelaySec; $i -gt 0; $i--) {
    Write-Host "$i..."
    Start-Sleep -Seconds 1
}

$VK_BACK = 0x08
$VK_TAB = 0x09
$VK_RETURN = 0x0D

foreach ($ch in $text.ToCharArray()) {
    if ([KeyboardTyper]::IsEscapeDown()) {
        Write-Host "Stopped because Esc is pressed." -ForegroundColor Yellow
        exit 130
    }

    switch ([int][char]$ch) {
        8 { [KeyboardTyper]::PressVirtualKey($VK_BACK) }
        9 { [KeyboardTyper]::PressVirtualKey($VK_TAB) }
        10 { [KeyboardTyper]::PressVirtualKey($VK_RETURN) }
        default {
            if (-not [KeyboardTyper]::SendKeyboardLayoutChar($ch)) {
                [KeyboardTyper]::SendUnicodeChar($ch)
            }
        }
    }

    if ($DelayMs -gt 0) {
        Start-Sleep -Milliseconds $DelayMs
    }
}

Write-Host "Done."
