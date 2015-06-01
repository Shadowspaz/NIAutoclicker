;Non-Intrusive Autoclicker, by Shadowspaz
;v.1.4

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

setTimer, checkMouseMovement, 10

setTimer, setTip, 5
TTStart = %A_TickCount%
while (A_TickCount - TTStart < 5000 && !toggle)
{
  TooltipMsg = Press (Alt + Backspace) to toggle autoclicker `n Press (Alt + Equals(=)) to change click speed
}
  TooltipMsg =

!=::
  IfWinNotExist, Change Value
  {
    Gui, Show, w210 h110, Change Value
    Gui, Add, Radio, x25 y10 gActEdit1 vMode, Clicks per second:
    Gui, Add, Radio, x25 y35 gActEdit2, Seconds per click:
    Gui, Add, Edit, x135 y8 w50 Number Left vTempRateCPS, % 1000 / clickRate
    Gui, Add, Edit, x135 y33 w50 Number Left vTempRateSPC, % clickRate / 1000
    Gui, Add, Text, x0 w210 0x10
    Gui, Add, Text, x27 y65, (Default is 50 clicks per second)
    Gui, Add, Button, x87 y82 Default gSetVal, Set
    if Mode < 2
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
  GuiControl, Enable, TempRateCPS
  GuiControl, Disable, TempRateSPC
  GuiControl, Focus, TempRateCPS
  Send +{End}
return

ActEdit2:
  GuiControl, Enable, TempRateSPC
  GuiControl, Disable, TempRateCPS
  GuiControl, Focus, TempRateSPC
  Send +{End}
return

SetVal:
  Gui, Submit
  if Mode < 2
    clickRate := TempRateCPS > 0 ? 1000 / TempRateCPS : 1000
  else
    clickRate := TempRateSPC > 0 ? 1000 * TempRateSPC : 1000
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
      TooltipMsg = Click the desired autoclick location.
      toggle := false
      Keywait, LButton, D
      Keywait, LButton
      TooltipMsg = 
      toggle := true
      MouseGetPos, xp, yp
      WinGet, actWin, ID, A
      ;msgbox, X: %xp% Y: %yp% `n %actWin%
      EmptyMem()
      setTimer, autoclick, %clickRate%
    }
    else
    {
      setTimer, setTip, 5
      TTStart = %A_TickCount%
      TooltipMsg = Autoclick disabled.
      setTimer, autoclick, off
    }
  }
return

setTip:
  Tooltip, % TooltipMsg
  if (TooltipMsg = "Autoclick disabled." && A_TickCount - TTStart > 1000)
    TooltipMsg =
  if TooltipMsg =
  {
    Tooltip
    setTimer, setTip, off
  }
return

checkMouseMovement:
  MouseGetPos, tx, ty
  if (tx == pmx && ty == pmy)
    mouseMoved := false
  else
    mouseMoved := true
  pmx := tx
  pmy := ty
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
  Click down
return

*LButton up::
  IfWinNotExist, Change Value
    setTimer, autoclick, %clickRate%
  Click up
return

EmptyMem()
{
  pid:= DllCall("GetCurrentProcessId")
  h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
  DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
  DllCall("CloseHandle", "Int", h)
}