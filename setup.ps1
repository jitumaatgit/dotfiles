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
    "zig",
    "gcc",
    "nodejs-lts",
    "ripgrep",
    "fd",
    "fzf",
    "lazygit",
    "tree-sitter",
    "JetBrainsMono-NF"
    "neovim",
    "opencode"
)

foreach ($pkg in $Packages) {
    Write-Host "[INFO] Installing scoop package: $pkg"
    scoop install $pkg
}

# --- WezTerm Portable ---
$WezDir = "$Base\wezterm"
$WezZip = "$Downloads\wezterm-portable.zip"
Write-Host "[INFO] Downloading WezTerm..."

Invoke-WebRequest `
  -Uri "https://github.com/wezterm/wezterm/releases/download/nightly/WezTerm-windows-nightly.zip" `
  -OutFile $WezZip

Write-Host "[INFO] Extracting WezTerm..."
Expand-Archive -Path $WezZip -DestinationPath $WezDir -Force


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
CapsLock::Esc
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

Write-Host "===== bootstrap complete ====="
Stop-Transcript
