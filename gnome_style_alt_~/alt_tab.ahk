!Tab::
; this makes each thread interruptible but higher priority than the other thread, causing buffered commands to be discarded
Thread, Priority, 10
Thread, Interrupt, 0
SetWinDelay, 10
DetectHiddenWindows, Off
; This will be the GUI name
CurrInd := 0
Direction := 1
ProcArray := []         ; FYI this is an object array (as opposed to pseudo-arrays which don't need to be initialized in advance)
GoSub Switch
Send  {Esc}
Thread, Priority, 0
Thread, Interrupt, 15, 1000
exit

!+Tab::
; this makes each thread interruptible but higher priority than the other thread, causing buffered commands to be discarded
Thread, Priority, 10
Thread, Interrupt, 0
SetWinDelay, 10
DetectHiddenWindows, Off
; This will be the GUI name
CurrInd := 0
Direction := 0
ProcArray := []
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

; Index first windows of each unique process
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
    ; MsgBox % "testing current proc index " . A_Index . ", active proc name is " . ActiveProc ", curr proc name is " . CurrProc
    ; check if we've hit a different process, and check if we've hit that process before
    If (CurrProc != ActiveProc) and !(HasVal(ProcArray, CurrProc))
    {
        ; store previous proc name and most recent window id in array
        CurrInd += 1
        CurrProcArray%CurrInd% := ActiveWinID
        ProcArray[CurrInd] := ActiveProc

        ; MsgBox % "stored current proc index " . CurrInd . ", proc id is " . CurrProcArray%CurrInd% . ", proc name is " . ProcArray[CurrInd]

        ; get new activeproc
        ActiveWinID := id
        ; MsgBox active window id is %ActiveWinID%
        WinGetTitle ActiveWinTitle, ahk_id %ActiveWinID%
        ; MsgBox active window title is %ActiveWinTitle%
        WinGetClass ActiveClass, ahk_id %ActiveWinID%
        ; MsgBox active class title is %ActiveClass%
        WinGet, ActiveProc, ProcessName, ahk_id %ActiveWinID%
        ; MsgBox active executable is %ActiveProc%
    }
}

; store previous proc name and most recent window id in array
CurrInd += 1
CurrProcArray%CurrInd% := ActiveWinID

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
            if GetKeyState("Tab", "P")
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
            if GetKeyState("Tab", "P")
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


; Source: https://www.autohotkey.com/boards/viewtopic.php?p=109173#p109173
HasVal(haystack, needle) {
	for index, value in haystack
		if (value = needle)
			return index
	if !IsObject(haystack)
		throw Exception("Bad haystack!", -1, haystack)
	return 0
}
