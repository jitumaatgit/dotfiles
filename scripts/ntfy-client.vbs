' Hidden launcher for the ntfy subscribe daemon.
' ntfy is a console app; launching it via HKCU Run would flash a
' console window on login. This VBS runs it with window style 0
' (hidden). Registered in HKCU\...\Run by setup.ps1.
'
' OS-specific mapping: tablet uses `systemctl --user enable ntfy-client`;
' Windows has no per-user service manager, so a hidden process + Run key
' is the closest equivalent.
Set sh = CreateObject("WScript.Shell")
home = sh.ExpandEnvironmentStrings("%USERPROFILE%")
sh.Run """" & home & "\scoop\shims\ntfy.exe"" subscribe --from-config", 0, False