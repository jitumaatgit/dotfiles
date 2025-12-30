# Setup nvim-data backup (git repo + junctions)
# This script clones the nvim-data git repo and creates junctions for persistent storage

Write-Host "[INFO] Setting up nvim-data backup..."

# --- Define paths ---
$backupRepo = "$env:USERPROFILE\nvim-data-remote"
$nvimData = "$env:LOCALAPPDATA\nvim-data"
$remoteUrl = "https://github.com/jitumaatgit/nvim-data-remote"
$junctionDirs = @("databases", "shada", "sessions", "undo")

# --- Clone or verify git repo ---
if (-not (Test-Path "$backupRepo\.git")) {
    Write-Host "[INFO] Cloning nvim-data repo from $remoteUrl..."
    git clone $remoteUrl $backupRepo
    if (-not (Test-Path "$backupRepo\.git")) {
        Write-Host "[ERROR] Failed to clone nvim-data repo"
        throw "Git clone failed"
    }
    Write-Host "[OK] nvim-data repo cloned successfully"
} else {
    Write-Host "[OK] nvim-data repo already exists"
}

# --- Create nvim-data directory ---
if (-not (Test-Path $nvimData)) {
    Write-Host "[INFO] Creating nvim-data directory: $nvimData"
    New-Item -ItemType Directory -Force -Path $nvimData | Out-Null
    Write-Host "[OK] nvim-data directory created"
} else {
    Write-Host "[OK] nvim-data directory already exists"
}

# --- Create junctions ---
Write-Host "[INFO] Creating junctions..."

foreach ($dir in $junctionDirs) {
    $junctionPath = Join-Path $nvimData $dir
    $targetPath = Join-Path $backupRepo $dir

    # Remove existing junction or directory if it exists
    if (Test-Path $junctionPath) {
        $item = Get-Item $junctionPath
        if ($item.LinkType -eq "Junction") {
            Write-Host "[INFO] Removing existing junction: $dir"
            cmd /c "rmdir /q `"$junctionPath`"" 2>$null
        } else {
            Write-Host "[WARN] $dir exists as a directory (not a junction), removing..."
            Remove-Item $junctionPath -Recurse -Force
        }
    }

    # Ensure target directory exists in the git repo
    if (-not (Test-Path $targetPath)) {
        Write-Host "[INFO] Creating target directory in repo: $dir"
        New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
    }

    # Create junction
    Write-Host "[INFO] Creating junction: $dir -> $targetPath"
    cmd /c "mklink /J `"$junctionPath`" `"$targetPath`"" | Out-Null

    if (Test-Path $junctionPath) {
        $junctionInfo = Get-Item $junctionPath | Select-Object LinkType
        if ($junctionInfo.LinkType -eq "Junction") {
            Write-Host "[OK] Junction created: $dir"
        } else {
            Write-Host "[ERROR] Failed to create junction: $dir"
            throw "Junction creation failed"
        }
    } else {
        Write-Host "[ERROR] Junction path does not exist: $dir"
        throw "Junction creation failed"
    }
}

# --- Verify setup ---
Write-Host "[INFO] Verifying setup..."
$setupValid = $true

foreach ($dir in $junctionDirs) {
    $junctionPath = Join-Path $nvimData $dir
    if (-not (Test-Path $junctionPath)) {
        Write-Host "[ERROR] Junction missing: $dir"
        $setupValid = $false
    } else {
        $junctionInfo = Get-Item $junctionPath | Select-Object LinkType
        if ($junctionInfo.LinkType -ne "Junction") {
            Write-Host "[ERROR] Invalid junction type: $dir"
            $setupValid = $false
        }
    }
}

if ($setupValid) {
    Write-Host "[OK] All junctions verified successfully"
} else {
    Write-Host "[ERROR] Junction verification failed"
    throw "Setup verification failed"
}

# --- Display git status ---
Write-Host "[INFO] Git repository status:"
Push-Location $backupRepo
git status --short
Pop-Location

Write-Host "[OK] nvim-data backup setup complete"
Write-Host ""
Write-Host "Summary:"
Write-Host "  Git repo: $backupRepo"
Write-Host "  Local data: $nvimData"
Write-Host "  Junctions: $($junctionDirs -join ', ')"
Write-Host ""
Write-Host "To sync changes:"
Write-Host "  cd ~/nvim-data-remote"
Write-Host "  git add ."
Write-Host "  git commit -m 'Update nvim data'"
Write-Host "  git push"
