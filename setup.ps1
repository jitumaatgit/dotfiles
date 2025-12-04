Write-Host "===== portable-dev bootstrap started ====="

# Paths
$Base = "$env:USERPROFILE\portable-dev"
$Downloads = "$Base\downloads"
$Logs = "$Base\logs"
New-Item -ItemType Directory -Force -Path $Downloads, $Logs | Out-Null

# Transcript
$timestamp = (Get-Date -Format "yyyyMMdd-HHmmss")
Start-Transcript -Path "$Logs\setup-$timestamp.log"

# --- Install Scoop (per-user) ---
Write-Host "[INFO] Installing Scoop..."
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    irm get.scoop.sh | iex
}
# --- Required: Git BEFORE buckets ---
Write-Host "[INFO] Ensuring git..."
scoop install git

scoop bucket add extras
scoop bucket add nerd-fonts

# --- Needed packages ----
$Packages = @(
    "wezterm",
    "gcc",
    "nodejs-lts",
    "ripgrep",
    "fd",
    "fzf",
    "lazygit",
    "tree-sitter",
    "JetBrainsMono-NF"
    "neovim",
    "opencode",
    "starship",
    "gh"
)

foreach ($pkg in $Packages) {
    Write-Host "[INFO] Installing scoop package: $pkg"
    scoop install $pkg
}


# --- AutoHotkey Portable (CapsLock -> Esc) ---
$ahkDir = "$Base\autohotkey-portable"
$ahkZip = "$Downloads\autohotkey.zip"
Write-Host "[INFO] Downloading AutoHotkey Portable..."
Invoke-WebRequest -Uri "https://github.com/AutoHotkey/AutoHotkey/releases/download/v2.0.18/AutoHotkey_2.0.18.zip" -OutFile $ahkZip
Write-Host "[INFO] Extracting AutoHotkey..."
Expand-Archive -Path $ahkZip -DestinationPath $ahkDir -Force
Remove-Item $ahkZip -ErrorAction SilentlyContinue
$remapAhk = "$ahkDir\remap.ahk"
@"
Esc::CapsLock
"@ | Out-File $remapAhk -Encoding ASCII
Write-Host "[INFO] Creating startup shortcut for AutoHotkey..."
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey-remap.lnk")
$Shortcut.TargetPath = "$ahkDir\AutoHotkey64.exe"
$Shortcut.Arguments = $remapAhk
$Shortcut.Save()
Write-Host "[INFO] Starting AutoHotkey remap (CapsLock -> Esc)..."
Start-Process "$ahkDir\AutoHotkey64.exe" $remapAhk

# --- Zen Browser Installer ---
scoop install zen-browser
Write-Host "[INFO] Zen Browser installed."

# --- Windows Dark Mode ---
Write-Host "[INFO] Enabling Windows Dark Mode..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Type Dword
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Type Dword

# --- Auto-hide Taskbar ---
Write-Host "[INFO] Setting taskbar to auto-hide..."
$taskbarSettings = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Name "Settings"
$taskbarSettings.Settings[8] = 0x03  # This sets auto-hide
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Name "Settings" -Value $taskbarSettings.Settings

# --- Hide Desktop Icons ---
Write-Host "[INFO] Hiding desktop icons..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1 -Type Dword

# --- Set Desktop Wallpaper ---
$currentWallpaper = "C:\Windows\Web\Wallpaper\ThemeA\img20.jpg"
Write-Host "[INFO] Setting desktop wallpaper..."
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
[Wallpaper]::SystemParametersInfo(0x0014, 0, $currentWallpaper, 0x01)

# Restart Explorer to apply changes
Write-Host "[INFO] Restarting Explorer to apply changes..."
Stop-Process -Name explorer -Force
Start-Process explorer

Write-Host "===== bootstrap complete ====="
Write-Host "run gh auth login to authenticate"
Write-Host "then run git init -b main"
Write-Host "git remote add origin https://github.com/jitumaatgit/dotfiles"
Write-Host "git fetch"
Write-Host "git checkout -f main"
Write-Host "for notes, run mkdir notes"
Write-Host "cd notes"
Write-Host "git clone https://github.com/jitumaatgit/notes . "
Stop-Transcript
