/**
 * @class TestLogger
 * @description Non-blocking GUI logger for test output with singleton pattern
 * @version 3.1.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-11-10
 * @requires AutoHotkey v2.0+
 * @changes
 *   v3.1.0:
 *   - Added singleton pattern with instance tracker
 *   - Constructor now prevents duplicate instances per script name
 *   - Added TestLogger.GetInstance() static method for explicit singleton access
 *   - Library files using TestLogger(A_LineFile) automatically get singleton behavior
 *   - Prevents multiple logger instances when library is included by multiple scripts
 *   
 *   v3.0.0:
 *   - Converted to instance-only class - removed all static functionality
 *   - Each logger instance is fully independent with its own state
 *   - Simplified architecture: no static/instance duplication
 *   - Removed global/static logger concept - all usage is instance-based
 *   - Removed instances tracking and auto-tiling features
 *   - Cleaner, more maintainable codebase focused on single responsibility
 *   
 *   v2.5.0:
 *   - Completed full unification: _CreateGUI() now delegates to __CreateGUI(target, isStatic)
 *   - Eliminated final ~80 lines of duplicated GUI creation code
 *   - Total code reduction: ~280 lines eliminated across all method pairs
 * @example
 *   ; Main script pattern (creates unique instance per script)
 *   myLogger := TestLogger(A_LineFile)  ; Disabled by default
 *   myLogger.Enable()
 *   myLogger.SetState("running")
 *   myLogger.Log("Test 1", "Message content")
 *   
 *   ; Library file pattern (singleton - returns same instance if already created)
 *   ; ThemeMgr.ahk:
 *   themeLogger := TestLogger(A_LineFile)  ; Only creates ONE instance for "ThemeMgr"
 *   ; Even if ThemeMgr is included by multiple scripts, they all share the same logger
 *   
 *   ; Explicit singleton access
 *   logger := TestLogger.GetInstance("ThemeMgr")  ; Returns existing or creates new
 *   
 *   ; Legacy pattern still works (creates independent instances)
 *   OmniTestLogger := TestLogger("Omnibar")
 *   OmniTestLogger.Enable()
 */

#Requires AutoHotkey v2+
#Warn All, OutputDebug

;? this is my lib file, for Quartz-RTE, use the one below
;! for the local lib files, comment out the below and uncomment the ones after
; #Include <Extensions/.structs/Array>

;? this the local lib files, for Quartz-RTE, use this one
;! for the local lib files, uncomment the ones below
#Include ../Extensions/.structs/Array.ahk

class TestLogger {
	; -----------------------------------------------------------------------
	; @region Static Instance Tracker (Singleton Pattern)
	/**
	 * @static
	 * @property {Map} _instances - Map tracking all created instances by script name
	 * @description Ensures only one TestLogger instance per script name
	 */
	static _instances := Map()
	
	/**
	 * @static
	 * @method GetInstance
	 * @description Get or create a TestLogger instance for a script (singleton pattern)
	 * @param {String} scriptName Script name or path (uses A_LineFile if path)
	 * @param {Boolean} autoEnable Enable automatically on creation
	 * @returns {TestLogger} Existing or new TestLogger instance
	 * @example
	 *   logger := TestLogger.GetInstance(A_LineFile)
	 *   logger := TestLogger.GetInstance("MyScript", true)
	 */
	static GetInstance(scriptName, autoEnable := false) {
		; Extract clean script name from path if needed
		cleanName := scriptName
		if (InStr(scriptName, "\") || InStr(scriptName, "/")) {
			SplitPath(scriptName, &fileName)
			cleanName := RegExReplace(fileName, "\.ahk$", "")
		}
		
		; Return existing instance if already created
		if (TestLogger._instances.Has(cleanName)) {
			return TestLogger._instances[cleanName]
		}
		
		; Create new instance (bypass singleton check in constructor)
		instance := TestLogger(scriptName, autoEnable, true)  ; true = internal flag
		TestLogger._instances[cleanName] := instance
		return instance
	}
	; @endregion Static Instance Tracker
	; -----------------------------------------------------------------------
	
	; -----------------------------------------------------------------------
	; @region Instance Properties
	logs := []
	gui := ""
	logEdit := ""
	statusBar := ""  ; Native Windows status bar control
	isVisible := false
	enabled := false  ; Instance-specific enable/disable
	autoShow := true
	logFilePath := Paths.Lib '\.loggers\.testlogger\'
	autoSave := true
	callingScript := ""
	callingScriptPath := ""
	state := "startup"  ; Track logger state: startup | running | complete
	; @endregion Instance Properties
	; -----------------------------------------------------------------------

	; @region Constructor
	/**
	 * @constructor __New
	 * @description Create a new instance-based logger
	 * @param {String} [scriptName=""] Optional script name for this instance (can be A_LineFile)
	 * @param {Boolean} [autoEnable=false] Automatically enable this instance
	 * @param {Boolean} [_internalBypass=false] Internal flag - bypass singleton check
	 * @note For library files, use TestLogger.GetInstance(A_LineFile) to ensure singleton behavior
	 * @example
	 *   ; Direct instantiation (creates new instance every time)
	 *   logger := TestLogger("MyScript")
	 *   
	 *   ; Singleton pattern (recommended for library files)
	 *   logger := TestLogger.GetInstance(A_LineFile)
	 */
	__New(scriptName := "", autoEnable := false, _internalBypass := false) {
		; Singleton check - if not bypassed, redirect to GetInstance
		if (!_internalBypass && scriptName != "") {
			; Check if instance already exists for this script
			cleanName := scriptName
			if (InStr(scriptName, "\") || InStr(scriptName, "/")) {
				SplitPath(scriptName, &fileName)
				cleanName := RegExReplace(fileName, "\.ahk$", "")
			}
			
			if (TestLogger._instances.Has(cleanName)) {
				; Return existing instance - but we can't return from __New
				; So we'll just populate this instance with the existing one's data
				existing := TestLogger._instances[cleanName]
				this.logs := existing.logs
				this.gui := existing.gui
				this.logEdit := existing.logEdit
				this.statusBar := existing.statusBar
				this.isVisible := existing.isVisible
				this.enabled := existing.enabled
				this.autoShow := existing.autoShow
				this.logFilePath := existing.logFilePath
				this.autoSave := existing.autoSave
				this.callingScript := existing.callingScript
				this.callingScriptPath := existing.callingScriptPath
				this.state := existing.state
				return  ; Don't continue with normal initialization
			} else {
				; Register this new instance
				TestLogger._instances[cleanName] := this
			}
		}
		
		; Capture the calling script's file path for this instance
		if (scriptName != "") {
			; If scriptName looks like a file path (contains \ or /), extract just the filename
			if (InStr(scriptName, "\") || InStr(scriptName, "/")) {
				this.callingScriptPath := scriptName
				SplitPath(scriptName, &fileName)
				; Remove .ahk extension for cleaner display
				this.callingScript := RegExReplace(fileName, "\.ahk$", "")
			} else {
				; Use the provided name directly
				this.callingScript := scriptName
			}
		} else {
			; No name provided, use script path
			if A_LineFile != A_ScriptFullPath {
				this.callingScriptPath := A_ScriptFullPath
				SplitPath(this.callingScriptPath, &fileName)
				this.callingScript := RegExReplace(fileName, "\.ahk$", "")
			}
			
			; Fallback if detection failed
			if (!this.callingScript) {
				this.callingScript := "Instance_" A_TickCount
			}
		}
		
		; Initialize instance properties
		this.logs := []
		this.enabled := autoEnable
		
		; Return instance for method chaining
		return this
	}
	; @endregion Constructor

	; -----------------------------------------------------------------------
	; @region Logging Methods

	; @region Enable()
	/**
	 * @method Enable
	 * @description Enable logging
	 * @param {Boolean} [enableAutoSave=true] Enable/disable autosave for this logger
	 * @example
	 *   myLogger.Enable()    ; Instance - enable this instance
	 */
	Enable(enableAutoSave := true) {
		this.enabled := true
		this.autoSave := enableAutoSave
		return this
	}

	; @region Disable()
	/**
	 * @method Disable
	 * @description Disable logging
	 * @example
	 *   myLogger.Disable()    ; Instance - disable this instance
	 */
	Disable() {
		this.enabled := false
		return this
	}

	; @region SetState()
	/**
	 * @method SetState
	 * @description Set the logger state (startup/running/complete) and update status bar
	 * @param {String} newState - One of: "startup", "running", "complete"
	 * @example
	 *   myLogger.SetState("complete")    ; Instance
	 */
	SetState(newState) {
		if (newState ~= "i)^(startup|running|complete)$") {
			this.state := newState
			this._UpdateDisplay()
		}
		return this
	}

	; @region Log()
	/**
	 * @method Log
	 * @description Log a general message
	 * @param {String} title Message title/category
	 * @param {String} message Message content
	 * @example
	 *   myLogger.Log("Test", "Message")    ; Instance
	 */
	Log(title, message := "") {
		if (!this.enabled)
			return this
			
		timestamp := FormatTime(A_Now, "HH:mm:ss")
		entry := Format("[{1}] {2}: {3}", timestamp, title, message)
		this.logs.Push(entry)
		OutputDebug(entry)
		
		if (this.autoSave && this.logFilePath) {
			this._AppendToFile(entry)
		}
		
		if (this.autoShow && !this.isVisible) {
			this.Show()
		} else if (this.isVisible) {
			this._UpdateDisplay()
		}
		
		return this
	}

	; @region Info()
	/**
	 * @method Info
	 * @description Log an info message (green indicator)
	 * @param {String} message Message content
	 */
	Info(message) {
		if (!this.enabled)
			return this
		this.Log("✓ INFO", message)
		return this
	}

	; @region Success()
	/**
	 * @method Success
	 * @description Log a success message (green indicator)
	 * @param {String} message Message content
	 */
	Success(message) {
		if (!this.enabled)
			return this
		this.Log("✓ SUCCESS", message)
		return this
	}

	; @region Error()
	/**
	 * @method Error
	 * @description Log an error message (red indicator)
	 * @param {String} message Error message
	 * @param {Error} [err] Optional error object
	 */
	Error(message, err?) {
		if (!this.enabled)
			return this
			
		errorMsg := message
		if IsSet(err) {
			errorMsg .= "`nError: " err.Message
			if err.HasOwnProp("Line")
				errorMsg .= " (Line " err.Line ")"
		}
		this.Log("✗ ERROR", errorMsg)
		OutputDebug("[ERROR] " errorMsg)
		return this
	}

	; @region Warning()
	/**
	 * @method Warning
	 * @description Log a warning message (yellow indicator)
	 * @param {String} message Warning message
	 */
	Warning(message) {
		if (!this.enabled)
			return this
		this.Log("⚠ WARNING", message)
		return this
	}

	; @region Test()
	/**
	 * @method Test
	 * @description Log a test step
	 * @param {Integer} testNum Test number
	 * @param {String} description Test description
	 */
	Test(testNum, description) {
		if (!this.enabled)
			return this
		this.Log("TEST " testNum, description)
		return this
	}

	; @region Result()
	/**
	 * @method Result
	 * @description Log a test result
	 * @param {String} description Result description
	 * @param {Any} value Result value
	 */
	Result(description, value) {
		if (!this.enabled)
			return this
		; Convert value to string using concatenation
		this.Log("  → " description, "" value)
		return this
	}
	; @endregion Logging Methods

	; -----------------------------------------------------------------------
	; @region GUI Methods

	; @region Show()
	/**
	 * @method Show
	 * @description Show the logger GUI
	 */
	Show() {
		if (this.isVisible) {
			this.gui.Show()
			return this
		}

		; Create the GUI
		this._CreateGUI()
		
		; Show and mark visible
		this.gui.Show("AutoSize")
		this.isVisible := true
		this._UpdateDisplay()
		
		return this
	}

	/**
	 * @private
	 * @method _CreateGUI
	 * @description Create the GUI controls and layout
	 */
	_CreateGUI() {
		; Build GUI title with calling script name
		guiTitle := "Test Logger"
		if (this.callingScript) {
			guiTitle .= " - " this.callingScript
		}

		; Create GUI
		this.gui := Gui("+Resize +MinSize420x300", guiTitle)
		
		; Apply TestLogger theme with safe fallback to prevent recursion
		try {
			this.gui.TerminalMode()
		} catch {
			; Fallback to default dark theme if ThemeMgr fails
			this.gui.BackColor := "0x1E1E1E"
			this.gui.SetFont("s9 cD4D4D4", "Consolas")
		}
		
		this.gui.SetFont("s9", "Consolas")

		; Set margins for the window
		this.gui.MarginX := 10
		this.gui.MarginY := 10

		; Header - first control starts at margin automatically
		headerText := this.gui.AddText("w400 cWhite Section", "Test Execution Log")
		headerText.SetFont("s10 Bold")

		; Log display (Edit control with readonly) - positioned below header
		this.logEdit := this.gui.AddEdit("xm y+10 w400 r20 ReadOnly VScroll cSilver Background1E1E1E", "")
		
		; Buttons row - positioned below edit control
		; First button starts new row
		clearBtn := this.gui.AddButton("xm y+10 w90 h30 Section", "Clear")
		
		; Remaining buttons positioned to the right of previous button
		copyBtn := this.gui.AddButton("x+10 w90 h30", "Copy")
		closeBtn := this.gui.AddButton("x+10 w90 h30", "Close")
		topBtn := this.gui.AddButton("x+10 w90 h30", "Always On Top")
		
		; Set up button events
		clearBtn.OnEvent("Click", (*) => this.Clear())
		copyBtn.OnEvent("Click", (*) => this.CopyToClipboard())
		closeBtn.OnEvent("Click", (*) => this.Hide())
		topBtn.OnEvent("Click", (*) => this.ToggleAlwaysOnTop())

		; Create status bar - automatically positioned at bottom
		this._CreateStatusBar()

		; Set up GUI events
		this.gui.OnEvent("Close", (*) => this.Hide())
		this.gui.OnEvent("Size", (*) => this._OnResize())

		; Position window on right side of screen with bounds checking
		MonitorGetWorkArea(, &monLeft, &monTop, &monRight, &monBottom)
		guiWidth := 420
		guiHeight := 500
		
		; Calculate position ensuring GUI stays within screen bounds
		guiX := Max(monLeft, monRight - guiWidth - 20)
		guiY := Max(monTop + 20, Min(20, monBottom - guiHeight - 20))
		
		; Set position
		this.gui.Move(guiX, guiY, guiWidth, guiHeight)
	}

	/**
	 * @method CreateStatusBar
	 * @description Create the status bar with proper sizing and sections
	 */
	_CreateStatusBar() {
		; Create status bar with proper sizing and options
		this.statusBar := this.gui.AddStatusBar()
		
		; Set explicit part sizes - allocate appropriate width for each section
		this.statusBar.SetParts(150, 150, 150)  ; State | Enabled | Logs
		
		; Initialize with current values
		this._UpdateStatusBar()
	}

	/**
	 * @method UpdateStatusBar
	 * @description Update status bar with current logger state
	 */
	_UpdateStatusBar() {
		if (!this.statusBar) {
			return
		}
		
		; Update status bar with accurate information
		stateText := "State: " this.state
		enabledText := this.enabled ? "ENABLED" : "DISABLED"
		logsText := "Logs: " this.logs.Length
		
		this.statusBar.SetText(stateText, 1)
		this.statusBar.SetText(enabledText, 2)
		this.statusBar.SetText(logsText, 3)
	}

	/**
	 * @method Hide
	 * @description Hide the logger GUI
	 */
	Hide() {
		if (this.gui) {
			this.gui.Hide()
			this.isVisible := false
		}
		return this
	}

	/**
	 * @method Clear
	 * @description Clear all logs
	 */
	Clear() {
		this.logs := []
		if (this.isVisible) {
			this._UpdateDisplay()
		}
		return this
	}

	/**
	 * @method CopyToClipboard
	 * @description Copy all logs to clipboard
	 */
	CopyToClipboard() {
		if (this.logs.Length > 0) {
			A_Clipboard := this.logs.Join("`n")
		}
		return this
	}

	/**
	 * @method ToggleAlwaysOnTop
	 * @description Toggle always-on-top state
	 */
	ToggleAlwaysOnTop() {
		if (this.gui) {
			WinSetAlwaysOnTop(-1, "ahk_id " this.gui.Hwnd)
		}
		return this
	}
	; @endregion GUI Methods

	; -----------------------------------------------------------------------
	; @region File Logging Methods
	/**
	 * @method SetLogFile
	 * @description Set the log file path and optionally enable auto-save
	 * @param {String} filePath Path to log file
	 * @param {Boolean} [autoSave=false] Enable auto-save on each log entry
	 * @param {Boolean} [clearExisting=false] Clear existing file content
	 * @example
	 *   myLogger.SetLogFile(A_Temp "\my_log.txt", true)      ; Instance
	 */
	SetLogFile(filePath, autoSave := false, clearExisting := false) {
		this.logFilePath := filePath
		this.autoSave := autoSave
		
		if (clearExisting || !FileExist(filePath)) {
			try {
				file := FileOpen(filePath, "w", "UTF-8")
				file.Write(";; Test Logger - " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n")
				file.Write(";; =============================================================`n`n")
				file.Close()
			} catch Error as e {
				this.Error("Failed to initialize log file", e)
			}
		}
		return this
	}

	/**
	 * @method SaveToFile
	 * @description Save all current logs to the configured file
	 * @param {String} [filePath] Optional file path (uses logFilePath if not provided)
	 * @throws {ValueError} When no file path is set
	 * @example
	 *   myLogger.SaveToFile()  ; Save to configured file
	 *   myLogger.SaveToFile("custom_log.txt")  ; Save to specific file
	 */
	SaveToFile(filePath?) {
		targetPath := IsSet(filePath) ? filePath : this.logFilePath
		
		if (!targetPath) {
			throw ValueError("No log file path set. Use SetLogFile() first or provide a file path.", -1)
		}
		
		try {
			file := FileOpen(targetPath, "w", "UTF-8")
			file.Write(";; Test Logger - " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n")
			file.Write(";; =============================================================`n`n")
			
			if (this.logs.Length > 0) {
				file.Write(this.logs.Join("`n"))
				file.Write("`n")
			}
			
			file.Close()
			this.Success("Logs saved to: " targetPath)
			return this
		} catch Error as e {
			this.Error("Failed to save log file", e)
			return this
		}
	}
	; @endregion File Logging Methods

	; -----------------------------------------------------------------------
	; @region Private Methods
	/**
	 * @private
	 * @method _UpdateDisplay
	 * @description Update the log display and status bar
	 */
	_UpdateDisplay() {
		if (this.logEdit) {
			logText := this.logs.Length > 0 ? this.logs.Join("`n") : "(No logs)"
			this.logEdit.Value := logText
			
			; Scroll to bottom
			SendMessage(0x0115, 7, 0, this.logEdit)  ; WM_VSCROLL, SB_BOTTOM
		}
		
		; Update status bar
		this._UpdateStatusBar()
	}

	/**
	 * @private
	 * @method _OnResize
	 * @description Handle GUI resize
	 */
	_OnResize() {
		if (!this.gui)
			return
			
		this.gui.GetPos(, , &w, &h)
		
		; Get current margin settings
		marginX := this.gui.MarginX
		marginY := this.gui.MarginY
		
		; Fixed heights
		buttonHeight := 30
		statusHeight := 20
		headerHeight := 25      ; Approximate header text height
		
		; Calculate content width (accounting for margins on both sides)
		contentWidth := w - (marginX * 2)
		
		; Calculate available space for edit control
		; Window height - (header + margins + button height + status bar)
		editHeight := h - (headerHeight + (marginY * 3) + buttonHeight + statusHeight + 10)
		
		; Ensure minimum edit height
		if (editHeight < 100) {
			editHeight := 100
		}
		
		; Resize edit control (maintains relative positioning via xm)
		if (this.logEdit) {
			this.logEdit.Move(, , contentWidth, editHeight)
		}
		
		; Resize buttons proportionally if window is wider
		buttonWidth := 90
		if (contentWidth > 400) {
			; Distribute extra width among buttons
			buttonWidth := Floor((contentWidth - 30) / 4)  ; 30 = 3 gaps of 10px
		}
		
		; Buttons maintain their relative positions, just resize
		try this.gui["Clear"].Move(, , buttonWidth)
		try this.gui["Copy"].Move(, , buttonWidth)
		try this.gui["Close"].Move(, , buttonWidth)
		try this.gui["Always On Top"].Move(, , buttonWidth)
		
		; Native status bar auto-resizes, just update its part sizes proportionally
		if (this.statusBar) {
			this.statusBar.SetParts(w * 0.33, w * 0.33, w * 0.34)
		}
	}

	/**
	 * @private
	 * @method _AppendToFile
	 * @description Append a log entry to the file
	 * @param {String} entry Log entry to append
	 */
	_AppendToFile(entry) {
		if (!this.logFilePath)
			return
		
		logDir := this.logFilePath
		logFileName := "testlogger.log"
		
		if (this.callingScript) {
			scriptBaseName := RegExReplace(this.callingScript, "\.ahk$", "")
			logFileName := scriptBaseName "_testlogger.log"
		}
		
		fullLogPath := logDir logFileName
		
		try {
			if (!DirExist(logDir)) {
				DirCreate(logDir)
			}
			
			if (!FileExist(fullLogPath)) {
				headerFile := FileOpen(fullLogPath, "w", "UTF-8")
				headerFile.Write(";; Test Logger")
				if (this.callingScript) {
					headerFile.Write(" - " this.callingScript)
				}
				headerFile.Write("`n;; Started: " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n")
				headerFile.Write(";; =============================================================`n`n")
				headerFile.Close()
			}
			
			file := FileOpen(fullLogPath, "a", "UTF-8")
			file.Write(entry "`n")
			file.Close()
		} catch Error as e {
			OutputDebug("[TestLogger] Failed to append to file: " e.Message)
		}
	}
	; @endregion Private Methods
}
