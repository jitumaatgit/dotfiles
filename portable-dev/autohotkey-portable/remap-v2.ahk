; AutoHotkey v2 remap script for productivity
CapsLock::Esc
RWin::LCtrl

; Remap Win + (1...9) to Alt + (1...9)
; for WindowsVirtualDesktopHelper to change desktops
Loop 9 {
    n := A_Index
    fDown := KeyDown.Bind(n)
    fUp   := KeyUp.Bind(n)
    Hotkey("#" . n, fDown)
    Hotkey("#" . n . " Up", fUp)
}

KeyDown(n, *) {
    Send("{Alt down}")
    Send("{" n " down}")
}

KeyUp(n, *) {
    Send("{Alt up}")
    Send("{" n " up}")
}

; Windows desktop cycling - Win+[ for previous, Win+] for next
#[::Send("^#{Left}")
#]::Send("^#{Right}")

