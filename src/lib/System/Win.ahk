#Requires AutoHotkey v2+

#Include <Extensions/.structs/Object>
#Include <Managers\WindowManager>

; @region Class Definition
/**
 * @class Win
 * @description Window management class with rich window manipulation functionality
 * @version 1.1.0
 * @author AHK Community
 * @requires AutoHotkey v2.0+
 */
class Win {
	; @region Properties
	/**
	 * @property {String} winTitle - Title of the window to target (default "A" for active window)
	 */
	winTitle := "A"

	/**
	 * @property {String} winText - Text contained in the window
	 */
	winText := ""

	/**
	 * @property {String} excludeTitle - Exclude windows with this title
	 */
	excludeTitle := ""

	/**
	 * @property {String} excludeText - Exclude windows with this text
	 */
	excludeText := ""

	/**
	 * @property {Array} winTitles - Collection of window titles to work with
	 */
	winTitles := []

	/**
	 * @property {String} exePath - Path to executable or folder to open
	 */
	exePath := ""

	/**
	 * @property {String} startIn - Directory to start in
	 */
	startIn := ""

	/**
	 * @property {String} runOpt - Options for Run command
	 */
	runOpt := ""

	/**
	 * @property {Number} runTimeout - Timeout in seconds for Run operations
	 */
	runTimeout := 5

	/**
	 * @property {Number} actTimeout - Timeout in seconds for Activate operations
	 */
	actTimeout := 2

	/**
	 * @property {Number} extTimeout - Timeout in seconds for Close operations
	 */
	extTimeout := 3

	/**
	 * @property {Number} posTimeout - Timeout in seconds for positioning operations
	 */
	posTimeout := 3

	/**
	 * @property {String|Array} toClose - Window(s) to close once target exists
	 * @static
	 */
	static toClose := ''

	/**
	 * @property {String|Array} toClose - Instance version of the static property
	 */
	toClose := Win.toClose

	/**
	 * @property {String} startupWintitle - Alternative window title to use during startup
	 */
	startupWintitle := ""

	/**
	 * @property {String} position - Position preset for the window
	 */
	position := ""

	/**
	 * @property {Number} isAlwaysOnTop - Always on top state (2 = uninitialized value)
	 */
	isAlwaysOnTop := 2 ; sentinel value to indicate uninitialized state
	; @endregion Properties
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region Constructor
	/**
	 * @constructor
	 * @param {Object} paramsObject - Key value pairs for properties of the class you want to set
	 * @throws {TypeError} If you didn't pass an object
	 * @throws {PropertyError} If paramsObject contains properties not defined by the class
	 * @example
	 * Win({
	 *   exePath: A_AppData "\Spotify\Spotify.exe",
	 *   winTitle: "ahk_exe Spotify.exe"
	 * }).RunAct()
	 */
	__New(paramsObject?) {
    if IsSet(paramsObject) {
        try {
            Hydrate(this, paramsObject)
        } catch PropertyError as err {
            ; Provide more helpful error message
            throw PropertyError(
                Format("Win class doesn't have property '{}'. Available properties: {}", 
                    err.Extra, 
                    this._getAvailableProperties().Join(", ")
                ), 
                -1, 
                err.Extra
            )
        }
    }
}

/**
 * @private
 * @description Get list of available properties for error messages
 * @returns {Array} Array of property names
 */
_getAvailableProperties() {
    return [
        "winTitle", "winText", "excludeTitle", "excludeText", "winTitles",
        "exePath", "startIn", "runOpt", "runTimeout", "actTimeout", 
        "extTimeout", "posTimeout", "toClose", "startupWintitle", 
        "position", "isAlwaysOnTop"
    ]
}
	; @endregion Constructor
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region Testing Subclass
	/**
	 * @class Testing
	 * @description Internal testing and validation helpers
	 * @extends Win
	 */
	class Testing extends Win {
		/**
		 * @static
		 * @method NoExePath
		 * @description Throws error when exePath is not specified
		 * @throws {TargetError} When exePath is missing
		 */
		static NoExePath() {
			throw TargetError("Specify a file path", -1)
		}

		/**
		 * @static
		 * @method WrongType_toClose
		 * @description Validates the type of toClose property
		 * @throws {TypeError} When toClose is not a string or array
		 */
		static WrongType_toClose() {
			throw TypeError(
				"Win.toClose has to either be an array or a string",
				-1,
				this.toClose " : " Type(this.toClose)
			)
		}
	}
	; @endregion Testing Subclass
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region Explorer Methods
	/**
	 * @method SetExplorerWintitle
	 * @description Sets window title for Explorer windows based on exePath
	 * @returns {String} Updated window title
	 */
	SetExplorerWintitle() => this.winTitle := this.exePath " ahk_exe explorer.exe"
	; @endregion Explorer Methods
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region Window Control Methods
	/**
	 * @method Close
	 * @description Attempts to close the target window
	 * @returns {Boolean} True if close message was sent successfully, false otherwise
	 */
	Close() {
		try {
			PostMessage("0x0010",,,, this.winTitle,, this.excludeTitle)
		}
		catch Error {
			return false
		}
		return true
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method CloseAll
	 * @description Closes all matching windows
	 * @returns {Void}
	 */
	CloseAll() {
		while this.Close() {
		}
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method Activate
	 * @description Activates the target window
	 * @returns {Boolean} True if activation was successful, false otherwise
	 */
	Activate() {
		try {
			WinActivate(this.winTitle,, this.excludeTitle)
			WinWaitActive(this.winTitle,, this.actTimeout, this.excludeTitle)
			return true
		}
		catch Error {
			return false
		}
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method ActivateAnother
	 * @description Activates another window matching the same criteria as the active one
	 * @returns {Boolean} False if fewer than 2 matching windows exist, true if operation completed
	 */
	ActivateAnother() {
		windows := WinGetList(this.winTitle,, this.excludeTitle)
		if (windows.Length < 2) {
			return false
		}
		temp := this.winTitle
		id   := WinGetID("A")
		i := -1
		inverseLength := -windows.Length
		while i > inverseLength {
			if windows[i] != id {
				this.winTitle := windows[i]
				break
			}
			i--
		}
		this.Activate()
		this.winTitle := temp
		return true
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method MinMax
	 * @description Toggles window between active and minimized states
	 * @returns {Boolean} True if operation completed, false if window doesn't exist
	 */
	MinMax() {
		if !WinExist(this.winTitle,, this.excludeTitle) {
			return false
		}

		if WinActive(this.winTitle,, this.excludeTitle) {
			if !this.ActivateAnother()
				WinMinimize(this.winTitle, this.winText, this.excludeTitle, this.excludeText)
		}
		else {
			this.Activate()
		}
		return true
	}
	; @endregion Window Control Methods
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region Run and Execution Methods
	/**
	 * @method Run
	 * @description Runs the application if it's not already running
	 * @throws {TargetError} If exePath is not specified
	 * @returns {Boolean} True if application was started, false if it was already running
	 */
	Run() {
		if WinExist(this.winTitle,, this.excludeTitle){
			return false
		}
		if !this.exePath {
			Win.Testing.NoExePath()
		}
		Run(this.exePath, this.startIn, this.runOpt ? this.runOpt : "Max")
		WinWait(
			this.startupWintitle ? this.startupWintitle : this.winTitle,,
			this.runTimeout,
			this.excludeTitle
		)
		if this.toClose {
			this.CloseOnceExists()
		}
		return true
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method CloseOnceExists
	 * @description Closes specified window(s) once they exist
	 * @throws {TypeError} If toClose is not a string or array
	 * @returns {Void}
	 */
	CloseOnceExists() {
		stopWaitingAt := A_TickCount + this.extTimeout * 1000
		if IsArray(this.toClose) {
			SetTimer(foTryCloseArray, 20)
		}
		else if IsString(this.toClose) {
			SetTimer(foTryClose, 20)
		}
		else if !this.toClose{
			Win.Testing.WrongType_toClose()
		}
		else{
			Win.Testing.WrongType_toClose()
		}
		foTryCloseArray() {
			for key, value in this.toClose {
				if WinExist(value) {
					WindowManager.Close(value)
					SetTimer(, 0)
				}
			}
			if A_TickCount >= stopWaitingAt {
				SetTimer(, 0)
			}
		}
		foTryClose() {
			if WinExist(this.toClose) {
				WindowManager.Close(this.toClose)
				SetTimer(, 0)
			}
			else if A_TickCount >= stopWaitingAt {
				SetTimer(, 0)
			}
		}
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method RunAct
	 * @description Runs and activates the application, applying positioning if specified
	 * @returns {Win} Current instance for method chaining
	 */
	RunAct() {
		this.Run()
		if this.startupWintitle {
			temp := this.winTitle
			this.winTitle := this.startupWintitle
		}
		this.Activate()
		if this.startupWintitle {
			this.winTitle := temp
		}
		if this.position {
			WindowManager(this.winTitle, this.excludeTitle).%this.position%()
		}
		if this.isAlwaysOnTop != 2 {
			WinSetAlwaysOnTop(this.isAlwaysOnTop, this.winTitle, this.winText, this.excludeTitle, this.excludeText)
		}
		return this
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method runActivate
	 * @description Alias for RunAct for more descriptive naming
	 * @returns {Win} Current instance for method chaining
	 */
	runActivate() {
		return this.RunAct()
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method runActivate_Folders
	 * @description Alias for RunAct_Folders for more descriptive naming
	 * @returns {Win} Current instance for method chaining
	 */
	runActivate_Folders() {
		return this.RunAct_Folders()
	}
	; @endregion Run and Execution Methods
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region Folder Operations
	/**
	 * @method RunAct_Folders
	 * @description Run and activate an Explorer window with folder-specific settings
	 * @returns {Win} Current instance for method chaining
	 * @example
	 *   Win({exePath: "C:\Users\Documents"}).RunAct_Folders()
	 */
	RunAct_Folders() {
		this.SetExplorerWintitle()
		if !this.runOpt {
			this.runOpt := Explorer.runOpt
		}
		if this.isAlwaysOnTop = 2 {
			this.isAlwaysOnTop := Explorer.isAlwaysOnTop
		}
		if !this.position {
			this.position := Explorer.position
		}
		this.RunAct()
		return this
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method App_Folders
	 * @description Specialized version of App for folder operations
	 * @returns {Win} Current instance for method chaining
	 */
	App_Folders() {
		this.SetExplorerWintitle()
		if !this.runOpt {
			this.runOpt := Explorer.runOpt
		}
		if this.isAlwaysOnTop = 2 {
			this.isAlwaysOnTop := Explorer.isAlwaysOnTop
		}
		if !this.position {
			this.position := Explorer.position
		}
		this.App()
		return this
	}
	; @endregion Folder Operations
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region Application Control Methods
	/**
	 * @method App
	 * @description Smart window control: toggles if exists, runs if doesn't
	 * @returns {Win} Current instance for method chaining
	 */
	App() {
		if this.MinMax() {
			return this
		}
		this.RunAct()
		return this
	}
	; @endregion Application Control Methods
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region Window Detection Methods
	/**
	 * @method ActiveRegex
	 * @description Checks if current window is active using regex matching
	 * @returns {Number} Window ID if active, 0 if not
	 */
	ActiveRegex() {
		SetTitleMatchMode("RegEx")
		return WinActive(this.winTitle, this.winText, this.excludeTitle, this.excludeText)
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method ActiveRegex
	 * @description Static version to check if a window is active using regex matching
	 * @param {String} winTitle - Title of window to check (default "A")
	 * @param {String} winText - Text contained in the window
	 * @param {String} excludeTitle - Exclude windows with this title
	 * @param {String} excludeText - Exclude windows with this text
	 * @returns {Number} Window ID if active, 0 if not
	 * @static
	 */
	static ActiveRegex(winTitle := "A", winText?, excludeTitle?, excludeText?) {
		SetTitleMatchMode("RegEx")
		return WinActive(winTitle, winText?, excludeTitle?, excludeText?)
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method AreActive
	 * @description Checks if any windows from winTitles array/map are active
	 * @returns {Number} Count of active windows matching criteria
	 */
	AreActive() {
		i := 0
		for key, value in this.winTitles {
			if Type(this.winTitles) = "Map" {
				if WinActive(key,, value)
					i++
			}
			else if IsArray(this.winTitles) {
				if WinActive(value) {
					i++
				}
			}
		}
		return i
	}
	; @endregion Window Detection Methods
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
}
; @endregion Class Definition
