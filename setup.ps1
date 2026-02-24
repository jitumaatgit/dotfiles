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
    Write-Host "[ERROR] Error details: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ScriptStackTrace) {
        Write-Host "[ERROR] Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    }
    Write-Host "[INFO] Check the transcript log for full details: $Logs\setup-*.log" -ForegroundColor Cyan
    $script:ExitCode = 1
    Stop-Transcript
    if (-not [string]::IsNullOrEmpty($global:scriptFailed)) {
        # Continue if this is a non-fatal package installation error
        Write-Host "[INFO] Continuing despite error..." -ForegroundColor Yellow
    } else {
        exit $script:ExitCode
    }
}

# Configuration
$Config = @{
    BaseUrl = 'https://raw.githubusercontent.com/jitumaatgit/dotfiles/main'
    ScoopPackages = @('wezterm', 'gcc', 'nodejs-lts', 'ripgrep', 'fd', 'fzf', 'lazygit',
                      'tree-sitter', 'luacheck',
                      'neovim', 'opencode', 'starship', 'gh', 'eza', 'yazi', 'poppler', 'uv', 'python')
    AhkDownloadUrl = "https://github.com/AutoHotkey/AutoHotkey/releases/download/v2.0.18/AutoHotkey_2.0.18.zip"
}

# Helper functions
function Test-DomainTrust {
    # Check if computer is domain-joined and trust is working
    try {
        $computerInfo = Get-WmiObject -Class Win32_ComputerSystem -ErrorAction SilentlyContinue
        if ($computerInfo -and $computerInfo.PartOfDomain) {
            $trustValid = Test-ComputerSecureChannel -ErrorAction SilentlyContinue
            if (-not $trustValid) {
                Write-Host "[WARN] This computer is domain-joined but the trust relationship is broken!" -ForegroundColor Yellow
                Write-Host "[INFO] Fonts will be downloaded manually instead of installing via Scoop to avoid this issue." -ForegroundColor Cyan
                Write-Host "[INFO] To fix domain trust, run PowerShell as Administrator and execute: Test-ComputerSecureChannel -Repair" -ForegroundColor Cyan
                return $false
            }
        }
        return $true
    } catch {
        # Test-ComputerSecureChannel may not be available on all systems
        return $true
    }
}

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

# Check domain trust before proceeding
Test-DomainTrust

# Install Scoop
Write-Host "[INFO] Installing Scoop..."
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

Write-Host "[INFO] Installing git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    scoop install git
} else {
    Write-Host "[OK] git already installed"
}
scoop bucket add extras 2>$null
scoop bucket add nerd-fonts 2>$null

# Install packages
Write-Host "[INFO] Installing scoop packages..."
$installedPackages = scoop list 2>$null | ForEach-Object { ($_ -split '\s+')[0] }
$failedPackages = @()

$Config.ScoopPackages | ForEach-Object {
    $pkg = $_
    if ($installedPackages -contains $pkg) {
        Write-Host "[OK] ${pkg} already installed"
    } else {
        Write-Host "[INFO] Installing ${pkg}..."
        try {
            scoop install $pkg 2>&1 | Out-Null
            Write-Host "[OK] ${pkg} installed"
        } catch {
            Write-Host "[WARN] Failed to install ${pkg}: $_" -ForegroundColor Yellow
            $failedPackages += $pkg
        }
    }
}

if ($failedPackages.Count -gt 0) {
    Write-Host "[WARN] The following packages failed to install: $($failedPackages -join ', ')" -ForegroundColor Yellow
    Write-Host "[INFO] You may need to fix domain trust issues or run as administrator" -ForegroundColor Yellow
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
$sqliteDllPath = "$env:LOCALAPPDATA\nvim\bin\sqlite3.dll"
if (Test-Path $sqliteDllPath) {
    Write-Host "[OK] SQLite already installed"
} else {
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
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "[WARN] npm not found, skipping markdown-preview.nvim setup"
    } else {
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
    }
} else {
    Write-Host "[INFO] markdown-preview.nvim will be handled by lazy.nvim"
}

# AutoHotkey Portable
$ahkDir = "$Base\autohotkey-portable"
$ahkZip = "$Downloads\autohotkey.zip"
$ahkExe = "$ahkDir\AutoHotkey64.exe"
$needsAhkInstall = $false
$needsVdDownload = $false

# Check if AutoHotkey needs installation
if (-not (Test-Path $ahkExe)) {
    $needsAhkInstall = $true
    Write-Host "[INFO] AutoHotkey not found, will install..."
} else {
    Write-Host "[OK] AutoHotkey already installed"
}

# Check if VD.ah2 needs download
$vdAhkPath = Join-Path $ahkDir "VD.ah2"
if (-not (Test-Path $vdAhkPath)) {
    $needsVdDownload = $true
    Write-Host "[INFO] VD.ah2 not found, will download..."
}

if ($needsAhkInstall -or $needsVdDownload) {
    # Stop existing AutoHotkey processes
    $ahkProcess = Get-Process -Name "AutoHotkey64" -ErrorAction SilentlyContinue
    if ($ahkProcess) {
        Write-Host "[INFO] Stopping AutoHotkey..."
        Stop-Process -Name "AutoHotkey64" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
}

if ($needsAhkInstall) {
    Write-Host "[INFO] Downloading AutoHotkey..."
    Invoke-SafeDownload $Config.AhkDownloadUrl $ahkZip
    if (-not (Test-Path $ahkZip)) {
        throw "[ERROR] Failed to download AutoHotkey"
    }
    Write-Host "[INFO] Extracting AutoHotkey..."
    Expand-Archive -Path $ahkZip -DestinationPath $ahkDir -Force
    Remove-Item $ahkZip -ErrorAction SilentlyContinue
}

if ($needsVdDownload) {
    Write-Host "[INFO] Downloading VD.ah2..."
    Invoke-SafeDownload 'https://raw.githubusercontent.com/FuPeiJiang/VD.ahk/v2_port/VD.ah2' $vdAhkPath
    if (-not (Test-Path $vdAhkPath)) { throw "[ERROR] Failed to download VD.ah2" }
}

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

; Include VD.ah2 library
#Include %A_ScriptDir%\VD.ah2

; Configure VD
VD.animation_on:=false
VD.createUntil(5)

; Desktop switch: Win + 1-9
#1::GoToDesktop(1)
#2::GoToDesktop(2)
#3::GoToDesktop(3)
#4::GoToDesktop(4)
#5::GoToDesktop(5)
#6::GoToDesktop(6)
#7::GoToDesktop(7)
#8::GoToDesktop(8)
#9::GoToDesktop(9)

GoToDesktop(num) {
    try {
        VD.goToDesktopNum(num)
    } catch {
        ; Fallback: use Windows default
        Send "#{Tab}"
    }
}

; Desktop nav
#[::VD.goToRelativeDesktopNum(-1)
#]::VD.goToRelativeDesktopNum(1)

; Move window + follow: Win + Shift + 1-9
#+1::MoveWindowToDesktop(1, true)
#+2::MoveWindowToDesktop(2, true)
#+3::MoveWindowToDesktop(3, true)
#+4::MoveWindowToDesktop(4, true)
#+5::MoveWindowToDesktop(5, true)
#+6::MoveWindowToDesktop(6, true)
#+7::MoveWindowToDesktop(7, true)
#+8::MoveWindowToDesktop(8, true)
#+9::MoveWindowToDesktop(9, true)

MoveWindowToDesktop(num, follow := false) {
    try {
        if (follow) {
            VD.MoveWindowToDesktopNum("A", num).follow()
        } else {
            VD.MoveWindowToDesktopNum("A", num)
        }
    } catch {
        ; Fallback
        Send "#{Tab}"
    }
}

; Move window - stay: Win + Alt + 1-9
#!1::MoveWindowToDesktop(1, false)
#!2::MoveWindowToDesktop(2, false)
#!3::MoveWindowToDesktop(3, false)
#!4::MoveWindowToDesktop(4, false)
#!5::MoveWindowToDesktop(5, false)
#!6::MoveWindowToDesktop(6, false)
#!7::MoveWindowToDesktop(7, false)
#!8::MoveWindowToDesktop(8, false)
#!9::MoveWindowToDesktop(9, false)

; Pin window: Win + Shift + P
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

# Check if AHK script needs update
$scriptNeedsUpdate = $true
if (Test-Path $remapAhk) {
    $tempFile = [System.IO.Path]::GetTempFileName()
    $ahkScript | Out-File $tempFile -Encoding UTF8
    $existingHash = (Get-FileHash $remapAhk -Algorithm SHA256).Hash
    $newHash = (Get-FileHash $tempFile -Algorithm SHA256).Hash
    
    if ($existingHash -eq $newHash) {
        Write-Host "[OK] AutoHotkey script up to date"
        $scriptNeedsUpdate = $false
        Remove-Item $tempFile
    } else {
        Move-Item $tempFile $remapAhk -Force
        Write-Host "[OK] AutoHotkey script updated"
    }
} else {
    $ahkScript | Out-File $remapAhk -Encoding UTF8
    Write-Host "[OK] AutoHotkey script created"
}

# Create startup shortcut
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey-remap.lnk"
$WshShell = New-Object -ComObject WScript.Shell
try {
    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "$ahkDir\AutoHotkey64.exe"
    $shortcut.Arguments = $remapAhk
    $shortcut.Save()
} finally {
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WshShell) | Out-Null
}

Write-Host "[INFO] Starting AutoHotkey..."
Start-Process "$ahkDir\AutoHotkey64.exe" $remapAhk

# Windows Settings
Write-Host "[INFO] Applying Windows settings..."

# Check if zen-browser needs installation
if ($installedPackages -contains "zen-browser") {
    Write-Host "[OK] zen-browser already installed"
} else {
    scoop install zen-browser
}

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
        # Verify all items are actually junctions and targets exist
        $junctionValid = $true
        foreach ($dir in $profileDirs) {
            $item = Get-Item $dir.FullName -ErrorAction SilentlyContinue
            if (-not $item -or $item.LinkType -ne "Junction") {
                $junctionValid = $false
                break
            }
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
try {
    $themePath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    @{ AppsUseLightTheme = 0; SystemUsesLightTheme = 0 }.GetEnumerator() | ForEach-Object {
        Set-ItemProperty $themePath $_.Key $_.Value -Type Dword -ErrorAction Stop
    }
    Write-Host "[OK] Dark mode enabled"
} catch {
    Write-Host "[WARN] Could not enable dark mode: ${_}"
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

# Font Installation (manual, no admin required)
Write-Host "[INFO] Installing fonts manually..."
$fontDir = "$env:USERPROFILE\Desktop\DownloadedFonts"
$fontTempDir = "$env:TEMP\fonts-install"
New-Item -ItemType Directory -Force -Path $fontDir, $fontTempDir | Out-Null

$cascadiaCopied = 0
$jetbrainsCopied = 0

try {
    # Download Cascadia Code
    $cascadiaUrl = "https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip"
    $cascadiaZip = "$fontTempDir\CascadiaCode.zip"

    Write-Host "[INFO] Downloading Cascadia Code..."
    Invoke-SafeDownload $cascadiaUrl $cascadiaZip
    
    if (Test-Path $cascadiaZip) {
        Write-Host "[INFO] Extracting Cascadia Code..."
        Expand-Archive -Path $cascadiaZip -DestinationPath $fontTempDir -Force
        
        $staticTtfPath = Join-Path $fontTempDir "ttf\static"
        $ttfPath = Join-Path $fontTempDir "ttf"
        
        if (-not (Test-Path $staticTtfPath) -and -not (Test-Path $ttfPath)) {
            $extractedDir = Get-ChildItem $fontTempDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName "ttf") } | Select-Object -First 1
            if ($extractedDir) {
                $staticTtfPath = Join-Path $extractedDir.FullName "ttf\static"
                $ttfPath = Join-Path $extractedDir.FullName "ttf"
            }
        }
        
        if (Test-Path $staticTtfPath) {
            Write-Host "[INFO] Found static TTF files, copying..."
            $fontFiles = Get-ChildItem $staticTtfPath -Filter *.ttf
            $fontFiles | ForEach-Object { Copy-Item $_.FullName -Destination $fontDir -Force }
            $cascadiaCopied = $fontFiles.Count
        } elseif (Test-Path $ttfPath) {
            Write-Host "[INFO] Found TTF files, copying..."
            $fontFiles = Get-ChildItem $ttfPath -Filter *.ttf -Recurse
            $fontFiles | ForEach-Object { Copy-Item $_.FullName -Destination $fontDir -Force }
            $cascadiaCopied = $fontFiles.Count
        } else {
            Write-Host "[WARN] Could not find TTF files in Cascadia Code archive" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[WARN] Cascadia Code download failed" -ForegroundColor Yellow
    }
    
    # Download JetBrains Mono
    $jetbrainsUrl = "https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip"
    $jetbrainsZip = "$fontTempDir\JetBrainsMono.zip"
    
    Write-Host "[INFO] Downloading JetBrains Mono..."
    Invoke-SafeDownload $jetbrainsUrl $jetbrainsZip
    
    if (Test-Path $jetbrainsZip) {
        Write-Host "[INFO] Extracting JetBrains Mono..."
        Expand-Archive -Path $jetbrainsZip -DestinationPath $fontTempDir -Force
        
        # Find all TTF files in extracted directory
        $allTtfFiles = Get-ChildItem $fontTempDir -Filter *.ttf -Recurse -ErrorAction SilentlyContinue
        if ($allTtfFiles) {
            Write-Host "[INFO] Found $($allTtfFiles.Count) JetBrains Mono font files, copying..."
            $allTtfFiles | ForEach-Object { Copy-Item $_.FullName -Destination $fontDir -Force }
            $jetbrainsCopied = $allTtfFiles.Count
        } else {
            Write-Host "[WARN] Could not find TTF files in JetBrains Mono archive" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[WARN] JetBrains Mono download failed" -ForegroundColor Yellow
    }
    
    # Report results
    if ($cascadiaCopied -gt 0 -or $jetbrainsCopied -gt 0) {
        Write-Host ""
        Write-Host "[OK] Font download complete:" -ForegroundColor Green
        if ($cascadiaCopied -gt 0) {
            Write-Host "  - Cascadia Code: $cascadiaCopied files" -ForegroundColor Green
        }
        if ($jetbrainsCopied -gt 0) {
            Write-Host "  - JetBrains Mono: $jetbrainsCopied files" -ForegroundColor Green
        }
        Write-Host "[OK] Fonts saved to: $fontDir" -ForegroundColor Green
        Write-Host ""
        Write-Host "[INFO] To install fonts:" -ForegroundColor Cyan
        Write-Host "  1. Open File Explorer and navigate to: $fontDir"
        Write-Host "  2. Select all font files"
        Write-Host "  3. Right-click and select 'Install' for current user only"
        Write-Host "  4. Restart your terminal/editor to see the new fonts"
        Write-Host ""
    } else {
        Write-Host "[WARN] No fonts were downloaded successfully" -ForegroundColor Yellow
        Write-Host "[INFO] You can download fonts manually later from:" -ForegroundColor Cyan
        Write-Host "  - Cascadia Code: https://github.com/microsoft/cascadia-code/releases" -ForegroundColor Cyan
        Write-Host "  - JetBrains Mono: https://www.jetbrains.com/lp/mono/" -ForegroundColor Cyan
    }
} catch {
    Write-Host "[WARN] Font download failed: $_" -ForegroundColor Yellow
    Write-Host "[INFO] You can download fonts manually later from:" -ForegroundColor Cyan
    Write-Host "  - Cascadia Code: https://github.com/microsoft/cascadia-code/releases" -ForegroundColor Cyan
    Write-Host "  - JetBrains Mono: https://www.jetbrains.com/lp/mono/" -ForegroundColor Cyan
} finally {
    # Cleanup temp files
    Write-Host "[INFO] Cleaning up temporary files..."
    Remove-Item $fontTempDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "===== bootstrap complete =====`n"
Write-Host "Key Bindings:
  Desktop: Win+1-9 | Win+[ / ]
  Window: Win+Shift+1-9 (follow) | Win+Alt+1-9 (stay) | Win+Shift+P (pin)
  Other: CapsLock=Esc | RWin=LCtrl`n"
Write-Host "Dotfiles setup:
  gh auth login
  git init -b main 
  git remote add origin https://github.com/jitumaatgit/dotfiles
  git fetch 
  git checkout -f main`n"
Write-Host "nvim-data: cd ~/vim-data-remote 
Write-Host "git status"
Write-Host "zen-browser-data: cd ~/zen-browser-data 
Write-Host "git status"
Write-Host "============================================================"
Stop-Transcript
