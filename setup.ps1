<#
Non-Admin portable-dev bootstrapper (save as setup.ps1)
- BaseDir: C:\Users\student\portable-dev
- Non-admin only (no winget, no admin elevation)
- Scoop (per-user) for neovim + node + ripgrep + fd + fzf + lazygit
- Portable WezTerm downloaded from GitHub releases
- Portable Zen Browser downloaded from releases or official download page
- Portable MSYS2 from MSYS2 archives (extracted, not Windows-installer)
- Idempotent and verbose
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------- Configuration ----------
$BaseDir      = 'C:\Users\student\portable-dev'
$MsysDir      = Join-Path $BaseDir "msys2\msys64"   # user-corrected line (keep)
$DownloadsDir = Join-Path $BaseDir 'downloads'
$WezDir       = Join-Path $BaseDir 'wezterm'
$ZenDir       = Join-Path $BaseDir 'zen-browser'
$DotfilesDir  = Join-Path $BaseDir 'dotfiles'
$FontsDir     = Join-Path $BaseDir 'fonts'
$LogsDir      = Join-Path $BaseDir 'logs'
$ScoopRoot    = Join-Path $env:USERPROFILE 'scoop'  # per-user scoop location

# ---------- Create required directories (idempotent) ----------
$paths = @($BaseDir, $DownloadsDir, $WezDir, $ZenDir, $DotfilesDir, $FontsDir, $LogsDir)
foreach ($p in $paths) {
    if (-not (Test-Path $p)) {
        Write-Host "Creating: $p"
        New-Item -ItemType Directory -Path $p | Out-Null
    }
}

$LogFile = Join-Path $LogsDir ("setup-{0:yyyyMMdd-HHmmss}.log" -f (Get-Date))
Start-Transcript -Path $LogFile -Force

function Write-Info($s) { Write-Host "[INFO] $s" -ForegroundColor Cyan }
function Write-Warn($s) { Write-Warning "[WARN] $s" }
function Write-Err($s)  { Write-Host "[ERR]  $s" -ForegroundColor Red }

# ---------- Helper utilities ----------
function Download-File([string]$Url, [string]$OutPath) {
    if (Test-Path $OutPath) {
        Write-Info "Download already exists: $OutPath"
        return $OutPath
    }
    Write-Info "Downloading: $Url -> $OutPath"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutPath -UseBasicParsing -ErrorAction Stop
        return $OutPath
    } catch {
        Write-Warn "Download failed: $($_.Exception.Message)"
        return $null
    }
}

function Extract-Zip([string]$ZipPath, [string]$Dest) {
    if (-not (Test-Path $ZipPath)) { throw "Zip not found: $ZipPath" }
    if (-not (Test-Path $Dest)) { New-Item -ItemType Directory -Path $Dest | Out-Null }
    # Prefer 7z if present (faster / more robust). No admin required to run 7z.exe if it's installed.
    $seven = (Get-Command 7z.exe -ErrorAction SilentlyContinue)
    if ($seven) {
        Write-Info "Extracting $ZipPath -> $Dest using 7z"
        & 7z.exe x $ZipPath "-o$Dest" -y | Out-Null
    } else {
        Write-Info "Extracting $ZipPath -> $Dest using Expand-Archive"
        try {
            Expand-Archive -Path $ZipPath -DestinationPath $Dest -Force
        } catch {
            throw "Extraction failed (Expand-Archive). Install 7-Zip or extract manually. Error: $($_.Exception.Message)"
        }
    }
}

# ---------- Install Scoop (per-user, non-admin) ----------
function Ensure-Scoop {
    $scoopShim = Join-Path $ScoopRoot 'shims\scoop.ps1'
    if (Test-Path $scoopShim) {
        Write-Info "Scoop already installed (per-user) at $ScoopRoot"
        return
    }

    Write-Info "Installing Scoop (per-user)..."
    try {
        # Per-user install; doesn't need admin
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue
        # The official bootstrap command is: iwr -useb get.scoop.sh | iex
        # We'll try that but catch and fallback to git-clone if network blocks script execution.
        Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://get.scoop.sh'))
        Write-Info "Scoop bootstrap attempted."
    } catch {
        Write-Warn "Automatic scoop bootstrap failed. Attempting git clone fallback."
        try {
            if (-not (Test-Path $ScoopRoot)) { New-Item -ItemType Directory -Path $ScoopRoot | Out-Null }
            git clone https://github.com/scoopinstaller/scoop $ScoopRoot 2>$null
            if (-not (Test-Path (Join-Path $ScoopRoot 'shims\scoop.ps1'))) {
                throw "scoop git-clone fallback did not produce shims; please install Scoop manually (per-user) and re-run script."
            }
            Write-Info "Scoop installed via git fallback."
        } catch {
            throw "Scoop installation failed. Please install Scoop per-user and re-run script. Error: $($_.Exception.Message)"
        }
    }

    # Ensure common buckets exist (no admin)
    $scoopExe = Join-Path $ScoopRoot 'shims\scoop.ps1'
    if (Test-Path $scoopExe) {
        & $scoopExe bucket add extras 2>$null | Out-Null
        & $scoopExe bucket add versions 2>$null | Out-Null
    } else {
        Write-Warn "Scoop shim not found at $scoopExe even after install. You may need to restart PowerShell session."
    }
}

# ---------- Install user-space packages via Scoop ----------
function Ensure-Scoop-Packages {
    $scoopShim = Join-Path $ScoopRoot 'shims\scoop.ps1'
    if (-not (Test-Path $scoopShim)) {
        Write-Warn "Scoop shim missing; cannot install packages via scoop."
        return
    }

    $packages = @('neovim','nodejs-lts','ripgrep','fd','fzf','lazygit')
    foreach ($pkg in $packages) {
        Write-Info "Ensuring scoop package: $pkg"
        try {
            & $scoopShim install $pkg --no-progress 2>$null
        } catch {
            Write-Warn "scoop install $pkg failed or $pkg not available in your buckets. Continuing."
        }
    }
    Write-Info "Scoop package installation step finished (non-fatal failures allowed)."
}

# ---------- Install portable WezTerm (non-admin) ----------
function Install-WezTerm-Portable {
    Write-Info "Installing WezTerm (portable) into $WezDir"

    # Use GitHub releases API to find a portable Windows asset
    $apiUrl = 'https://api.github.com/repos/wez/wezterm/releases/latest'
    try {
        $rel = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Warn "Could not query GitHub API for WezTerm. Falling back to common fallback filename."
        $rel = $null
    }

    $assetUrl = $null
    if ($rel -ne $null -and $rel.assets) {
        foreach ($a in $rel.assets) {
            $n = $a.name.ToLower()
            if ($n -match 'portable' -and ($n -match 'windows' -or $n -match 'win')) {
                $assetUrl = $a.browser_download_url
                break
            }
        }
        if (-not $assetUrl) {
            # try any windows zip
            foreach ($a in $rel.assets) {
                if ($a.name.ToLower() -match 'windows' -and $a.browser_download_url) { $assetUrl = $a.browser_download_url; break }
            }
        }
    }

    if (-not $assetUrl) {
        # fallback common URL (may or may not exist depending on release scheme)
        $assetUrl = 'https://github.com/wez/wezterm/releases/latest/download/WezTerm-windows-portable.zip'
        Write-Warn "Could not find portable asset via API; using fallback URL: $assetUrl"
    } else {
        Write-Info "Selected WezTerm asset: $assetUrl"
    }

    $zipPath = Join-Path $DownloadsDir 'wezterm-portable.zip'
    $dl = Download-File -Url $assetUrl -OutPath $zipPath
    if (-not $dl) { Write-Warn "WezTerm download failed; skip WezTerm install."; return }

    # Extract to WezDir
    try {
        Extract-Zip -ZipPath $zipPath -Dest $WezDir
        Write-Info "WezTerm extracted to $WezDir"
    } catch {
        Write-Warn "WezTerm extraction failed: $($_.Exception.Message)"
    }
}

# ---------- Install portable Zen Browser (non-admin) ----------
function Install-ZenBrowser-Portable {
    Write-Info "Installing Zen Browser (portable) into $ZenDir"

    # Try GitHub releases first (zen-browser/desktop). Fallback to the official download page.
    $apiUrl = 'https://api.github.com/repos/zen-browser/desktop/releases/latest'
    $assetUrl = $null
    try {
        $rel = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing -ErrorAction Stop
        foreach ($a in $rel.assets) {
            $n = $a.name.ToLower()
            if ($n -match 'portable' -and ($n -match 'windows' -or $n -match 'win')) {
                $assetUrl = $a.browser_download_url; break
            }
            if ($n -match 'win' -and ($n -match '.zip' -or $n -match '.7z')) { $assetUrl = $a.browser_download_url; break }
        }
    } catch {
        Write-Warn "Could not query Zen GitHub releases; will try official download page."
        $rel = $null
    }

    if (-not $assetUrl) {
        # Try official download page which often has Windows builds
        $downloadPage = 'https://zen-browser.app/download/'
        try {
            $html = Invoke-WebRequest -Uri $downloadPage -UseBasicParsing -ErrorAction Stop
            # crude parse: look for links to .zip or .7z
            $link = $html.Links | Where-Object { $_.href -and ($_.href -match '\.zip$' -or $_.href -match '\.7z$') } | Select-Object -First 1
            if ($link -and $link.href) { $assetUrl = $link.href }
        } catch {
            Write-Warn "Could not parse Zen download page: $($_.Exception.Message)"
        }
    }

    if (-not $assetUrl) {
        Write-Warn "Could not automatically find a Zen Browser portable asset. You can download a portable zip and place it in $DownloadsDir, or install Zen manually."
        return
    }

    $zipPath = Join-Path $DownloadsDir 'zen-portable.zip'
    $dl = Download-File -Url $assetUrl -OutPath $zipPath
    if (-not $dl) { Write-Warn "Zen Browser download failed; skipping."; return }

    try {
        Extract-Zip -ZipPath $zipPath -Dest $ZenDir
        Write-Info "Zen Browser extracted to $ZenDir"
    } catch {
        Write-Warn "Zen extraction failed: $($_.Exception.Message)"
    }
}

# ---------- Portable MSYS2 (archive) ----------
function Install-MSYS2-Portable {
    Write-Info "Preparing portable MSYS2 under $MsysDir (no admin)."

    if (Test-Path $MsysDir) {
        Write-Info "MSYS2 directory already exists: $MsysDir (skip download/extract)"
        return
    }

    # MSYS2 provides installer and base archives. The archive route allows non-admin extraction.
    # We try to fetch a 64-bit base archive from msys2.org's download links (the filenames/URLs may change).
    # If automatic download fails, the user should manually download an MSYS2 base archive and extract it into $BaseDir\msys2.
    $archiveUrlCandidates = @(
        'https://mirror.msys2.org/msys2-base-x86_64.tar.xz',
        'https://repo.msys2.org/distrib/x86_64/msys2-base-x86_64.tar.xz',
        'https://repo.msys2.org/distrib/x86_64/msys2-base-x86_64.7z'
    )

    $found = $false
    foreach ($u in $archiveUrlCandidates) {
        $dest = Join-Path $DownloadsDir ([IO.Path]::GetFileName($u))
        Write-Info "Trying MSYS2 archive: $u"
        $dl = Download-File -Url $u -OutPath $dest
        if ($dl) {
            # attempt extract - 7z preferred for tar.xz or .7z content
            try {
                if (Get-Command 7z.exe -ErrorAction SilentlyContinue) {
                    Write-Info "Extracting MSYS2 archive using 7z"
                    New-Item -ItemType Directory -Path (Split-Path $MsysDir -Parent) -Force | Out-Null
                    & 7z.exe x $dest "-o$(Split-Path $MsysDir -Parent)" -y | Out-Null
                    $found = $true; break
                } else {
                    Write-Info "No 7z found. Attempting Expand-Archive only for .zip; tar.xz requires 7z or external tools. Skipping."
                    # Can't reliably extract tar.xz without 7z; continue trying other URLs
                }
            } catch {
                Write-Warn "Extract attempt failed for $dest: $($_.Exception.Message)"
            }
        }
    }

    if (-not $found) {
        Write-Warn "Automatic MSYS2 base archive download/extract did not succeed. Visit https://www.msys2.org/ to download a base archive manually and extract it into $BaseDir\msys2 (no admin required)."
        return
    }

    Write-Info "MSYS2 archive extracted. You can now run the MSYS2 shell executables from $MsysDir (e.g. msys2_shell.cmd -defterm -here -msystem UCRT64)."
    Write-Info "Next step (recommended): open the ucrt64 shell and run pacman -Syuu to fully update packages (no admin required for user-local msys2)."
}

# ---------- Add lightweight session PATH shims (non-persistent) ----------
function Add-Session-Paths {
    # Add scoop shims for current session if present
    $scoopShims = Join-Path $ScoopRoot 'shims'
    if (Test-Path $scoopShims -and -not ($env:PATH -split ';' | Where-Object { $_ -eq $scoopShims })) {
        $env:PATH = "$scoopShims;$env:PATH"
        Write-Info "Added scoop shims to PATH for this session: $scoopShims"
    }

    # Add WezTerm exe dir (session only)
    $wezExe = Get-ChildItem -Path $WezDir -Recurse -Filter 'wezterm.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($wezExe) {
        $wezDirOnly = $wezExe.DirectoryName
        if (-not ($env:PATH -split ';' | Where-Object { $_ -eq $wezDirOnly })) {
            $env:PATH = "$wezDirOnly;$env:PATH"
            Write-Info "Added WezTerm to PATH for this session: $wezDirOnly"
        }
    }

    # Add Zen launcher dir (session only)
    $zenExe = Get-ChildItem -Path $ZenDir -Recurse -Include '*.exe','*.bat' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($zenExe) {
        $zenDirOnly = $zenExe.DirectoryName
        if (-not ($env:PATH -split ';' | Where-Object { $_ -eq $zenDirOnly })) {
            $env:PATH = "$zenDirOnly;$env:PATH"
            Write-Info "Added Zen Browser dir to PATH for this session: $zenDirOnly"
        }
    }
}

# ---------- Main flow ----------
Write-Host "===== portable-dev non-admin bootstrap started ====="

try {
    Ensure-Scoop
    Ensure-Scoop-Packages

    Install-MSYS2-Portable

    Install-WezTerm-Portable

    Install-ZenBrowser-Portable

    Add-Session-Paths

    Write-Host "===== bootstrap finished (non-admin mode) ====="
    Write-Host "Summary (locations):"
    Write-Host "  BaseDir:    $BaseDir"
    Write-Host "  MSYS2 dir:  $MsysDir"
    Write-Host "  WezTerm dir:$WezDir"
    Write-Host "  Zen dir:    $ZenDir"
    Write-Host "  Scoop root: $ScoopRoot (per-user)"
    Write-Host ""
    Write-Host "Notes:"
    Write-Host "  - No admin operations were performed."
    Write-Host "  - For MSYS2: after extraction you should open the UCRT64 shell and run pacman -Syuu inside MSYS2 to finish updates (no admin needed for a user-local msys2)."
    Write-Host "  - If any automatic downloads failed, check $DownloadsDir and extract the files manually into the appropriate folder."
} catch {
    Write-Err "Bootstrap failed: $($_.Exception.Message)"
    Write-Err "Check $LogFile for full transcript and errors."
    throw
} finally {
    Stop-Transcript
    Write-Host "Log saved to: $LogFile"
}
