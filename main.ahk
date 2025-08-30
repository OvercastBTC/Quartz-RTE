/************************************************************************
 * @description Main script for Quartz RTE using WebViewToo
 * @file main.ahk
 * @author Generated for Quartz RTE
 * @date 2024/12/19
 * @version 1.0
 ***********************************************************************/

#SingleInstance Force
#Requires AutoHotkey v2.0+

; Include required libraries
#Include Lib\WebViewToo.ahk

; Application Configuration
Version := "1.0"
Title := "Quartz RTE"
Description := "Rich Text Editor using WebViewToo and Quill.js"

; Path Configuration
A_RootDir := A_ScriptDir
path := {}
path.pages := A_RootDir '\Pages\'
path.html := path.pages 'index.html'

; Initialize GUI
RTE := Gui("+Border +Resize", Title)
RTE.BackColor := "White"
RTE.MarginX := 0
RTE.MarginY := 0

; Show the GUI
RTE.Show("w1200 h800")

; Initialize WebViewToo
try {
    WV := WebViewToo(RTE.Hwnd)
    HTML := WV.CoreWebView2
    
    ; Navigate to the HTML file
    HTML.Navigate('file:///' path.html)
    
    ; Add host object for AHK-WebView interaction
    HTML.AddHostObjectToScript('ahk', {
        about: about,
        OpenFile: OpenFile, 
        SaveFile: SaveFile,
        get: getText,
        getHTML: getHTML,
        exit: Exit,
        newFile: newFile
    })
    
    ; Handle GUI events
    RTE.OnEvent('Close', (*) => Exit())
    RTE.OnEvent('Size', gui_resize)
    
    MsgBox("Quartz RTE initialized successfully!`n`nFeatures:`n- Basic toolbar (Bold, Italic, Underline)`n- File operations (New, Open, Save)`n- AHK-WebView interaction`n- Bootstrap sidebar and theme switching`n- Quill.js rich text editing", "Quartz RTE", "64")
    
} catch as e {
    MsgBox("Failed to initialize WebView: " e.message, "Error", "16")
    Exit()
}

; GUI resize handler
gui_resize(GuiObj, MinMax, Width, Height) {
    if (MinMax != -1 && IsSet(WV)) {
        try {
            WV.Resize(Width, Height)
            WV.Fill()
        }
    }
}

; File Operations
OpenFile() {
    try {
        selected := FileSelect(, , "Select a file to open", "Text Files (*.txt)|HTML Files (*.html)|All Files (*.*)")
        if (selected = "" || !FileExist(selected)) {
            return
        }
        
        ; Read file content
        content := FileRead(selected)
        
        ; Escape content for JavaScript
        content := StrReplace(content, "\", "\\")
        content := StrReplace(content, "'", "\'")
        content := StrReplace(content, "`n", "\\n")
        content := StrReplace(content, "`r", "")
        
        ; Insert content into editor
        script := "if(window.quill) { window.quill.clipboard.dangerouslyPasteHTML('" content "'); }"
        HTML.ExecuteScript(script, WebView2.Handler(ScriptCompletedHandler))
        
        ; Show success message
        script := "console.log('File opened: " selected "');"
        HTML.ExecuteScript(script, WebView2.Handler(ScriptCompletedHandler))
        
    } catch as e {
        MsgBox("Error opening file: " e.message, "Error", "16")
    }
}

SaveFile(content := "") {
    try {
        ; If no content provided, get it from the editor
        if (content = "") {
            ; Request content from editor
            HTML.ExecuteScript("if(window.quill) { window.ahk.SaveFile(window.quill.root.innerHTML); }", 
                              WebView2.Handler(ScriptCompletedHandler))
            return
        }
        
        ; Select save location
        selected := FileSelect("S", , "Save file as...", "HTML Files (*.html)|Text Files (*.txt)")
        if (selected = "") {
            return
        }
        
        ; Add extension if not provided
        if (InStr(selected, ".") = 0) {
            selected := selected . ".html"
        }
        
        ; Save file
        FileAppend(content, selected)
        
        ; Show success message
        script := "console.log('File saved: " selected "');"
        HTML.ExecuteScript(script, WebView2.Handler(ScriptCompletedHandler))
        
        MsgBox("File saved successfully: " selected, "Save Complete", "64")
        
    } catch as e {
        MsgBox("Error saving file: " e.message, "Error", "16") 
    }
}

newFile() {
    try {
        ; Clear the editor
        script := "if(window.quill) { window.quill.setContents([]); }"
        HTML.ExecuteScript(script, WebView2.Handler(ScriptCompletedHandler))
        
        ; Log action
        script := "console.log('New file created');"
        HTML.ExecuteScript(script, WebView2.Handler(ScriptCompletedHandler))
        
    } catch as e {
        MsgBox("Error creating new file: " e.message, "Error", "16")
    }
}

getText(text := "") {
    if (text = "") {
        ; Request text from editor
        HTML.ExecuteScript("if(window.quill) { window.ahk.get(window.quill.getText()); }", 
                          WebView2.Handler(ScriptCompletedHandler))
        return
    }
    
    ; Display the text content
    MsgBox("Text Content:`n`n" text, "Text Content", "64")
}

getHTML(html := "") {
    if (html = "") {
        ; Request HTML from editor  
        HTML.ExecuteScript("if(window.quill) { window.ahk.getHTML(window.quill.root.innerHTML); }", 
                          WebView2.Handler(ScriptCompletedHandler))
        return
    }
    
    ; Display the HTML content
    MsgBox("HTML Content:`n`n" html, "HTML Content", "64")
}

about() {
    aboutText := "
    (
    Quartz RTE - Rich Text Editor
    Version: " Version "
    
    Built with:
    - AutoHotkey v2
    - WebViewToo library
    - Quill.js rich text editor
    - Bootstrap components
    
    Features:
    - Rich text editing with formatting
    - File operations (New, Open, Save)
    - AHK-WebView interaction
    - Bootstrap sidebar navigation
    - Dark/Light theme switching
    - Keyboard shortcuts
    
    Keyboard Shortcuts:
    - Ctrl+N: New file
    - Ctrl+O: Open file
    - Ctrl+S: Save file
    - Ctrl+B: Bold
    - Ctrl+I: Italic
    - Ctrl+U: Underline
    - Ctrl+T: Get text content
    - Ctrl+H: Get HTML content
    - Ctrl+Q: Exit application
    )"
    
    MsgBox(aboutText, "About Quartz RTE", "64")
}

Exit() {
    try {
        if (IsSet(HTML)) {
            HTML := unset
        }
        if (IsSet(WV)) {
            WV := unset
        }
        if (IsSet(RTE)) {
            RTE.Destroy()
        }
    }
    ExitApp()
}

; Script execution completed handler
ScriptCompletedHandler(handler, errorCode, resultObjectAsJson) {
    if (errorCode != 0) {
        ; Only show errors in development mode
        ; MsgBox("Script Error: " errorCode "`nResult: " StrGet(resultObjectAsJson))
    }
}

; Hotkeys for quick access
^n::newFile()              ; Ctrl+N - New file
^o::OpenFile()             ; Ctrl+O - Open file  
^s::SaveFile()             ; Ctrl+S - Save file
^t::getText()              ; Ctrl+T - Get text
^h::getHTML()              ; Ctrl+H - Get HTML
^q::Exit()                 ; Ctrl+Q - Exit

; Keep script running
return