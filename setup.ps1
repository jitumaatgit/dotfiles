Write-Host "===== portable-dev bootstrap started ====="

# Paths
$Base = "$env:USERPROFILE\portable-dev"
$Downloads = "$Base\downloads"
$Logs = "$Base\logs"
New-Item -ItemType Directory -Force -Path $Downloads, $Logs | Out-Null

# Transcript
Start-Transcript -Path "$Logs\setup-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Global error handling
$ErrorActionPreference = 'Stop'
$script:ExitCode = 0

trap {
    Write-Host "[ERROR] Script failed: $_" -ForegroundColor Red
    $script:ExitCode = 1
    Stop-Transcript
    exit $script:ExitCode
}

# Configuration
$Config = @{
    BaseUrl = 'https://raw.githubusercontent.com/jitumaatgit/dotfiles/main'
    ScoopPackages = @('wezterm', 'gcc', 'nodejs-lts', 'ripgrep', 'fd', 'fzf', 'lazygit',
                      'tree-sitter', 'luacheck', 'Cascadia-Code', 'JetBrainsMono-NF',
                      'neovim', 'opencode', 'starship', 'gh', 'eza', 'python')
    AhkDownloadUrl = "https://github.com/AutoHotkey/AutoHotkey/releases/download/v2.0.18/AutoHotkey_2.0.18.zip"
}

# Helper functions
function Invoke-SafeDownload {
    param([string]$Uri, [string]$OutFile, [int]$MaxRetries = 3)
    $retryCount = 0
    while ($retryCount -lt $MaxRetries) {
        try {
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing -ErrorAction Stop
            if (Test-Path $OutFile) {
                return
            }
        } catch {
            $retryCount++
            if ($retryCount -ge $MaxRetries) {
                throw "[ERROR] Failed to download $Uri after $MaxRetries attempts: $_"
            }
            Write-Host "[WARN] Download failed, retrying ($retryCount/$MaxRetries)..."
            Start-Sleep -Seconds 2
        }
    }
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
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

Write-Host "[INFO] Installing git..."
scoop install git
scoop bucket add extras 2>$null
scoop bucket add nerd-fonts 2>$null

# Install packages
Write-Host "[INFO] Installing scoop packages..."
$Config.ScoopPackages | ForEach-Object {
    $result = scoop install $_ 2>&1
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 2) {
        Write-Host "[OK] ${_}"
    } else {
        Write-Host "[WARN] Issue installing ${_}: ${result}"
    }
}

# Notes Repository
$notesDir = "$env:USERPROFILE\notes"
if (-not (Test-Path "$notesDir\.git")) {
    Write-Host "[INFO] Setting up notes repository..."
    if (Test-Path $notesDir) {
        $itemCount = (Get-ChildItem $notesDir -Force | Measure-Object).Count
        if ($itemCount -gt 0) {
            Write-Host "[WARN] Notes directory exists and is not empty. Skipping clone."
        } else {
            Remove-Item $notesDir -Force -Recurse
            git clone https://github.com/jitumaatgit/notes $notesDir
        }
    } else {
        New-Item -ItemType Directory -Force -Path $notesDir | Out-Null
        git clone https://github.com/jitumaatgit/notes $notesDir
    }
} else {
    Write-Host "[OK] Notes repository configured"
}

# SQLite for Neovim
Write-Host "[INFO] Installing SQLite for Neovim..."
$nvimProcess = Get-Process nvim -ErrorAction SilentlyContinue
if ($nvimProcess) {
    Write-Host "[INFO] Stopping nvim to update sqlite3.dll..."
    Stop-Process -Name nvim -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}
Invoke-SafeDownload "$($Config.BaseUrl)/install-sqlite-for-neovim.ps1" "$env:TEMP\install-sqlite-for-neovim.ps1"
if (-not (Test-Path "$env:TEMP\install-sqlite-for-neovim.ps1")) {
    throw "[ERROR] Failed to download SQLite install script"
}
try {
    & "$env:TEMP\install-sqlite-for-neovim.ps1"
} catch {
    Write-Host "[WARN] SQLite installation encountered errors: $_"
}

# nvim-data Backup
Write-Host "[INFO] Checking nvim-data backup..."
$nvimData = "$env:LOCALAPPDATA\nvim-data"

if (-not (Test-Path "$env:USERPROFILE\nvim-data-remote\.git") -or -not (New-JunctionCheck $nvimData @('databases','shada','sessions','undo'))) {
    Write-Host "[INFO] Running nvim-data backup setup..."
    if (-not (Test-Path $nvimData)) {
        New-Item -ItemType Directory -Path $nvimData -Force | Out-Null
    }
    Invoke-SafeDownload "$($Config.BaseUrl)/setup-nvim-data-backup.ps1" "$env:TEMP\setup-nvim-data-backup.ps1"
    if (-not (Test-Path "$env:TEMP\setup-nvim-data-backup.ps1")) {
        throw "[ERROR] Failed to download nvim-data backup script"
    }
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

# Stop existing AutoHotkey processes
$ahkProcess = Get-Process -Name "*AutoHotkey*" -ErrorAction SilentlyContinue
if ($ahkProcess) {
    Write-Host "[INFO] Stopping running AutoHotkey processes..."
    Stop-Process -Name "*AutoHotkey*" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

Write-Host "[INFO] Downloading AutoHotkey..."
Invoke-SafeDownload $Config.AhkDownloadUrl $ahkZip
if (-not (Test-Path $ahkZip)) {
    throw "[ERROR] Failed to download AutoHotkey"
}
Write-Host "[INFO] Extracting AutoHotkey..."
Expand-Archive -Path $ahkZip -DestinationPath $ahkDir -Force
Remove-Item $ahkZip -ErrorAction SilentlyContinue

Write-Host "[INFO] Downloading VD.ah2..."
$vdAhkPath = Join-Path $ahkDir "VD.ah2"
Invoke-SafeDownload 'https://raw.githubusercontent.com/FuPeiJiang/VD.ahk/v2_port/VD.ah2' $vdAhkPath
if (-not (Test-Path $vdAhkPath)) { throw "[ERROR] Failed to download VD.ah2" }

# Cleanup WindowsVirtualDesktopHelper
Write-Host "[INFO] Removing WindowsVirtualDesktopHelper..."
scoop uninstall windows-virtualdesktop-helper 2>$null
Remove-Item "$env:APPDATA\WindowsVirtualDesktopHelper" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\windows-virtualdesktop-helper.lnk" -ErrorAction SilentlyContinue
Write-Host "[OK] WindowsVirtualDesktopHelper cleanup complete"

# AutoHotkey v2 script with VD.ah2
$remapAhk = "$ahkDir\remap-v2.ahk"

$winVersion = [Environment]::OSVersion.Version
$isWindows11 = $winVersion.Major -ge 10 -and $winVersion.Build -ge 22000

if ($isWindows11) {
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
} else {
    Write-Host "[WARN] VD.ah2 virtual desktop features require Windows 11. Using basic remaps only."
    $ahkScript = @'
#SingleInstance force
ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
ProcessSetPriority "H"
SetWinDelay -1
SetControlDelay -1

; Remaps
CapsLock::Esc
RWin::LCtrl
'@
}
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

# zen-browser Data Backup
Write-Host "[INFO] Checking zen-browser data backup..."
$zenBackupRepo = "$env:USERPROFILE\zen-browser-data"
$zenProfileBase = "$env:APPDATA\zen\Profiles"

# Check if zen-browser profile exists and junction is set up
$needsSetup = $false

# Check if repo exists
if (-not (Test-Path "$zenBackupRepo\.git")) {
    $needsSetup = $true
} else {
    # Verify junction exists
    $profileDirs = Get-ChildItem $zenBackupRepo -Directory | 
        Where-Object { $_.LinkType -eq "Junction" }
    
    if (-not $profileDirs -or $profileDirs.Count -eq 0) {
        $needsSetup = $true
    } else {
        # Verify junction is valid
        $junctionValid = $true
        foreach ($dir in $profileDirs) {
            if (-not (Test-Path $dir.FullName)) {
                $junctionValid = $false
                break
            }
        }
        if (-not $junctionValid) {
            $needsSetup = $true
        }
    }
}

if ($needsSetup) {
    Write-Host "[INFO] Running zen-browser data backup setup..."
    if (-not (Test-Path $zenProfileBase)) {
        Write-Host "[WARN] Zen-browser profile not found. Please launch zen-browser and re-run setup."
        Write-Host "[INFO] Skipping zen-browser backup setup."
    } else {
        Invoke-SafeDownload "$($Config.BaseUrl)/setup-zen-data-backup.ps1" "$env:TEMP\setup-zen-data-backup.ps1"
        if (-not (Test-Path "$env:TEMP\setup-zen-data-backup.ps1")) {
            throw "[ERROR] Failed to download zen-browser backup script"
        }
        & "$env:TEMP\setup-zen-data-backup.ps1"
    }
} else {
    Write-Host "[OK] zen-browser data backup configured"
}

# Dark mode
$themePath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
@{ AppsUseLightTheme = 0; SystemUsesLightTheme = 0 }.GetEnumerator() | ForEach-Object {
    Set-ItemProperty $themePath $_.Key $_.Value -Type Dword
}

# Auto-hide taskbar
try {
    $taskbarSettings = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3' -Name Settings -ErrorAction Stop
    if ($taskbarSettings.Settings.Count -gt 8) {
        $taskbarSettings.Settings[8] = 0x03
        Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3' -Name Settings $taskbarSettings.Settings
    } else {
        Write-Host "[WARN] Could not set taskbar auto-hide: Settings array too short"
    }
} catch {
    Write-Host "[WARN] Could not set taskbar auto-hide: $_"
}

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
$wallpaperPath = 'C:\Windows\Web\Wallpaper\ThemeA\img20.jpg'
if (-not (Test-Path $wallpaperPath)) {
    Write-Host "[WARN] Wallpaper not found at $wallpaperPath, skipping..."
} else {
    [Wallpaper]::SystemParametersInfo(20, 0, $wallpaperPath, 1)
}

$explorer = Get-Process explorer -ErrorAction SilentlyContinue
if ($explorer) {
    Stop-Process -Name explorer -Force
    Start-Sleep -Seconds 2
}
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
Write-Host "zen-browser-data: cd ~/zen-browser-data && git status"
Write-Host "============================================================"
Stop-Transcript
