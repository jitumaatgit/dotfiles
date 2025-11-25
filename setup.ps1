# setup.ps1

# 1. Install Scoop (The package manager)
Write-Host "Installing Scoop..." -ForegroundColor Cyan
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
irm get.scoop.sh | iex
}

# 2. Install The Missing Helpers FIRST ( for 7zip/ innounp)
Write-Host "Installing Helper Tools..." -ForegroundColor Yellow
scoop install 7zip innounp dark

# 3. Install my Main Tools
Write-Host "Installing Neovim, Git, and Ripgrep" -ForegroundColor Green
scoop update
scoop install git neovim ripgrep gcc

# 4. Clone my Dotfiles
$RepoPath  = "$HOME\dotfiles"
if (-not (Test-Path $RepoPath)) {
    Write-Host "Cloning Dotfiles from Github..." -ForegroundColor Cyan
    git clone https://github.com/jitumaatgit/dotfiles.git $RepoPath
} else { 
    # if folder exists, just pull latest changes
    Set-Location $RepoPath
    git pull
}

# 5. Apply Configurations (the non-admin way)

# --- Neovim: Directory Junction (works w/o admin) ---
$NvimLocal = "$env:LOCALAPPDATA\nvim"
if (Test-Path $NvimLocal) { Remove-Item $NvimLocal -Recurse -Force }
New-Item -ItemType Junction -Path $NvimLocal -Target "$RepoPath\nvim"

# --- Git Config: Copy File (bypasses Symlink restriction) ---
# We copy the file because file-symlinks need Admin. 
Copy-Item "$RepoPath\git\.gitconfig" "$HOME\.gitconfig" -Force

Write-Host "--- Setup Complete! ---" -ForegroundColor Green
Write-Host "Run 'nvim' to start coding." 