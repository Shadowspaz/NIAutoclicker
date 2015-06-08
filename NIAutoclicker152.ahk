;Non-Intrusive Autoclicker, by Shadowspaz
;v1.5.3

#InstallKeybdHook
DetectHiddenWindows, on
SetControlDelay -1
SetBatchLines -1
Thread, Interrupt, 0
SetFormat, float, 0.0
toggle := false
inputPresent := false
clickRate := 20
Mode := 0
mouseMoved := false
pmx := 0
pmy := 0

TempRateCPS := 50
TempRateSPC := 1

setTimer, checkMouseMovement, 10

setTimer, setTip, 5
TTStart = %A_TickCount%
while (A_TickCount - TTStart < 5000 && !toggle)
{
  TooltipMsg = Press (Alt + Backspace) to toggle autoclicker `n Press (Alt + Dash(-)) for options
}
  TooltipMsg =

!-::
  IfWinNotExist, Change Value
  {
    Gui, Show, w210 h110, Change Value
    Gui, Add, Radio, x25 y10 gActEdit1 vmode, Clicks per second:
    Gui, Add, Radio, x25 y35 gActEdit2, Seconds per click:
    Gui, Add, Edit, x135 y8 w50 Number Left vtempRateCPS, % tempRateCPS
    Gui, Add, Edit, x135 y33 w50 Number Left vtempRateSPC, % tempRateSPC
    Gui, Add, Text, x0 w210 0x10
    Gui, Add, Text, x27 y65, (Default is 50 clicks per second)
    Gui, Add, Button, x92 y82 Default gSetVal, Set
    Gui, Font, s6
    Gui, Add, Text, x188 y101, v1.5.3
    if mode < 2
    {
      GuiControl,, Mode, 1
      GoSub, ActEdit1
    }
    else
    {
      GuiControl,, Seconds per click:, 1
      GoSub, ActEdit2
    }
  }
  else
    WinActivate, Change Value
return

ActEdit1:
  GuiControl, Enable, tempRateCPS
  GuiControl, Disable, tempRateSPC
  GuiControl, Focus, tempRateCPS
  Send +{End}
return

ActEdit2:
  GuiControl, Enable, tempRateSPC
  GuiControl, Disable, tempRateCPS
  GuiControl, Focus, tempRateSPC
  Send +{End}
return

SetVal:
  Gui, Submit
  if mode < 2
    clickRate := tempRateCPS > 0 ? 1000 / tempRateCPS : 1000
  else
    clickRate := tempRateSPC > 0 ? 1000 * tempRateSPC : 1000
GuiClose:
  if toggle
  {
    EmptyMem()
    setTimer, autoclick, %clickRate%
  }
  Gui, Destroy
return

!Backspace::
  IfWinNotExist, Change Value
  {
    toggle := !toggle
    if toggle
    {
      setTimer, setTip, 5
      if (!actWin)
      {
        TooltipMsg = Click the desired autoclick location.
        toggle := false
        Keywait, LButton, D
        Keywait, LButton
        TooltipMsg = 
        MouseGetPos, xp, yp
        WinGet, actWin, ID, A
      }
      else
      {
        setTimer, setTip, 5
        TTStart = %A_TickCount%
        TooltipMsg = ##Autoclick enabled.
      }
      ;msgbox, X: %xp% Y: %yp% `n %actWin%
      toggle := true
      EmptyMem()
      setTimer, autoclick, %clickRate%
    }
    else
    {
      setTimer, setTip, 5
      TTStart = %A_TickCount%
      TooltipMsg = ##Autoclick disabled.
      setTimer, autoclick, off
    }
  }
return

setTip:
  StringReplace, cleanTTM, TooltipMsg, ##
  Tooltip, % cleanTTM
  if (InStr(TooltipMsg, "##") && A_TickCount - TTStart > 1000)
    TooltipMsg =
  if TooltipMsg =
  {
    Tooltip
    setTimer, setTip, off
  }
return

checkMouseMovement:
  if (WinExist("ahk_id" . actWin) || !actWin)
  {
    MouseGetPos, tx, ty
    if (tx == pmx && ty == pmy)
      mouseMoved := false
    else
      mouseMoved := true
    pmx := tx
    pmy := ty
  }
  else
  {
    Msgbox, 4, NIAutoclicker, Target window has been closed, `n Do you want to close NIAutoclicker as well?
    IfMsgBox Yes
      ExitApp
    else
    {
      actWin :=
      toggle := false
    }
  }
return

autoclick:
  if !(WinActive("ahk_id" . actWin) && (A_TimeIdlePhysical < 50 && !mouseMoved))
    ControlClick, x%xp% y%yp%, ahk_id %actWin%,,,, NA
return

~*LButton up::
return

#If WinActive("ahk_id" . actWin) && toggle
*LButton::
  MouseGetPos,,, winClick
  if winClick = %actWin%
    setTimer, autoclick, off
  SetMouseDelay -1
  Send {Blind}{LButton Down}
return

*LButton up::
  IfWinNotExist, Change Value
    setTimer, autoclick, %clickRate%
  SetMouseDelay -1
  Send {Blind}{LButton Up}
return

EmptyMem()
{
  pid:= DllCall("GetCurrentProcessId")
  h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
  DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
  DllCall("CloseHandle", "Int", h)
}