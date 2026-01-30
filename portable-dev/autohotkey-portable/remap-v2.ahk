#SingleInstance force
ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
ProcessSetPriority "H"
SetWinDelay -1
SetControlDelay -1

; Include VD.ah2 library
#Include %A_ScriptDir%\VD.ah2

; Configure VD
VD.animation_on:=false
VD.createUntil(5)

; Desktop switch: Win + 1-9
#1::GoToDesktop(1)
#2::GoToDesktop(2)
#3::GoToDesktop(3)
#4::GoToDesktop(4)
#5::GoToDesktop(5)
#6::GoToDesktop(6)
#7::GoToDesktop(7)
#8::GoToDesktop(8)
#9::GoToDesktop(9)

GoToDesktop(num) {
    try {
        VD.goToDesktopNum(num)
    } catch {
        ; Fallback: use Windows default
        Send "#{Tab}"
    }
}

; Desktop nav
#[::VD.goToRelativeDesktopNum(-1)
#]::VD.goToRelativeDesktopNum(1)

; Move window + follow: Win + Shift + 1-9
#+1::MoveWindowToDesktop(1, true)
#+2::MoveWindowToDesktop(2, true)
#+3::MoveWindowToDesktop(3, true)
#+4::MoveWindowToDesktop(4, true)
#+5::MoveWindowToDesktop(5, true)
#+6::MoveWindowToDesktop(6, true)
#+7::MoveWindowToDesktop(7, true)
#+8::MoveWindowToDesktop(8, true)
#+9::MoveWindowToDesktop(9, true)

MoveWindowToDesktop(num, follow := false) {
    try {
        if (follow) {
            VD.MoveWindowToDesktopNum("A", num).follow()
        } else {
            VD.MoveWindowToDesktopNum("A", num)
        }
    } catch {
        ; Fallback
        Send "#{Tab}"
    }
}

; Move window - stay: Win + Alt + 1-9
#!1::MoveWindowToDesktop(1, false)
#!2::MoveWindowToDesktop(2, false)
#!3::MoveWindowToDesktop(3, false)
#!4::MoveWindowToDesktop(4, false)
#!5::MoveWindowToDesktop(5, false)
#!6::MoveWindowToDesktop(6, false)
#!7::MoveWindowToDesktop(7, false)
#!8::MoveWindowToDesktop(8, false)
#!9::MoveWindowToDesktop(9, false)

; Pin window: Win + Shift + P
#+p::VD.TogglePinWindow("A")

; Remaps
CapsLock::Esc
RWin::LCtrl
