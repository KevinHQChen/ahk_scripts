; AHK resources
; Threads: https://www.autohotkey.com/docs/misc/Threads.htm
; Variables, Expressions, and Operators: https://www.autohotkey.com/docs/Variables.htm
; Object vs Pseudo Arrayrs: https://www.autohotkey.com/docs/misc/Arrays.htm
; Common Key Names: https://www.autohotkey.com/docs/commands/Send.htm
; Even more key names: https://www.autohotkey.com/docs/KeyList.htm

; Based on this script: https://www.autohotkey.com/boards/viewtopic.php?p=331696#p331696
; Runner-up scripts: https://www.autohotkey.com/board/topic/66588-cyclewindow/page-2

!`::
; Critical  ; this was a good idea but it buffers commands indefinitely and executes them immediately after the current thread exits, spamming window switches all over the place
; this makes each thread interruptible but higher priority than the other thread, causing buffered commands to be discarded
Thread, Priority, 10
Thread, Interrupt, 0
SetWinDelay, 10
DetectHiddenWindows, Off
; This will be the GUI name
CurrInd := 0
Direction := 1
GoSub Switch
Send  {Esc}
Thread, Priority, 0
Thread, Interrupt, 15, 1000
exit

!+`::
; Critical  ; this was a good idea but it buffers commands indefinitely and executes them immediately after the current thread exits, spamming window switches all over the place
Thread, Priority, 10
Thread, Interrupt, 0
SetWinDelay, 10
DetectHiddenWindows, Off
; This will be the GUI name
CurrInd := 0
Direction := 0
GoSub Switch
Send  {Esc}
Thread, Priority, 0
Thread, Interrupt, 15, 1000
exit

Switch:
ActiveWinID := WinExist("A")
InitActiveWinID := ActiveWinID
; MsgBox active window id is %ActiveWinID%
WinGetTitle ActiveWinTitle, ahk_id %ActiveWinID%
InitActiveWinTitle := ActiveWinTitle
; MsgBox active window title is %ActiveWinTitle%
WinGetClass ActiveClass, ahk_id %ActiveWinID%
; MsgBox active class title is %ActiveClass%
WinGet, ActiveProc, ProcessName, ahk_id %ActiveWinID%
; MsgBox active executable is %ActiveProc%

; Index all windows running the current process
WinGet, OpenWindow, List
Loop, %OpenWindow%
{
    id := OpenWindow%A_Index%
    ; MsgBox id is %id%
    WinGetTitle Title, ahk_id %id%
    ; MsgBox title is %Title%
    ; MsgBox active proc title is %ActiveWinTitle%
    WinGet, style, style, ahk_id %id%
    WinGet, ClsID, ID, ahk_id %id%
    WinGet, CurrProc, ProcessName, ahk_id %id%
    ; MsgBox current proc is %CurrProc%

    If !(style & 0xC00000) or (title = "")
        continue
    WinGetClass class, ahk_id %id%
    If (class = "ApplicationFrameWindow")
    {
        WinGetText, text, ahk_id %id%
        If (text = "")
        {
            WinGet, style, style, ahk_id %id%
            If !(style = "0xB4CF0000")	 ; the window isn't minimized
                continue
        }
    }
    If (CurrProc != ActiveProc)
        continue

    ; build pseudo-array/list to hold windows of current process
    CurrInd += 1
    CurrProcArray%CurrInd% := id
    currID = % CurrProcArray%CurrInd%
    WinGetTitle ActiveWinTitle, ahk_id %currID%
    ; MsgBox % "at current proc index " . CurrInd . ", proc id is " . CurrProcArray%CurrInd% . ", window name is " . ActiveWinTitle
}

MaxInd := CurrInd

; initial switch (forward/backward)
if (Direction = 1)
{
    CurrInd := 2
    currID = % CurrProcArray%CurrInd%
    WinGetTitle ActiveWinTitle, ahk_id %currID%
    ; MsgBox activating %ActiveWinTitle%
    WinActivate, ahk_id %currID%
}
else
{
    CurrInd := MaxInd
    currID = % CurrProcArray%CurrInd%
    WinGetTitle ActiveWinTitle, ahk_id %currID%
    ; MsgBox activating %ActiveWinTitle%
    WinActivate, ahk_id %currID%
}

InitCurrInd := CurrInd

; subsequent switches (forward/backward)
Loop {
Sleep 150
    if GetKeyState("LAlt")
    {
        if GetKeyState("LShift")
        {
            if GetKeyState("``")
            {
                if (CurrInd > 1)
                    CurrInd -= 1
                else
                    CurrInd := MaxInd
                currID = % CurrProcArray%CurrInd%
                ; MsgBox activating backward switch
                WinActivate, ahk_id %currID%
            }
        }
        else
        {
            if GetKeyState("``")
            {
                if (CurrInd < MaxInd)
                    CurrInd += 1
                else
                    CurrInd := 1
                currID = % CurrProcArray%CurrInd%
                ; MsgBox activating forward switch
                WinActivate, ahk_id %currID%
            }
        }
    }
    else
        break
}

; if no subsequent switching occurred
if (CurrInd = InitCurrInd)
    return
else
{
    ; MsgBox moving %InitActiveWinTitle% to top
    ; WinSet, Top, , ahk_id %InitActiveWinID%
    ; WinSet, AlwaysOnTop, On, ahk_id %InitActiveWinID%
    ; WinSet, AlwaysOnTop, Off, ahk_id %InitActiveWinID%
    WinSet, Transparent, 0, ahk_id %InitActiveWinID%
    WinActivate, ahk_id %InitActiveWinID%

    ; WinGetTitle ActiveWinTitle, ahk_id %currID%
    ; MsgBox activating %ActiveWinTitle%
    WinActivate, ahk_id %currID%
    WinSet, Transparent, Off, ahk_id %InitActiveWinID%
    return
}
