;*****************************************
;Crosshair by Steve Mavic
;https://github.com/SteveMavic
;MIT License
;*****************************************
#RequireAdmin
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#Include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <ColorPicker.au3>
#include <WinAPIFiles.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

HotKeySet("{F10}", "Start")
HotKeySet("{F11}", "Stop")


Global Const $Path = @AppDataDir & "\Crosshair Configs"
Global $DefaultConfigPath = RegRead("HKEY_CURRENT_USER\Software\Crosshair", "Default configuration" )

If NOT FileExists($Path) Then
   DirCreate($Path)
   IniWrite($Path & "\Default.ini", "Config", "Gap", 0)
   IniWrite($Path & "\Default.ini", "Config", "App", Null)
   IniWrite($Path & "\Default.ini", "Config", "Length", 5)
   IniWrite($Path & "\Default.ini", "Config", "Thickness", 2)
   IniWrite($Path & "\Default.ini", "Config", "Color", 0xFF00FF00)
EndIf

Global $Gap = IniRead($DefaultConfigPath, "Config", "Gap", 0)
Global $App = IniRead($DefaultConfigPath, "Config", "App", "")
Global $Length = IniRead($DefaultConfigPath, "Config", "Length", 5)
Global $DotColor = IniRead($DefaultConfigPath, "Config", "Color", 0xFF00FF00)
Global $Thickness = IniRead($DefaultConfigPath, "Config", "Thickness", 2)

GUICreate("Crosshair", 230, 290)
   Global $idFileMenu = GUICtrlCreateMenu("File")
   Global $idFileItemOpen = GUICtrlCreateMenuItem("Open config", $idFileMenu)
   Global $idFileItemSave = GUICtrlCreateMenuItem("Save config", $idFileMenu)
   Global $idFileItemDefault = GUICtrlCreateMenuItem("Set Default config", $idFileMenu)
   GUICtrlCreateMenuItem("", $idFileMenu)
   Global $idFileItemClear = GUICtrlCreateMenuItem("Clear saved settings", $idFileMenu)
   GUICtrlCreateMenuItem("", $idFileMenu)
   Global $idExitItem = GUICtrlCreateMenuItem("Exit", $idFileMenu)
   Global $idHelpMenu = GUICtrlCreateMenu("About")
   Global $idAboutItem = GUICtrlCreateMenuItem("Help", $idHelpMenu)
   Global $idAboutItemAuthor = GUICtrlCreateMenuItem("Author", $idHelpMenu)
   GUICtrlCreateLabel("Game title", 20, 5)
   Global $inputApp = GUICtrlCreateInput("", 20, 20, 120)
   GUICtrlCreateLabel("Crosshair color", 20, 50)
   Global $Label = GUICtrlCreateLabel('', 20, 67, 20, 20, $SS_SUNKEN)
   Global $Picker = _GUIColorPicker_Create('Pick color...', 45, 65, 70, 23, _RgbToArgb($DotColor, 1), BitOR($CP_FLAG_DEFAULT, $CP_FLAG_TIP))
   GUICtrlSetBkColor($Label, _GUIColorPicker_GetColor($Picker))
   GUICtrlCreateLabel("Gap (in pixels)", 20, 95)
   Global $inputGap = GUICtrlCreateInput("", 20, 110, 120)
   GUICtrlCreateLabel("Lines length (in pixels)", 20, 140)
   Global $inputLength = GUICtrlCreateInput("", 20, 155, 120)
   GUICtrlCreateLabel("Lines thickness (in pixels)", 20, 185)
   Global $inputThickness = GUICtrlCreateInput("", 20, 200, 120)
   Global $Confirm = GUICtrlCreateButton("Apply", 20, 230, 70, 23)
GUISetState(@SW_SHOW)


_SetDataToControls()


GUI()
Func GUI()
   Do
	 Global $msg = GUIGetMsg()
	  Switch $msg
		 Case $GUI_EVENT_CLOSE
			Exit
		 Case $Picker
            GUICtrlSetBkColor($Label, _GUIColorPicker_GetColor($Picker))
			Local $info[2]
			$info = _GUIColorPicker_GetColor($Picker, 1)
			TrayTip("Crosshair", "Color: " & $info[1], 0, 16)
		 Case $Confirm
			$DotColor = _RgbToArgb(_GUIColorPicker_GetColor($Picker), 0)
			$Gap = GUICtrlRead($inputGap)
			$App = GUICtrlRead($inputApp)
			$Length = GUICtrlRead($inputLength)
			$Thickness = GUICtrlRead($inputThickness)
			;MsgBox(0, "Config", "Gap: " & $Gap & ", App: " & $App & ", Length: " & $Length & ", DotColor: " & $DotColor)
		 Case $idFileItemOpen
			$openDialog = FileOpenDialog("Choose config", $Path, "Configuration Files (*.ini)")
			If Not @error Then
			   GUICtrlSetData ( $inputApp, IniRead($openDialog, "Config", "App", ""))
			   GUICtrlSetData ( $inputGap, IniRead($openDialog, "Config", "Gap", 0))
			   GUICtrlSetData ( $inputLength, IniRead($openDialog, "Config", "Length", 5))
			   GUICtrlSetData ( $inputThickness, IniRead($openDialog, "Config", "Thickness", 2))
			   local $clr = IniRead($openDialog, "Config", "Color", 0xFF00FF00)
			   _GUIColorPicker_SetColor($Picker, _RgbToArgb($clr, 1))
			   GUICtrlSetBkColor($Label, _GUIColorPicker_GetColor($Picker))
			EndIf
		 Case $idFileItemSave
			$saveDialog = FileSaveDialog("Save config", $Path, "Configuration Files (*.ini)", $FD_PATHMUSTEXIST)
			If Not @error Then
			   If StringRight($saveDialog,4) <> ".ini" Then $saveDialog &= ".ini"
			   IniWrite($saveDialog, "Config", "Gap", GUICtrlRead($inputGap))
			   IniWrite($saveDialog, "Config", "App", GUICtrlRead($inputApp))
			   IniWrite($saveDialog, "Config", "Length", GUICtrlRead($inputLength))
			   IniWrite($saveDialog, "Config", "Thickness", GUICtrlRead($inputThickness))
			   IniWrite($saveDialog, "Config", "Color", _RgbToArgb(_GUIColorPicker_GetColor($Picker), 0))
			EndIf
		 Case $idFileItemDefault
			$openDialog = FileOpenDialog("Choose config", $Path, "Configuration Files (*.ini)")
			If Not @error Then
			   RegWrite("HKEY_CURRENT_USER\Software\Crosshair", "Default configuration", "REG_SZ", $openDialog)
			EndIf
		 Case $idAboutItem
			MsgBox(0, "Help", "Press F-10 to start drawing Crosshair" & @CRLF & "Press F-11 to stop drawing Crosshair" & @CRLF & @CRLF & "Made by Steve Mavic")
		 Case $idAboutItemAuthor
			$response = MsgBox(0, "Message", "If you found bugs, please report it by writing a message to me.")
			If $response = $IDOK Then ShellExecute("https://guidedhacking.com/member.php?58733-SteveMavic")
		 Case $idFileItemClear
			$response = MsgBox(BitOR($MB_YESNO,$MB_ICONWARNING), "Warning", "This option will DELETE all of your saved configuration and will clear default configuration which has been set." & @CRLF & @CRLF & "Continue?" )
			If $response = $IDYES Then
			   RegDelete("HKEY_CURRENT_USER\Software\Crosshair")
			   DirRemove($Path, 1)
			EndIf
		 Case $idExitItem
			Exit
	  EndSwitch
   Until $msg = $GUI_EVENT_CLOSE
EndFunc

Func Start()
   Local $Size[2]
   Local $Location[2]

   $Size = WinGetClientSize($App)
   If @error Then
	  mycross(@DesktopWidth/2, @DesktopHeight/2, $Length, $Thickness, $Gap, $DotColor)
   Else
	  $Location = WinGetPos($App)
	  ;$x = $Location[0] + ($Size[0] / 2)
	  $x = $Size[0] / 2
	  ;$y = $Location[1] + ($Size[1] / 2)
	  $y = $Size[1] / 2
	  mycross($x-1, $y, $Length, $Thickness, $Gap, $DotColor)
   EndIf
EndFunc

Func Stop()
   _WinAPI_RedrawWindow($App, 0, 0, BitOR($WM_ERASEBKGND, $RDW_INVALIDATE, $RDW_UPDATENOW, $RDW_FRAME))
   _GDIPlus_Shutdown()
   GUI()
EndFunc


func mycross($start_x, $start_y, $mylenght, $tickness, $gap, $color)
   _GDIPlus_Startup ()
   $hDC = _WinAPI_GetWindowDC(0)
   $handle = WinGetHandle($App)

   $hGraphic = _GDIPlus_GraphicsCreateFromHWND($handle)
   ;$hGraphic = _GDIPlus_GraphicsCreateFromHDC()
   $Color = $color
   $hPen = _GDIPlus_PenCreate($Color, $tickness)


    While 1
	  _GDIPlus_GraphicsDrawLine($hGraphic, $start_x - $mylenght, $start_y, $start_x - $gap, $start_y, $hPen);horizontal dx
      _GDIPlus_GraphicsDrawLine($hGraphic, $start_x  + $mylenght , $start_y, $start_x + $gap, $start_y, $hPen);horizontal sx
      _GDIPlus_GraphicsDrawLine($hGraphic, $start_x, $start_y - $mylenght, $start_x, $start_y - $gap, $hPen);vertical up
      _GDIPlus_GraphicsDrawLine($hGraphic, $start_x, $start_y + $mylenght, $start_x, $start_y + $gap, $hPen);vertical down
      _GDIPlus_PenSetColor($hPen, $Color)
   WEnd

EndFunc

Func _SetDataToControls()
   GUICtrlSetData ( $inputApp, $App)
   GUICtrlSetData ( $inputGap, $Gap)
   GUICtrlSetData ( $inputLength, $Length)
   GUICtrlSetData ( $inputThickness, $Thickness)
EndFunc

Func _RgbToArgb($color, $switcher = 0)

   If $switcher = 1 Then ;Argb to Rgb
	  $newColor = Hex($color)
	  $sString = StringMid($newColor, 3, 6)
	  $newColor = "0x" & $sString
   Else
	  $newColor = Hex($color)
	  $sString = StringMid($newColor, 3, 6)
	  $newColor = "0xFF" & $sString
   EndIf

   Return $newColor
EndFunc