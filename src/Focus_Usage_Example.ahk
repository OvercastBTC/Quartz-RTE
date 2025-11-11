#Requires AutoHotkey v2.0+

/**
 * @file Focus_Usage_Example.ahk
 * @description Example showing how to use Focus() in both script and compiled forms
 * @author Claude
 * @date 2025/11/05
 */

; Include the Quartz class
#Include "Quartz.ahk"

; Example usage of Focus() method
; This works identically in both script (.ahk) and compiled (.exe) forms

; =============================================================================
; METHOD 1: Instance Focus() - When you have a Quartz instance
; =============================================================================

; Create a new Quartz editor instance
myEditor := Quartz("Initial text content here")

; Wait a moment for the editor to fully load
Sleep(2000)

; Focus the editor (instance method)
myEditor.Focus()

; You can also chain it with other methods
myEditor.Focus().SetText("Now I have focus!")

; =============================================================================
; METHOD 2: Static Focus() - When you want to focus the active editor
; =============================================================================

; This is useful for hotkeys or when you don't have direct access to the instance
; It finds the currently active Quartz window and focuses it

; Focus the active editor (static method)
Quartz.Focus()

; =============================================================================
; HOTKEY EXAMPLES - Works in both script and compiled forms
; =============================================================================

; Hotkey to focus the active Quartz editor
F1::Quartz.Focus()

; Hotkey to focus and then add some text
F2::{
    if (Quartz.Focus()) {
        ; Focus was successful, now add text
        Sleep(100)  ; Small delay to ensure focus
        SendText("Focused via F2 hotkey!")
    }
}

; =============================================================================
; ADVANCED USAGE - Error Handling
; =============================================================================

F3::{
    try {
        result := Quartz.Focus()
        if (result) {
            ToolTip("Editor focused successfully!")
            SetTimer(() => ToolTip(), -2000)  ; Hide tooltip after 2 seconds
        } else {
            ToolTip("No active editor found!")
            SetTimer(() => ToolTip(), -2000)
        }
    } catch Error as err {
        MsgBox("Error focusing editor: " err.Message, "Focus Error")
    }
}

; =============================================================================
; COMPILATION DIFFERENCES EXPLANATION
; =============================================================================

/*
WHEN RUNNING AS SCRIPT (.ahk):
- A_IsCompiled = false
- Files loaded from relative paths (../lib/, ../fonts/, etc.)
- Dependencies referenced from source directory structure
- Focus() works by finding the WebView2 control in the GUI

WHEN RUNNING AS COMPILED (.exe):
- A_IsCompiled = true  
- Files extracted from embedded resources to executable directory
- Dependencies loaded from extracted locations (lib/, fonts/, etc.)
- Focus() works identically - finds WebView2 control in the GUI
- No functional difference in Focus() behavior

KEY POINTS:
1. Focus() method behavior is IDENTICAL in both forms
2. The compilation setup handles file paths automatically
3. WebView2 interactions work the same way
4. Static and instance methods both function normally

TECHNICAL DETAILS:
- Focus() calls WinActivate() on the GUI window
- Then executes "quill.focus()" JavaScript in WebView2
- Error handling and logging work in both forms
- Method chaining supported in both forms
*/

; =============================================================================
; TESTING COMPILATION STATUS
; =============================================================================

; Show current execution mode
if (A_IsCompiled) {
    MsgBox("Running as COMPILED executable`n`n" .
           "Focus() method works the same as script form!`n" .
           "All dependencies are embedded and extracted automatically.", 
           "Compiled Mode")
} else {
    MsgBox("Running as SCRIPT`n`n" .
           "Focus() method works with source directory structure.`n" .
           "When compiled, behavior will be identical.", 
           "Script Mode")
}

; Keep script running to test hotkeys
ExitApp  ; Remove this line to keep script running for hotkey testing
