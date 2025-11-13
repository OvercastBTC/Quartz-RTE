/************************************************************************
 * @description WebViewToo - Enhanced WebView2 wrapper for AutoHotkey v2
 * @file WebViewToo.ahk
 * @author Generated for Quartz RTE  
 * @version 1.0
 ***********************************************************************/

#Include WebView2.ahk
#Include ComVar.ahk
#Include Promise.ahk

; Enhanced WebView2 wrapper with additional functionality
class WebViewToo {
    __New(hwnd, options := {}) {
        this.hwnd := hwnd
        this.options := options
        this.webview := WebView2.create(hwnd)
        this.coreWebView2 := this.webview.CoreWebView2
    }
    
    ; Navigation methods
    Navigate(url) {
        return this.coreWebView2.Navigate(url)
    }
    
    NavigateToString(htmlContent) {
        ; Navigate to HTML string content
        return this.coreWebView2.NavigateToString(htmlContent)
    }
    
    ; Script execution
    ExecuteScript(script, callback := "") {
        return this.coreWebView2.ExecuteScript(script, callback)
    }
    
    ; Host object management
    AddHostObjectToScript(name, obj) {
        return this.coreWebView2.AddHostObjectToScript(name, obj)
    }
    
    ; Event handling
    AddNavigationCompletedHandler(handler) {
        ; Add navigation completed event handler
        this.navigationHandler := handler
    }
    
    ; Utility methods
    Fill() {
        return this.webview.Fill()
    }
    
    Resize(width, height) {
        this.coreWebView2.width := width
        this.coreWebView2.height := height
    }
    
    ; Property access
    CoreWebView2 {
        get => this.coreWebView2
    }
    
    ; Enhanced functionality for RTE
    SetContent(html) {
        script := 'document.body.innerHTML = `' html '`;'
        this.ExecuteScript(script)
    }
    
    GetContent(callback) {
        script := 'document.body.innerHTML;'
        this.ExecuteScript(script, callback)
    }
    
    InsertText(text) {
        escapedText := StrReplace(text, '`', '``')
        escapedText := StrReplace(escapedText, '"', '\"')
        script := 'if(window.quill) { window.quill.clipboard.dangerouslyPasteHTML("' escapedText '"); }'
        this.ExecuteScript(script)
    }
    
    GetText(callback) {
        script := 'if(window.quill) { window.quill.getText(); } else { document.body.innerText; }'
        this.ExecuteScript(script, callback)
    }
    
    ; Toolbar functionality
    Bold() {
        script := 'if(window.quill) { window.quill.format("bold", true); }'
        this.ExecuteScript(script)
    }
    
    Italic() {
        script := 'if(window.quill) { window.quill.format("italic", true); }'
        this.ExecuteScript(script)
    }
    
    Underline() {
        script := 'if(window.quill) { window.quill.format("underline", true); }'
        this.ExecuteScript(script)
    }
}