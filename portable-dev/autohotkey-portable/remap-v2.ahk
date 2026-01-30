#SingleInstance force
ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
ProcessSetPriority "H"
SetWinDelay -1
SetControlDelay -1

#Include %A_ScriptDir%\VD.ah2

VD.animation_on:=false
VD.createUntil(5)

; Desktop switch
Loop 9 { hotkey "#" A_Index, ((i) => VD.goToDesktopNum(i)).Bind(A_Index) }

; Desktop nav
#[::VD.goToRelativeDesktopNum(-1)
#]::VD.goToRelativeDesktopNum(1)

; Move window + follow
Loop 9 { hotkey "#+" A_Index, ((i) => VD.MoveWindowToDesktopNum("A",i).follow()).Bind(A_Index) }

; Move window - stay
Loop 9 { hotkey "#!" A_Index, ((i) => VD.MoveWindowToDesktopNum("A",i)).Bind(A_Index) }

; Pin window
#+p::VD.TogglePinWindow("A")

; Remaps
CapsLock::Esc
RWin::LCtrl
