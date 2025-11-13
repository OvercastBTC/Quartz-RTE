#Requires AutoHotkey v2+
;? this is my lib file, for Quartz-RTE, use the one below
;! for the local lib files, comment out the below and uncomment the ones after
; #Include <System/Paths>
; #Include <System/Win>
; #Include <Utilities/InternetSearch>
; #Include <Extensions/.modules/Clipboard>
; #Include <Extensions/.primitives/Keys>
; #Include <Extensions/.ui/Infos>

;? this the local lib files, for Quartz-RTE, use this one
;! for the local lib files, uncomment the ones below
#Include ../System/Paths.ahk
#Include ../System/Win.ahk
#Include ../Utilities/InternetSearch.ahk
#Include ../Extensions/.modules/Clipboard.ahk
#Include ../Extensions/.primitives/Keys.ahk
#Include ../Extensions/.ui/Infos.ahk

; @region Hotkeys
/**
 * @hotkey Ctrl+Shift+M
 * @description Search MSDN Win32 documentation for selected text in VSCode
 * @context Visual Studio Code window
 */
#HotIf WinActive(' Visual Studio Code')
^+m::
{
	text := ''
	cBak := ClipboardAll()
	; Infos(EmptyClipboard(), 3000)
	Sleep(100)
	; SndMsgCopy()
	Send("^c")
	text :=  A_Clipboard
	loop {
		Sleep(20)
	} until (text.length > 0)
	InternetSearch.TriggerSearch('msdn win32 ' text)
	; AE.EmptyClipboard()

	Sleep(1000)
	A_Clipboard := cBak
}
#HotIf

; @endregion Hotkeys

; @region VSCode
/**
 * @class VSCode
 * @description Visual Studio Code automation and control class
 * @version 1.0.0
 * @author GitHub Copilot
 * @date 2024-12-19
 * @requires AutoHotkey v2.0+
 * @example
 *   VSCode.Edit("C:\myfile.txt")
 *   VSCode.newEdit("C:\newfolder")
 */
class VSCode {
	; ---------------------------------------------------------------------------
	; @region Static Properties
	/**
	 * @static
	 * @property {String} exe VSCode executable identifier
	 */
	static exe := 'ahk_exe Code.exe'

	/**
	 * @static
	 * @property {String} exeTitle VSCode window identifier
	 */
	static exeTitle := "ahk_exe Code.exe"

	/**
	 * @static
	 * @property {String} winTitle Complete window title pattern
	 */
	static winTitle := "Visual Studio Code " this.exeTitle

	/**
	 * @static
	 * @property {String} path VSCode executable path
	 */
	static path := Paths.Code

	/**
	 * @static
	 * @property {Win} winObj Window object for VSCode automation
	 */
	static winObj := Win({
		winTitle: this.winTitle,
		exePath:  this.path,
	})
	; @endregion Static Properties

	; ---------------------------------------------------------------------------
	; @region Constructor
	/**
	 * @constructor
	 * @description Initialize VSCode window object
	 */
	static __New(){
		this.winObj := Win({
			winTitle: this.winTitle,
			exePath:  this.path,
		})
	}
	; @endregion Constructor

	; ---------------------------------------------------------------------------
	; @region File Operations
	/**
	 * @description Open file or folder in current VSCode window
	 * @param {String} fileOrfolder Path to file or folder to open
	 * @static
	 * @example
	 *   VSCode.Edit_Window_Current("C:\myproject")
	 */
	static Edit_Window_Current(fileOrfolder) {
		; Run(Paths.Code ' "' fileOrfolder '"') ;! This works, but below using the App syntax
		Run(this.winObj.exePath ' "' fileOrfolder '"')
	}

	/**
	 * @description Open file or folder in new VSCode window
	 * @param {String} fileOrfolder Path to file or folder to open
	 * @static
	 * @example
	 *   VSCode.Edit_Window_New("C:\newproject")
	 */
	static Edit_Window_New(fileOrfolder) {
		; Run(Paths.Code ' -n "' fileOrfolder '"') ;! This works, but below using the App syntax
		Run(this.winObj.exePath ' -n "' fileOrfolder '"')
	}
	; @endregion File Operations

	; ---------------------------------------------------------------------------
	; @region Input Processing
	/**
	 * @description Process text input commands for VSCode operations
	 * @param {String} input Command string to process
	 * @returns {String} Original input if no command matched
	 * @static
	 * @example
	 *   VSCode.processInput("reload")  // Reloads VSCode
	 *   VSCode.processInput("libs")    // Opens library workspace
	 */
	static processInput(input) {
		input := input.trim()
		switch input {
			case "reload": this.Reload()
			case "close": this.CloseTab()
			case "closeall": this.CloseAllTabs()
			case "libs" || 'lib' || 'v2lib': this.newEdit(Paths.Lib '\Lib_AllLibs.code-workspace')
			default: return input
		}
	}
	; @endregion Input Processing

	; ---------------------------------------------------------------------------
	; @region Syntax Sugar
	/**
	 * @description Alias for Edit_Window_New - open in new window
	 * @param {String} fileOrfolder Path to file or folder
	 * @static
	 */
	static newEdit(fileOrfolder) => this.Edit_Window_New(fileOrfolder)

	/**
	 * @description Short alias for Edit_Window_New
	 * @param {String} fileOrfolder Path to file or folder
	 * @static
	 */
	static nEdit(fileOrfolder) => this.Edit_Window_New(fileOrfolder)

	/**
	 * @description Alias for Edit_Window_Current - open in current window
	 * @param {String} fileOrfolder Path to file or folder
	 * @static
	 */
	static Edit(fileOrfolder) => this.Edit_Window_Current(fileOrfolder)
	; @endregion Syntax Sugar

	; ---------------------------------------------------------------------------
	; @region Window Controls
	/**
	 * @description Close all open tabs in VSCode
	 * @static
	 */
	static CloseAllTabs()  => Send("+!w")

	/**
	 * @description Reload VSCode window
	 * @static
	 */
	static Reload()        => Send("+!y+!y")

	/**
	 * @description Close current tab in VSCode
	 * @static
	 */
	static CloseTab()      => Send("!w")
	; @endregion Window Controls

	; ---------------------------------------------------------------------------
	; @region Text Manipulation
	/**
	 * @description Move current line up in editor
	 * @static
	 * @returns {Function} Function that moves text line up
	 */
	static movelineUp => (*) => this._movetextlineUp()

	/**
	 * @description Move current line down in editor
	 * @static
	 * @returns {Function} Function that moves text line down
	 */
	static moveLineDown => (*) => this._movetextlineDown()

	/**
	 * @description Duplicate current line in editor
	 * @static
	 * @returns {Function} Function that duplicates text line
	 */
	static duplicateLine => (*) => this._duplicatetextLine()
	; @endregion Text Manipulation

	; ---------------------------------------------------------------------------
	; @region Private Methods
	/**
	 * @private
	 * @description Internal method to move text line up
	 * @static
	 */
	static _movetextlineUp() {
		text := unset
		SM(&objSM)
		Send(keys.moveupdown) 			;? {Home}, +{End}, ^x, {Delete}
		text := A_Clipboard

		Sleep(A_Delay)

		Send(keys.moveup) 				;? {Up}{Enter}{Up}

		Sleep(A_Delay)

		Clipboard.Send(text)

		Sleep(A_Delay*10)
		text := unset
	}

	/**
	 * @private
	 * @description Internal method to move text line down
	 * @static
	 */
	static _movetextlineDown() {
		text := unset
		Send(keys.moveupdown) 			;? {Home}, +{End}, ^x, {Delete}
		text := A_Clipboard

		Sleep(A_Delay)

		Send(keys.movedown) 				;? {End}{Enter}

		Clipboard.Send(text)

		Sleep(A_Delay*10)
		text := unset
	}

	/**
	 * @private
	 * @description Internal method to duplicate text line
	 * @static
	 */
	static _duplicatetextLine() {
		text := unset

		Send(keys.duplicateLine)

		text := A_Clipboard

		Sleep(A_Delay)

		Send(keys.movedown)

		Sleep(A_Delay)

		Clipboard.Send(text)

		Sleep(A_Delay*10)
		text := unset
	}
	; @endregion Private Methods

	; ---------------------------------------------------------------------------
	; @region Text Expansion
	/**
	 * @class TextExpansion
	 * @description Nested class for VSCode text expansion functionality
	 * @version 1.0.0
	 * @author OvercastBTC
	 * @date 2025-07-29
	 */
	class TextExpansion {
		; @region Static Properties
		static InputBlockLevel := 1  ; Input blocking level for BISL operations
		; @endregion Static Properties

		/**
		 * @description Insert text template with cursor positioning and protection
		 * @param {String} template The text to insert
		 * @param {String} cursorAction Optional cursor positioning (default: '{Right}')
		 * @returns {Boolean} Success status
		 */
		static Insert(template, cursorAction := '{Right}') {
			try {
				; Block input during initial operation
				state := BISL(this.InputBlockLevel)

				; Insert the template text
				this.SendText(template)

				; Create protective hotstring to prevent accidental re-typing
				HotString(':B0:' template, '{bs ' template.length '}', 'On')

				Sleep(A_Delay/10)

				; Move cursor immediately if specified
				if (cursorAction) {
					Send(cursorAction)
					Sleep(A_Delay)
				}

				; Restore input state before monitoring
				if (IsSet(state)){
					BISL.Restore(state)
					Sleep(A_Delay*10)
				}
				; Turn off the protective hotstring
				HotString(':B0:' template, , 'Off')

				return true
			}
			catch Error as e {
				; Log error and return failure
				OutputDebug("VSCode.TextExpansion error: " e.Message)
				return false
			}
			finally {
				; Always restore input state if something went wrong
				if (IsSet(state)){
					BISL.Restore(state)
					Sleep(A_Delay*10)
					; Turn off the protective hotstring
					HotString(':B0:' template, , 'Off')
				}
			}
		}

		/**
		 * @description Send text using clipboard method for reliability
		 * @param {String} text The text to send
		 */
		static SendText(text) {
			if (!text){
				return
			}
			Clipboard.Send(text)
		}

		/**
		 * @description Convenient positioning methods
		 */
		static Right(text) => this.Insert(text, '{Right}')
		static Left(text) => this.Insert(text, '{Left}')
		static Home(text) => this.Insert(text, '{Home}')
		static End(text) => this.Insert(text, '{End}')
		static Template(template, cursorAction := '{Right}') => this.Insert(template, cursorAction)
	}
	; @endregion Text Expansion
}
; @endregion VSCode

/************************************************************************
; ---------------------------------------------------------------------------
* @description Open the folder containing the file, and (optional) edit the file in VS Code
* @example
* 	When VS Code is active, save and reload the script
* 	Open the folder containing the file, and (optional) edit the file in VS Code
* 	path: Can contain the file name, or just the path to the file
* 	newWin: Open file/folder in new window
* 	edit: Default = true (1) = Edit the file in VS Code
* 	oFolder: Default = true (1) = Open the file in Explorer
* 	fRun: Default = true (1) = Run the file
; ---------------------------------------------------------------------------
***********************************************************************/
OpenEdit(fullpath := '', fRun := true, newWin := false, edit := true, oFolder := true) {
	; n := f := p:= '', list := [], n := ('^([\\])$(\w+\.\w+)') ;! not in use atm
	; ---------------------------------------------------------------------------
	/************************************************************************
	* @example Unless provided, get the full path of the file (in an array)
	***********************************************************************/
	; ---------------------------------------------------------------------------
	val := GetFilesSortedByDate(fullpath)
	/************************************************************************
	* @example Convert the file path array into a single string
	***********************************************************************/
	strPath := val.ToString('')
	/************************************************************************
	* @example If opening the folder, first check for the strPath (full file path)
	* @example Else the full file path is already provided (fullpath)
	***********************************************************************/
	; ---------------------------------------------------------------------------
	;! Disabled for the moment (OC - 2024.07.02)
	; (oFolder = 1 && strPath != '') ? Explorer.OpenFolder(strPath) : (oFolder = 1 && fullpath != '') ? Explorer.OpenFolder(fullpath): Infos('No folder found to open.', 5000)
	; ---------------------------------------------------------------------------
	; Infos('`nstrpath: ' strPath '`nfullpath: ' fullpath, 10000)
	; edit = 1 ? Run(Paths.Code ' "' fullpath '"') : Infos('Unable to open the file for editing.', 5000)
	/************************************************************************
	* @example Edit the file in VS Code in the existing window, or a new window
	***********************************************************************/
	edit = 1 ? (newWin = 1 ? VSCode.nEdit(fullpath) : VSCode.Edit(fullpath)) : Infos('Unable to open the file for editing.', 5000)
}
; ---------------------------------------------------------------------------
