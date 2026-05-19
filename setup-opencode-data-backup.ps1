# --- OpenCode Data Backup (Persistent storage) ---
Write-Host "[INFO] Checking OpenCode data backup setup..."

$backupRepo = "$env:USERPROFILE\notes\opencode-data"
$opencodeShare = "$env:USERPROFILE\.local\share\opencode"
$needsSetup = $false

# Check if backup repo exists
if (-not (Test-Path $backupRepo)) {
    Write-Host "[INFO] OpenCode data backup not configured. Setting up..."
    $needsSetup = $true
} else {
    # Check if junctions exist and are valid
    $junctionsValid = $true
    @("storage\session", "storage\message", "storage\project", "storage\session_diff", "snapshot") | ForEach-Object {
        $junctionPath = Join-Path $opencodeShare $_
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
    Write-Host "[INFO] Running OpenCode data backup setup..."

    # Create directory structure in backup repo if needed
    if (-not (Test-Path "$backupRepo\share\storage")) {
        New-Item -ItemType Directory -Force -Path "$backupRepo\share\storage" | Out-Null
        Write-Host "[INFO] Created directory structure in notes repo" -ForegroundColor Cyan
    }

    # Create parent directories if they don't exist
    New-Item -ItemType Directory -Force -Path "$opencodeShare\storage" | Out-Null
    New-Item -ItemType Directory -Force -Path "$backupRepo\share" | Out-Null

    # Create junctions
    $junctions = @{
        "storage\session" = "$backupRepo\share\storage\session"
        "storage\message" = "$backupRepo\share\storage\message"
        "storage\project" = "$backupRepo\share\storage\project"
        "storage\session_diff" = "$backupRepo\share\storage\session_diff"
        "snapshot" = "$backupRepo\share\snapshot"
    }

    foreach ($junction in $junctions.GetEnumerator()) {
        $junctionPath = Join-Path $opencodeShare $junction.Key
        $targetPath = $junction.Value

        # Remove existing if not a valid junction
        if (Test-Path $junctionPath) {
            Remove-Item $junctionPath -Force -Recurse
        }

        # Create junction
        Write-Host "[INFO] Creating junction: $($junction.Key)" -ForegroundColor Cyan
        New-Item -ItemType Junction -Path $junctionPath -Target $targetPath | Out-Null
    }

    Write-Host "[OK] OpenCode data backup configured" -ForegroundColor Green
} else {
    Write-Host "[OK] OpenCode data backup already configured"
}
