/************************************************************************
 * @description Improved Rich Text Editor with enhanced RTF handling
 * @file Quartz.ahk
 * @author Original by Laser Made, improvements by Claude
 * @date 2025/04/09
 * @version 1.5
 * @versioncodename Beta 1
 ***********************************************************************/
#Requires AutoHotkey v2+

; Include dependencies from local lib folder
#Include lib/Extensions/.modules/Pipe.ahk
#Include lib/Utilities/TestLogger.ahk
quartzTestLogger := TestLogger(A_LineFile)
#Include lib/Extensions/.modules/Clipboard.ahk
#Include lib/Extensions/.primitives/Keys.ahk
#Include lib/Abstratctions/WindowManager.ahk
#Include lib/System/WebView2.ahk
#Include lib/System/ComVar.ahk

; Add resources for compilation (source files to embed)
;@Ahk2Exe-AddResource index.html
;@Ahk2Exe-AddResource style.css
;@Ahk2Exe-AddResource script.js
;@Ahk2Exe-AddResource ..\lib\quill.css
;@Ahk2Exe-AddResource ..\lib\quill.js
;@Ahk2Exe-AddResource ..\lib\WebView2.ahk
;@Ahk2Exe-AddResource ..\lib\ComVar.ahk
;@Ahk2Exe-AddResource ..\lib\32bit\WebView2Loader.dll
;@Ahk2Exe-AddResource ..\lib\64bit\WebView2Loader.dll
;@Ahk2Exe-AddResource ..\fonts\poppins.css 

; FileInstall directives for compilation - includes all dependencies
Class qSetup {
	static arrDirs := ['./lib', './lib/32bit', './lib/64bit', './fonts']
	static __New() {
		this.installFiles()
		this.loadWebView2()
		this.createIni()
	}
	static makeDirs(){
		for dir in this.arrDirs {
			if !DirExist(dir){
				DirCreate(dir)
			}
		}
	}
static installFiles() {
	this.makeDirs()
	FileInstall('./index.html', './lib/index.html', 1)
	FileInstall('./style.css', './lib/style.css', 1)
	FileInstall('./script.js', './lib/script.js', 1)
	FileInstall('../lib/quill.css', './lib/quill.css', 1)
	FileInstall('../lib/quill.js', './lib/quill.js', 1)
	FileInstall('../lib/WebView2.ahk', './lib/WebView2.ahk', 1)
	FileInstall('../lib/ComVar.ahk', './lib/ComVar.ahk', 1)
	FileInstall('../lib/32bit/WebView2Loader.dll', './lib/32bit/WebView2Loader.dll', 1)
	FileInstall('../lib/64bit/WebView2Loader.dll', './lib/64bit/WebView2Loader.dll', 1)
	FileInstall('../fonts/poppins.css', './fonts/poppins.css', 1)
}
	static loadWebView2() {
		dllPath := A_PtrSize = 8
		? "./lib/64bit/WebView2Loader.dll"
		: "./lib/32bit/WebView2Loader.dll"
		if !FileExist(dllPath){
		return 0
		}
		return DllCall("LoadLibrary", "Str", dllPath, "Ptr")
	}
	static createIni() {
		path := {
			root: A_ScriptDir,
			html: A_ScriptDir '/lib/index.html',
			css: A_ScriptDir '/lib/style.css',
			js: A_ScriptDir '/lib/script.js',
			settings: A_ScriptDir '/lib/settings.ini',
			splash: A_ScriptDir '/lib/splash.mp4'
		}
		if !FileExist(path.settings) {
		ini := '
					(
					[Preferences]
			
					[About]
					Version=' Version '
					Title=' Title '
					CodeName=' CodeName '
					Description=' Description '
		)'
		FileAppend(ini, path.settings)
		}
	}
}

quartzTestLogger.Log("=== Quartz.ahk loaded - Debug logging enabled ===")

/**
 * @class Quartz
 * @description Rich Text Editor using AHK and WebView2 with improved RTF handling
 */
class Quartz {
	static filetypes := "Text Files (*.txt; *.rtf; *.html; *.css; *.js; *.ahk; *.ah2; *.ahk2; *.md; *.ini;)"
	
	; Path configuration that changes based on compilation status
	static rootDir := A_IsCompiled ? A_ScriptDir : A_ScriptDir "\.."
	static libDir := A_IsCompiled ? A_ScriptDir "\lib" : A_ScriptDir "\..\lib"
	static fontDir := A_IsCompiled ? A_ScriptDir "\fonts" : A_ScriptDir "\..\fonts"
	static srcDir := A_IsCompiled ? A_ScriptDir : A_ScriptDir
	
	static Version := "0.5"
	static CodeName := "Beta 1"
	static Description := "Rich Text Editor using AHK and JS/HTML/CSS"
	
	static path := {
		src: this.srcDir "\",
		html: this.srcDir "\index.html",
		css: this.srcDir "\style.css",
		js: this.srcDir "\script.js"
	}

	; Instance tracking - Map of HWND -> Quartz instance
	static instances := Map()
	static instanceCount := 0

	; Instance properties
	RTE := ""      ; GUI Window object
	WV2 := ""      ; WebView2 control
	HTML := ""     ; CoreWebView2 interface
	isLoaded := false  ; Flag to track if WebView2 is loaded
	instanceID := 0    ; Unique instance ID
	hwnd := 0          ; Window handle

	/**
	 * @constructor
	 * @param {String} initialText Optional text to initialize the editor with
	 */
	__New(initialText := "") {
		quartzTestLogger.Log("__New", "Creating new Quartz instance, initialText length: " StrLen(initialText))
		
		; Assign unique instance ID
		Quartz.instanceCount++
		this.instanceID := Quartz.instanceCount
		quartzTestLogger.Log("__New", "Instance ID: " this.instanceID)
		
		this.text := initialText
		this.SetupGUI()
		
		; Register this instance
		Quartz.instances[this.hwnd] := this
		quartzTestLogger.Log("__New", "Instance registered with HWND: " this.hwnd)
		
		; If initial text is provided, set it once the editor is loaded
		if (initialText != "") {
			this.WaitForLoad()
			this.SetText(initialText)
		}
		
		quartzTestLogger.Log("__New", "Instance created successfully")
	}

	/**
	 * @description Setup the GUI and WebView2 control
	 */
	SetupGUI() {
		quartzTestLogger.Log("SetupGUI", "Starting GUI setup")
		; TEMPORARILY REMOVED TRY/CATCH FOR DEBUGGING
		; try {
			this.RTE := Gui()
			quartzTestLogger.Log("SetupGUI", "Gui object created")
			this.RTE.Opt("+Resize +MinSize640x400")
			this.RTE.Title := "Quartz Rich Text Editor"
			this.RTE.OnEvent("Close", (*) => ExitApp())
			quartzTestLogger.Log("SetupGUI", "Close event handler registered")
			this.RTE.OnEvent("Size", (GuiObj, MinMax, Width, Height) => this.GuiSize(GuiObj, MinMax, Width, Height))
			quartzTestLogger.Log("SetupGUI", "Size event handler registered")

			; Show the GUI initially
			this.RTE.Show()
			quartzTestLogger.Log("SetupGUI", "GUI shown")
			
			; Store the window handle
			this.hwnd := this.RTE.Hwnd
			quartzTestLogger.Log("SetupGUI", "HWND stored: " this.hwnd)
			
			; Position and size the window using WindowManager (right 30% of screen)
			WindowManager(this.hwnd).LeftSide()
			quartzTestLogger.Log("SetupGUI", "Window positioned")

			; Create WebView2 control
			this.WV2 := WebView2.create(this.RTE.Hwnd)
			quartzTestLogger.Log("SetupGUI", "WebView2.create() called")

			; Wait for the WebView2 to be fully created
			while !this.WV2.CoreWebView2 {
				Sleep(A_Delay)
			}
			quartzTestLogger.Log("SetupGUI", "WebView2.CoreWebView2 ready")

			this.HTML := this.WV2.CoreWebView2
			this.HTML.Navigate("file:///" Quartz.path.html)
			quartzTestLogger.Log("SetupGUI", "Navigating to: file:///" Quartz.path.html)
			
			this.HTML.AddHostObjectToScript("ahk", { 
				about: this.About.Bind(this), 
				OpenFile: this.OpenFile.Bind(this), 
				SaveFile: this.SaveFile.Bind(this), 
				get: this.GetText.Bind(this), 
				getHTML: this.GetHTML.Bind(this), 
				exit: this.Exit.Bind(this) 
			})
			quartzTestLogger.Log("SetupGUI", "Host objects added to script")

			; Register for navigation completed event
			this.HTML.add_NavigationCompleted(WebView2.Handler(this.OnNavigationCompleted.Bind(this)))
			quartzTestLogger.Log("SetupGUI", "Setup complete, navigation event registered")
		; }
		; catch Error as err {
		; 	; MsgBox("Error in SetupGUI: " err.Message)
		; 	throw err
		; }
	}

	/**
	 * @description Event handler for WebView2 navigation completed
	 * @param {Ptr} this The this pointer (COM interface)
	 * @param {Ptr} sender The sender object pointer
	 * @param {Ptr} args Event arguments pointer
	 */
	OnNavigationCompleted(this_ptr, sender, args) {
		quartzTestLogger.Log("OnNavigationCompleted", "Navigation completed, setting isLoaded to true")
		this.isLoaded := true
		quartzTestLogger.Log("OnNavigationCompleted", "isLoaded is now: " this.isLoaded)
	}

	/**
	 * @description Event handler for script execution completion
	 * @param {Object} handler The handler object
	 * @param {Integer} errorCode Error code if any
	 * @param {String} resultObjectAsJson Result as JSON string
	 */
	OnScriptExecuted(handler, errorCode, resultObjectAsJson) {
		; Handle any errors here if needed
	}

	/**
	 * @description Wait for the WebView2 control to be fully loaded
	 * @param {Integer} timeout Maximum time to wait in milliseconds
	 * @returns {Boolean} True if loaded successfully, false otherwise
	 */
	WaitForLoad(timeout := 5000) {
		startTime := A_TickCount
		while (!this.isLoaded) {
			Sleep(20)
			if (A_TickCount - startTime > timeout) {
				return false
			}
		}
		return true
	}

	/**
	 * @description Handle GUI resize event
	 * @param {Gui} GuiObj The GUI object
	 * @param {Integer} MinMax Minimized/maximized state
	 * @param {Integer} Width New width
	 * @param {Integer} Height New height
	 */
	GuiSize(GuiObj, MinMax, Width, Height) {
		if (MinMax = -1)
			return
		; Only resize if WV2 has been created (not during initial setup)
		if (!IsObject(this.WV2))
			return
		try {
			this.WV2.Fill()
		} catch Error as err {
			; MsgBox("Error in GuiSize: " err.Message)
			throw err
		}
	}

	/**
	 * @description Display About information
	 */
	About() {
		if (!this.isLoaded) {
			Infos("WebView is not fully loaded yet.")
			return
		}
		try {
			this.HTML.ExecuteScript("about()")
		} catch Error as err {
			throw err
		}
	}

	/**
	 * @description Focus the editor
	 * @description Works in both script and compiled forms
	 * @returns {Quartz} This instance for method chaining
	 */
	Focus() {
		if (!this.isLoaded) {
			quartzTestLogger.Log("Focus", "WebView not loaded, waiting...")
			this.WaitForLoad()
		}
		
		try {
			; Activate the GUI window first
			WinActivate(this.RTE.Hwnd)
			
			; Focus the Quill editor within the WebView
			this.HTML.ExecuteScript("quill.focus()")
			
			quartzTestLogger.Log("Focus", "Editor focused successfully")
			return this
		} catch Error as err {
			quartzTestLogger.Log("Focus", "Error focusing editor: " err.Message)
			throw Error("Failed to focus editor: " err.Message, -1)
		}
	}

	/**
	 * @description Focus the editor (static version for external calls)
	 * @description Works in both script and compiled forms
	 * @returns {Quartz|false} Active instance if successful, false otherwise
	 */
	static Focus() {
		try {
			instance := Quartz.GetActiveInstance()
			if (instance) {
				return instance.Focus()
			} else {
				quartzTestLogger.Log("Focus", "No active Quartz editor instance found")
				return false
			}
		} catch Error as err {
			quartzTestLogger.Log("Focus", "Error in static Focus: " err.Message)
			throw err
		}
	}

	/**
	 * @description Open a file for editing (static version for hotkey support)
	 * @param {String} savedfile Optional path to file to open
	 */
	static OpenFile(savedfile := "") {
		try {
			instance := Quartz.GetActiveInstance()
			if (instance) {
				return instance.OpenFile(savedfile)
			} else {
				Infos("No active Quartz editor instance found.")
			}
		} catch Error as err {
			Infos("Error in static OpenFile: " err.Message)
			throw err
		}
	}

	/**
	 * @description Open a file for editing (instance version)
	 * @param {String} savedfile Optional path to file to open
	 */
	OpenFile(savedfile := "") {
		; if (!this.isLoaded) {
		; 	throw Error("WebView is not fully loaded yet.")
		; 	return
		; }
		try {
			if (savedfile = "") {
				selected := FileSelect(,, "Select a file to open", Quartz.filetypes)
			} else {
				selected := savedfile
			}

			if (selected = "" || !FileExist(selected)) {
				return
			}
			infos("Opening file: " selected)
			if (InStr(selected, "rtf")) {
				infos("Detected RTF file.")
				this.OpenRTF(selected)
			} else {
				infos("Detected text file.")
				this.OpenTextFile(selected)
			}
		} catch Error as err {
			; MsgBox("Error in OpenFile: " err.Message)
			throw err
		}
	}

	Eval(script) {
		; ExecuteScript is async by default in WebView2, returns a promise/await
		try {
			result := this.HTML.ExecuteScript(script)
			return result
		} catch Error as err {
			MsgBox("Error executing script: " err.Message "`n`nScript: " script)
			throw err
		}
	}
	ToggleOnTop(window) {
		WinSetAlwaysOnTop(-1, window)
	}

	/**
	 * @description Open and render an RTF file with formatting preserved
	 * @param {String} rtfFile Path to RTF file
	 */
	OpenRTF(rtfFile) {
		quartzTestLogger.Log("OpenRTF", "Starting RTF file open: " rtfFile)
		try {
			; Wait for WebView2 to be loaded
			if (!this.isLoaded) {
				quartzTestLogger.Log("OpenRTF", "WebView not loaded, waiting...")
				this.WaitForLoad()
				quartzTestLogger.Log("OpenRTF", "WebView now loaded")
			}
			
			quartzTestLogger.Log("OpenRTF", "Attempting ComObjGet...")
			; Use ComObjGet to access the RTF file (simpler than Word automation)
			doc := ComObjGet(rtfFile)
			quartzTestLogger.Log("OpenRTF", "ComObjGet successful")
			
			quartzTestLogger.Log("OpenRTF", "Backing up clipboard...")
			; Backup the current clipboard
			Clipboard.BackupAll(&cBak)
			quartzTestLogger.Log("OpenRTF", "Clipboard backed up")
			
			quartzTestLogger.Log("OpenRTF", "Setting SendMode...")
			SM(&objSM)
			quartzTestLogger.Log("OpenRTF", "SendMode set")
			
			quartzTestLogger.Log("OpenRTF", "Copying formatted text to clipboard...")
			; Copy the formatted content to clipboard using Win32 API
			doc.content.formattedText.copy()
			quartzTestLogger.Log("OpenRTF", "Formatted text copied, waiting for clipboard...")
			Clipboard.Wait()
			quartzTestLogger.Log("OpenRTF", "Clipboard ready")
			Sleep(300)
			
			quartzTestLogger.Log("OpenRTF", "Activating window HWND: " this.RTE.Hwnd)
			; Activate our editor window
			WinActivate(this.RTE.Hwnd)
			quartzTestLogger.Log("OpenRTF", "Window activated, waiting for active state...")
			WinWaitActive(this.RTE.Hwnd, , 2)
			quartzTestLogger.Log("OpenRTF", "Window is active")
			
			quartzTestLogger.Log("OpenRTF", "Focusing Quill editor via JavaScript...")
			; Focus the Quill editor using Eval method (which has proper handler)
			this.Eval('quill.focus()')
			
			quartzTestLogger.Log("OpenRTF", "Focus script sent, waiting 500ms for focus to complete...")
			Sleep(500)  ; Give time for focus to complete
			quartzTestLogger.Log("OpenRTF", "Focus wait complete")
			
			quartzTestLogger.Log("OpenRTF", "Sending paste command: " keys.paste)
			; Paste using keyboard input
			Send(keys.paste)
			quartzTestLogger.Log("OpenRTF", "Paste sent, waiting 300ms...")
			Sleep(300)
			
			quartzTestLogger.Log("OpenRTF", "Navigating to top of document...")
			; Go to top of document
			Send(keys.ctrldown keys.home keys.ctrlup)
			quartzTestLogger.Log("OpenRTF", "Navigation complete")
			Sleep(100)
			
			quartzTestLogger.Log("OpenRTF", "Restoring clipboard...")
			; Restore clipboard
			Clipboard.RestoreAll(cBak)
			quartzTestLogger.Log("OpenRTF", "RTF file opened successfully!")
		}
		catch Error as err {
			quartzTestLogger.Log("OpenRTF", "ERROR: " err.Message)
			; More detailed error handling
			errDetail := "Error opening RTF file: " err.Message
			if (RegExMatch(err.Message, "i)com\s+error")) {
				errDetail .= "`n`nThis may be due to:`n"
				errDetail .= "• The RTF file is corrupted or invalid`n"
				errDetail .= "• Windows doesn't have an RTF viewer registered`n"
				errDetail .= "• Permissions issue accessing the file"
			}
			; MsgBox(errDetail, "RTF Import Error", "Icon!")
			throw err
		}
	}

	/**
	 * @description Open and render a text file
	 * @param {String} file Path to text file
	 */
	OpenTextFile(file) {
		try {
			fileContent := FileRead(file)
			escapedContent := StrReplace(fileContent, "\", "\\")
			escapedContent := StrReplace(escapedContent, "`r`n", "\n")
			escapedContent := StrReplace(escapedContent, "`n", "\n")
			escapedContent := StrReplace(escapedContent, "'", "\'")
			
			this.HTML.ExecuteScript("quill.setText('" escapedContent "')")
		} catch Error as err {
			throw err
		}
	}

	/**
	 * @description Save the content to a file (instance version)
	 * @param {String} content Content to save
	 */
	SaveFile(content) {
		if (!this.isLoaded) {
			throw Error("WebView is not fully loaded yet.")
			return
		}
		try {
			selected := FileSelect("S",, "Select a file to save", Quartz.filetypes)
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
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Save the content to a file (static version for hotkey support)
	 * @param {String} content Content to save
	 */
	static SaveFile(content) {
		try {
			instance := Quartz.GetActiveInstance()
			if (instance) {
				return instance.SaveFile(content)
			} else {
				throw Error("No active Quartz editor instance found.")
		}
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Get the text content from the editor
	 * @returns {String} Text content
	 */
	GetText() {
		if (!this.isLoaded) {
			throw Error("WebView is not fully loaded yet.")
			return
		}
		try {
			; Return the editor text synchronously (wrapper awaits the async call)
			return this.HTML.ExecuteScript("return quill.getText();")
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Get the HTML content from the editor
	 * @returns {String} HTML content
	 */
	GetHTML() {
		if (!this.isLoaded) {
			throw Error("WebView is not fully loaded yet.")
			return
		}
		try {
			; Need handler with return value 
			return this.HTML.ExecuteScript("return quill.root.innerHTML;")
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Set the text content of the editor
	 * @param {String} text Text to set
	 */
	SetText(text) {
		if (!this.isLoaded) {
			throw Error("WebView is not fully loaded yet.")
			return
		}
		try {
			escapedText := StrReplace(text, "'", "\'")
			this.HTML.ExecuteScript("quill.setText('" escapedText "');")
	} catch Error as err {
		throw err
	}
}

/**
 * @description Handles GUI close event with logging
 */
OnClose() {
	quartzTestLogger.Log("OnClose", "Close event fired - X button clicked")
	quartzTestLogger.Log("OnClose", "Calling Exit() method")
	this.Exit()
}

	/**
	 * @description Exit the application and clean up resources
	 */
	Exit() {
		quartzTestLogger.Log("Exit", "Exit() called for instance ID: " this.instanceID ", HWND: " this.hwnd)
		; TEMPORARILY REMOVED TRY/CATCH FOR DEBUGGING
		; try {
			if (this.isLoaded) {
				quartzTestLogger.Log("Exit", "Editor is loaded, calling exitApp()")
				this.HTML.ExecuteScript("exitApp()")
			} else {
				quartzTestLogger.Log("Exit", "Editor not loaded, skipping exitApp()")
			}
			
			; Unregister this instance
			if Quartz.instances.Has(this.hwnd) {
				quartzTestLogger.Log("Exit", "Unregistering instance from map")
				Quartz.instances.Delete(this.hwnd)
			}
			
			this.HTML := this.WV2 := ""
			quartzTestLogger.Log("Exit", "Destroying GUI")
			this.RTE.Destroy()
		; } catch Error as err {
		; 	throw err
		; }
		
		; If no more instances, exit the app
		quartzTestLogger.Log("Exit", "Remaining instances: " Quartz.instances.Count)
		if (Quartz.instances.Count = 0) {
			quartzTestLogger.Log("Exit", "No more instances, calling ExitApp()")
			ExitApp()
		}
	}
	
	/**
	 * @description Get the active Quartz instance based on the active window
	 * @returns {Quartz|false} The active instance or false if none found
	 * @static
	 */
	static GetActiveInstance() {
		try {
			; Get the active window handle
			activeHwnd := WinGetID("A")
			
			; Check if it's a Quartz window
			if Quartz.instances.Has(activeHwnd) {
				return Quartz.instances[activeHwnd]
			}
			
			; If not found directly, check if the active window is a child of any Quartz instance
			for hwnd, instance in Quartz.instances {
				if WinActive("ahk_id " hwnd) {
					return instance
				}
			}
			
			return false
		} catch Error as err {
			return false
		}
	}

	/**
	 * @description Get a specific instance by window handle
	 * @param {Integer} hwnd Window handle
	 * @returns {Quartz|false} The instance or false if not found
	 * @static
	 */
	static GetInstance(hwnd) {
		return Quartz.instances.Has(hwnd) ? Quartz.instances[hwnd] : false
	}

	/**
	 * @description Get all active instances
	 * @returns {Map} Map of all instances
	 * @static
	 */
	static GetAllInstances() {
		return Quartz.instances
	}

	/**
	 * @description Create a new file (static version for hotkey support)
	 */
	static NewFile() {
		try {
			instance := Quartz.GetActiveInstance()
			if (instance) {
			return instance.NewFile()
		} else {
			throw Error("No active Quartz editor instance found.")
		}
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Create a new file (instance version)
	 */
	NewFile() {
		if (!this.isLoaded) {
			throw Error("WebView is not fully loaded yet.")
			return
		}
		try {
			this.HTML.ExecuteScript("newFile()")
	}
	catch Error as err {
		throw err
	}
}	
	/**
	 * @description Get the plain text from the editor for interop with AHK
	 * @returns {String} Plain text content
	 */
	PassTextToAHK() {
		if (!this.isLoaded) {
			throw Error("WebView is not fully loaded yet.")
			return
	}
	try {
		return this.HTML.ExecuteScript("return quill.getText();")
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Get the HTML from the editor for interop with AHK
	 * @returns {String} HTML content
	 */
	PassHTMLToAHK() {
		if (!this.isLoaded) {
			throw Error("WebView is not fully loaded yet.")
			return
		}
		try {
			return this.HTML.ExecuteScript("return quill.root.innerHTML;")
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Static version of PassHTMLToAHK for hotkey/global use
	 * @returns {String} HTML content
	 */
	static PassHTMLToAHK() {
		try {
			instance := Quartz.GetActiveInstance()
			if (instance) {
				return instance.PassHTMLToAHK()
			} else {
				throw Error("No active Quartz editor instance found.")
			}
	} catch Error as err {
		throw err
	}
}
	/**
	 * @description Static factory method to create a new instance
	 * @param {String} initialText Optional text to initialize with
	 * @returns {Quartz} New Quartz instance
	 */
	static New(initialText := "") {
		return Quartz(initialText)
	}

	/**
	 * @description Static Exit method for hotkey/global use
	 */
	static Exit() {
		try {
			instance := Quartz.GetActiveInstance()
			if (instance) {
				return instance.Exit()
		} else {
			throw Error("No active Quartz editor instance found.")
		}
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Static About method for hotkey/global use
	 */
	static About() {
		try {
			instance := Quartz.GetActiveInstance()
			if (instance) {
				return instance.About()
		} else {
			throw Error("No active Quartz editor instance found.")
		}
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Apply formatting to selected text via Quill API
	 * @param {String} formatName Format to apply (e.g., 'strike', 'bold', 'italic', 'underline')
	 * @param {Any} value Format value (default: true for toggle)
	 */
	ApplyFormat(formatName, value := "true") {
		try {
			if (!this.isLoaded) {
				throw Error("Editor is not yet loaded.")
				return
			}
			
			; Execute JavaScript to apply formatting
			script := "applyFormat('" formatName "', " value ");"
			; Use synchronous ExecuteScript (wrapper will call ExecuteScriptAsync and await)
			this.HTML.ExecuteScript(script)
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Toggle strikethrough formatting for selected text
	 */
	ToggleStrikethrough() {
		try {
			if (!this.isLoaded) {
				throw Error("Editor is not yet loaded.")
				return
			}
			
		; Toggle strikethrough via ExecuteScript
		this.HTML.ExecuteScript("toggleStrikethrough();")
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Static method to toggle strikethrough for hotkey use
	 */
	static ToggleStrikethrough() {
		try {
			instance := Quartz.GetActiveInstance()
			if (instance) {
				return instance.ToggleStrikethrough()
		} else {
			throw Error("No active Quartz editor instance found.")
		}
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Enable or disable live markdown conversion mode
	 * @param {Boolean} enable Whether to enable markdown mode (default: true)
	 */
	EnableMarkdownMode(enable := true) {
		try {
			if (!this.isLoaded) {
				throw Error("Editor is not yet loaded.")
				return
			}
			
			enableStr := enable ? "true" : "false"
			this.HTML.ExecuteScript("enableMarkdownMode(" enableStr ");")
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Import markdown text into the editor
	 * @param {String} markdown Markdown text to import
	 */
	ImportMarkdown(markdown) {
		try {
			if (!this.isLoaded) {
				throw Error("Editor is not yet loaded.")
				return
			}
			
			; Escape the markdown text for JavaScript
			escapedMarkdown := StrReplace(markdown, "\", "\\")
			escapedMarkdown := StrReplace(escapedMarkdown, "'", "\'")
			escapedMarkdown := StrReplace(escapedMarkdown, "`n", "\n")
			escapedMarkdown := StrReplace(escapedMarkdown, "`r", "")
			
			this.HTML.ExecuteScript("importMarkdown('" escapedMarkdown "');")
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Static method to enable markdown mode for hotkey use
	 */
	static EnableMarkdownMode(enable := true) {
		try {
			instance := Quartz.GetActiveInstance()
			if (instance) {
				return instance.EnableMarkdownMode(enable)
			} else {
				throw Error("No active Quartz editor instance found.")
		}
	} catch Error as err {
		throw err
	}
}	
	/**
	 * @description Handle RTF content from clipboard with ADODB.Stream approach
	 * @returns {Quartz} This instance for method chaining
	 */
	EditorRTF() {
		try {
			; Get clipboard content
			clipContent := A_Clipboard
			
			; Check if content appears to be RTF
			; if (SubStr(clipContent, 1, 5) != "{\rtf") {
			; 	Infos("Clipboard does not contain RTF content.", "RTF Import", 48)
			; 	return this
			; }
			
			; Create ADODB.Stream object
			stream := ComObject("ADODB.Stream")
			
			try {
				; Configure the stream for text
				stream.Type := 2 ; adTypeText
				stream.Charset := "UTF-8"
				stream.Open()
				
				; Write RTF content to the stream
				stream.WriteText(clipContent)
				
				; Position the stream at the beginning
				stream.Position := 0
				
				; Create Word application
				word := ComObject("Word.Application")
				word.Visible := false
				
				try {
					; Create a new document
					doc := word.Documents.Add()
					
					try {
						; Get the range where we'll insert the content
						range := doc.Range()
						
						; Insert the RTF content from the stream
						range.InsertFile("", "", false, false, stream)
						
						; Copy the formatted content to clipboard
						Clipboard.BackupAll(&cBak)
						doc.Range.FormattedText.Copy
						Clipboard.Sleep()
						
						; Activate our editor window and focus the editor
						this.Focus()
						
						Send(keys.paste)
						Sleep(A_Delay)
						
						; Restore clipboard
						Clipboard.RestoreAll(cBak)
					}
					finally {
						; Close document without saving
						doc.Close(false)
						ObjRelease(doc)
					}
				}
				finally {
					; Quit Word and release COM object
					word.Quit()
					ObjRelease(word)
				}
			}
			finally {
			; Always close the stream and release the COM object
			stream.Close()
			ObjRelease(stream)
		}
	}
	catch Error as err {
		throw err
	}
	
	return this
}	
	/**
	 * @description Handle RTF content via JavaScript RTF parser
	 * @param {String} rtfContent RTF content to process
	 * @returns {Quartz} This instance for method chaining
	 */
	ImportRTFasHTML(rtfContent := "") {
		if (!this.isLoaded) {
			throw Error("WebView is not fully loaded yet.")
			return this
		}
		
		try {
			; If no content provided, try to get it from clipboard
			; if (rtfContent == "") {
			; 	rtfContent := A_Clipboard
			; 	if (SubStr(rtfContent, 1, 5) != "{\rtf") {
			; 		MsgBox("Clipboard does not contain RTF content.", "RTF Import", 48)
			; 		return this
			; 	}
			; }
			
			; Escape the RTF content for JavaScript
			escapedRTF := this.EscapeForJS(rtfContent)
			
				; Call the JavaScript function to handle RTF
				this.HTML.ExecuteScript("importRTFasHTML(" escapedRTF ");")
	} 
	catch Error as err {
		throw err
	}
	
	return this
}	
	/**
	 * @description Handle RTF content via JavaScript with Delta format
	 * @param {String} rtfContent RTF content to process
	 * @returns {Quartz} This instance for method chaining
	 */
	ImportRTFasDelta(rtfContent := "") {
		if (!this.isLoaded) {
			throw Error("WebView is not fully loaded yet.")
			return this
		}
		
		try {
			; If no content provided, try to get it from clipboard
			; if (rtfContent == "") {
			; 	rtfContent := A_Clipboard
			; 	if (SubStr(rtfContent, 1, 5) != "{\rtf") {
			; 		MsgBox("Clipboard does not contain RTF content.", "RTF Import", 48)
			; 		return this
			; 	}
			; }
			
			; Escape the RTF content for JavaScript
			escapedRTF := this.EscapeForJS(rtfContent)
			
				; Call the JavaScript function to handle RTF
				this.HTML.ExecuteScript("importRTFasHTML(" escapedRTF ");")
	} 
	catch Error as err {
		throw err
	}
	
	return this
}	
	/**
	 * @private
	 * @description Escape a string for JavaScript
	 * @param {String} str String to escape
	 * @returns {String} Escaped string
	 */
	EscapeForJS(str) {
		; Replace backslashes first (important!)
		str := StrReplace(str, "\", "\\")
		
		; Replace other special characters
		str := StrReplace(str, "`r`n", "\n")
		str := StrReplace(str, "`n", "\n")
		str := StrReplace(str, "`t", "\t")
		str := StrReplace(str, "'", "\'")
		str := StrReplace(str, "`"", "\`"")
		
		return str
	}
	
	/**
	 * @description Detects edit control type (plain text, rich text, etc.)
	 * @param {Integer} hwnd Handle to the control
	 * @returns {String} "PlainText", "RichText", or "Unknown"
	 * @static
	 */
	static DetermineEditControlType(hwnd) {
		try {
			; Get the class name
			className := WinGetClass("ahk_id " hwnd)
			
			; Common class names
			if (className = "Edit")
				return "PlainText"
				
			if (InStr(className, "RICHEDIT") || InStr(className, "RichEdit"))
				return "RichText"
				
			; For WebView or other embedded controls, try sending messages
			; EM_GETOLEINTERFACE is only supported in rich edit controls
			result := SendMessage(0x43C, 0, 0, , "ahk_id " hwnd)  ; EM_GETOLEINTERFACE
			if (result)
				return "RichText"
				
			return "Unknown"
		}
		catch Error as err {
			return "Unknown"
		}
	}
}

; Create initial instance when script runs directly
; Check if a file was passed as a parameter
if (A_Args.Length > 0 && FileExist(A_Args[1])) {
	quartzTestLogger.Log("Main", "Opening file from command line: " A_Args[1])
	editor := Quartz()
	editor.OpenFile(A_Args[1])
} else {
	quartzTestLogger.Log("Main", "Creating new Quartz instance")
	editor := Quartz()
	; TEMPORARY: Auto-open test RTF file
	Sleep(1000)  ; Wait for GUI to fully initialize
	testFile := A_ScriptDir "\..\(AJB - 2024.06.19) - test file.rtf"
	if FileExist(testFile) {
		quartzTestLogger.Log("Main", "Auto-opening test file: " testFile)
		editor.OpenFile(testFile)
	}
}

; ---------------------------------------------------------------------------
; Hotkeys - Context-sensitive to Quartz Rich Text Editor window
; ---------------------------------------------------------------------------
#HotIf WinActive("Quartz Rich Text Editor")

; File operations
^+n::Quartz.NewFile()                          ; Ctrl+Shift+N - New file
^+o::Quartz.OpenFile()                         ; Ctrl+Shift+O - Open file
^+s::{                                         ; Ctrl+Shift+S - Save file
	instance := Quartz.GetActiveInstance()
	if (instance) {
		Quartz.SaveFile(instance.GetHTML())
	}
}
^+t::{                                         ; Ctrl+Shift+T - Show text
	instance := Quartz.GetActiveInstance()
	if (instance) {
		infos(instance.PassTextToAHK())
	}
}
^+h::infos(Quartz.PassHTMLToAHK())           ; Ctrl+Shift+H - Show HTML
^+q::Quartz.Exit()                            ; Ctrl+Shift+Q - Quit
^+a::Quartz.About()                           ; Ctrl+Shift+A - About

; RTF operations
^+e::{                                         ; Ctrl+Shift+E - Import RTF (ADODB.Stream)
	instance := Quartz.GetActiveInstance()
	if (instance) {
		instance.EditorRTF()
	}
}
; ^v hotkey removed to allow normal paste functionality
; Use Shift+Insert or right-click paste instead
; ^v::{                                          ; Ctrl+V - Paste RTF as Delta
; 	instance := Quartz.GetActiveInstance()
; 	if (instance) {
; 		instance.ImportRTFasDelta()
; 	}
; }
^+f::{                                         ; Ctrl+Shift+F - Import RTF as HTML
	instance := Quartz.GetActiveInstance()
	if (instance) {
		instance.ImportRTFasHTML()
	}
}

; Formatting hotkeys - Direct Quill API calls
!s::Quartz.ToggleStrikethrough()              ; Alt+S - Toggle strikethrough
^+x::Quartz.ToggleStrikethrough()             ; Ctrl+Shift+X - Toggle strikethrough (alternative)

; Markdown mode
^+m::Quartz.EnableMarkdownMode(true)          ; Ctrl+Shift+M - Enable markdown mode
^!m::Quartz.EnableMarkdownMode(false)         ; Ctrl+Alt+M - Disable markdown mode

#HotIf
; ---------------------------------------------------------------------------
