
# ====================================================================== #
#  Portable Dev Environment (No Admin, No Scoop, No Shims)
#  - MSYS2 portable
#  - Neovim (inside MSYS2) + Lazy.nvim bootstrap
#  - WezTerm portable
#  - Portable NerdFonts (FiraCode Nerd Font)
#  - Portable .gitconfig
#  - Dotfiles sync (set $DotRepo below)
# ====================================================================== #

Set-StrictMode -Version Latest

# ---------------------------
# Config - edit these values
# ---------------------------
$BaseDir     = Join-Path $HOME "portable-dev"
$MsysDir     = Join-Path $BaseDir "msys2\msys64"
$DownloadDir = Join-Path $BaseDir "downloads"
$FontsDir    = Join-Path $BaseDir "fonts"
$WezDir      = Join-Path $BaseDir "wezterm"
$DotfilesDir = Join-Path $BaseDir "dotfiles"

# Replace this with your dotfiles repo URL (https or ssh)
$DotRepo = "https://github.com/jitumaatgit/dotfiles.git"

# Source URLs (stable "latest" downloads)
$MsysURL = "https://github.com/msys2/msys2-installer/releases/latest/download/msys2-base-x86_64-latest.tar.xz"
$WezURL  = "https://github.com/wez/wezterm/releases/latest/download/WezTerm-windows-portable.zip"
$NFURL   = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"


# ---------------------------
# Prepare directories
# ---------------------------
Write-Host "Creating folders under $BaseDir ..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $BaseDir, $MsysDir, $DownloadDir, $FontsDir, $WezDir, $DotfilesDir | Out-Null

# ---------------------------
# Download helpers
# ---------------------------
Function Download-IfMissing {
    param($Uri, $OutFile)
    if (-not (Test-Path $OutFile)) {
        Write-Host "Downloading $Uri -> $OutFile ..."
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
    } else {
        Write-Host "Already downloaded: $OutFile"
    }
}

# ---------------------------
# 1) Download & extract MSYS2
# ---------------------------
$MsysArchive = Join-Path $DownloadDir "msys2.tar.xz"
Download-IfMissing -Uri $MsysURL -OutFile $MsysArchive

Write-Host "`nExtracting MSYS2 archive ... (using tar). If this fails, rerun with 7zip available." -ForegroundColor Yellow

# Try using Windows 'tar' first
try {
    & tar -xf $MsysArchive -C $MsysDir 2>$null
    # The tar above usually extracts a top-level .tar file, so extract any nested .tar
    $innerTar = Get-ChildItem -Path $MsysDir -Filter "*.tar" -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($innerTar) {
        & tar -xf $innerTar.FullName -C $MsysDir 2>$null
        Remove-Item $innerTar.FullName -Force -ErrorAction SilentlyContinue
    }
    Write-Host "MSYS2 extracted to $MsysDir"
} catch {
    Write-Host "tar extraction failed. Attempting to use 7z if available..." -ForegroundColor Yellow
    if (-not (Get-Command 7z -ErrorAction SilentlyContinue)) {
        Write-Host "7z not found. Attempting to download a portable 7-Zip for extraction..."
        $SevenZipUrl = "https://www.7-zip.org/a/7z2201-x64.zip"   # fallback portable zip; may change upstream
        $SevenZipZip = Join-Path $DownloadDir "7zip.zip"
        Download-IfMissing -Uri $SevenZipUrl -OutFile $SevenZipZip
        Expand-Archive -LiteralPath $SevenZipZip -DestinationPath (Join-Path $BaseDir "7zip") -Force
        $seven = Get-ChildItem -Path (Join-Path $BaseDir "7zip") -Filter "7z.exe" -Recurse -File | Select-Object -First 1
        if (-not $seven) { throw "7z not found after download. Manual extraction required." }
        & $seven.FullName x $MsysArchive "-o$MsysDir" -y | Out-Null
        $innerTar = Get-ChildItem -Path $MsysDir -Filter "*.tar" -File | Select-Object -First 1
        if ($innerTar) { & $seven.FullName x $innerTar.FullName "-o$MsysDir" -y | Out-Null; Remove-Item $innerTar.FullName -Force -ErrorAction SilentlyContinue }
        Write-Host "MSYS2 extracted to $MsysDir (via 7z)"
    } else {
        Write-Host "Found 7z in PATH; using it to extract..."
        & 7z x $MsysArchive "-o$MsysDir" -y | Out-Null
        $innerTar = Get-ChildItem -Path $MsysDir -Filter "*.tar" -File | Select-Object -First 1
        if ($innerTar) { & 7z x $innerTar.FullName "-o$MsysDir" -y | Out-Null; Remove-Item $innerTar.FullName -Force -ErrorAction SilentlyContinue }
        Write-Host "MSYS2 extracted to $MsysDir (via 7z)"
    }
}

# Ensure msys2_shell.cmd exists
$msysShell = Join-Path $MsysDir "msys2_shell.cmd"
if (-not (Test-Path $msysShell)) {
    Write-Host "WARNING: msys2_shell.cmd not found in $MsysDir. The extraction may have placed files under a nested folder. Check $MsysDir." -ForegroundColor Yellow
}

# ---------------------------
# 2) Initialize MSYS2 & install packages
# ---------------------------
Write-Host "`nInitializing MSYS2 pacman and installing packages..." -ForegroundColor Cyan
$bash = Join-Path $MsysDir "usr\bin\bash.exe"
if (-not (Test-Path $bash)) { throw "bash.exe not found in $MsysDir/usr/bin. Extraction likely failed." }

# Update pacman DB and core packages (may run twice if needed)
& $bash -lc "pacman -Sy --noconfirm"
& $bash -lc "yes | pacman -Syu --noconfirm"   # first full upgrade
# Some MSYS2 setups require running twice; run again with --noconfirm
& $bash -lc "yes | pacman -Syu --noconfirm"

# Install neovim + essentials
& $bash -lc "pacman -S --noconfirm neovim git unzip ripgrep make gcc python python-pip nodejs fd fzf lazygit luarocks zen-browser-bin"

Write-Host "✔ Neovim and core tools installed inside MSYS2."

# ---------------------------
# 3) Bootstrap Lazy.nvim inside the MSYS2 environment
# ---------------------------
# Write-Host "`nBootstrapping lazy.nvim and creating minimal Neovim config..." -ForegroundColor Cyan
#
# # Ensure target dirs exist (POSIX paths for MSYS2)
# & $bash -lc "mkdir -p ~/.local/share/nvim/lazy"
# & $bash -lc "git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/lazy/lazy.nvim 2>/dev/null || true"
#
# # Create minimal init.lua (Windows-style file write to $HOME\.config\nvim)
# $NvimConfigWin = Join-Path $HOME ".config\nvim"
# New-Item -ItemType Directory -Force -Path $NvimConfigWin | Out-Null
# ## Note I will be refactoring this later, but its fine to test this script. 
# $InitLua = @'
# -- Auto-bootstrap lazy.nvim
# local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
# if not vim.loop.fs_stat(lazypath) then
#   vim.fn.system({
#     "git",
#     "clone",
#     "--filter=blob:none",
#     "https://github.com/folke/lazy.nvim.git",
#     "--branch=stable",
#     lazypath,
#   })
# end
# vim.opt.rtp:prepend(lazypath)
#
# require("lazy").setup({
#
#   { "nvim-telescope/telescope.nvim" },
#   {
#     "catppuccin/nvim",
#     priority = 1000,
#     name = "catppuccin",
#     config = function()
#       require("catppuccin").setup({
#         flavour = "mocha",
#         transparent_background = false,
#         integrations = {
#           telescope = true,
#           treesitter = true,
#         },
#       })
#       vim.cmd("colorscheme catppuccin-mocha")
#     end,
#   },
# })
#
# vim.keymap.set('i', 'jj', '<Esc>')
# '@
#
# Set-Content -Path (Join-Path $NvimConfigWin "init.lua") -Value $InitLua -Encoding UTF8
# Write-Host "✔ Neovim config written to $NvimConfigWin\init.lua"

# ---------------------------
# 4) Download & extract WezTerm portable
# ---------------------------
Write-Host "`nDownloading WezTerm portable..." -ForegroundColor Cyan
$WezZip = Join-Path $DownloadDir "wezterm.zip"
Download-IfMissing -Uri $WezURL -OutFile $WezZip

Write-Host "Extracting WezTerm..."
try {
    Expand-Archive -LiteralPath $WezZip -DestinationPath $WezDir -Force
} catch {
    # fallback to 7z if Expand-Archive fails
    $seven = Get-Command 7z -ErrorAction SilentlyContinue
    if ($seven) {
        & $seven.Path x $WezZip "-o$WezDir" -y | Out-Null
    } else {
        throw "Failed to extract WezTerm. Install 7z or ensure Expand-Archive works."
    }
}
Write-Host "✔ WezTerm extracted to $WezDir"

# ---------------------------
# 5) Download & extract NerdFonts (portable)
# ---------------------------
Write-Host "`nDownloading NerdFonts (FiraCode)..." -ForegroundColor Cyan
$NFZip = Join-Path $DownloadDir "FiraCodeNF.zip"
Download-IfMissing -Uri $NFURL -OutFile $NFZip

Write-Host "Extracting NerdFonts into $FontsDir ..."
try {
    Expand-Archive -LiteralPath $NFZip -DestinationPath $FontsDir -Force
} catch {
    $seven = Get-Command 7z -ErrorAction SilentlyContinue
    if ($seven) {
        & $seven.Path x $NFZip "-o$FontsDir" -y | Out-Null
    } else {
        throw "Failed to extract NerdFonts. Install 7z or ensure Expand-Archive works."
    }
}
Write-Host "✔ NerdFonts extracted to $FontsDir"

# Note: WezTerm can be pointed to fonts explicitly in its wezterm.lua config.
# Example wezterm.lua inside %USERPROFILE%/.wezterm.lua:
#   font = wezterm.font_with_fallback({ "FiraCode Nerd Font", "<path-to-font-file>" })

# ---------------------------
# 6) Portable .gitconfig
# ---------------------------
Write-Host "`nCreating portable .gitconfig (if missing)..." -ForegroundColor Cyan
$GitConfigPath = Join-Path $HOME ".gitconfig"
if (-not (Test-Path $GitConfigPath)) {
    @"
[user]
    name = Jitu Maat
    email = jitumaat@protonmail.com
[core]
    editor = nvim
[credential]
    helper = store --file=$BaseDir/git-credentials.txt
[init]
    defaultBranch = main
"@ | Set-Content -Path $GitConfigPath -Encoding UTF8
    Write-Host "✔ .gitconfig created at $GitConfigPath"
} else {
    Write-Host ".gitconfig already exists; skipping creation."
}

# ---------------------------
# 7) Dotfile sync (git clone)
# ---------------------------
Write-Host "`nCloning dotfiles repo (set $DotRepo at top of script)..." -ForegroundColor Cyan
if ($DotRepo -eq "https://github.com/jitumaatgit/dotfiles.git") {
    Write-Host "ERROR: Please edit this script and set the \$DotRepo variable to your dotfiles repo URL." -ForegroundColor Red
} else {
    Write-Host "You are already logged into Github" -ForegroundColor Green
    if (-not (Test-Path (Join-Path $DotfilesDir ".git"))) {
        Write-Host "Cloning $DotRepo -> $DotfilesDir ..."
        git clone $DotRepo $DotfilesDir
    } else {
        Write-Host "Dotfiles already cloned. Pulling latest..."
        Push-Location $DotfilesDir
        git pull --rebase
        Pop-Location
    }

    # Copy common configs (if present) into $HOME config locations
    try {
        if (Test-Path (Join-Path $DotfilesDir "nvim")) {
            Write-Host "Copying nvim config from dotfiles..."
            Copy-Item -Path (Join-Path $DotfilesDir "nvim\*") -Destination (Join-Path $HOME ".config\nvim") -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path (Join-Path $DotfilesDir "wezterm")) {
            Write-Host "Copying wezterm config from dotfiles..."
            $UserWezConfigDir = Join-Path $HOME ".config\wezterm"
            New-Item -ItemType Directory -Force -Path $UserWezConfigDir | Out-Null
            Copy-Item -Path (Join-Path $DotfilesDir "wezterm\*") -Destination $UserWezConfigDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "Warning: copy from dotfiles failed: $_" -ForegroundColor Yellow
    }
}

# ---------------------------
# 8) Final notes & instructions
# ---------------------------
Write-Host "`n✅ All done — portable environment installed." -ForegroundColor Green
Write-Host "MSYS2 (bash) location: $bash"
Write-Host "Launch MSYS2 shell with: $MsysDir\msys2_shell.cmd" -ForegroundColor Cyan
Write-Host "Inside MSYS2 you can run: pacman, nvim, git, etc." -ForegroundColor Cyan
Write-Host "WezTerm location (portable): $WezDir" -ForegroundColor Cyan
Write-Host "NerdFonts location (portable): $FontsDir" -ForegroundColor Cyan
Write-Host "`nNotes:" -ForegroundColor Yellow
Write-Host " - This script does NOT modify system fonts or PATH." -ForegroundColor Yellow
Write-Host " - To use NerdFonts in WezTerm, either install them system-wide (requires admin) or point WezTerm's config to the font files in $FontsDir." -ForegroundColor Yellow
Write-Host " - Edit the variable \$DotRepo at the top and re-run to sync your dotfiles." -ForegroundColor Yellow
Write-Host "`nExample: open WezTerm -> set font path in ~/.config/wezterm.lua to point at $FontsDir" -ForegroundColor Magenta

# End of script
