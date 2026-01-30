Write-Host "===== portable-dev bootstrap started ====="

# Paths
$Base = "$env:USERPROFILE\portable-dev"
$Downloads = "$Base\downloads"
$Logs = "$Base\logs"
New-Item -ItemType Directory -Force -Path $Downloads, $Logs | Out-Null

# Transcript
Start-Transcript -Path "$Logs\setup-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Configuration
$Config = @{
    BaseUrl = 'https://raw.githubusercontent.com/jitumaatgit/dotfiles/main'
    ScoopPackages = @('wezterm', 'gcc', 'nodejs-lts', 'ripgrep', 'fd', 'fzf', 'lazygit', 
                      'tree-sitter', 'luacheck', 'Cascadia-Code', 'JetBrainsMono-NF', 
                      'neovim', 'opencode', 'starship', 'gh', 'eza', 'python')
    AhkVersion = 'v2.0.18'
    AhkDownloadUrl = "https://github.com/AutoHotkey/AutoHotkey/releases/download/v2.0.18/AutoHotkey_2.0.18.zip"
}

# Helper functions
function Invoke-SafeDownload {
    param([string]$Uri, [string]$OutFile)
    Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
}

function New-JunctionCheck {
    param([string]$Path, [string[]]$Items)
    foreach ($item in $Items) {
        $junctionPath = Join-Path $Path $item
        if (Test-Path $junctionPath) {
            if ((Get-Item $junctionPath).LinkType -ne 'Junction') { return $false }
        } else {
            return $false
        }
    }
    return $true
}

# Install Scoop
Write-Host "[INFO] Installing Scoop..."
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-WebRequest -Uri 'https://get.scoop.sh' -OutFile "$env:TEMP\install.ps1" -UseBasicParsing
    & "$env:TEMP\install.ps1" -RunAsAdmin
}

Write-Host "[INFO] Installing git..."
scoop install git
scoop bucket add extras, nerd-fonts

# Install packages in parallel (PS 7+) or sequentially (PS 5.1)
Write-Host "[INFO] Installing scoop packages..."
$Config.ScoopPackages | ForEach-Object {
    Write-Host "[INFO] Installing $_..."
    scoop install $_
}

# Notes Repository
$notesDir = "$env:USERPROFILE\notes"
if (-not (Test-Path "$notesDir\.git")) {
    Write-Host "[INFO] Setting up notes repository..."
    New-Item -ItemType Directory -Force -Path $notesDir | Out-Null
    git clone https://github.com/jitumaatgit/notes $notesDir
} else {
    Write-Host "[OK] Notes repository configured"
}

# SQLite for Neovim
Write-Host "[INFO] Installing SQLite for Neovim..."
Invoke-SafeDownload "$($Config.BaseUrl)/install-sqlite-for-neovim.ps1" "$env:TEMP\install-sqlite-for-neovim.ps1"
& "$env:TEMP\install-sqlite-for-neovim.ps1"

# nvim-data Backup
Write-Host "[INFO] Checking nvim-data backup..."
$backupRepo = "$env:USERPROFILE\nvim-data-remote"
$nvimData = "$env:LOCALAPPDATA\nvim-data"

if (-not (Test-Path "$backupRepo\.git") -or -not (New-JunctionCheck $nvimData @('databases','shada','sessions','undo'))) {
    Write-Host "[INFO] Running nvim-data backup setup..."
    Invoke-SafeDownload "$($Config.BaseUrl)/setup-nvim-data-backup.ps1" "$env:TEMP\setup-nvim-data-backup.ps1"
    & "$env:TEMP\setup-nvim-data-backup.ps1"
} else {
    Write-Host "[OK] nvim-data backup configured"
}

# Neovim Plugin Dependencies
$mkdpPath = "$env:LOCALAPPDATA\nvim-data\lazy\markdown-preview.nvim"
if (Test-Path "$mkdpPath\app") {
    Push-Location "$mkdpPath\app"
    try {
        npm install
        Write-Host "[OK] markdown-preview.nvim installed"
    } catch {
        powershell.exe -ExecutionPolicy Bypass -File ".\install.cmd" v0.0.10
        if (-not (Test-Path "bin\markdown-preview-win.exe")) {
            Write-Host "[WARN] markdown-preview.nvim install incomplete"
        }
    }
    Pop-Location
} else {
    Write-Host "[INFO] markdown-preview.nvim will be handled by lazy.nvim"
}

# AutoHotkey Portable
$ahkDir = "$Base\autohotkey-portable"
$ahkZip = "$Downloads\autohotkey.zip"
Write-Host "[INFO] Downloading AutoHotkey..."
Invoke-SafeDownload $Config.AhkDownloadUrl $ahkZip
Write-Host "[INFO] Extracting AutoHotkey..."
Expand-Archive -Path $ahkZip -DestinationPath $ahkDir -Force
Remove-Item $ahkZip -ErrorAction SilentlyContinue

Write-Host "[INFO] Downloading VD.ah2..."
$vdAhkPath = Join-Path $ahkDir "VD.ah2"
Invoke-SafeDownload 'https://raw.githubusercontent.com/FuPeiJiang/VD.ahk/v2_port/VD.ah2' $vdAhkPath
if (-not (Test-Path $vdAhkPath)) { throw "[ERROR] Failed to download VD.ah2" }

# Cleanup WindowsVirtualDesktopHelper
Write-Host "[INFO] Removing WindowsVirtualDesktopHelper..."
@('scoop uninstall windows-virtualdesktop-helper', 
  "Remove-Item '$env:APPDATA\WindowsVirtualDesktopHelper' -Recurse -Force",
  "Remove-Item '$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\windows-virtualdesktop-helper.lnk'") | ForEach-Object {
    Invoke-Expression $_ 2>$null
}

# AutoHotkey v2 script with VD.ah2
$remapAhk = "$ahkDir\remap-v2.ahk"
$ahkScript = @'
#SingleInstance force
ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
ProcessSetPriority "H"
SetWinDelay -1
SetControlDelay -1

#Include %A_ScriptDir%\VD.ah2

VD.animation_on:=false
VD.createUntil(5)

; Desktop switch
Loop 9 { hotkey "#" A_Index, ((i) => VD.goToDesktopNum(i)).Bind(A_Index) }

; Desktop nav
#[::VD.goToRelativeDesktopNum(-1)
#]::VD.goToRelativeDesktopNum(1)

; Move window + follow
Loop 9 { hotkey "#+" A_Index, ((i) => VD.MoveWindowToDesktopNum("A",i).follow()).Bind(A_Index) }

; Move window - stay
Loop 9 { hotkey "#!" A_Index, ((i) => VD.MoveWindowToDesktopNum("A",i)).Bind(A_Index) }

; Pin window
#+p::VD.TogglePinWindow("A")

; Remaps
CapsLock::Esc
RWin::LCtrl
'@
$ahkScript | Out-File $remapAhk -Encoding UTF8

# Create startup shortcut
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey-remap.lnk"
$WshShell = New-Object -comObject WScript.Shell
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "$ahkDir\AutoHotkey64.exe"
$shortcut.Arguments = $remapAhk
$shortcut.Save()

Write-Host "[INFO] Starting AutoHotkey..."
Start-Process "$ahkDir\AutoHotkey64.exe" $remapAhk

# Windows Settings
Write-Host "[INFO] Applying Windows settings..."

scoop install zen-browser

# Dark mode
$themePath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
@{ AppsUseLightTheme = 0; SystemUsesLightTheme = 0 }.GetEnumerator() | ForEach-Object {
    Set-ItemProperty $themePath $_.Key $_.Value -Type Dword
}

# Auto-hide taskbar
$taskbarSettings = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3' -Name Settings
$taskbarSettings.Settings[8] = 0x03
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3' -Name Settings $taskbarSettings.Settings

# Hide icons
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideIcons 1 -Type Dword

# Wallpaper
Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll")]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
[Wallpaper]::SystemParametersInfo(20, 0, 'C:\Windows\Web\Wallpaper\ThemeA\img20.jpg', 1)

Stop-Process -Name explorer -Force
Start-Process explorer

Write-Host "===== bootstrap complete =====`n"
Write-Host "Key Bindings:
  Desktop: Win+1-9 | Win+[ / ]
  Window: Win+Shift+1-9 (follow) | Win+Alt+1-9 (stay) | Win+Shift+P (pin)
  Other: CapsLock=Esc | RWin=LCtrl`n"
Write-Host "Dotfiles setup:
  gh auth login
  git init -b main && git remote add origin https://github.com/jitumaatgit/dotfiles
  git fetch && git checkout -f main`n"
Write-Host "nvim-data: cd ~/vim-data-remote && git status"
Write-Host "============================================================"
Stop-Transcript
