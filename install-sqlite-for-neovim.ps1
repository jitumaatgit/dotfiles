# Install SQLite for Neovim (yanky.nvim / sqlite.lua)
# This script downloads SQLite DLL directly and configures Neovim to use the DLL

Write-Host "[INFO] Installing SQLite for Neovim..."

# --- Detect architecture ---
$arch = $env:PROCESSOR_ARCHITECTURE.ToLower()
if ($arch -eq "arm64") {
    $archName = "arm64"
} elseif ($arch -eq "amd64") {
    $archName = "x64"
} else {
    $archName = "x86"
}
Write-Host "[INFO] Detected architecture: $archName"

# --- Download SQLite DLL ---
$url = "https://www.sqlite.org/2024/sqlite-dll-win-$archName-3510100.zip"
$tempZip = [System.IO.Path]::GetTempFileName() + ".zip"
$tempDir = [System.IO.Path]::GetTempPath() + "sqlite_extract"
Write-Host "[INFO] Downloading SQLite DLL from $url..."
try {
    Invoke-WebRequest -Uri $url -OutFile $tempZip -ErrorAction Stop
    Write-Host "[OK] Download complete"
} catch {
    Write-Host "[ERROR] Failed to download SQLite DLL: $_"
    throw "Download failed"
}

# --- Extract SQLite DLL ---
Write-Host "[INFO] Extracting SQLite DLL..."
try {
    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force -ErrorAction Stop
    Write-Host "[OK] Extraction complete"
} catch {
    Write-Host "[ERROR] Failed to extract SQLite DLL: $_"
    Remove-Item $tempZip -ErrorAction SilentlyContinue
    throw "Extraction failed"
}

# --- Place DLL in local bin ---
$binDir = "$env:LOCALAPPDATA\nvim\bin"
$sqliteDllPath = "$binDir\sqlite3.dll"
New-Item -ItemType Directory -Path $binDir -Force -ErrorAction Stop
Copy-Item "$tempDir\sqlite3.dll" $sqliteDllPath -Force -ErrorAction Stop
Write-Host "[OK] SQLite DLL placed at $sqliteDllPath"

# --- Clean up ---
Remove-Item $tempZip -ErrorAction SilentlyContinue
Remove-Item $tempDir -Recurse -ErrorAction SilentlyContinue

# --- Configure Neovim to use SQLite DLL ---
$nvimOptionsPath = "$env:LOCALAPPDATA\nvim\lua\config\options.lua"

# Check if options.lua exists
if (-not (Test-Path $nvimOptionsPath)) {
    Write-Host "[WARN] Neovim options.lua not found at $nvimOptionsPath"
    throw "Neovim configuration directory not found"
}

# Read existing options.lua
$optionsContent = Get-Content $nvimOptionsPath -Raw

# Convert Windows path to forward slashes for Lua compatibility
$sqliteDllPathLua = $sqliteDllPath -replace "\\", "/"

# Check if sqlite_clib_path is already configured
if ($optionsContent -match "sqlite_clib_path") {
    Write-Host "[WARN] sqlite_clib_path already configured in options.lua"
    Write-Host "[INFO] Updating existing configuration..."
    # Replace existing sqlite_clib_path line
    $optionsContent = $optionsContent -replace "vim\.g\.sqlite_clib_path\s*=\s*`"[^`"]*`"", "vim.g.sqlite_clib_path = `"$sqliteDllPathLua`""
} else {
    Write-Host "[INFO] Adding sqlite_clib_path to options.lua..."
    # Append new configuration
    $optionsContent += "`nvim.g.sqlite_clib_path = `"$sqliteDllPathLua`"`n"
}

# Write updated options.lua
$optionsContent | Set-Content $nvimOptionsPath -Encoding UTF8
Write-Host "[OK] Neovim configured to use SQLite DLL at $sqliteDllPathLua"

Write-Host "[INFO] SQLite installation for Neovim complete"
Write-Host "[INFO] Neovim will use: $sqliteDllPathLua"
