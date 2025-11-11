/************************************************************************
 * @description Creating a class for clipboard manipulation
 * The class provides both static and non-static versions to allow flexibility in usage:
 * - Static version (Clip.[method]): Used when you need to call the method directly from the class
 * - Non-static version (instance.[method]): Used when working with class instances
 * @author OvercastBTC
 * @date 2025/03/17
 * @version 3.0.0
 ***********************************************************************/

#Requires AutoHotkey v2+
#Warn All, OutputDebug
;? this is my lib file, for Quartz-RTE, use the one below
;! for the local lib files, comment out the below and uncomment the ones after
; #Include <System/Paths>
; #Include <Extensions/.modules/Pipe>
; #Include <Extensions/.primitives/String>
; #Include <Extensions/.formats/JSONS>
; #Include <Extensions/.formats/FormatConverter>
; #Include <Apps/VSCode>
; #Include <Apps/Pandoc>
; #Include <Utilities/TestLogger>

;? this the local lib files, for Quartz-RTE, use this one
;! for the local lib files, uncomment the ones below
#Include ../../System/Paths.ahk
#Include ../../Extensions/.modules/Pipe.ahk
#Include ../../Extensions/.primitives/String.ahk
#Include ../../Extensions/.formats/JSONS.ahk
#Include ../../Extensions/.formats/FormatConverter.ahk
#Include ../../Apps/VSCode.ahk
#Include ../../Apps/Pandoc.ahk
#Include ../../Utilities/TestLogger.ahk

clipboardTestLogger := TestLogger(A_LineFile)
; clipboardTestLogger.Enable
clipboardTestLogger.Log("Clipboard.ahk loaded - TestLogger enabled")

;@region Detect Hidden
/**
 * @class DH
 * @description Utility class for managing detection of hidden windows and text.
 * @version 1.0.0
 * @author OvercastBTC
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Set both to true
 * DH()
 * ; Set both to false
 * DH(false)
 * ; Set individually
 * DH.Text(true)
 * DH.Windows(false)
 */
class DH {
	#Requires AutoHotkey v2+

	; Store original settings
	static originalState := {
		Text: A_DetectHiddenText,
		Windows: A_DetectHiddenWindows
	}

	/**
	 * @constructor
	 * @param {Boolean} detect Whether to detect hidden elements (default: true)
	 * @returns {Object} The current instance for method chaining
	 */
	__New(detect := true) {
		DH.Set(detect)
		return this
	}

	/**
	 * @static
	 * @description Static constructor alternative
	 * @param {Boolean} detect Whether to detect hidden elements (default: true)
	 * @returns {Object} The class for method chaining
	 */
	static __New(detect := true) {
		return this.Set(detect)
	}

	/**
	 * @static
	 * @description Sets detection for both hidden windows and text
	 * @param {Boolean} detect Whether to detect hidden elements
	 * @returns {Object} The class for method chaining
	 */
	static Set(detect := true) {
		this.Text(detect)
		this.Windows(detect)
		return this
	}

	/**
	 * @static
	 * @description Sets detection for hidden text
	 * @param {Boolean} detect Whether to detect hidden text
	 * @returns {Object} The class for method chaining
	 */
	static Text(detect := true) {
		DetectHiddenText(detect)
		return this
	}

	/**
	 * @static
	 * @description Sets detection for hidden windows
	 * @param {Boolean} detect Whether to detect hidden windows
	 * @returns {Object} The class for method chaining
	 */
	static Windows(detect := true) {
		DetectHiddenWindows(detect)
		return this
	}

	/**
	 * @description Gets current detection state
	 * @returns {Object} Object with Text and Windows properties
	 */
	static GetState() {
		return {
			Text: A_DetectHiddenText,
			Windows: A_DetectHiddenWindows
		}
	}

	/**
	 * @description Restores original settings from when class was first loaded
	 * @returns {Object} The class for method chaining
	 */
	static Restore() {
		this.Text(this.originalState.Text)
		this.Windows(this.originalState.Windows)
		return this
	}
}
; @endregion Detect Hidden
; ---------------------------------------------------------------------------
;@region class SM
/**
 * @class SM
 * @description Advanced utility class for managing SendMode and key delay settings.
 * @version 3.1.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Save current settings and switch to Event mode
 * settings := SM()
 * ; Restore previous settings
 * SM.Restore(settings)
 * ; Just change mode
 * SM.Mode("Input")
 */
class SM {

	#Requires AutoHotkey v2+

	; Store original settings
	objSM := {}

	/**
	 * @constructor
	 * @description Captures current settings and switches to Event mode
	 * @returns {SM} Instance for method chaining
	 */
	__New(&objSM?) {
		; Capture current settings
		this.objSM := {
			mode: A_SendMode,
			delay: A_KeyDelay,
			duration: A_KeyDuration
		}

		; Set to default values for Event mode
		SendMode('Event')
		SetKeyDelay(-1, -1)
		objSM := this.objSM ; Return the captured settings
		return this
	}

	/**
	 * @description Restores original settings when object is destroyed
	 */
	__Delete() {
		this.objSM := {} ; Clear the stored settings
	}

	/**
	 * @description Sets the SendMode to a specified value
	 * @param {String} mode The SendMode to set (e.g., "Input", "Event")
	 * @returns {SM} This instance for method chaining
	 */
	Mode(mode) {
		SendMode(mode)
		return this
	}

	/**
	 * @description Sets the key delay settings
	 * @param {Integer} delay The delay between keystrokes
	 * @param {Integer} duration The key press duration
	 * @returns {SM} This instance for method chaining
	 */
	KeyDelay(delay, duration) {
		SetKeyDelay(delay, duration)
		return this
	}

	/**
	 * @description Get current SendMode settings
	 * @returns {Object} Object containing current SendMode and key delay settings
	 */
	GetSettings() {
		return this.objSM := {
			mode: A_SendMode,
			delay: A_KeyDelay,
			duration: A_KeyDuration
		}
	}

	/**
	 * @description Resets the SendMode and key delay settings to Input mode
	 * @returns {SM} This instance for method chaining
	 */
	Reset() {
		SendMode('Input')
		SetKeyDelay(0, 0)
		return this
	}

	/**
	 * @description Static method to quickly set SendMode
	 * @param {String} mode The SendMode to set
	 */
	static Mode(mode) {
		SendMode(mode)
	}

	/**
	 * @description Static method to quickly set key delay
	 * @param {Integer} delay The delay between keystrokes
	 * @param {Integer} duration The key press duration
	 */
	static SetDelays(delay, duration) {
		SetKeyDelay(delay, duration)
	}
}
; ---------------------------------------------------------------------------
; @region rSM
/**
 * @name RestoreSendMode
 * @abstract Restores SendMode and key delay settings from an object.
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-04-23
 * @version 3.1.0
 * @param {Object} objSM Object containing SendMode and key delay settings.
 * @description Uses try to identify of objSM is populated, and sets/resets the SendMode() and SetKeyDelay()
 */
class rSM {
	__New(objSM?) {
		try {
			; Check if objSM is set and has properties
			if (IsObject(objSM) && objSM.HasOwnProp("s") && objSM.HasOwnProp("d") && objSM.HasOwnProp("p")) {
				SendMode(objSM.s)
				SetKeyDelay(objSM.d, objSM.p)
			}
			else {
				SendMode('Input')
				SetKeyDelay(0, 0) ; Reset key delay to default values
			}
		} finally {
			SendMode('Input')
			SetKeyDelay(0, 0) ; Reset key delay to default values
		}
	}
}
; @endregion rSM
; ---------------------------------------------------------------------------
; @region BISL
/**
 * @class BISL
 * @description Advanced utility class for managing BlockInput and SendLevel settings.
 * @version 1.1.0
 * @author OvercastBTC
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Save current state and block input with sendlevel 1
 * state := BISL(1)
 * ; Restore previous settings
 * BISL.Restore(state)
 * ; Just change BlockInput
 * BISL.Block(true)
 */
class BISL {
	#Requires AutoHotkey v2+

	/**
	 * @property {Object} DefaultSettings
	 * @description Default settings for BlockInput and SendLevel
	 */
	static DefaultSettings := {
		SendLevel: 0,
		BlockInput: false
	}

	; Tracking for current block state
	static _currentBlockState := false

	/**
	 * @constructor
	 * @param {Integer|Object} params SendLevel or settings object
	 * @param {Boolean} block Whether to block input
	 * @returns {Object} Previous settings before changes
	 */
	__New(params?, block?) {
		return BISL.Apply(params?, block?)
	}

	/**
	 * @static
	 * @description Static constructor alternative
	 * @param {Integer|Object} params SendLevel or settings object
	 * @param {Boolean} block Whether to block input
	 * @returns {Object} Previous settings before changes
	 */
	static __New(params?, block?) {
		return this.Apply(params?, block?)
	}

	/**
	 * @static
	 * @description Applies BlockInput and SendLevel settings
	 * @param {Integer|Object} params SendLevel or settings object
	 * @param {Boolean} block Whether to block input
	 * @returns {Object} Previous settings for later restoration
	 */
	static Apply(params?, block?) {
		; Capture current settings
		prevSettings := {
			SendLevel: A_SendLevel,
			BlockInput: this._currentBlockState
		}

		; Handle number parameter as SendLevel
		if (IsSet(params) && IsInteger(params)) {
			this.Level(params)

			; Handle optional block parameter when first param is a number
			if (IsSet(block) && IsInteger(block)) {
				this.Block(!!block)
			}

			return prevSettings
		}

		; Apply default settings if no params
		if (!IsSet(params)) {
			this.Level(this.DefaultSettings.SendLevel)
			this.Block(this.DefaultSettings.BlockInput)
			return prevSettings
		}

		; Apply settings from object
		if (params is Object) {
			; Support different property naming styles
			if (params.HasOwnProp("SendLevel") || params.HasOwnProp("sl"))
				this.Level(params.HasOwnProp("SendLevel") ? params.SendLevel : params.sl)

			if (params.HasOwnProp("BlockInput") || params.HasOwnProp("bi"))
				this.Block(params.HasOwnProp("BlockInput") ? params.BlockInput : params.bi)
		}

		return prevSettings
	}

	/**
	 * @static
	 * @description Sets just the SendLevel
	 * @param {Integer} level The SendLevel to set
	 * @returns {Object} The class for method chaining
	 */
	static Level(level := 0) {
		; Reset to zero first as recommended
		SendLevel(0)

		; Apply the new level with safe value handling
		if (IsInteger(level)) {
			if (level < 0)
				level := 0

			; Avoid going beyond 100 (AHK limit) by using a safer approach
			if (level >= 100)
				level := 99

			SendLevel(level)
		}

		return this
	}

	/**
	 * @static
	 * @description Sets just the BlockInput state
	 * @param {Boolean|Integer} block Whether to block input (true/false or 1/0)
	 * @returns {Object} The class for method chaining
	 */
	static Block(block := true) {
		block := !!block
		BlockInput(block)
		this._currentBlockState := block
		return this
	}

	/**
	 * @static
	 * @description Restores BlockInput and SendLevel from an object
	 * @param {Object} settings Settings object to restore from
	 * @returns {Object} The class for method chaining
	 */
	static Restore(settings) {
		if (!IsSet(settings) || !IsObject(settings)) {
			settings := this.DefaultSettings
		}

		; Support different property naming styles
		if (settings.HasOwnProp("SendLevel") || settings.HasOwnProp("sl"))
			this.Level(settings.HasOwnProp("SendLevel") ? settings.SendLevel : settings.sl)

		if (settings.HasOwnProp("BlockInput") || settings.HasOwnProp("bi"))
			this.Block(settings.HasOwnProp("BlockInput") ? settings.BlockInput : settings.bi)

		return this
	}

	/**
	 * @description Gets current BlockInput and SendLevel settings
	 * @returns {Object} Object with current settings
	 */
	static GetState() {
		return {
			SendLevel: A_SendLevel,
			BlockInput: this._currentBlockState
		}
	}

	/**
	 * @static
	 * @description Resets SendLevel to 0 and unblocks input
	 * @returns {Object} The class for method chaining
	 */
	static Reset() {
		this.Level(0)
		this.Block(false)
		return this
	}
}
; @endregion BISL
; ---------------------------------------------------------------------------
; @region SM_BISL
/**
 * @class SM_BISL
 * @description Convenience class that combines SM and BISL functionality
 * @version 1.0.0
 * @author OvercastBTC
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Set SendMode to Event and SendLevel to 1
 * settings := SM_BISL(1)
 */
class SM_BISL {
	/**
	 * @constructor
	 * @param {Integer} n SendLevel to apply (default: 1)
	 * @param {Object} SendModeObj Reference to store SendMode settings
	 * @returns {Object} SendModeObj with settings
	 */
	__New(n := 1, &SendModeObj?) {
		; Initialize SendModeObj if not provided
		if (!IsSet(SendModeObj)){
			SendModeObj := {}
		}
		SM(&SendModeObj)
		BISL(n)
		return SendModeObj
	}

	/**
	 * @static
	 * @description Static constructor alternative
	 * @param {Integer} n SendLevel to apply (default: 1)
	 * @param {Object} SendModeObj Reference to store SendMode settings
	 * @returns {Object} SendModeObj with settings
	 */
	static __New(n := 1, &SendModeObj?) {
		; Initialize SendModeObj if not provided
		if (!IsSet(SendModeObj))
			SendModeObj := {}

		SM(&SendModeObj)
		BISL(n)
		return SendModeObj
	}
}
; @endregion SM_BISL
; ---------------------------------------------------------------------------
; @region rSM_BISL
/**
 * @class rSM_BISL
 * @description Convenience class for restoring SM settings and resetting BISL
 * @version 1.0.0
 * @author OvercastBTC
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Restore SendMode and reset BISL
 * rSM_BISL(savedSettings)
 */
class rSM_BISL {
	/**
	 * @constructor
	 * @param {Object} SendModeObj SendMode settings to restore
	 * @returns {Object} This instance for method chaining
	 */
	__New(SendModeObj?) {
		SM()
		BISL(0)
		return this
	}

	/**
	 * @static
	 * @description Static constructor alternative
	 * @param {Object} SendModeObj SendMode settings to restore
	 * @returns {Object} The class for method chaining
	 */
	static __New(SendModeObj?) {
		SM()
		BISL(0)
		return this
	}
}
; class SM_BISL {
; 	__New(&SendModeObj, n := 1) {
; 		SM(&SendModeObj)
; 		BISL(n)
; 		return SendModeObj
; 	}
; }
; class rSM_BISL {
; 	__New(SendModeObj) {
; 		rSM(SendModeObj)
; 		BISL(0)
; 	}
; }
; @endregion SM_BISL
; ---------------------------------------------------------------------------
; @region SD
/**
 * @class SD
 * @description Comprehensive utility class for managing various system delays.
 * @version 1.1.0
 * @author OvercastBTC
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Set all delays to -1
 * SD()
 * ; Set all delays with custom values
 * SD(10, 50)
 * ; Set specific delay
 * SD.Control(20)
 */
class SD {
	#Requires AutoHotkey v2+

	/**
	 * @property {Integer} _defaults
	 * @description Default delay values used when resetting
	 */
	static _defaults := {
		control: -1,
		mouse: -1,
		window: -1,
		key: -1,
		keyDuration: -1
	}

	/**
	 * @constructor
	 * @param {Integer} delay Main delay value for Control, Mouse, and Window (default: -1)
	 * @param {Integer} keyDuration Key press duration for KeyDelay (default: -1)
	 * @returns {Object} The current instance for method chaining
	 */
	__New(delay := -1, keyDuration := -1) {
		SD.SetAll(delay, keyDuration)
		return this
	}

	/**
	 * @static
	 * @description Static constructor alternative
	 * @param {Integer} delay Main delay value (default: -1)
	 * @param {Integer} keyDuration Key press duration (default: -1)
	 */
	static __New(delay := -1, keyDuration := -1) {
		SD.SetAll(delay, keyDuration)
	}

	/**
	 * @static
	 * @description Sets all delay types to the same value
	 * @param {Integer} delay Delay value in milliseconds (default: -1)
	 * @param {Integer} keyDuration Key press duration (default: -1)
	 * @returns {Object} The class for method chaining
	 */
	static SetAll(delay := -1, keyDuration := -1) {
		this.Control(delay)
		this.Mouse(delay)
		this.Window(delay)
		this.Key(delay, keyDuration)
		return this
	}

	/**
	 * @static
	 * @description Sets control delay
	 * @param {Integer} delay Delay in milliseconds
	 * @returns {Object} The class for method chaining
	 */
	static Control(delay := -1) {
		if (!IsInteger(delay))
			delay := -1
		SetControlDelay(delay)
		return this
	}

	/**
	 * @static
	 * @description Sets mouse delay
	 * @param {Integer} delay Delay in milliseconds
	 * @returns {Object} The class for method chaining
	 */
	static Mouse(delay := -1) {
		if (!IsInteger(delay))
			delay := -1
		SetMouseDelay(delay)
		return this
	}

	/**
	 * @static
	 * @description Sets window delay
	 * @param {Integer} delay Delay in milliseconds
	 * @returns {Object} The class for method chaining
	 */
	static Window(delay := -1) {
		if (!IsInteger(delay))
			delay := -1
		SetWinDelay(delay)
		return this
	}

	/**
	 * @static
	 * @description Sets key delay and duration
	 * @param {Integer} delay Delay in milliseconds
	 * @param {Integer} duration Key press duration in milliseconds
	 * @returns {Object} The class for method chaining
	 */
	static Key(delay := -1, duration := -1) {
		if (!IsInteger(delay))
			delay := -1
		if (!IsInteger(duration))
			duration := -1
		SetKeyDelay(delay, duration)
		return this
	}

	/**
	 * @static
	 * @description Resets all delays to default values
	 * @returns {Object} The class for method chaining
	 */
	static Reset() {
		return this.SetAll(this._defaults.key, this._defaults.keyDuration)
	}

	/**
	 * @description Gets current delay settings
	 * @returns {Object} Object with all current delay settings
	 */
	static GetState() {
		return {
			Control: A_ControlDelay,
			Mouse: A_MouseDelay,
			Window: A_WinDelay,
			Key: A_KeyDelay,
			KeyDuration: A_KeyDuration
		}
	}
}
; @endregion SD
; ---------------------------------------------------------------------------
; @region Clip
/**
 * @class Clip
 * @description Static utility class for clipboard and focused control operations.
 * @version 3.0.0
 * @author OvercastBTC
 * @date 2025-03-17
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * Clip.Send("Some text")
 */
class Clip {

	static _logFile := A_ScriptDir "\.loggers\.clipboard\clipboard_Usage.log"
	static _usageLog := []
	static _isLoaded := false
	#Requires AutoHotkey v2+

	static defaultEndChar := ''
	static defaultIsClipReverted := true
	static defaultUntilRevert := 500

	/**
	 * @description Default delay time for the class
	 * @property {Integer} Dynamic calculation based on system performance
	 */
	static d := dly := delay := A_Delay
	static dly := delay := A_Delay
	static delay := A_Delay
	static __New(show := true, d := -1) {
		this.DH(show)
		this.SD(d)
		SM()
	}

	__New(show := true, d := -1) {
		this.DH(show)
		SD(d)
		SM()
	}

	/************************************************************************
	* @description Set SendMode, SendLevel, and BlockInput
	* @example this.SM_BISL(&SendModeObj, 1)
	***********************************************************************/
	static _SendMode_SendLevel_BlockInput(&SendModeObj?, n := 1) {
		SM(&SendModeObj)
		BISL(n)
		return SendModeObj
	}

	; static SM_BISL(&SendModeObj?, n := 1) => this._SendMode_SendLevel_BlockInput(&SendModeObj, n:=1)
	static SM_BISL(&SendModeObj?, n := 1) {
		return this._SendMode_SendLevel_BlockInput(&SendModeObj, n:=1)
	}

	/************************************************************************
	 * @description Changes SendMode to 'Event' and adjusts SetKeyDelay settings.
	 * The class provides both static and non-static versions to allow flexibility in usage:
	 * - Static version (Clip.SM): Used when you need to call the method directly from the class
	 * - Non-static version (instance.SM): Used when working with class instances
	 *
	 * @class SM
	 * @param {Object} objSM - Configuration object for send mode settings
	 * @param {String} objSM.s - Current send mode (A_SendMode)
	 * @param {Integer} objSM.d - Key delay in milliseconds (A_KeyDelay)
	 * @param {Integer} objSM.p - Key press duration (A_KeyDuration)
	 *
	 * @returns {Object} Returns the modified objSM object
	*************************************************************************/

	SM(&objSM) => SM(&objSM)

	; ---------------------------------------------------------------------------
	/************************************************************************
	* @description Restore SendMode and SetKeyDelay
	* @example Clip.rSM(objRestore)
	***********************************************************************/
	static rSM(objSM) => this._RestoreSendMode(objSM)
	static _RestoreSendMode(objSM) {
		SetKeyDelay(objSM.d, objSM.p)
		SendMode(objSM.s)
	}
	; ---------------------------------------------------------------------------
	/************************************************************************
	* @description Set BlockInput and SendLevel
	* @example this.BISL(1)
	* @var {Integer} : Send_Level := A_SendLevel
	* @var {Integer} : Block_Input := bi := 0
	* @var {Integer} : n = send level increase number
	* @returns {Integer}
	*************************************************************************/
	static BISL(n := 1, bi := 0, &sl?) => this._BlockInputSendLevel(n, bi, &sl)
	; static BISL(n := 1, bi := 0, &sl?) {
	; 	return this._BlockInputSendLevel(n, bi, &sl)
	; }
	static _BlockInputSendLevel(n := 1, bi := 0, &send_Level?) {
		SendLevel(0)
		send_Level := sl := A_SendLevel
		(sl < 100) ? SendLevel(sl + n) : SendLevel(n + n)
		(n >= 1) ? bi := 1 : bi := 0
		BlockInput(bi)
		return send_Level
	}
	; ---------------------------------------------------------------------------

	/************************************************************************
	* @description Set detection for hidden windows and text
	* @example this.DH(1)
	***********************************************************************/
	static DetectHidden(n) 	=> this._DetectHidden_Text_Windows(n)
	static DH(n) 			=> this._DetectHidden_Text_Windows(n)
	DH(n) 					=> this.DH(n)
	static _DetectHidden_Text_Windows(n := true) {
		DetectHiddenText(n)
		DetectHiddenWindows(n)
	}

	/************************************************************************
	* @description Set various delay settings
	* @example this.SetDelays(-1)
	***********************************************************************/
	static _SetDelays(n := -1, p:=-1) {
		SetControlDelay(n)
		SetMouseDelay(n)
		SetWinDelay(n)
		SetKeyDelay(n, p)
	}
	static SetDelays(n) => this._SetDelays(n)
	static SD(n) => this._SetDelays(n)
	; ---------------------------------------------------------------------------
	/**
	 * @private
	 * @description Log Clip method usage to log file and optionally display.
	 * @param {String} method Method name
	 * @param {Map|Object} params Parameters used
	 * @param {Any} result Result returned (optional)
	 */
	static _LogUsage(method, params, result := unset) {
		; LOGGING DISABLED - No clipboard usage logs will be created
		return
		
		/* ORIGINAL LOGGING CODE - DISABLED
		timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
		
		; Create log directory if it doesn't exist
		logDir := A_ScriptDir "\.loggers\.clipboard"
		if !DirExist(logDir) {
			DirCreate(logDir)
		}
		
		; Build log entry as formatted text
		logEntry := "[" timestamp "] " method "`n"
		logEntry .= "  Params: "
		
		; Format params (Map/Object)
		if IsObject(params) {
			for key, value in params {
				logEntry .= key "=" (value ?? "null") ", "
			}
			logEntry := RTrim(logEntry, ", ")
		} else {
			logEntry .= (params ?? "null")
		}
		
		if IsSet(result) {
			logEntry .= "`n  Result: " (result ?? "null")
		}
		logEntry .= "`n" (StrReplace(Format("{:=<80}", ""), " ", "=")) "`n"
		
		; Append to log file
		try {
			FileAppend(logEntry, this._logFile, "UTF-8")
		} catch as err {
			OutputDebug("Failed to write to Clip usage log: " err.Message)
		}
		*/
	}

	/**
	 * @description Get the handle of the focused control.
	 * @returns {Ptr} Handle of focused control.
	 */
	static hCtl() {
		result := ControlGetFocus('A')
		this._LogUsage("hCtl", Map(), result)
		return result
	}

	/**
	 * @description Select all text in the focused control.
	 */
	static SelectAllText() {
		static EM_SETSEL := 0x00B1
		hCtl := this.hCtl()
		if hCtl
			DllCall('SendMessage', 'Ptr', hCtl, 'UInt', EM_SETSEL, 'Ptr', 0, 'Ptr', -1)
		this._LogUsage("SelectAllText", Map("hCtl", hCtl))
	}

	/**
	 * @description Copy selected text to clipboard.
	 */
	static CopyToClipboard() {
		static WM_COPY := 0x0301
		hCtl := this.hCtl()
		if hCtl{
			DllCall('SendMessage', 'Ptr', hCtl, 'UInt', WM_COPY, 'Ptr', 0, 'Ptr', 0)
		}
		this._LogUsage("CopyToClipboard", Map("hCtl", hCtl))
	}

	/**
	 * @description Check if the clipboard is currently busy.
	 * @returns {Boolean} True if busy.
	 */
	static IsClipboardBusy() {
		busy := Clipboard.IsBusy
		this._LogUsage("IsClipboardBusy", Map(), busy)
		return busy
	}

	/**
	 * @description Get text from clipboard.
	 * @param {String} format Clipboard format: "T" (text), "U" (unicode), "R" (rtf), "H" (html), "C" (csv)
	 * @returns {String} Clipboard content.
	 */
	static GetClipboardText(format := "T") {
		switch format {
			case "U", "Unicode":
				text := Clipboard.GetUnicode()
			case "R", "RTF":
				text := Clipboard.GetRTF()
			case "H", "HTML":
				text := Clipboard.GetHTML()
			case "C", "CSV":
				text := Clipboard.GetCSV()
			default:
				text := Clipboard.GetPlain()
		}
		this._LogUsage("GetClipboardText", Map("format", format), text)
		return text
	}

	/**
	 * @description Set clipboard text (unicode).
	 * @param {String} text Text to set.
	 */
	static SetClipboardText(text) {
		Clipboard.Set.Unicode(text)
		this._LogUsage("SetClipboardText", Map("text", text))
	}

	/**
	 * @description Clear the clipboard.
	 */
	static ClearClipboard() {
		Clipboard.Clear()
		this._LogUsage("ClearClipboard", Map())
	}

	/**
	 * @description Backup current clipboard content and clear it.
	 * @returns {ClipboardAll} Clipboard backup.
	 */
	static BackupAndClearClipboard() {
		backup := Clipboard.BackupAll()
		Clipboard.Clear()
		this._LogUsage("BackupAndClearClipboard", Map(), backup)
		return backup
	}

	/**
	 * @description Restore clipboard from backup.
	 * @param {ClipboardAll} backup Clipboard backup object.
	 */
	static RestoreClipboard(backup) {
		Clipboard.RestoreAll(backup)
		this._LogUsage("RestoreClipboard", Map("backup", backup))
	}

	/**
	 * @description Wait for the clipboard to be available.
	 * @param {Integer} timeout Timeout in ms.
	 */
	static WaitForClipboard(timeout := 1000) {
		result := Clipboard.Wait(timeout)
		this._LogUsage("WaitForClipboard", Map("timeout", timeout), result)
		return result
	}

	/**
	 * @description Safely copy content to clipboard with verification.
	 * @returns {String} Clipboard content.
	 */
	static SafeCopyToClipboard() {
		backup := this.BackupAndClearClipboard()
		this.WaitForClipboard()
		this.SelectAllText()
		this.CopyToClipboard()
		this.WaitForClipboard()
		clipContent := this.GetClipboardText()
		this._LogUsage("SafeCopyToClipboard", Map(), clipContent)
		return clipContent
	}

	; /**
	;  * @description [DEPRECATED - REMOVED] Show the usage log in a GUI
	;  * @deprecated This method has been removed as clipboard logging is deprecated
	;  */
	; static ShowUsageLog() {
	; 	; REMOVED - Clipboard usage log GUI is deprecated and has been removed
	; }

	/**
	 * @description Paste text (or clipboard) into the focused control, with clipboard backup and restore.
	 * @param {String} text Text to send. If omitted, sends current clipboard.
	 * @param {String} endChar Optional character(s) to send after paste.
	 * @param {Boolean} isClipReverted Restore clipboard after paste (default: true).
	 * @param {Integer} untilRevert Time in ms to wait before restoring clipboard (default: 500).
	 * @returns {Boolean} True if sent.
	 * @example
	 * Clip.Send("Hello world")
	 */
	static Send(text := "", endChar := "", isClipReverted := true, untilRevert := 500) {
		Clipboard.Send(text, endChar, isClipReverted, untilRevert)
		; /**
		;  * Implementation notes:
		;  * - Backs up clipboard if text is provided.
		;  * - Sets clipboard, waits for availability, sends Ctrl+V, restores clipboard if needed.
		;  * - If text is empty, just sends Ctrl+V.
		;  */
		; local cBak := unset, sent := false
		; try {
		; 	if (text != "") {
		; 		cBak := ClipboardAll()
		; 		; Wait for clipboard to update by monitoring the sequence number
		; 		initialSeq := Clipboard.GetSequenceNumber
		; 		Clipboard.Set.Unicode(text)
		; 		Loop {
		; 			Sleep(10)
		; 		} until Clipboard.GetSequenceNumber != initialSeq
		; 		Sleep(A_Delay)
		; 		; Send(keys.paste)
		; 		Send(keys.shiftinsert)
		; 		sent := true
		; 		if (endChar != "")
		; 			Send(endChar)
		; 		if isClipReverted {
		; 			SetTimer(() => (A_Clipboard := cBak), -untilRevert)
		; 		}
		; 	} else {
		; 		Send("^v")
		; 		sent := true
		; 		if (endChar != "")
		; 			Send(endChar)
		; 	}
		sent := true
		try {
			this._LogUsage("Send", Map("text", text, "endChar", endChar, "isClipReverted", isClipReverted, "untilRevert", untilRevert), sent)
			return sent
		} catch Error as err {
			this._LogUsage("Send", Map("text", text, "endChar", endChar, "isClipReverted", isClipReverted, "untilRevert", untilRevert), "error: " err.Message)
			; throw err
			ErrorLogger.Log(err)
		}
	}

	/**
	 * @description Clean up resources when object is destroyed.
	 */
	__Delete() {
		; No persistent resources, but included for standards.
	}
}


; @endregion Clip
; ----------------------------------------------------------------------------
; @region Format Conversion Hotkeys
;
; Pandoc-based Format Conversion Hotkeys (Only active when NOT in VSCode):
;
; ^+r (Ctrl+Shift+R) - Convert RTF to HTML using Pandoc
; ^+m (Ctrl+Shift+M) - Convert Markdown to RTF using Pandoc (with RTF list processing)
; ^+p (Ctrl+Shift+P) - Convert Markdown to RTF using Pandoc (with RTF list processing)
; ^+h (Ctrl+Shift+H) - Convert Markdown to HTML using Pandoc
; ^+j (Ctrl+Shift+J) - Convert any format to JSON using Pandoc
; ^+f (Ctrl+Shift+F) - Format existing RTF text as proper RTF clipboard format
; ^+l (Ctrl+Shift+L) - Process clipboard content with FormatConverter (proper bullet formatting)
; ^+!p (Ctrl+Shift+Alt+P) - Convert any format to RTF using Pandoc (fallback)
;
; Legacy CSV/JSON Conversion Hotkeys (Always active):
; ^!c (Ctrl+Alt+C) - Convert to CSV
; ^!j (Ctrl+Alt+J) - Convert to JSON
; ^!k (Ctrl+Alt+K) - Convert to Key-Value JSON
; ^!#v (Ctrl+Alt+Win+V) - Convert CSV to JSON
; ^!h (Ctrl+Alt+H) - Convert RTF to HTML (at bottom of file)
;
; ----------------------------------------------------------------------------
^!c:: ; Ctrl+Alt+C to convert to CSV
{
	csvData := Clipboard.ToCSV()
	A_Clipboard := csvData
	Infos("Clipboard converted to CSV format")
}

^!j:: ; Ctrl+Alt+J to convert to JSON
{
	jsonData := Clipboard.ToJSON()
	A_Clipboard := jsonData
	Infos("Clipboard converted to JSON format")
}

^!k:: ; Ctrl+Alt+K to convert to Key-Value JSON
{
	jsonData := Clipboard.ToKeyValueJSON()
	A_Clipboard := jsonData
	MsgBoxGUI.Show("Clipboard converted to Key-Value JSON format", "Conversion Complete", "T3")
}

^!#v:: ; Ctrl+Alt+V to convert CSV to JSON
{
	jsonData := Clipboard.CSVToJSON()
	A_Clipboard := jsonData
	Infos("CSV data converted to JSON format")
}
#HotIf !WinActive(VSCode.exe)
^+r:: ; Ctrl+Shift+R to convert RTF to HTML using Pandoc
{
	try {
		htmlContent := Pandoc.toHTML(A_Clipboard)
		A_Clipboard := htmlContent
		Infos("RTF converted to HTML using Pandoc")
	} catch Error as e {
		Infos("Pandoc RTF to HTML conversion failed: " e.Message)
	}
}
^+m:: ; Ctrl+Shift+M to convert Markdown to RTF using Pandoc
{
	try {
		mdContent := Pandoc.toMD(A_Clipboard)
		A_Clipboard := mdContent
		; rtfData := FormatConverter._ProcessRTFLists(rtfContent)
		; Clipboard._SetClipboardRTF(rtfData)
		Infos("Markdown converted to RTF using Pandoc")
	} catch Error as e {
		Infos("Pandoc Markdown to RTF conversion failed: " e.Message)
	}
}
; #HotIf !WinActive(PandocFormatGUI.hwnd)
^+p:: ; Ctrl+Shift+P to show Pandoc conversion GUI
{
	PandocFormatGUI.Show()
}
; #HotIf
; #HotIf WinActive(PandocFormatGUI)
; ^+!p:: ; Ctrl+Shift+Alt+P to convert any format to RTF using Pandoc (fallback)
^+!p:: ; Ctrl+Shift+Alt+P to convert any format to RTF using Pandoc (fallback)
{
	try {
		rtfContent := Pandoc.MarkdownToRTF(A_Clipboard)
		rtfContent := Pandoc.RTFToRTF(A_Clipboard)
		rtfData := FormatConverter._ProcessRTFLists(rtfContent)
		Clipboard._SetClipboardRTF(rtfData)
		Infos("Content converted to RTF using Pandoc")
	} catch Error as e {
		Infos("Pandoc conversion failed: " e.Message)
	}
}
; #HotIf
^+f:: ; Ctrl+Shift+F to format existing RTF text as proper RTF clipboard format
{
	try {
		success := Clipboard.FormatClipboardAsRTF()
		if (success) {
			Infos("RTF content formatted and set to clipboard")
		} else {
			Infos("No RTF content found on clipboard")
		}
	} catch Error as e {
		throw Error("RTF formatting failed: " e.Message)
	}
}
^+!l:: ; Ctrl+Shift+L to process clipboard content with FormatConverter (proper bullet formatting)
{
	try {
		success := Clipboard.ProcessClipboardWithFormatConverter()
		if (success) {
			Infos("Content processed with FormatConverter and set to RTF clipboard format")
		} else {
			Infos("No suitable content found on clipboard")
		}
	} catch Error as e {
		Infos("FormatConverter processing failed: " e.Message)
	}
}
^+h:: ; Ctrl+Shift+H to convert Markdown to HTML using Pandoc
{
	try {
		htmlContent := Pandoc.toHTML(A_Clipboard)
		A_Clipboard := htmlContent
		Infos("Markdown converted to HTML using Pandoc")
	} catch Error as e {
		Infos("Pandoc Markdown to HTML conversion failed: " e.Message)
	}
}
^+j:: ; Ctrl+Shift+J to convert any format to JSON using Pandoc
{
	try {
		jsonContent := Pandoc.toJSON(A_Clipboard)
		A_Clipboard := jsonContent
		Infos("Content converted to JSON using Pandoc")
	} catch Error as e {
		Infos("Pandoc JSON conversion failed: " e.Message)
	}
}
#HotIf
; ----------------------------------------------------------------------------
; @region Format Conversion Hotkeys
;
; Pandoc-based Format Conversion Hotkeys (Only active when NOT in VSCode):
;
; ^+r (Ctrl+Shift+R) - Convert RTF to HTML using Pandoc
; ^+m (Ctrl+Shift+M) - Convert Markdown to RTF using Pandoc (with RTF list processing)
; ^+p (Ctrl+Shift+P) - Convert Markdown to RTF using Pandoc (with RTF list processing)
; ^+h (Ctrl+Shift+H) - Convert Markdown to HTML using Pandoc
; ^+j (Ctrl+Shift+J) - Convert any format to JSON using Pandoc
; ^+f (Ctrl+Shift+F) - Format existing RTF text as proper RTF clipboard format
; ^+l (Ctrl+Shift+L) - Process clipboard content with FormatConverter (proper bullet formatting)
; ^+!p (Ctrl+Shift+Alt+P) - Convert any format to RTF using Pandoc (fallback)
;
; Legacy CSV/JSON Conversion Hotkeys (Always active):
; ^!c (Ctrl+Alt+C) - Convert to CSV
; ^!j (Ctrl+Alt+J) - Convert to JSON
; ^!k (Ctrl+Alt+K) - Convert to Key-Value JSON
; ^!#v (Ctrl+Alt+Win+V) - Convert CSV to JSON
; ^!h (Ctrl+Alt+H) - Convert RTF to HTML (at bottom of file)
;
; ----------------------------------------------------------------------------
; @region Clipboard Class
; ----------------------------------------------------------------------------
/**
 * @class Clipboard
 * @description Provides advanced clipboard manipulation and introspection methods for AHK v2.
 * @version 2.0.0
 * @author OvercastBTC
 * @date 2025-04-17
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @property {UInt} SequenceNumber Current clipboard sequence number (increments on change)
 * @property {Ptr} Owner HWND of the clipboard owner window
 * @method {Array} EnumFormats() Enumerate all available clipboard formats
 * @method {String} GetFormatName(fmt) Get the name of a clipboard format
 * @method {Boolean} IsFormatAvailable(fmt) Check if a clipboard format is available
 * @method {Buffer|""} GetBuffer(fmt) Get clipboard data as a Buffer for a given format
 * @method {Int} AddFormatListener(hWnd) Add a clipboard format listener (modern)
 * @method {Int} RemoveFormatListener(hWnd) Remove a clipboard format listener
 * @method {Ptr} SetViewer(hWnd) Set the clipboard viewer (legacy)
 * @method {Int} ChangeChain(hWndRemove, hWndNext) Change the clipboard viewer chain
 * @method {ClipboardAll} BackupAll() Backup the entire clipboard using ClipboardAll()
 * @method {Boolean} RestoreAll(clipBackup) Restore the clipboard from a ClipboardAll() backup
 * @example
 *   seq := Clipboard.SequenceNumber
 *   formats := Clipboard.EnumFormats()
 *   name := Clipboard.GetFormatName(formats[1])
 *   isAvailable := Clipboard.IsFormatAvailable(13) ; Unicode text
 *   backup := Clipboard.BackupAll()
 *   ; ... do something ...
 *   Clipboard.RestoreAll(backup)
 */

class Clipboard {

	#Requires AutoHotkey v2+
	static _logFile := A_ScriptDir "\.loggers\.clipboard\clipboard_Usage.log"
	static _usageLog := []

	; @region Open()
	/**
	 * @description Opens the clipboard with retry logic.
	 * @param {Integer} maxAttempts Maximum number of attempts to open the clipboard.
	 * @param {Integer} delay Delay between attempts in milliseconds.
	 * @throws {OSError} If the clipboard cannot be opened.
	 * @returns {Boolean} True if opened successfully.
	 */
	static Open(maxAttempts := 5, delay := 50) {
		attempt := 0
		while attempt < maxAttempts {
			if DllCall('User32.dll\OpenClipboard', 'Ptr', 0) {
				return true
			}
			attempt++
			Sleep(delay)
		}
		try {

		}
		catch OSError as err {
			; throw OSError('Failed to open clipboard after ' maxAttempts ' attempts', -1)
			throw(err)
		}
	}
	; @endregion Open()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region Clear()
	/**
	 * @description Empties the clipboard.
	 * @throws {OSError} If the clipboard cannot be emptied.
	 * @returns {Boolean} True if successful.
	 */
	static Clear() {
		return !!DllCall('User32.dll\EmptyClipboard')
	}
	; @endregion Clear()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region Close()
	/**
	 * @description Closes the clipboard.
	 * @returns {Boolean} True if successful.
	 */
	static Close() {
		return !!DllCall('User32.dll\CloseClipboard')
	}
	; @endregion Close()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region _IsHTMLContent
	static _IsHTMLContent(content) {
		; Simple HTML detection logic - check for common HTML tags
		; return RegExMatch(content, "i)^\s*<(!DOCTYPE|html|head|body|div)")
		return FormatConverter.VerifyHTML(content).isHTML
	}

	; @endregion _IsHTMLContent

	static RTFToHTML(rtfText) {
		; Use FormatConverter to handle the conversion instead
		; First convert RTF to Markdown
		markdownText := FormatConverter.RTFToMarkdown(rtfText)

		; Then convert Markdown to HTML
		return FormatConverter.MarkdownToHTML(markdownText)
		}
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region _IsRTFContent
	static _IsRTFContent(content:=unset) {
		if !IsSet(content)
			content := this
		result := false
		try result := FormatConverter.VerifyRTF(content).isRTF
		return result
		; return FormatConverter.VerifyRTF(content).isRTF
	}
	; @endregion _IsRTFContent
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region _SetClipboardRTF()
	/**
	 * @description Set the clipboard content to RTF format.
	 * @param rtfText
	 */
	static _SetClipboardRTF(rtfText) {
		; TestLogger integration
		static hasTestLogger := false
		if (!hasTestLogger) {
			try {
				hasTestLogger := true
			}
		}

		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF() START", "RTF text length: " StrLen(rtfText))

		; Register RTF format if needed
		static CF_RTF := DllCall("RegisterClipboardFormat", "Str", "Rich Text Format", "UInt")
		
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF()", "CF_RTF format ID: " CF_RTF)

		; Open and clear clipboard
		; DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
		openResult := DllCall("OpenClipboard", "Ptr", 0)
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF()", "OpenClipboard result: " openResult)

		emptyResult := DllCall("EmptyClipboard")
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF()", "EmptyClipboard result: " emptyResult)

		; Allocate and copy RTF data
		allocSize := StrPut(rtfText, "UTF-8")
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF()", "Allocation size needed: " allocSize " bytes")

		hGlobal := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", allocSize)
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF()", "GlobalAlloc handle: " hGlobal)

		pGlobal := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF()", "GlobalLock pointer: " pGlobal)

		bytesWritten := StrPut(rtfText, pGlobal, "UTF-8")
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF()", "StrPut bytes written: " bytesWritten)

		unlockResult := DllCall("GlobalUnlock", "Ptr", hGlobal)
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF()", "GlobalUnlock result: " unlockResult " (0 is expected)")

		; Set clipboard data and close
		setDataResult := DllCall("SetClipboardData", "UInt", CF_RTF, "Ptr", hGlobal)
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF()", "SetClipboardData result: " setDataResult " (should equal hGlobal: " hGlobal ")")

		closeResult := DllCall("CloseClipboard")
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF()", "CloseClipboard result: " closeResult)

		; Verify clipboard was set
		if (hasTestLogger) {
			Sleep(50)  ; Small delay to let clipboard settle
			testOpen := DllCall("OpenClipboard", "Ptr", 0)
			testData := DllCall("GetClipboardData", "UInt", CF_RTF, "Ptr")
			DllCall("CloseClipboard")
			clipboardTestLogger.Log("_SetClipboardRTF() VERIFY", "Clipboard verify - opened: " testOpen ", data handle: " testData)
		}

		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardRTF() END", "Returning true")

		; this.Sleep()
		return true
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region _SetClipboardHTML()
	/**
	 * @description Set the clipboard content to HTML format for browser compatibility.
	 * @param htmlText Raw HTML content
	 */
	static _SetClipboardHTML(htmlText) {
		; TestLogger integration
		static hasTestLogger := false
		if (!hasTestLogger) {
			try {
				hasTestLogger := true
			}
		}

		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML() START", "HTML text length: " StrLen(htmlText))

		; HTML clipboard format requires a specific header
		; Format: Version:0.9\r\nStartHTML:nnnnnnnn\r\nEndHTML:nnnnnnnn\r\nStartFragment:nnnnnnnn\r\nEndFragment:nnnnnnnn\r\n<html>...</html>
		
		htmlPrefix := "<!DOCTYPE html><html><body><!--StartFragment-->"
		htmlSuffix := "<!--EndFragment--></body></html>"
		fullHTML := htmlPrefix . htmlText . htmlSuffix
		
		; Calculate byte positions (UTF-8)
		header := "Version:0.9`r`nStartHTML:00000000`r`nEndHTML:00000000`r`nStartFragment:00000000`r`nEndFragment:00000000`r`n"
		headerLen := StrPut(header, "UTF-8") - 1
		
		startHTML := headerLen
		startFragment := startHTML + StrPut(htmlPrefix, "UTF-8") - 1
		endFragment := startFragment + StrPut(htmlText, "UTF-8") - 1
		endHTML := endFragment + StrPut(htmlSuffix, "UTF-8") - 1
		
		; Format header with positions (8 digits zero-padded)
		header := Format("Version:0.9`r`nStartHTML:{:08d}`r`nEndHTML:{:08d}`r`nStartFragment:{:08d}`r`nEndFragment:{:08d}`r`n", 
						 startHTML, endHTML, startFragment, endFragment)
		
		clipboardHTML := header . fullHTML
		
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML()", "Full HTML clipboard length: " StrLen(clipboardHTML))

		; Register HTML format
		static CF_HTML := DllCall("RegisterClipboardFormat", "Str", "HTML Format", "UInt")
		
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML()", "CF_HTML format ID: " CF_HTML)

		; Open and clear clipboard
		openResult := DllCall("OpenClipboard", "Ptr", 0)
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML()", "OpenClipboard result: " openResult)

		emptyResult := DllCall("EmptyClipboard")
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML()", "EmptyClipboard result: " emptyResult)

		; Allocate and copy HTML data
		allocSize := StrPut(clipboardHTML, "UTF-8")
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML()", "Allocation size needed: " allocSize " bytes")

		hGlobal := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", allocSize)
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML()", "GlobalAlloc handle: " hGlobal)

		pGlobal := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML()", "GlobalLock pointer: " pGlobal)

		bytesWritten := StrPut(clipboardHTML, pGlobal, "UTF-8")
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML()", "StrPut bytes written: " bytesWritten)

		unlockResult := DllCall("GlobalUnlock", "Ptr", hGlobal)
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML()", "GlobalUnlock result: " unlockResult " (0 is expected)")

		; Set clipboard data and close
		setDataResult := DllCall("SetClipboardData", "UInt", CF_HTML, "Ptr", hGlobal)
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML()", "SetClipboardData result: " setDataResult " (should equal hGlobal: " hGlobal ")")

		closeResult := DllCall("CloseClipboard")
		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML()", "CloseClipboard result: " closeResult)

		if (hasTestLogger)
			clipboardTestLogger.Log("_SetClipboardHTML() END", "Returning true")

		return true
	}
	; @endregion _SetClipboardHTML()
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	;@region ToRTF()
	/**
	 * @description Converts current clipboard content to RTF format using existing converters
	 * @param {Boolean} standardize Whether to standardize existing RTF content
	 * @param {Boolean} setClipboard Whether to set converted RTF back to clipboard
	 * @param {String} sourceFormat Force a specific source format detection
	 * @returns {String} RTF formatted text
	 */
	static ToRTF(standardize := true, setClipboard := true, sourceFormat := "") {
		; Get current clipboard content and detect format
		clipText := ""
		detectedFormat := ""

		; Use enhanced format detection if no source format specified
		if (!sourceFormat) {
			detectedFormat := FormatConverter.DetectClipboardFormat()

			; Get content based on detected format using existing methods
			switch (detectedFormat) {
				case "rtf":
					clipText := this.GetRTF()
				case "html":
					clipText := this.GetHTML()
				case "csv":
					clipText := this.GetCSV()
				case "tsv":
					clipText := this.GetTSV()
				case "unicode", "text":
					clipText := this.GetUnicode()
					; Re-analyze the text content for more specific format detection
					if (clipText) {
						detectedFormat := FormatConverter.DetectFormat(clipText, false)
					}
				default:
					; Fallback to Unicode text
					clipText := this.GetUnicode()
					if (clipText) {
						detectedFormat := FormatConverter.DetectFormat(clipText, false)
					}
			}
		} else {
			; Use forced source format
			detectedFormat := sourceFormat
			switch (sourceFormat) {
				case "rtf":
					clipText := this.GetRTF()
				case "html":
					clipText := this.GetHTML()
				case "csv":
					clipText := this.GetCSV()
				case "tsv":
					clipText := this.GetTSV()
				default:
					clipText := this.GetUnicode()
			}
		}

		if (!clipText) {
			return ""
		}

		; Convert based on detected format using existing converters
		rtfContent := ""
		switch (detectedFormat) {
			case "rtf":
				rtfContent := standardize ? FormatConverter.RTFtoRTF(clipText, true) : clipText
			case "html":
				rtfContent := FormatConverter.HTMLToRTF(clipText)
			case "markdown":
				rtfContent := FormatConverter.MarkdownToRTF(clipText)
			case "csv", "tsv":
				; Convert structured data to RTF using existing method
				rtfContent := FormatConverter.toRTF(clipText)
			default:
				; Plain text or unknown format
				rtfContent := FormatConverter.toRTF(clipText)
		}

		; Set back to clipboard if requested using existing method
		if (setClipboard && rtfContent) {
			this.Set.RTF(rtfContent)
		}

		this._LogUsage("ToRTF", Map(
			"standardize", standardize,
			"setClipboard", setClipboard,
			"sourceFormat", detectedFormat
		), rtfContent)

		return rtfContent
	}
	; @endregion ToRTF()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	static ConvertClipboardRTFToHTML() {
		; Check if clipboard has RTF
		if (!Clipboard.IsFormatAvailable(Clipboard.RegisterFormat.RTF)) {
			objMsg := {success: false, message: "No RTF content in clipboard"}
			strMsg := objMsg.ToString()
			Infos(strMsg)
			return objMsg
		}

		; Get RTF content
		rtfContent := Clipboard.GetRTF()

		; Convert to HTML
		htmlContent := FormatConverter.RTFToHTML(rtfContent)
		if (!htmlContent) {
			objMsg := {success: false, message: "Conversion failed"}
			strMsg := objMsg.ToString()
			Infos(strMsg)
			return objMsg
		}

		; Set HTML to clipboard
		previousClipboard := ClipboardAll()  ; Backup clipboard
		A_Clipboard := ""  ; Clear clipboard

		; Set HTML format
		Clipboard.Set.HTML(htmlContent)

		objMsg := {success: true, message: "RTF converted to HTML successfully", html: htmlContent}
		strMsg := objMsg.ToString()
		Infos(strMsg)
		return objMsg
	}
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region winclipSetRTF()
	; static winclipSetRTF(rtfText) {
	; 	wClip := WinClip()
	; 	if (this._IsRTFContent(rtfText)) {
	; 		wClip.SetRTF(rtfText)
	; 	} else {
	; 		throw OSError("Invalid RTF content", -1)
	; 	}
	; }
	; @endregion winclipSetRTF()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region SetRTF()
	static SetRTF(rtfText) {
		; return this.winclipSetRTF(rtfText)
		return this._SetClipboardRTF(rtfText)
	}
	; @endregion SetRTF()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region FormatClipboardAsRTF()
	/**
	 * @description Takes existing RTF text from clipboard and formats it properly as RTF clipboard format
	 * @returns {Boolean} True if successful, false if no RTF content found
	 * @throws {Error} If clipboard operation fails
	 */
	static FormatClipboardAsRTF() {
		try {
			; Get existing RTF content from clipboard
			rtfContent := this.GetRTF()

			; If no RTF content found, try to get plain text that might be RTF
			if (!rtfContent) {
				plainText := A_Clipboard
				; Check if plain text contains RTF content
				if (this._IsRTFContent(plainText)) {
					rtfContent := plainText
				} else {
					return false
				}
			}

			; Set the RTF content back to clipboard with proper formatting
			return this._SetClipboardRTF(rtfContent)
		} catch Error as e {
			throw Error("Failed to format clipboard as RTF: " e.Message, -1)
		}
	}
	; @endregion FormatClipboardAsRTF()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region ProcessClipboardWithFormatConverter()
	/**
	 * @description Uses FormatConverter to properly process clipboard content (markdown/text) to RTF format
	 * @returns {Boolean} True if successful, false if no suitable content found
	 * @throws {Error} If conversion fails
	 */
	static ProcessClipboardWithFormatConverter() {
		try {
			; Get clipboard text content
			textContent := A_Clipboard

			if (!textContent) {
				return false
			}

			; Use FormatConverter to convert to RTF (handles markdown and text formatting)
			rtfContent := FormatConverter.MarkdownToRTF(textContent)

			if (!rtfContent) {
				return false
			}

			; Set the processed RTF content to clipboard
			return this._SetClipboardRTF(rtfContent)
		} catch Error as e {
			throw Error("Failed to process clipboard with FormatConverter: " e.Message, -1)
		}
	}
	; @endregion ProcessClipboardWithFormatConverter()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region BackupAndClearClipboard()
	/**
	 * @description Backup the entire clipboard using ClipboardAll()
	 * @returns {ClipboardAll} The backup of the clipboard.
	 */
	static BackupAndClearClipboard(&backup?) {
		backup := this.Backup()
		this.Clear()
		return backup
	}

	/**
	 * @description {helper method} Backup and clear the clipboard.
	 * @returns {ClipboardAll} The backup of the clipboard from BackupAndClearClipboard()
	 */
	static BackupAndClear(&backup?) {
		return this.BackupAndClearClipboard(&backup)
	}

	;@region Send()
	/**
	 * Universal send method handling both RTF and regular content
	 * @param {String|Array|Map|Object|Class} input The content to send
	 * @param {String} endChar The ending character(s) to append
	 * @param {Boolean} isClipReverted Whether to revert the clipboard
	 * @param {Integer} untilRevert Time in ms before reverting clipboard
	 * @returns {String} The sent content
	 */

	static Send(input?, endChar := '', isClipReverted := true, untilRevert := 500, delay := A_Delay) {
		; TestLogger integration
		static hasTestLogger := false
		if (!hasTestLogger) {
			try {
				
				hasTestLogger := true
				clipboardTestLogger.Info("Clipboard.Send() - TestLogger initialized")
			} catch {
				hasTestLogger := false
			}
		}

		if (hasTestLogger)
			clipboardTestLogger.Log("Clipboard.Send() START", "input: " (IsSet(input) ? Type(input) " len=" StrLen(input) : "UNSET") ", endChar: '" endChar "', isClipReverted: " isClipReverted ", untilRevert: " untilRevert)

		prevClip := ''

		ReadyToRestore := false
		GroupAdd('CtrlV', 'ahk_exe EXCEL.exe')
		GroupAdd('CtrlV', 'ahk_exe VISIO.exe')
		GroupAdd('CtrlV', 'ahk_exe OUTLOOK.exe') ;? maybe?

		if (!IsSet(input)){
			input := this
			if (hasTestLogger)
				clipboardTestLogger.Log("Clipboard.Send()", "Input was unset, using 'this' (Clipboard class)")
		}

	; Handle backup and clear first
	if (isClipReverted){
		prevClip := this.BackupAndClear()
		if (hasTestLogger) {
			prevClipType := Type(prevClip)
			prevClipInfo := (prevClipType = "ClipboardAll") ? "ClipboardAll object (binary)" : "String len: " StrLen(prevClip)
			clipboardTestLogger.Log("Clipboard.Send()", "Backup created, type: " prevClipType ", " prevClipInfo)
		}
	}		; Regular content handling
		input := StrReplace(input, "`n", "`r`n") ; Convert Unix-style to Windows-style
		input := StrReplace(input, "`r`r`n", "`r`n") ; Remove extra CRLF
		input := StrReplace(input, "`r`r", "`r") ; Remove extra CR
		input := input endChar

	if (hasTestLogger)
		clipboardTestLogger.Log("Clipboard.Send()", "After line ending normalization, input len: " StrLen(input))

	; Check active window to determine best clipboard format
	activeExe := ""
	try activeExe := WinGetProcessName("A")
	isBrowser := (activeExe ~= "i)(chrome|msedge|firefox|brave|opera)\.exe")
	
	if (hasTestLogger && isBrowser)
		clipboardTestLogger.Log("Clipboard.Send()", "Browser detected (" activeExe "), will use HTML format instead of RTF")

	; input._IsRTFContent()
	; Process input based on type
	if (this._IsRTFContent(input)) {
		; For browsers, convert RTF to HTML for better compatibility
		if (isBrowser) {
			if (hasTestLogger)
				clipboardTestLogger.Log("Clipboard.Send()", "Converting RTF to HTML for browser compatibility")
			try {
				htmlContent := Pandoc.Convert("rtf", "html", input)
				if (hasTestLogger)
					clipboardTestLogger.Log("Clipboard.Send()", "RTF->HTML conversion successful, length: " StrLen(htmlContent))
				this._SetClipboardHTML(htmlContent)
			} catch Error as e {
				if (hasTestLogger)
					clipboardTestLogger.Log("Clipboard.Send()", "RTF->HTML conversion failed: " e.Message ", falling back to RTF")
				this._SetClipboardRTF(input)
			}
		} else {
			if (hasTestLogger)
				clipboardTestLogger.Log("Clipboard.Send()", "RTF content detected, calling _SetClipboardRTF()")
			Infos("Sending RTF content via clipboard")
			this._SetClipboardRTF(input)
		}
		if (hasTestLogger)
			clipboardTestLogger.Log("Clipboard.Send()", "Clipboard set, waiting for clipboard to be ready")
		; Critical: Wait for clipboard to be ready after setting RTF/HTML
		this.Wait(A_Delay * 10)  ; Give clipboard time to settle with data
	}
	else {
		if (hasTestLogger)
			clipboardTestLogger.Log("Clipboard.Send()", "Plain text detected, setting A_Clipboard directly")
		A_Clipboard := input
		if (hasTestLogger)
			clipboardTestLogger.Log("Clipboard.Send()", "Waiting for clipboard to be ready")
		this.Wait(A_Delay * 10)  ; Wait up to 1 second for clipboard to contain data
	}		; Wait for clipboard and send
		; Sleep(A_Delay)

		if (hasTestLogger) {
			activeWin := WinGetTitle("A")
			activeExe := WinGetProcessName("A")
			clipboardTestLogger.Log("Clipboard.Send()", "Active window: " activeWin " (exe: " activeExe ")")
			clipboardTestLogger.Log("Clipboard.Send()", "About to Send(keys.paste) = " keys.paste)
		}
		
		; Small delay to ensure window has focus and is ready to receive paste
		Sleep(50)
		
		Send(keys.paste)
		
		if (hasTestLogger) {
			clipboardTestLogger.Log("Clipboard.Send()", "Paste command sent successfully")
			; Check if focus changed
			Sleep(10)
			newActiveWin := WinGetTitle("A")
			if (newActiveWin != activeWin)
				clipboardTestLogger.Log("Clipboard.Send()", "WARNING: Active window changed to: " newActiveWin)
		}
		; Sleep(A_Delay)
		readyToRestore := true
		; If WinActive('ahk_group CtrlV') {
		; 	; Send('{sc1D Down}{sc2F}{sc1D Up}')          ;! {Control}{v}
		; 	Send(keys.paste)
		; 	Sleep(A_Delay)
		; 	readyToRestore := true
		; }
		; else {
		; 	; Send('{sc2A Down}{sc152}{sc2A Up}')         ;! {Shift}{Insert}
		; 	Send(keys.shiftinsert)
		; 	Sleep(A_Delay)
		; 	readyToRestore := true
		; }


		; Restore clipboard if needed using SetTimer with negative delay (countdown)
		if (isClipReverted && readyToRestore) {
			if (hasTestLogger)
				clipboardTestLogger.Log("Clipboard.Send()", "Setting timer to restore clipboard in " A_Delay "ms")
			SetTimer(() => (
				this.Clear(),
				A_Clipboard := prevClip,
				this.Wait()
			), -A_Delay)
		}

		if (hasTestLogger)
			clipboardTestLogger.Log("Clipboard.Send() END", "Returning input, len: " StrLen(input))
		return input
	}

	/**
	 * @property {Boolean} IsEmpty
	 * @description Checks if the clipboard is empty.
	 * @returns {Boolean} True if empty.
	; Check if the clipboard is empty
	; If GetClipboardData returns 0, the clipboard is empty
	; If it returns a valid handle, the clipboard is not empty
	; Return true if empty, false otherwise
	*/
	static IsEmpty => this._IsEmpty()

	static _IsEmpty() {

		if DllCall("User32.dll\OpenClipboard", "Ptr", 0) {
			return (DllCall("User32.dll\GetClipboardData", "UInt", 0) ? false : true)
		}
		else {
			throw OSError("Failed to check clipboard", -1)
		}
	}

	/**
	 * @property {UInt} GetSequenceNumber
	 * @description Gets the clipboard sequence number (increments on change).
	 * @example
	 *   seq := Clipboard.GetSequenceNumber
	 */
	static GetSequenceNumber => DllCall("User32.dll\GetClipboardSequenceNumber", "UInt")

	/**
	 * @property {Ptr} Owner
	 * @description Gets the HWND of the clipboard owner.
	 * @example
	 *   hwnd := Clipboard.Owner
	 */
	static Owner => DllCall("User32.dll\GetClipboardOwner", "Ptr")

	/**
	 * @method EnumFormats
	 * @description Enumerates all available clipboard formats.
	 * @returns {Array} Array of format identifiers.
	 * @example
	 *   formats := Clipboard.EnumFormats()
	 */
	static EnumFormats() {
		local formats := []
		local prevFormat := 0
		this.Open()
		try {
			while (nextFormat := DllCall("User32.dll\EnumClipboardFormats", "UInt", prevFormat, "UInt")) {
				formats.Push(nextFormat)
				prevFormat := nextFormat
			}
		}
		finally {
			this.Close()
		}
		return formats
	}

	/**
	 * @method GetFormatName
	 * @description Gets the name of a clipboard format.
	 * @param {Integer} fmt Format identifier.
	 * @returns {String} Format name or empty string.
	 * @throws {ValueError} If format identifier is not provided.
	 * @example
	 *   name := Clipboard.GetFormatName(fmt)
	 */
	static GetFormatName(fmt) {
		local buf := Buffer(128, 0)
		if !IsSet(fmt) || !fmt {
			throw ValueError("Format identifier required", -1)
		}
		this.Open()
		try {
			local len := DllCall("User32.dll\GetClipboardFormatName", "UInt", fmt, "Ptr", buf, "Int", 128, "Int")
			return len ? StrGet(buf, len, "UTF-16") : ""
		}
		finally {
			this.Close()
		}
	}

	/**
	 * @method IsFormatAvailable
	 * @description Checks if a clipboard format is available.
	 * @param {Integer} fmt Format identifier.
	 * @returns {Boolean} True if available.
	 * @throws {ValueError} If format identifier is not provided.
	 * @example
	 *   isAvailable := Clipboard.IsFormatAvailable(13)
	 */
	static IsFormatAvailable(fmt) {
		if !IsSet(fmt) || !fmt {
			throw ValueError("Format identifier required", -1)
		}
		return !!DllCall("User32.dll\IsClipboardFormatAvailable", "UInt", fmt, "Int")
	}

	/**
	 * @method GetBuffer
	 * @description Gets clipboard data as a Buffer for a given format.
	 * @param {Integer} fmt Format identifier.
	 * @returns {Buffer|""} Buffer with clipboard data or empty string.
	 * @throws {ValueError} If format identifier is not provided.
	 * @example
	 *   buf := Clipboard.GetBuffer(13)
	 */
	static GetBuffer(fmt) {
		if !IsSet(fmt) || !fmt {
			throw ValueError("Format identifier required", -1)
		}
		this.Open()
		try {
			local hData := DllCall("User32.dll\GetClipboardData", "UInt", fmt, "Ptr")
			if !hData {
				return ""
			}
			local pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "Ptr")
			if !pData {
				return ""
			}
			local size := DllCall("Kernel32.dll\GlobalSize", "Ptr", hData, "UPtr")
			local buf := Buffer(size)
			DllCall("RtlMoveMemory", "Ptr", buf, "Ptr", pData, "UPtr", size)
			DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
			return buf
		} finally this.Close()
	}

	/**
	 * @method AddFormatListener
	 * @description Adds a clipboard format listener (modern clipboard monitoring).
	 * @param {Ptr} hWnd Window handle to receive notifications.
	 * @returns {Int} Nonzero if successful.
	 * @throws {ValueError} If window handle is not provided.
	 */
	static AddFormatListener(hWnd) {
		if !IsSet(hWnd) || !hWnd
			throw ValueError("Window handle required", -1)
		return DllCall("User32.dll\AddClipboardFormatListener", "Ptr", hWnd, "Int")
	}

	/**
	 * @method RemoveFormatListener
	 * @description Removes a clipboard format listener.
	 * @param {Ptr} hWnd Window handle.
	 * @returns {Int} Nonzero if successful.
	 * @throws {ValueError} If window handle is not provided.
	 */
	static RemoveFormatListener(hWnd) {
		if !IsSet(hWnd) || !hWnd
			throw ValueError("Window handle required", -1)
		return DllCall("User32.dll\RemoveClipboardFormatListener", "Ptr", hWnd, "Int")
	}

	/**
	 * @method SetViewer
	 * @description Sets the clipboard viewer (legacy monitoring).
	 * @param {Ptr} hWnd Window handle.
	 * @returns {Ptr} Handle to the next window in the chain.
	 * @throws {ValueError} If window handle is not provided.
	 */
	static SetViewer(hWnd) {
		if !IsSet(hWnd) || !hWnd
			throw ValueError("Window handle required", -1)
		return DllCall("User32.dll\SetClipboardViewer", "Ptr", hWnd, "Ptr")
	}

	/**
	 * @method ChangeChain
	 * @description Changes the clipboard viewer chain.
	 * @param {Ptr} hWndRemove Handle to remove.
	 * @param {Ptr} hWndNext Next window in chain.
	 * @returns {Int} Nonzero if successful.
	 * @throws {ValueError} If either window handle is not provided.
	 */
	static ChangeChain(hWndRemove, hWndNext) {
		if !IsSet(hWndRemove) || !hWndRemove
			throw ValueError("hWndRemove required", -1)
		if !IsSet(hWndNext) || !hWndNext
			throw ValueError("hWndNext required", -1)
		return DllCall("User32.dll\ChangeClipboardChain", "Ptr", hWndRemove, "Ptr", hWndNext, "Int")
	}

	/**
	 * @method BackupAll
	 * @description Backup the entire clipboard using ClipboardAll().
	 * @returns {ClipboardAll} Clipboard backup object.
	 * @example
	 *   backup := Clipboard.BackupAll()
	 */
	static BackupAll(&cBak?) {
		cBak := ClipboardAll()
		return cBak
	}

	/**
	 * @method Backup
	 * @description {helper method} Backup the entire clipboard using ClipboardAll().
	 * @returns {ClipboardAll} Clipboard backup object from BackupAll()
	 * @example
	 *   backup := Clipboard.BackupAll()
	 */
	static Backup(&cBak?) {
		return this.BackupAll(&cBak)
	}

	/**
	 * @method RestoreAll
	 * @description Restore the clipboard from a ClipboardAll() backup.
	 * @param {ClipboardAll} clipBackup The backup object to restore.
	 * @returns {Boolean} True if restored.
	 * @throws {ValueError} If backup is not provided.
	 * @example
	 *   Clipboard.RestoreAll(backup)
	 */
	static RestoreAll(clipBackup) {
		if !IsSet(clipBackup){
			throw ValueError("ClipboardAll backup required", -1)
		}
		A_Clipboard := clipBackup
		return true
	}

	/**
	 * @method Restore()
	 * @description Restores the clipboard from a backup.
	 * @param {ClipboardAll} clipBackup The backup object to restore.
	 * @returns {Boolean} True if restored.
	 * @throws {ValueError} If backup is not provided.
	 * @example
	 *   Clipboard.Restore(backup)
	 */
	static Restore(clipBackup) {
		return this.RestoreAll(clipBackup)
	}

	/**
	 * @property {Boolean} IsOpen
	 * @description Checks if the clipboard is currently open.
	 * @returns {Boolean}
	 */
	static IsOpen => !!DllCall("User32.dll\GetOpenClipboardWindow", "Ptr")

	/**
	 * @property {Boolean} IsBusy
	 * @description Checks if the clipboard is currently busy.
	 * @returns {Boolean}
	 */
	static IsBusy => !!DllCall("User32.dll\GetOpenClipboardWindow", "Ptr")

	/**
	 * @property {Boolean} IsNotBusy
	 * @description Checks if the clipboard is not busy.
	 * @returns {Boolean}
	 */
	static IsNotBusy => !DllCall("User32.dll\GetOpenClipboardWindow", "Ptr")

	/**
	 * @method Wait
	 * @description Waits until the clipboard is available or timeout.
	 * @param {Integer} timeout Timeout in ms.
	 * @returns {Boolean} True if clipboard became available.
	 */
	static Wait(timeout := 1000) {
		local startTime := A_TickCount
		while this.IsBusy {
			if (A_TickCount - startTime > timeout) {
				return false
			}
			Sleep(10)
		}
		return true
	}

	/**
	 * @method ClearClipboard
	 * @description Clears the clipboard safely.
	 * @returns {Boolean} True if successful.
	 */
	static ClearClipboard() {
		this.OpenClipboard()
		this.EmptyClipboard()
		this.CloseClipboard()
		Sleep(A_Delay)
		return true
	}

	/**
	 * @method OpenClipboard
	 * @description Opens the clipboard with retry logic.
	 * @param {Integer} maxAttempts Maximum number of attempts to open the clipboard.
	 * @param {Integer} delay Delay between attempts in milliseconds.
	 * @returns {Boolean} True if opened successfully.
	 * @throws {OSError} If the clipboard cannot be opened.
	 */
	static OpenClipboard(maxAttempts := 5, delay := 50) {
		local attempt := 0
		while attempt < maxAttempts {
			if DllCall("User32.dll\OpenClipboard", "Ptr", 0) {
				return true
			}
			attempt++
			Sleep(delay)
		}
		throw OSError("Failed to open clipboard after " maxAttempts " attempts", -1)
	}

	/**
	 * @method EmptyClipboard
	 * @description Empties the clipboard.
	 * @returns {Boolean} True if successful.
	 * @throws {OSError} If the clipboard cannot be emptied.
	 */
	static EmptyClipboard() {
		if !DllCall("User32.dll\EmptyClipboard") {
			throw OSError("Failed to empty clipboard", -1)
		}
		return true
	}

	/**
	 * @method CloseClipboard
	 * @description Closes the clipboard.
	 * @returns {Boolean} True if successful.
	 */
	static CloseClipboard() {
		return !!DllCall("User32.dll\CloseClipboard")
	}

	/**
	 * @method Busy
	 * @description Checks if clipboard is currently open/busy.
	 * @returns {Boolean} True if busy.
	 */
	static Busy() {
		return !!DllCall("User32.dll\GetOpenClipboardWindow", "Ptr")
	}

	/**
	 * @method Sleep
	 * @description Waits for the clipboard to be available or for a specified time.
	 * @param {Integer} n Time in ms to wait.
	 * @returns {Void}
	 */
	static Sleep(n := 10) {
		this.Wait(n)
	}


	/**
	 * @description Gets clipboard data as string for a given format.
	 * @param {Integer} format Clipboard format identifier.
	 * @returns {String} Clipboard content or empty string.
	 */
	static GetContent(format := 1) => this.Get.Content(format)

	/**
	 * @description Gets TSV content from the clipboard.
	 * @returns {String} TSV clipboard content or empty string.
	 */
	static GetTSV() {
		format := this.RegisterFormat.TSV()
		return this.GetContent(format)
	}

	/**
	 * @description Gets plain text from the clipboard.
	 * @returns {String} Clipboard text or empty string.
	 */
	static GetPlain() {
		static CF_TEXT := 1
		return this.GetContent(CF_TEXT)
	}

	/**
	 * @description Gets Unicode text from the clipboard.
	 * @returns {String} Clipboard text or empty string.
	 */
	static GetUnicode() {
		static CF_UNICODETEXT := 13
		return this.GetContent(CF_UNICODETEXT)
	}

	/**
	 * @description Get text content from clipboard with automatic format detection
	 * @param {String} format Optional format specification ("text", "unicode", "rtf", "html", "csv", "tsv", "auto")
	 * @returns {String} Text content from clipboard
	 */
	static GetText(format := "auto") {
		switch format {
			case "text", "plain":
				return this.GetPlain()
			case "unicode":
				return this.GetUnicode()
			case "rtf":
				return this.GetRTF()
			case "html":
				return this.GetHTML()
			case "csv":
				return this.GetCSV()
			case "tsv":
				return this.GetTSV()
			case "auto":
				; Auto-detect format
				if this.IsFormatAvailable(this.RegisterFormat.RTF) {
					return this.GetRTF()
				} else if this.IsFormatAvailable(this.RegisterFormat.HTML) {
					return this.GetHTML()
				} else if this.IsFormatAvailable(this.RegisterFormat.UnicodeText) {
					return this.GetUnicode()
				} else {
					return this.GetPlain()
				}
			default:
				return this.GetPlain()
		}
	}

	/**
	 * @description Gets RTF content from the clipboard.
	 * @returns {String} RTF clipboard content or empty string.
	 */
	static GetRTF() {
		format := this.RegisterFormat.RTF
		return this.GetContent(format)
	}

	/**
	 * @description Gets HTML content from the clipboard.
	 * @returns {String} HTML clipboard content or empty string.
	 */
	static GetHTML() {
		format := this.RegisterFormat.HTML
		return this.GetContent(format)
	}

	/**
	 * @description Gets CSV content from the clipboard.
	 * @returns {String} CSV clipboard content or empty string.
	 */
	static GetCSV() {
		format := this.RegisterFormat.CSV
		return this.GetContent(format)
	}

	/**
	 * @description Convert clipboard content to CSV.
	 * @returns {String} CSV text.
	 */
	static ToCSV() {
		clipText := Clipboard.GetPlain()
		lines := StrSplit(clipText, "`n", "`r")
		csvText := ""
		for index, line in lines {
			fields := StrSplit(line, "`t")
			csvLine := ""
			for _, field in fields {
				csvLine .= '"' . StrReplace(field, '"', '""') . '",'
			}
			csvText .= RTrim(csvLine, ",") . "`n"
		}
		csvText := RTrim(csvText, "`n")
		this._LogUsage("ToCSV", Map(), csvText)
		return csvText
	}

	/**
	 * @description Convert clipboard content to JSON.
	 * @returns {String} JSON text.
	 */
	static ToJSON() {
		clipText := Clipboard.GetPlain()
		lines := StrSplit(clipText, "`n", "`r")
		jsonArray := []
		headers := StrSplit(lines[1], "`t")
		for i, line in lines {
			if (i == 1) {
				continue
			}
			fields := StrSplit(line, "`t")
			; Use a plain Map instead of {} to avoid __Item error
			row := Map()
			Loop headers.Length {
				row[headers[A_Index]] := fields.Has(A_Index) ? fields[A_Index] : ""
			}
			jsonArray.Push(row)
		}
		json := cJson.Dump(jsonArray)
		this._LogUsage("ToJSON", Map(), json)
		return json
	}

	/**
	 * @description Convert clipboard content to Key-Value JSON.
	 * @returns {String} JSON text.
	 */
	static ToKeyValueJSON() {
		clipText := Clipboard.GetPlain()
		lines := StrSplit(clipText, "`n", "`r")
		obj := {}
		currentSection := "root"
		for _, line in lines {
			if (RegExMatch(line, "\[(.+?)\]", &match)) {
				currentSection := Trim(match[1])
				obj[currentSection] := {}
			} else if (RegExMatch(line, "(.+?):(.+)", &match)) {
				key := Trim(match[1])
				value := Trim(match[2])
				if (currentSection == "root") {
					obj[key] := value
				} else {
					obj[currentSection][key] := value
				}
			}
		}
		json := cJson.Dump(obj)
		this._LogUsage("ToKeyValueJSON", Map(), json)
		return json
	}

	/**
	 * @description Convert CSV clipboard content to JSON.
	 * @returns {String} JSON text.
	 */
	static CSVToJSON() {
		csvText := Clipboard.GetCSV()
		lines := StrSplit(csvText, "`n", "`r")
		jsonArray := []
		headers := StrSplit(lines[1], ",")
		headers := headers.Map((header) => (StrReplace(Trim(header, '"'), " ", "_")))
		for i, line in lines {
			if (i == 1) {
				continue
			}
			fields := StrSplit(line, ",")
			obj := {}
			Loop headers.Length {
				obj[headers[A_Index]] := fields.Has(A_Index) ? Trim(fields[A_Index], '"') : ""
			}
			jsonArray.Push(obj)
		}
		json := cJson.Dump(jsonArray)
		this._LogUsage("CSVToJSON", Map(), json)
		return json
	}
	;@region class Get
	/**
	 * @class Clipboard.Get
	 * @description Provides grouped accessors for clipboard state and sequence number.
	 */
	class Get {

		/**
		 * @property {UInt} SequenceNumber
		 * @description Gets the clipboard sequence number (increments on change).
		 * @example
		 *   seq := Clipboard.Get.SequenceNumber
		 */
		static SequenceNumber => DllCall("User32.dll\GetClipboardSequenceNumber", "UInt")

		/**
		 * @property {Ptr} Owner
		 * @description Gets the HWND of the clipboard owner.
		 * @example
		 *   hwnd := Clipboard.Get.Owner
		 */
		static Owner => DllCall("User32.dll\GetClipboardOwner", "Ptr")

		/**
		 * @property {String} Format
		 * @description Gets the current clipboard format.
		 * @example
		 *   format := Clipboard.Get.Format
		 */
		static Format => DllCall("User32.dll\GetClipboardFormatName", "UInt", DllCall("User32.dll\GetClipboardFormatName", "UInt"), "Str", "", "UInt", 256)

		/**
		 * @method Clipboard.Get.Data
		 * @description Retrieves data from the clipboard.
		 * @param {UInt} format The format of the data to retrieve.
		 * @returns {Ptr} Pointer to the clipboard data.
		 * @throws {OSError} If the data cannot be retrieved.
		 */
		static Data(format) {
			if !IsSet(format) {
				throw ValueError("Format required", -1)
			}
			if !DllCall("User32.dll\OpenClipboard", "Ptr", 0) {
				throw OSError("Failed to open clipboard", -1)
			}
			local hData := DllCall("User32.dll\GetClipboardData", "UInt", format, "Ptr")
			if !hData {
				throw OSError("Failed to get clipboard data", -1)
			}
			return hData
		}

		/**
		 * @description Gets clipboard data as string for a given format.
		 * @param {Integer} format Clipboard format identifier.
		 * @returns {String} Clipboard content or empty string.
		 */
		static Content(format := 1) {
			if !Clipboard.Open() {
				return ""
			}
			try {
				hData := DllCall('User32.dll\GetClipboardData', 'UInt', format, 'Ptr')
				if !hData {
					return ""
				}
				pData := DllCall('Kernel32.dll\GlobalLock', 'Ptr', hData, 'Ptr')
				if !pData {
					return ""
				}
				text := StrGet(pData, "UTF-8")
				DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', hData)
				return text
			}
			finally {
				Clipboard.Close()
			}
		}
	}
	; ---------------------------------------------------------------------------
	;@endregion class Get
	; ---------------------------------------------------------------------------

	; For backward compatibility, keep static methods on Clipboard itself
	/**
	 * @description Sets clipboard content with specified format.
	 * @param {String} content Content to set in the clipboard.
	 * @param {Integer} format Clipboard format identifier.
	 * @throws {OSError} If clipboard operations fail.
	 */
	static SetContent(content, format) => Clipboard.Set.Content(content, format)

	;@region class Set
	/**
	 * @class Clipboard.Set
	 * @description Provides methods to set clipboard content in various formats and raw format.
	 * @version 1.1.0
	 * @author OvercastBTC
	 * @date 2025-06-11
	 * @requires AutoHotkey v2.0+
	 */
	class Set {
		/**
		 * @description Sets clipboard content with specified format using proper error handling
		 * @param {String} content Content to set in the clipboard
		 * @param {Integer} format Clipboard format identifier
		 * @throws {OSError} If clipboard operations fail
		 * @returns {Boolean} True if successful
		 */
		static Content(content, format) {
			if (!IsString(content)) {
				throw TypeError("Content must be a string", -1)
			}

			if (!IsInteger(format) || format <= 0) {
				throw ValueError("Format must be a positive integer", -1)
			}

			; Ensure clipboard is closed first
			try {
				Clipboard.Close()
			} catch {
				; Ignore if already closed
			}

			; Wait for clipboard to be available
			if (!Clipboard.Wait(1000)) {
				throw OSError("Clipboard is busy and cannot be accessed", -1)
			}

			; Open with retry logic
			if (!Clipboard.Open(5, 100)) {
				throw OSError("Failed to open clipboard for writing", -1)
			}

			try {
				; Clear existing content
				Clipboard.Clear()

				; Allocate and set content
				size := StrPut(content, "UTF-8")
				hGlobal := DllCall('Kernel32.dll\GlobalAlloc', 'UInt', 0x42, 'UPtr', size, 'Ptr')

				if (!hGlobal) {
					throw OSError('Failed to allocate memory for clipboard', -1)
				}

				try {
					pGlobal := DllCall('Kernel32.dll\GlobalLock', 'Ptr', hGlobal, 'Ptr')
					if (!pGlobal) {
						throw OSError('Failed to lock memory for clipboard', -1)
					}

					StrPut(content, pGlobal, "UTF-8")
					DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', hGlobal)

					if (!DllCall('User32.dll\SetClipboardData', 'UInt', format, 'Ptr', hGlobal)) {
						throw OSError('Failed to set clipboard data', -1)
					}

					hGlobal := 0 ; Ownership transferred to system
					return true

				} catch as err {
					if (hGlobal) {
						DllCall('Kernel32.dll\GlobalFree', 'Ptr', hGlobal)
					}
					throw err
				}

			} finally {
				Clipboard.Close()
			}
		}

		/**
		 * @description Sets RTF content to the clipboard with enhanced error handling
		 * @param {String} rtfText RTF formatted text
		 * @param {String} endChar Optional character(s) to append
		 * @throws {OSError} If clipboard operations fail
		 * @throws {TypeError} If rtfText is not a string
		 * @returns {Boolean} True if successful
		 */
		static RTF(rtfText, endChar := '') {
			; Validate input
			if (!IsString(rtfText)) {
				throw TypeError("RTF text must be a string", -1)
			}

			if (!IsString(endChar)) {
				throw TypeError("End character must be a string", -1)
			}

			; Validate RTF content
			if (!Clipboard._IsRTFContent(rtfText)) {
				throw ValueError("Invalid RTF content provided", -1)
			}

			; Get RTF format identifier
			static rtfFormat := 0
			if (!rtfFormat) {
				rtfFormat := Clipboard.RegisterFormat.RTF
				if (!rtfFormat) {
					throw OSError("Failed to register RTF clipboard format", -1)
				}
			}

			; Prepare content
			finalContent := rtfText . endChar

			; Set content using the robust Content method
			try {
				return this.Content(finalContent, rtfFormat)
			} catch as err {
				throw OSError("Failed to set RTF content: " . err.Message, -1)
			}
		}

		/**
		 * @description Sets plain text to the clipboard with error handling
		 * @param {String} text Plain text
		 * @throws {OSError} If clipboard operations fail
		 * @throws {TypeError} If text is not a string
		 * @returns {Boolean} True if successful
		 */
		static Plain(text) {
			if (!IsString(text)) {
				throw TypeError("Text must be a string", -1)
			}

			static CF_TEXT := 1
			return this.Content(text, CF_TEXT)
		}

		/**
		 * @description Sets Unicode text to the clipboard with enhanced handling
		 * @param {String} text Unicode text
		 * @throws {OSError} If clipboard operations fail
		 * @throws {TypeError} If text is not a string
		 * @returns {Boolean} True if successful
		 */
		static Unicode(text) {
			if (!IsString(text)) {
				throw TypeError("Text must be a string", -1)
			}

			static CF_UNICODETEXT := 13

			; Ensure clipboard is available
			try {
				Clipboard.Close()
			} catch {
				; Ignore if already closed
			}

			if (!Clipboard.Wait(1000)) {
				throw OSError("Clipboard is busy and cannot be accessed", -1)
			}

			if (!Clipboard.Open(5, 100)) {
				throw OSError("Failed to open clipboard for Unicode text", -1)
			}

			try {
				Clipboard.Clear()

				; Calculate size for UTF-16
				size := StrPut(text, "UTF-16")
				hGlobal := DllCall('Kernel32.dll\GlobalAlloc', 'UInt', 0x42, 'UPtr', size * 2, 'Ptr')

				if (!hGlobal) {
					throw OSError('Failed to allocate memory for Unicode text', -1)
				}

				try {
					pGlobal := DllCall('Kernel32.dll\GlobalLock', 'Ptr', hGlobal, 'Ptr')
					if (!pGlobal) {
						throw OSError('Failed to lock memory for Unicode text', -1)
					}

					StrPut(text, pGlobal, "UTF-16")
					DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', hGlobal)

					if (!DllCall('User32.dll\SetClipboardData', 'UInt', CF_UNICODETEXT, 'Ptr', hGlobal)) {
						throw OSError('Failed to set Unicode clipboard data', -1)
					}

					hGlobal := 0 ; Ownership transferred
					return true

				} catch as err {
					if (hGlobal) {
						DllCall('Kernel32.dll\GlobalFree', 'Ptr', hGlobal)
					}
					throw err
				}

			} finally {
				Clipboard.Close()
			}
		}

		/**
		 * @description Sets HTML content to the clipboard
		 * @param {String} htmlText HTML formatted text
		 * @throws {OSError} If clipboard operations fail
		 * @throws {TypeError} If htmlText is not a string
		 * @returns {Boolean} True if successful
		 */
		static HTML(htmlText) {
			if (!IsString(htmlText)) {
				throw TypeError("HTML text must be a string", -1)
			}

			static htmlFormat := 0
			if (!htmlFormat) {
				htmlFormat := Clipboard.RegisterFormat.HTML
				if (!htmlFormat) {
					throw OSError("Failed to register HTML clipboard format", -1)
				}
			}

			return this.Content(htmlText, htmlFormat)
		}

		/**
		 * @description Sets CSV content to the clipboard
		 * @param {String} csvText CSV formatted text
		 * @throws {OSError} If clipboard operations fail
		 * @throws {TypeError} If csvText is not a string
		 * @returns {Boolean} True if successful
		 */
		static CSV(csvText) {
			if (!IsString(csvText)) {
				throw TypeError("CSV text must be a string", -1)
			}

			static csvFormat := 0
			if (!csvFormat) {
				csvFormat := Clipboard.RegisterFormat.CSV
				if (!csvFormat) {
					throw OSError("Failed to register CSV clipboard format", -1)
				}
			}

			return this.Content(csvText, csvFormat)
		}
	}
	; ---------------------------------------------------------------------------
	;@endregion class Set
	; ---------------------------------------------------------------------------

	;@region RegisterFormat
	/**
	 * @class Clipboard.RegisterFormat
	 * @description Provides methods to register custom clipboard formats.
	 */
	class RegisterFormat {
		/**
		 * @description Registers the RTF clipboard format.
		 * @returns {Integer} Format identifier.
		 */
		static RTF => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'Rich Text Format', 'UInt')
		/**
		 * @description Registers the HTML clipboard format.
		 * @returns {Integer} Format identifier.
		 */
		static HTML => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'HTML Format', 'UInt')
		/**
		 * @description Registers the CSV clipboard format.
		 * @returns {Integer} Format identifier.
		 */
		static CSV => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'CSV', 'UInt')
		/**
		 * @description Registers the TSV clipboard format.
		 * @returns {Integer} Format identifier.
		 */
		static TSV => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'TSV', 'UInt')
		/**
		 * @description Registers the Unicode Text clipboard format.
		 * @returns {Integer} Format identifier.
		 */
		static UnicodeText => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'UnicodeText', 'UInt')
		/**
		 * @description Registers the OEM Text clipboard format.
		 * @returns {Integer} Format identifier.
		 */
		static OEMText => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'OEMText', 'UInt')
		/**
		 * @description Registers the Bitmap clipboard format.
		 * @returns {Integer} Format identifier.
		 */
		static Bitmap => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'Bitmap', 'UInt')
		/**
		 * @description Registers the FileName clipboard format.
		 * @returns {Integer} Format identifier.
		 */
		static FileName => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'FileName', 'UInt')
		/**
		 * @description Registers a custom clipboard format by name.
		 * @param {String} name Format name.
		 * @returns {Integer} Format identifier.
		 */
		static Custom(name) {
			return DllCall('User32.dll\RegisterClipboardFormat', 'Str', name, 'UInt')
		}
	}
	;@endregion RegisterFormat
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	;@region Logging
	/**
	 * @private
	 * @description Log Clipboard method usage to log file.
	 * @param {String} method Method name
	 * @param {Map|Object} params Parameters used
	 * @param {Any} result Result returned (optional)
	 */
	static _LogUsage(method, params, result := unset) {
		timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
		
		; Create log directory if it doesn't exist
		logDir := A_ScriptDir "\.loggers\.clipboard"
		if !DirExist(logDir) {
			DirCreate(logDir)
		}
		
		; Build log entry as formatted text
		logEntry := "[" timestamp "] " method "`n"
		logEntry .= "  Params: "
		
		; Format params (Map/Object)
		if IsObject(params) {
			for key, value in params {
				logEntry .= key "=" (value ?? "null") ", "
			}
			logEntry := RTrim(logEntry, ", ")
		} else {
			logEntry .= (params ?? "null")
		}
		
		if IsSet(result) {
			logEntry .= "`n  Result: " (result ?? "null")
		}
		logEntry .= "`n" (StrReplace(Format("{:=<80}", ""), " ", "=")) "`n"
		
		; Append to log file
		try {
			FileAppend(logEntry, this._logFile, "UTF-8")
		} catch as err {
			OutputDebug("Failed to write to Clipboard usage log: " err.Message)
		}
	}
	; @endregion Logging
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @method __Delete
	 * @description Clean up resources when object is destroyed.
	 */
	__Delete() {
		; No persistent resources to clean up, but method included for completeness.
	}
}
; ---------------------------------------------------------------------------
;@endregion class Clipboard
; ---------------------------------------------------------------------------

^!h:: ; Ctrl+Alt+H to convert RTF to HTML using Pandoc
{
	try {
		htmlContent := Pandoc.toHTML(A_Clipboard)
		A_Clipboard := htmlContent
		Infos("RTF converted to HTML using Pandoc")
	} catch Error as e {
		Infos("Pandoc RTF to HTML conversion failed: " e.Message)
	}
}

