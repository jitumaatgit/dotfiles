# Install SQLite for Neovim (yanky.nvim / sqlite.lua)
# This script installs SQLite via Scoop and configures Neovim to use the DLL

Write-Host "[INFO] Installing SQLite for Neovim..."

# --- Install SQLite via Scoop ---
Write-Host "[INFO] Checking if SQLite is already installed..."
if (-not (Get-Command sqlite3 -ErrorAction SilentlyContinue)) {
    Write-Host "[INFO] Installing SQLite via Scoop..."
    scoop install sqlite
} else {
    Write-Host "[OK] SQLite already installed"
}

# --- Determine SQLite DLL path ---
$sqliteDllPath = "$env:USERPROFILE\scoop\apps\sqlite\current\sqlite3.dll"
Write-Host "[INFO] SQLite DLL path: $sqliteDllPath"

# --- Verify DLL exists ---
if (-not (Test-Path $sqliteDllPath)) {
    Write-Host "[ERROR] SQLite DLL not found at $sqliteDllPath"
    throw "SQLite DLL installation failed"
}
Write-Host "[OK] SQLite DLL found"

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
