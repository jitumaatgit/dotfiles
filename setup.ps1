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
    "Cascadia-Code",
    "JetBrainsMono-NF",
    "neovim",
    "opencode",
    "starship",
    "gh",
    "eza"
 )

foreach ($pkg in $Packages) {
    Write-Host "[INFO] Installing scoop package: $pkg"
    scoop install $pkg
}

# --- SQLite DLL for Neovim ---
Write-Host "[INFO] Installing SQLite for Neovim..."
& "$PSScriptRoot\install-sqlite-for-neovim.ps1"

# --- nvim-data Backup (Persistent storage) ---
Write-Host "[INFO] Checking nvim-data backup setup..."

$backupRepo = "$env:USERPROFILE\nvim-data-remote" $nvimData = "$env:LOCALAPPDATA\nvim-data"
$needsSetup = $false

# Check if backup repo exists
if (-not (Test-Path "$backupRepo\.git")) {
    Write-Host "[INFO] nvim-data backup not configured. Setting up..."
    $needsSetup = $true
} else {
    # Check if junctions exist and are valid
    $junctionsValid = $true
    @("databases", "shada", "sessions", "undo") | ForEach-Object {
        $junctionPath = Join-Path $nvimData $_
        if (Test-Path $junctionPath) {
            # Verify it's actually a junction (not a regular directory)
            $junctionInfo = Get-Item $junctionPath | Select-Object LinkType
            if ($junctionInfo.LinkType -ne "Junction") {
                Write-Host "[WARN] $_ junction exists but is not a Junction. Will recreate."
                $needsSetup = $true
            }
        } else {
            Write-Host "[WARN] $_ junction missing. Will recreate."
            $needsSetup = $true
        }
    }
}

# Only run setup if something needs fixing
if ($needsSetup) {
    Write-Host "[INFO] Running nvim-data backup setup..."
    & "$PSScriptRoot\setup-nvim-data-backup.ps1"
} else {
    Write-Host "[OK] nvim-data backup already configured"
}

# --- AutoHotkey Portable (CapsLock -> Esc) ---
$ahkDir = "$Base\autohotkey-portable"
$ahkZip = "$Downloads\autohotkey.zip"
Write-Host "[INFO] Downloading AutoHotkey Portable..."
Invoke-WebRequest -Uri "https://github.com/AutoHotkey/AutoHotkey/releases/download/v2.0.18/AutoHotkey_2.0.18.zip" -OutFile $ahkZip
Write-Host "[INFO] Extracting AutoHotkey..."
Expand-Archive -Path $ahkZip -DestinationPath $ahkDir -Force
Remove-Item $ahkZip -ErrorAction SilentlyContinue

# --- Download VD.ahk Library (v2 version for AutoHotkey v2) ---
Write-Host "[INFO] Downloading VD.ah2 virtual desktop library (v2 version)..."
$vdAhkPath = Join-Path $ahkDir "VD.ah2"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FuPeiJiang/VD.ahk/v2_port/VD.ah2" -OutFile $vdAhkPath
if (Test-Path $vdAhkPath) {
    Write-Host "[OK] VD.ah2 v2 downloaded to $vdAhkPath"
} else {
    throw "[ERROR] Failed to download VD.ah2"
}

# --- Cleanup WindowsVirtualDesktopHelper ---
Write-Host "[INFO] Cleaning up WindowsVirtualDesktopHelper..."
$ErrorActionPreference = 'SilentlyContinue'
scoop uninstall windows-virtualdesktop-helper
Remove-Item "$env:APPDATA\WindowsVirtualDesktopHelper" -Recurse -Force
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\windows-virtualdesktop-helper.lnk"
Write-Host "[OK] WindowsVirtualDesktopHelper removed"
$ErrorActionPreference = 'Continue'

# --- AutoHotkey remap script with VD.ahk (v2) ---
Write-Host "[INFO] Creating AutoHotkey v2 script with VD.ah2..."
$remapAhk = "$ahkDir\remap-v2.ahk"
$remapContent = @'
; AutoHotkey v2 remap script with VD.ah2 for virtual desktop management
; Source: https://github.com/FuPeiJiang/VD.ahk/tree/v2_port
; Replaces: WindowsVirtualDesktopHelper (removed due to focus issue)
; Note: Using v2_port branch for AutoHotkey v2 compatibility

; Performance headers - required for VD.ah2 (see VD.ah2 README)
; Without these, virtual desktop operations will be slow
#SingleInstance force
ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
#WinActivateForce

ProcessSetPriority "H"

SetWinDelay -1
SetControlDelay -1

; Include VD.ah2 library - provides virtual desktop management for Windows 11
; Must be in same directory as this script
#Include %A_ScriptDir%\VD.ah2

; Disable desktop switching animations for instant navigation
; Set to true to enable smooth but slower transitions
VD.animation_on:=false

; Create up to 5 desktops on startup if they don't exist
; This ensures consistent workspace configuration across reboots
; Note: Doesn't delete extra desktops if more than 5 exist
VD.createUntil(5)

; Desktop switching: Win + (1-9) jumps directly to desktop 1-9
; VD.ah2 automatically focuses first window on destination desktop
; This solves: focus issue present in WindowsVirtualDesktopHelper
#1::VD.goToDesktopNum(1)
#2::VD.goToDesktopNum(2)
#3::VD.goToDesktopNum(3)
#4::VD.goToDesktopNum(4)
#5::VD.goToDesktopNum(5)
#6::VD.goToDesktopNum(6)
#7::VD.goToDesktopNum(7)
#8::VD.goToDesktopNum(8)
#9::VD.goToDesktopNum(9)

; Navigate to previous desktop: Win + [
; Navigate to next desktop: Win + ]
; Wraps around (from desktop 9, goes to desktop 1)
#[::VD.goToRelativeDesktopNum(-1)
#]::VD.goToRelativeDesktopNum(1)

; Move current window to desktop N and follow it: Win + Shift + (1-9)
; "A" refers to active window
; .follow() switches to destination desktop after moving
#+1::VD.MoveWindowToDesktopNum("A",1).follow()
#+2::VD.MoveWindowToDesktopNum("A",2).follow()
#+3::VD.MoveWindowToDesktopNum("A",3).follow()
#+4::VD.MoveWindowToDesktopNum("A",4).follow()
#+5::VD.MoveWindowToDesktopNum("A",5).follow()
#+6::VD.MoveWindowToDesktopNum("A",6).follow()
#+7::VD.MoveWindowToDesktopNum("A",7).follow()
#+8::VD.MoveWindowToDesktopNum("A",8).follow()
#+9::VD.MoveWindowToDesktopNum("A",9).follow()

; Move current window to desktop N without following: Win + Alt + (1-9)
; Window moves to destination but you stay on current desktop
#!1::VD.MoveWindowToDesktopNum("A",1)
#!2::VD.MoveWindowToDesktopNum("A",2)
#!3::VD.MoveWindowToDesktopNum("A",3)
#!4::VD.MoveWindowToDesktopNum("A",4)
#!5::VD.MoveWindowToDesktopNum("A",5)
#!6::VD.MoveWindowToDesktopNum("A",6)
#!7::VD.MoveWindowToDesktopNum("A",7)
#!8::VD.MoveWindowToDesktopNum("A",8)
#!9::VD.MoveWindowToDesktopNum("A",9)

; Toggle pin current window to all desktops: Win + Shift + P
; Pinned windows appear on all virtual desktops
; Pinning is like "Show this window on all desktops" in Windows 11
#+p::VD.TogglePinWindow("A")

; Existing productivity remaps (from original setup)
; CapsLock -> Esc (Vim-friendly)
; Right Win -> Left Ctrl (keyboard ergonomics)
CapsLock::Esc
RWin::LCtrl
'@
$remapContent | Out-File $remapAhk -Encoding UTF8
Write-Host "[OK] AutoHotkey v2 script created with VD.ah2 integration"
Write-Host "[INFO] Creating AutoHotkey startup shortcut..."
$WshShell = New-Object -comObject WScript.Shell

# AutoHotkey startup shortcut only (VD.ahk replaces WindowsVirtualDesktopHelper)
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey-remap.lnk")
$Shortcut.TargetPath = "$ahkDir\AutoHotkey64.exe"
$Shortcut.Arguments = $remapAhk
$Shortcut.Save()

Write-Host "[INFO] Starting AutoHotkey remap with VD.ahk (virtual desktop management)..."
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
Write-Host ""
Write-Host "Key Bindings Summary:"
Write-Host "  Desktop Switching:"
Write-Host "    Win + 1-9: Switch to desktop 1-9 (auto-focus)"
Write-Host "    Win + [ / ]: Previous / next desktop"
Write-Host "  Window Management:"
Write-Host "    Win + Shift + 1-9: Move window to desktop (follow)"
Write-Host "    Win + Alt + 1-9: Move window to desktop (stay)"
Write-Host "    Win + Shift + P: Pin window to all desktops"
Write-Host "  Other:"
Write-Host "    CapsLock: Esc | Right Win: Left Ctrl"
Write-Host ""
Write-Host "Virtual Desktops: VD.ah2 (v2_port branch, instant switching, auto-focus enabled)"
Write-Host ""
Write-Host "run gh auth login to authenticate"
Write-Host "then run git init -b main"
Write-Host "git remote add origin https://github.com/jitumaatgit/dotfiles"
Write-Host "git fetch"
Write-Host "git checkout -f main"
Write-Host "for notes, run mkdir notes"
Write-Host "cd notes"
Write-Host "git clone https://github.com/jitumaatgit/notes . "
Write-Host ""
Write-Host "===== nvim-data backup ====="
Write-Host "Check nvim-data status:"
Write-Host "  cd ~/vim-data-remote && git status"
Write-Host ""
Write-Host "Sync nvim-data to GitHub:"
Write-Host "  cd ~/vim-data-remote"
Write-Host "  git add ."
Write-Host "  git commit -m 'Update nvim data'"
Write-Host "  git push -u origin main"
Write-Host "============================================================"
Stop-Transcript
