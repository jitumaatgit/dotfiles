# Setup zen-browser data backup (git repo + junction)
# This script creates a private git repo and junctions the zen-browser profile for persistent storage

Write-Host "[INFO] Setting up zen-browser data backup..."

# --- Define paths and config ---
$repoName = "jitumaatgit/zen-browser-data"
$backupRepo = "$env:USERPROFILE\zen-browser-data"
$zenProfileBase = "$env:APPDATA\zen\Profiles"
$zenProfileDir = $null

# --- Check gh CLI is available ---
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] gh CLI not found. Please install gh first."
    throw "gh CLI required"
}

# --- Detect zen-browser profile ---
if (-not (Test-Path $zenProfileBase)) {
    Write-Host "[ERROR] Zen-browser profile directory not found."
    Write-Host "[INFO] Please launch zen-browser first to create a profile."
    throw "Zen-browser profile not found"
}

# Find default profile directory (pattern: *.Default (release))
$zenProfileDir = Get-ChildItem $zenProfileBase | 
    Where-Object { $_.Name -match '\.Default \(release\)' } | 
    Select-Object -First 1

if (-not $zenProfileDir) {
    Write-Host "[ERROR] Could not find zen-browser default profile."
    Write-Host "[INFO] Please launch zen-browser first to create a profile."
    throw "Default profile not found"
}

Write-Host "[INFO] Found zen-browser profile: $($zenProfileDir.FullName)"

# --- Create or clone private git repo ---
if (-not (Test-Path "$backupRepo\.git")) {
    # Check if remote repo already exists
    $repoExists = $false
    try {
        $repoExists = gh repo view $repoName --json name --jq '.name' 2>$null
        if ($repoExists) {
            Write-Host "[INFO] Remote repo exists: $repoName"
        }
    } catch {
        Write-Host "[INFO] Remote repo does not exist, will create: $repoName"
    }

    if ($repoExists) {
        # Clone existing private repo
        Write-Host "[INFO] Cloning existing private repo..."
        git clone "https://github.com/$repoName" $backupRepo
        if (-not (Test-Path "$backupRepo\.git")) {
            Write-Host "[ERROR] Failed to clone repo"
            throw "Git clone failed"
        }
    } else {
        # Create new private repo and clone it
        Write-Host "[INFO] Creating new private repo: $repoName"
        gh repo create $repoName --private --description "Zen-browser persistent data for ephemeral laptops"
        
        # Clone the newly created repo
        git clone "https://github.com/$repoName" $backupRepo
        if (-not (Test-Path "$backupRepo\.git")) {
            Write-Host "[ERROR] Failed to clone newly created repo"
            throw "Git clone failed"
        }
    }
    Write-Host "[OK] Repository cloned successfully"
} else {
    Write-Host "[OK] Repository already exists locally"
}

# --- Create profile junction ---
$profileJunctionName = $zenProfileDir.Name
$profileJunctionPath = Join-Path $backupRepo $profileJunctionName

Write-Host "[INFO] Setting up profile junction..."

# Remove existing junction or directory if it exists
if (Test-Path $profileJunctionPath) {
    $item = Get-Item $profileJunctionPath
    if ($item.LinkType -eq "Junction") {
        Write-Host "[INFO] Removing existing junction: $profileJunctionName"
        cmd /c "rmdir /q `"$profileJunctionPath`"" 2>$null
    } else {
        Write-Host "[WARN] Path exists as directory (not junction), removing..."
        Remove-Item $profileJunctionPath -Recurse -Force
    }
}

# Create junction from git repo to profile directory
Write-Host "[INFO] Creating junction: $profileJunctionName -> $($zenProfileDir.FullName)"
cmd /c "mklink /J `"$profileJunctionPath`" `"$($zenProfileDir.FullName)`"" | Out-Null

# Verify junction
if (Test-Path $profileJunctionPath) {
    $junctionInfo = Get-Item $profileJunctionPath | Select-Object LinkType
    if ($junctionInfo.LinkType -eq "Junction") {
        Write-Host "[OK] Junction created successfully"
    } else {
        Write-Host "[ERROR] Failed to create junction (not a junction type)"
        throw "Junction creation failed"
    }
} else {
    Write-Host "[ERROR] Junction path does not exist"
    throw "Junction creation failed"
}

# --- Create .gitignore ---
$gitignorePath = Join-Path $backupRepo ".gitignore"
$gitignoreContent = @'
# Zen-browser cache and temporary files
*.sqlite-wal
*.sqlite-shm
cache2/
startupCache/
thumbnails/
safebrowsing/
activity-stream.streams/
startupCache/
sessionCheckpoints.jsonlz4
telemetry/
crashes/
datareporting/
pingsender.log

# Profile-specific metadata (exclude)
.lock
parent.lock

# OS-specific
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
'@

if (-not (Test-Path $gitignorePath)) {
    $gitignoreContent | Out-File $gitignorePath -Encoding UTF8 -Force
    Write-Host "[OK] Created .gitignore"
} else {
    Write-Host "[OK] .gitignore already exists"
}

# --- Create README.md ---
$readmePath = Join-Path $backupRepo "README.md"
$readmeContent = @'
# Zen-Browser Persistent Data

Private repository for zen-browser settings and data across ephemeral laptops.

## Purpose

This repository provides persistent storage for zen-browser profile data using junctions.
The profile directory is junctioned into this git repository for version control.

## Profile Location

Current profile: `*.Default (release)/`

## What Gets Backed Up

### Automatically (via junction)
- **All browser data**: bookmarks, history, passwords, preferences
- **Extensions**: installed extensions and their settings
- **Themes**: zen-browser themes and customizations
- **Keyboard shortcuts**: custom key bindings
- **Sessions**: browser session backups
- **User chrome**: custom CSS styles in `chrome/` directory

### What Gets Filtered Out (via .gitignore)
- Cache files and temporary data
- SQLite WAL files (`*.sqlite-wal`, `*.sqlite-shm`)
- Telemetry and crash data
- Thumbnail cache
- Safe browsing databases

## Usage

### Initial Setup

After running `setup-zen-data-backup.ps1`, sync your changes:

```powershell
cd $env:USERPROFILE\zen-browser-data
git add .
git commit -m "Initial zen-browser data backup"
git push
```

### Daily Sync

After making changes in zen-browser:

```powershell
cd $env:USERPROFILE\zen-browser-data
git status              # Check what changed
git add .
git commit -m "Update browser data"
git push
```

### Restore on New Machine

1. Run `setup.ps1` which will call `setup-zen-data-backup.ps1`
2. The profile junction will be created automatically
3. Launch zen-browser - it will use the junctioned data

## Notes

- Profile directory name includes profile ID which may differ between machines
- Junctions are created dynamically based on actual profile directory name
- Repository is private to protect sensitive data (passwords, browsing history)
- Large databases are included by default but can be excluded via .gitignore

## Profile Structure

The junctioned profile contains:

```
*.Default (release)/
├── chrome/                  # Custom CSS
├── extensions/              # Installed extensions
├── bookmarkbackups/         # Bookmark backups
├── sessionstore-backups/    # Session backups
├── zen-sessions-backup/    # Zen-specific sessions
├── prefs.js                # User preferences
├── places.sqlite           # Bookmarks & history
├── logins.json             # Saved passwords
├── key4.db                 # Password encryption keys
├── zen-themes.json         # Theme data
├── zen-keyboard-shortcuts.json  # Custom shortcuts
└── ...                     # Other browser data
```
'@

if (-not (Test-Path $readmePath)) {
    $readmeContent | Out-File $readmePath -Encoding UTF8 -Force
    Write-Host "[OK] Created README.md"
} else {
    Write-Host "[OK] README.md already exists"
}

# --- Display git status ---
Write-Host "[INFO] Git repository status:"
Push-Location $backupRepo
git status --short
Pop-Location

# --- Summary ---
Write-Host ""
Write-Host "============================================================"
Write-Host "[OK] zen-browser data backup setup complete"
Write-Host "============================================================"
Write-Host ""
Write-Host "Git repository: $backupRepo"
Write-Host "Junction target: $profileJunctionPath"
Write-Host "Profile source: $($zenProfileDir.FullName)"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  cd ~/zen-browser-data"
Write-Host "  git status"
Write-Host "  git add ."
Write-Host "  git commit -m 'Initial backup'"
Write-Host "  git push"
Write-Host ""
