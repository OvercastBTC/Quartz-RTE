/************************************************************************
 * @description Rich Text Editor using AHK and JS/HTML/CSS
 * @file Quartz.ahk
 * @author Laser Made
 * @date 2024/06/20
 * @version 0.4
 * @versioncodename Alpha 4
 ***********************************************************************/
#Requires AutoHotkey v2+
#Include <Extensions/.modules/Clipboard>
#Include <Extensions/.primitives//Keys>
#Include ../lib/WebView2.ahk
#Include ../lib/Comvar.ahk
; Persistent(1)
/*You must have WebView2.ahk, Comvar.ahk, and WebView2.dll in the proper directories.
For instance, my WebView2.ahk file is located at: My Documents\AutoHotkey\lib\WebView2.ahk
The "Documents/AutoHotkey/lib" directory is a valid AHK library path that AutoHotkey.exe looks in when including files with <brackets>
*/

/**
 * @description
 * There are multiple ways to handle document formatting. One way is to use ComObjects and Query the document class in windows.
 * You can load a document from a file as a ComObject using ComObjGet.
 * @example doc := ComObjGet('document.rtf')
 * ;then you can use the properties of the document to determine it's formatting:
 * doc.characters.item(1).text ;this will give you the first character in the document
 * doc.characters.item(1).italic ;this will return 1 if the character is italic or 0 if it is not
 * doc.sentences.item(1).text ;this will return the first sentence in the document, no formatting
 * doc.content.text ;this will return the entirety of text in the document without any formatting
 * doc.content.WordOpenXML ;this will return the entire document in Word Open XML format. It contains the formatting in XML
 * @info
 * {@link https://learn.microsoft.com/en-us/dotnet/api/microsoft.office.interop.word.range?view=word-pia|This Microsoft page} shows the properties of the Range object that can be used
 * 
 * You can also get more info about the com object using:
 * @example MsgBox "Interface name: " ComObjType(doc, "name") "And value : " ComObjValue(doc)
 */

; Initialize Quartz
editor1 := QuartzEditor()

; Hotkeys
#HotIf WinActive(A_LineFile)
^+n::QuartzEditor.NewFile()
^+o::QuartzEditor.OpenFile()
^+s::QuartzEditor.SaveFile(QuartzEditor.GetHTML())
^+t::MsgBox(QuartzEditor.PassTextToAHK())
^+h::MsgBox(QuartzEditor.PassHTMLToAHK())
^+q::QuartzEditor.Exit()
^+a::QuartzEditor.About()
; ^v::QuartzEditor.
#Hotif

class QuartzEditor {
	static filetypes := "Text Files (*.txt; *.rtf; *.html; *.css; *.js; *.ahk; *.ah2; *.ahk2; *.md; *.ini;)"
	static rootDir := A_ScriptDir "\.."
	static libDir := this.rootDir "\lib"
	static fontDir := this.rootDir "\fonts"
	static srcDir := this.rootDir "\src"
	static Version := "0.4"
	static CodeName := "Alpha " SubStr(this.Version, 3, 1)
	static Description := "Rich Text Editor using AHK and JS/HTML/CSS"
	
	static path := {
		src: this.srcDir "\",
		html: this.srcDir "\index.html",
		css: this.srcDir "\style.css",
		js: this.srcDir "\script.js"
	}

	static RTE := ""
	static WV2 := ""
	static HTML := ""
	static isLoaded := false

	static __New() {
        ; EditorHotkeys.__New()
        this.SetupGUI()
    }

    static HandleFormat(type) {
        if (!this.isLoaded) {
            return
        }
        if WinActive('ahk_exe hznHorizon.exe') {
            ; Convert to RTF
            this.HTML.ExecuteScript("
			(
                const format = quill.getFormat();
                if (format.${type}) {
                    quill.format('${type}', false);
                } else {
                    quill.format('${type}', true);
                }
            )", WebView2.Handler((handler, errorCode, result) => {}))
        } else {
            ; Use markdown syntax
            this.HTML.ExecuteScript("
			(
                const sel = quill.getSelection();
                if (sel) {
                    const text = quill.getText(sel.index, sel.length);
                    const mdFormat = {
                        'bold': '**${text}**',
                        'italic': '*${text}*',
                        'underline': '__${text}__'
                    };
                    quill.deleteText(sel.index, sel.length);
                    quill.insertText(sel.index, mdFormat['${type}']);
                }
            )", WebView2.Handler((handler, errorCode, result) => {}))
        }
    }

    ; Add format methods
    static Bold() 			=> this.HandleFormat('bold')
    static Italic() 		=> this.HandleFormat('italic')
    static Underline() 		=> this.HandleFormat('underline')
    static Superscript() 	=> this.HandleFormat('super')
    static Subscript() 		=> this.HandleFormat('sub')

	static SetupGUI() {
		try {
			this.RTE := Gui()
			this.RTE.Opt("+Resize +MinSize640x400")
			this.RTE.Title := "Quartz Rich Text Editor"
			this.RTE.OnEvent("Close", (*) => this.Exit())
			this.RTE.OnEvent("Size", (*) => this.GuiSize)

			this.RTE.Show("w915 h445")

			; Create WebView2 control
			this.WV2 := WebView2.create(this.RTE.Hwnd)

			; Wait for the WebView2 to be fully created
			while !this.WV2.CoreWebView2 {
				Sleep(10)
			}

			this.HTML := this.WV2.CoreWebView2
			this.HTML.Navigate("file:///" this.path.html)
			
			this.HTML.AddHostObjectToScript("ahk", { 
				about: this.About, 
				OpenFile: this.OpenFile, 
				SaveFile: this.SaveFile, 
				get: this.GetText, 
				getHTML: this.GetHTML, 
				exit: this.Exit 
			})

			; this.HTML.add_NavigationCompleted((sender, args) => this.OnNavigationCompleted)
			this.HTML.add_NavigationCompleted(WebView2.Handler((sender, args) => this.OnNavigationCompleted(sender, args)))

		}
		catch Error as err {
			; MsgBox("Error in SetupGUI: " err.Message)
			throw err
		}
	}

	static OnNavigationCompleted(sender, args) {
		this.isLoaded := true
		this.HTML.ExecuteScript("console.log('Navigation completed');", WebView2.Handler((handler, errorCode, resultObjectAsJson) => {}))
	}

	static GuiSize(GuiObj, MinMax, Width, Height) {
		if (MinMax = -1)
			return
		try {
			this.WV2.Fill()
		} catch as err {
			MsgBox("Error in GuiSize: " err.Message)
		}
	}

	static About() {
		if (!this.isLoaded) {
			MsgBox("WebView is not fully loaded yet.")
			return
		}
		try {
			this.HTML.ExecuteScript("about()", WebView2.Handler((handler, errorCode, resultObjectAsJson) => {}))
		} catch as err {
			MsgBox("Error in About: " err.Message)
		}
	}

	static OpenFile(savedfile := "") {
		if (!this.isLoaded) {
			MsgBox("WebView is not fully loaded yet.")
			return
		}
		try {
			if (savedfile = "") {
				selected := FileSelect(,, "Select a file to open", this.filetypes)
			} else {
				selected := savedfile
			}

			if (selected = "" || !FileExist(selected)) {
				return
			}

			if (InStr(selected, ".rtf")) {
				this.OpenRTF(selected)
			} else {
				this.OpenTextFile(selected)
			}
		} catch as err {
			MsgBox("Error in OpenFile: " err.Message)
		}
	}

	static OpenRTF(file) {
		try {
			doc := ComObject("Word.Application").Documents.Open(file)
			Clipboard.BackupAll(&cBak)
			SM(&objSM)
			doc.Range.FormattedText.Copy()
			Clipboard.Wait()
			WinActivate(this.RTE.Hwnd)
			QuartzEditor.HTML.ExecuteScript("quill.focus()")
			Send(keys.paste)
			Clipboard.RestoreAll(cBak)
			doc.Close()
		}
		catch Error as err {
			; MsgBox("Error opening RTF file: " err.Message)
			throw err
		}
	}

	; static OpenTextFile(file) {
	; 	try {
	; 		fileContent := FileRead(file)
	; 		escapedContent := StrReplace(fileContent, "\", "\\")
	; 		escapedContent := StrReplace(escapedContent, "`r`n", "\n")
	; 		escapedContent := StrReplace(escapedContent, "`n", "\n")
	; 		escapedContent := StrReplace(escapedContent, "'", "\'")
	; 		this.HTML.ExecuteScript("quill.setText('" escapedContent "')")
	; 	} catch as err {
	; 		MsgBox("Error in OpenTextFile: " err.Message)
	; 	}
	; }
	static OpenTextFile(file) {
		try {
			fileContent := FileRead(file)
			escapedContent := StrReplace(fileContent, "\", "\\")
			escapedContent := StrReplace(escapedContent, "`r`n", "\n")
			escapedContent := StrReplace(escapedContent, "`n", "\n")
			escapedContent := StrReplace(escapedContent, "'", "\'")
			this.HTML.ExecuteScript("quill.setText('" escapedContent "')", WebView2.Handler((handler, errorCode, resultObjectAsJson) => {}))
		} catch as err {
			MsgBox("Error in OpenTextFile: " err.Message)
		}
	}

	static SaveFile(content) {
		if (!this.isLoaded) {
			MsgBox("WebView is not fully loaded yet.")
			return
		}
		try {
			selected := FileSelect("S",, "Select a file to save", this.filetypes)
			if (selected = "") {
				return
			}
			if FileExist(selected) {
				overwrite := MsgBox("File already exists, overwrite?", "Overwrite", 4)
				if (overwrite != "Yes") {
					return
				}
			}
			FileAppend(content, selected)
		} catch as err {
			MsgBox("Error in SaveFile: " err.Message)
		}
	}

	static GetText() {
		if (!this.isLoaded) {
			MsgBox("WebView is not fully loaded yet.")
			return
		}
		try {
			; Need handler with return value
			return this.HTML.ExecuteScript("quill.getText();", WebView2.Handler((handler, errorCode, resultObjectAsJson) => resultObjectAsJson))
		} catch as err {
			MsgBox("Error in GetText: " err.Message)
		}
	}

	static GetHTML() {
		if (!this.isLoaded) {
			MsgBox("WebView is not fully loaded yet.")
			return
		}
		try {
			; Need handler with return value 
			return this.HTML.ExecuteScript("quill.root.innerHTML;", WebView2.Handler((handler, errorCode, resultObjectAsJson) => resultObjectAsJson))
		} catch as err {
			MsgBox("Error in GetHTML: " err.Message)
		}
	}

	static SetText(text) {
		if (!this.isLoaded) {
			MsgBox("WebView is not fully loaded yet.")
			return
		}
		try {
			escapedText := StrReplace(text, "'", "\'")
			this.HTML.ExecuteScript("quill.setText('" escapedText "');", WebView2.Handler((handler, errorCode, resultObjectAsJson) => {}))
		} catch as err {
			MsgBox("Error in SetText: " err.Message)
		}
	}

	static Exit() {
		try {
			if (this.isLoaded) {
				this.HTML.ExecuteScript("exitApp()", WebView2.Handler((handler, errorCode, resultObjectAsJson) => {}))
			}
			this.HTML := this.WV2 := ""
			this.RTE.Destroy()
		} catch as err {
			MsgBox("Error in Exit: " err.Message)
		}
		ExitApp()
	}

	static NewFile() {
		if (!this.isLoaded) {
			MsgBox("WebView is not fully loaded yet.")
			return
		}
		try {
			this.HTML.ExecuteScript("newFile()", WebView2.Handler((handler, errorCode, resultObjectAsJson) => {}))
		}
		catch as err {
			MsgBox("Error in NewFile: " err.Message)
		}
	}

	static PassTextToAHK() {
		if (!this.isLoaded) {
			MsgBox("WebView is not fully loaded yet.")
			return
		}
		try {
			return this.HTML.ExecuteScript("return quill.getText();")
		} catch as err {
			MsgBox("Error in PassTextToAHK: " err.Message)
		}
	}

	static PassHTMLToAHK() {
		if (!this.isLoaded) {
			MsgBox("WebView is not fully loaded yet.")
			return
		}
		try {
			return this.HTML.ExecuteScript("return quill.root.innerHTML;")
		} catch as err {
			MsgBox("Error in PassHTMLToAHK: " err.Message)
		}
	}
}

; class EditorHotkeys {
;     editor := ""  ; Store reference to editor object
    
;     /**
;      * Initialize hotkeys for an editor instance
;      * @param editorObj The editor class instance to bind hotkeys to
;      */
;     __New(editorObj) {
;         this.editor := editorObj
;         this.SetupHotkeys()
;     }

;     SetupHotkeys() {
;         HotIfWinActive(this.editor.RTE.Title)
        
;         ; File Operations  
;         Hotkey("^n", (*) => this.editor.NewFile())
;         Hotkey("^o", (*) => this.editor.OpenFile())
;         Hotkey("^s", (*) => this.editor.SaveFile())
;         Hotkey("^f", (*) => this.editor.FindText())
;         Hotkey("^h", (*) => this.editor.FindReplace())

;         ; Formatting
;         Hotkey("^b", (*) => this.editor.Bold())
;         Hotkey("^i", (*) => this.editor.Italic()) 
;         Hotkey("^u", (*) => this.editor.Underline())
;         Hotkey("^=", (*) => this.editor.Superscript())
;         Hotkey("^+=", (*) => this.editor.Subscript())

;         ; Exit
;         Hotkey("^q", (*) => this.editor.Exit())
;         HotIf()
;     }
; }

; class EditorHotkeys {
;     static __New() {
;         ; Bind hotkeys when Quartz editor is active
;         static setupHotkeys() {
;             HotIfWinActive("Quartz Rich Text Editor")
;             ; File Operations  
;             Hotkey("^n", (*) => Quartz.NewFile())
;             Hotkey("^o", (*) => Quartz.OpenFile())
;             Hotkey("^s", (*) => Quartz.SaveFile(Quartz.GetHTML()))
;             Hotkey("^f", (*) => Quartz.FindText())
;             Hotkey("^h", (*) => Quartz.FindReplace())

;             ; Formatting
;             Hotkey("^b", (*) => Quartz.Bold())
;             Hotkey("^i", (*) => Quartz.Italic()) 
;             Hotkey("^u", (*) => Quartz.Underline())
;             Hotkey("^=", (*) => Quartz.Superscript())
;             Hotkey("^+=", (*) => Quartz.Subscript())

;             ; Exit
;             Hotkey("^q", (*) => Quartz.Exit())
;             HotIf() ; Clear HotIf context
;         }
;     }
; }
