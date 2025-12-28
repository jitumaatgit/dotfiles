; AutoHotkey v2 remap script with VD.ah2 for virtual desktop management
; Source: https://github.com/FuPeiJiang/VD.ahk/tree/v2_port
; Replaces: WindowsVirtualDesktopHelper (removed due to focus issue)
; Note: Using v2_port branch for AutoHotkey v2 compatibility

; Performance headers - required for VD.ah2 (see VD.ah2 README)
; Without these, virtual desktop operations will be slow
#SingleInstance force
ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
#WinActivateForce

ProcessSetPriority "H"

SetWinDelay -1
SetControlDelay -1

; Include VD.ah2 library - provides virtual desktop management for Windows 11
; Must be in same directory as this script
#Include %A_ScriptDir%\VD.ah2

; Disable desktop switching animations for instant navigation
; Set to true to enable smooth but slower transitions
VD.animation_on:=false

; Create up to 5 desktops on startup if they don't exist
; This ensures consistent workspace configuration across reboots
; Note: Doesn't delete extra desktops if more than 5 exist
VD.createUntil(5)

; Desktop switching: Win + (1-9) jumps directly to desktop 1-9
; VD.ah2 automatically focuses first window on destination desktop
; This solves: focus issue present in WindowsVirtualDesktopHelper
#1::VD.goToDesktopNum(1)
#2::VD.goToDesktopNum(2)
#3::VD.goToDesktopNum(3)
#4::VD.goToDesktopNum(4)
#5::VD.goToDesktopNum(5)
#6::VD.goToDesktopNum(6)
#7::VD.goToDesktopNum(7)
#8::VD.goToDesktopNum(8)
#9::VD.goToDesktopNum(9)

; Navigate to previous desktop: Win + [
; Navigate to next desktop: Win + ]
; Wraps around (from desktop 9, goes to desktop 1)
#[::VD.goToRelativeDesktopNum(-1)
#]::VD.goToRelativeDesktopNum(1)

; Move current window to desktop N and follow it: Win + Shift + (1-9)
; "A" refers to active window
; .follow() switches to destination desktop after moving
#+1::VD.MoveWindowToDesktopNum("A",1).follow()
#+2::VD.MoveWindowToDesktopNum("A",2).follow()
#+3::VD.MoveWindowToDesktopNum("A",3).follow()
#+4::VD.MoveWindowToDesktopNum("A",4).follow()
#+5::VD.MoveWindowToDesktopNum("A",5).follow()
#+6::VD.MoveWindowToDesktopNum("A",6).follow()
#+7::VD.MoveWindowToDesktopNum("A",7).follow()
#+8::VD.MoveWindowToDesktopNum("A",8).follow()
#+9::VD.MoveWindowToDesktopNum("A",9).follow()

; Move current window to desktop N without following: Win + Alt + (1-9)
; Window moves to destination but you stay on current desktop
#!1::VD.MoveWindowToDesktopNum("A",1)
#!2::VD.MoveWindowToDesktopNum("A",2)
#!3::VD.MoveWindowToDesktopNum("A",3)
#!4::VD.MoveWindowToDesktopNum("A",4)
#!5::VD.MoveWindowToDesktopNum("A",5)
#!6::VD.MoveWindowToDesktopNum("A",6)
#!7::VD.MoveWindowToDesktopNum("A",7)
#!8::VD.MoveWindowToDesktopNum("A",8)
#!9::VD.MoveWindowToDesktopNum("A",9)

; Toggle pin current window to all desktops: Win + Shift + P
; Pinned windows appear on all virtual desktops
; Pinning is like "Show this window on all desktops" in Windows 11
#+p::VD.TogglePinWindow("A")

; Existing productivity remaps (from original setup)
; CapsLock -> Esc (Vim-friendly)
; Right Win -> Left Ctrl (keyboard ergonomics)
CapsLock::Esc
RWin::LCtrl
