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
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    iwr -useb get.scoop.sh | iex
}
scoop bucket add main
scoop bucket add extras

# --- Required: Git BEFORE buckets ---
Write-Host "[INFO] Ensuring git..."
scoop install git

# --- Needed packages ----
$Packages = @(
    "neovim",
    "nodejs-lts",
    "ripgrep",
    "fd",
    "fzf",
    "lazygit"
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

# --- Zen Browser Installer ---
Write-Host "[INFO] Installing Zen Browser..."

$ZenInstaller = "$Downloads\zen.installer.exe"
Invoke-WebRequest `
  -Uri "https://github.com/zen-browser/desktop/releases/latest/download/zen.installer.exe" `
  -OutFile $ZenInstaller

# Run Zen installer silently if possible
Start-Process $ZenInstaller -ArgumentList "/S" -Wait

Write-Host "[INFO] Zen Browser installed."

Write-Host "===== bootstrap complete ====="
Stop-Transcript
