#NoTrayIcon
; Text Overlay Script - Displays file content in a centered, non-blocking overlay
; Updates every 20 seconds automatically

; Global variables
TextContent := ""
IsVisible := true
IsPermanentlyHidden := false

; Initialize
ReadFileContent()
CreateGUI()
SetTimer, UpdateContent, 20000
return

; Read text file content
ReadFileContent() {
    global TextContent
    FileRead, TextContent, F:\home\org\org-clock-status.txt
    if ErrorLevel {
        TextContent := ""
    } else {
        TextContent := Trim(TextContent, " `t`n`r")
    }
}

; Create centered GUI overlay
CreateGUI() {
    global TextContent, IsVisible, IsPermanentlyHidden
    
    ; Destroy existing GUI if it exists
    Gui, MyOverlay:Destroy
    
    ; Reset temporary visibility if not permanently hidden
    if (!IsPermanentlyHidden) {
        IsVisible := true
    }
    
    ; Always create GUI but only show based on visibility states
    Gui, MyOverlay:New, +AlwaysOnTop +ToolWindow -Caption +E0x08000000 -MaximizeBox -MinimizeBox
    Gui, MyOverlay:Margin, 20, 18
    Gui, MyOverlay:Font, s14 cFFFFFF w700, Fira Code
    Gui, MyOverlay:Color, 000000
    Gui, MyOverlay:Add, Text, Center BackgroundTrans gClickHide, %TextContent%
    
    ; Only show if both visibility conditions are met
    if (IsVisible && !IsPermanentlyHidden && TextContent) {
        ; Show GUI and get dimensions for centering
        Gui, MyOverlay:Show, AutoSize Hide NoActivate, Text Overlay
        WinGetPos,,, GuiWidth, GuiHeight, Text Overlay
        
        ; Calculate center position
        ScreenWidth := A_ScreenWidth
        ScreenHeight := A_ScreenHeight
        CenterX := (ScreenWidth - GuiWidth) // 2
        CenterY := (ScreenHeight - GuiHeight) // 2
        
        ; Position in center and show
        Gui, MyOverlay:Show, x%CenterX% y%CenterY% NoActivate, Text Overlay
        
        ; Apply visual effects
        WinSet, Transparent, 140, Text Overlay
        WinSet, Region, 0-0 w%GuiWidth% h%GuiHeight% r40-40, Text Overlay
    }
}

; Timer function to update content
UpdateContent:
    ReadFileContent()
    CreateGUI()
return

; Toggle permanent visibility with Ctrl+Shift+T (stays hidden until used again)
^+t::
    IsPermanentlyHidden := !IsPermanentlyHidden
    CreateGUI()
return

; Click to temporarily hide (shows back on next timer update)
ClickHide:
    IsVisible := false
    Gui, MyOverlay:Hide
return
