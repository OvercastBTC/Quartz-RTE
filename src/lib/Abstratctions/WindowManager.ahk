#Requires AutoHotkey v2+
#Warn All, OutputDebug

; ---------------------------------------------------------------------------
; @region WindowManager Class
/**
 * @class WindowManager
 * @description Window positioning and management utility for common window layouts
 * Provides methods for positioning windows in predefined grid layouts (halves, thirds, custom splits)
 * @version 2.0.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-10-22
 * @requires AutoHotkey v2+
 * @example
 *   ; Static usage for closing windows
 *   WindowManager.Close("Notepad")
 *   
 *   ; Instance usage for window positioning
 *   wm := WindowManager("A")
 *   wm.LeftSide()
 *   wm.RightSide()
 */
class WindowManager {
	; ---------------------------------------------------------------------------
	; @region Static Properties
	static version := "2.0.0"
	static author := "OvercastBTC (Adam Bacon)"
	; @endregion Static Properties
	
	; ---------------------------------------------------------------------------
	; @region Instance Properties
	winTitle := ""
	excludeTitle := ""
	guiObj := ""  ; Store reference to Gui object if provided
	autoResize := false  ; Enable automatic control resizing
	trackedControls := []  ; Array of controls to auto-resize
	originalDimensions := Map()  ; Store original window dimensions
	
	; Screen dimension properties
	zeroX := -8
	zeroY := 0
	fullWidth := A_ScreenWidth + 14
	fullHeight := A_ScreenHeight + 6
	halfX := this.fullWidth // 2 - 18
	halfWidth := this.fullWidth // 2 + 12
	halfY := this.fullHeight // 2 - 3
	halfHeight := this.fullHeight // 2 + 3
	
	; 70/30 split properties
	seventyX := 1350
	seventyWidth := this.seventyX + 22
	thirtyWidth := this.fullWidth - this.seventyWidth + 14
	
	seventyY := 790
	seventyHeight := this.seventyY + 7
	thirtyHeight := this.fullHeight - this.seventyHeight + 7
	; @endregion Instance Properties
	
	; ---------------------------------------------------------------------------
	; @region Static Methods
	/**
	 * @static
	 * @method Close
	 * @description Close a window gracefully using WM_CLOSE message
	 * @param {String} winTitle Window title or criteria (default: "A" for active window)
	 * @param {String} excludeTitle Optional window exclusion criteria
	 * @throws {Error} When window cannot be found
	 */
	static Close(winTitle := "A", excludeTitle?) {
		try {
			PostMessage(0x112, 0xF060,,, winTitle,, excludeTitle?)
			WinWaitClose(winTitle,, 1, excludeTitle?)
		} catch Error as err {
			throw Error("Failed to close window: " err.Message, -1)
		}
	}
	
	/**
	 * @static
	 * @method CloseOnceInactive
	 * @description Close a window automatically when it becomes inactive
	 * @param {String} winTitle Window title or criteria (default: "A" for active window)
	 * @param {String} excludeTitle Optional window exclusion criteria
	 */
	static CloseOnceInactive(winTitle := "A", excludeTitle?) {
		try {
			id := WinGetID(winTitle)
			WindowManager.Wait(
				() => !WinActive(id,, excludeTitle?),
				() => WindowManager.Close(id, excludeTitle?),
				0, 100
			)
		} catch Error as err {
			throw Error("Failed to setup inactive close: " err.Message, -1)
		}
	}
	
	/**
	 * @static
	 * @method Wait
	 * @description Non-blocking condition checker with timeout support
	 * Polls a condition function and executes an action when condition becomes true
	 * @param {Func} condition Function evaluated periodically, action runs when this returns true
	 * @param {Func} action Function to execute once condition is met
	 * @param {Integer} timeout Time in milliseconds before automatic timeout (0 = no timeout)
	 * @param {Integer} interval Polling interval in milliseconds (default: 1ms)
	 * @example
	 *   WindowManager.Wait(
	 *     () => WinExist("Notepad"),
	 *     () => MsgBox("Notepad appeared!"),
	 *     5000,
	 *     100
	 *   )
	 */
	static Wait(condition, action, timeout := 0, interval := 1) {
		startTime := A_TickCount
		
		Check() {
			try {
				; Check timeout first
				if timeout > 0 && (A_TickCount - startTime >= timeout) {
					SetTimer(Check, 0)
					return
				}
				
				; Check condition
				if !condition.Call() {
					return
				}
				
				; Execute action and cleanup
				action.Call()
				SetTimer(Check, 0)
			} catch Error as err {
				SetTimer(Check, 0)
				throw Error("Wait operation failed: " err.Message, -1)
			}
		}
		
		SetTimer(Check, interval)
	}
	; @endregion Static Methods
	
	; ---------------------------------------------------------------------------
	; @region Constructor
	/**
	 * @constructor
	 * @description Initialize WindowManager for a specific window
	 * Automatically restores window if currently maximized
	 * Optionally enables automatic control resizing when window is repositioned
	 * @param {String|Gui} winTitle Window title, criteria, or Gui object (default: "A" for active window)
	 * @param {String|Boolean} excludeTitle Window exclusion criteria, or true to enable auto-resize
	 * @param {Boolean} autoResize Enable automatic control resizing (default: false)
	 * @throws {Error} When window cannot be found
	 * @example
	 *   ; Basic usage with window title
	 *   wm := WindowManager("Notepad")
	 *   
	 *   ; With Gui object and auto-resize enabled
	 *   wm := WindowManager(myGui, true)
	 *   wm.ThirtyVert()  ; Automatically resizes all controls
	 *   
	 *   ; With exclude title and auto-resize
	 *   wm := WindowManager("ahk_exe Code.exe", "", true)
	 */
	__New(winTitle := "A", excludeTitle := "", autoResize := false) {
		try {
			; Check if winTitle is a Gui object
			if Type(winTitle) = "Gui" {
				this.guiObj := winTitle
				this.winTitle := winTitle.Hwnd
				
				; If excludeTitle is a boolean, it's the autoResize parameter
				if Type(excludeTitle) = "Integer" {
					this.autoResize := excludeTitle
					this.excludeTitle := ""
				} else {
					this.excludeTitle := excludeTitle
					this.autoResize := autoResize
				}
				
				; Capture original dimensions and controls if auto-resize enabled
				if this.autoResize {
					this._CaptureControlPositions()
				}
			} else {
				this.winTitle := winTitle
				this.excludeTitle := excludeTitle
				this.autoResize := autoResize
			}
			
			; Restore if maximized
			if WinGetMinMax(this.winTitle,, this.excludeTitle) = 1 {
				WinRestore(this.winTitle,, this.excludeTitle)
			}
			
		} catch Error as err {
			throw Error("Failed to initialize WindowManager: " err.Message, -1)
		}
	}
	; @endregion Constructor
	
	; ---------------------------------------------------------------------------
	; @region Auto-Resize Helper Methods
	/**
	 * @method _CaptureControlPositions
	 * @description Capture current positions and sizes of all controls relative to window
	 * @private
	 */
	_CaptureControlPositions() {
		try {
			if !this.guiObj {
				return
			}
			
			; Get original window dimensions
			this.guiObj.GetPos(&winX, &winY, &winWidth, &winHeight)
			this.originalDimensions := {
				width: winWidth,
				height: winHeight
			}
			
			; Capture all controls and their relative positions
			this.trackedControls := []
			
			; Iterate through all controls in the Gui
			for ctrlHwnd, ctrlObj in this.guiObj {
				try {
					ctrlObj.GetPos(&x, &y, &w, &h)
					
					; Calculate relative positions and sizes as percentages
					this.trackedControls.Push({
						control: ctrlObj,
						relX: x / winWidth,           ; X as percentage of window width
						relY: y / winHeight,          ; Y as percentage of window height
						relW: w / winWidth,           ; Width as percentage of window width
						relH: h / winHeight,          ; Height as percentage of window height
						absX: x,                      ; Absolute X position
						absY: y,                      ; Absolute Y position
						absW: w,                      ; Absolute width
						absH: h                       ; Absolute height
					})
				} catch {
					; Skip controls that can't be positioned (some control types)
					continue
				}
			}
		} catch Error as err {
			; Silent failure for position capture
		}
	}
	
	/**
	 * @method _ResizeTrackedControls
	 * @description Automatically resize and reposition tracked controls based on new window size
	 * @private
	 */
	_ResizeTrackedControls() {
		try {
			if !this.guiObj || this.trackedControls.Length = 0 {
				return
			}
			
			; Get new window dimensions
			this.guiObj.GetPos(&newWinX, &newWinY, &newWinWidth, &newWinHeight)
			
			; Calculate scale factors
			scaleX := newWinWidth / this.originalDimensions.width
			scaleY := newWinHeight / this.originalDimensions.height
			
			; Resize each tracked control
			for controlInfo in this.trackedControls {
				try {
					; Calculate new positions and sizes
					newX := controlInfo.relX * newWinWidth
					newY := controlInfo.relY * newWinHeight
					newW := controlInfo.relW * newWinWidth
					newH := controlInfo.relH * newWinHeight
					
					; Apply new dimensions
					controlInfo.control.Move(newX, newY, newW, newH)
				} catch {
					; Skip controls that can't be resized
					continue
				}
			}
		} catch Error as err {
			; Silent failure for auto-resize
		}
	}
	
	/**
	 * @method EnableAutoResize
	 * @description Enable automatic control resizing for future positioning operations
	 * @returns {WindowManager} This instance for method chaining
	 */
	EnableAutoResize() {
		this.autoResize := true
		if this.guiObj && this.trackedControls.Length = 0 {
			this._CaptureControlPositions()
		}
		return this
	}
	
	/**
	 * @method DisableAutoResize
	 * @description Disable automatic control resizing
	 * @returns {WindowManager} This instance for method chaining
	 */
	DisableAutoResize() {
		this.autoResize := false
		return this
	}
	; @endregion Auto-Resize Helper Methods
	
	; ---------------------------------------------------------------------------
	; @region Window Positioning Methods - Half Screen
	/**
	 * @method LeftSide
	 * @description Position window on left half of screen
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	LeftSide() {
		WinMove(
			this.zeroX,
			this.zeroY,
			this.halfWidth,
			this.fullHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method RightSide
	 * @description Position window on right half of screen
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	RightSide() {
		WinMove(
			this.halfX,
			this.zeroY,
			this.halfWidth,
			this.fullHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method TopSide
	 * @description Position window on top half of screen (full width)
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	TopSide() {
		WinMove(
			this.zeroX,
			this.zeroY,
			this.fullWidth,
			this.halfHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method TopRight
	 * @description Position window in top-right quadrant
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	TopRight() {
		WinMove(
			this.halfX,
			this.zeroY,
			this.halfWidth,
			this.halfHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method BottomSide
	 * @description Position window on bottom half of screen (full width)
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	BottomSide() {
		WinMove(
			this.zeroX,
			this.halfY,
			this.fullWidth,
			this.halfHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	; @endregion Window Positioning Methods - Half Screen
	
	; ---------------------------------------------------------------------------
	; @region Window Positioning Methods - 70/30 Split Vertical
	/**
	 * @method ThirtyVert
	 * @description Position window in right 30% vertical section (full height)
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	ThirtyVert() {
		WinMove(
			this.seventyX,
			this.zeroY,
			this.thirtyWidth,
			this.fullHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method UpThirtyVert
	 * @description Position window in top-right 30% vertical section
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	UpThirtyVert() {
		WinMove(
			this.seventyX,
			this.zeroY,
			this.thirtyWidth,
			this.halfHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method DownThirtyVert
	 * @description Position window in bottom-right 30% vertical section
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	DownThirtyVert() {
		WinMove(
			this.seventyX,
			this.halfY,
			this.thirtyWidth,
			this.halfHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method SeventyVert
	 * @description Position window in left 70% vertical section (full height)
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	SeventyVert() {
		WinMove(
			this.zeroX,
			this.zeroY,
			this.seventyWidth,
			this.fullHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method UpSeventyVert
	 * @description Position window in top-left 70% vertical section
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	UpSeventyVert() {
		WinMove(
			this.zeroX,
			this.zeroY,
			this.seventyWidth,
			this.halfHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method DownSeventyVert
	 * @description Position window in bottom-left 70% vertical section
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	DownSeventyVert() {
		WinMove(
			this.zeroX,
			this.halfY,
			this.seventyWidth,
			this.halfHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	; @endregion Window Positioning Methods - 70/30 Split Vertical
	
	; ---------------------------------------------------------------------------
	; @region Window Positioning Methods - 70/30 Split Horizontal
	/**
	 * @method SeventyVertSeventyHor
	 * @description Position window in top-left 70% vertical x 70% horizontal section
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	SeventyVertSeventyHor() {
		WinMove(
			this.zeroX,
			this.zeroY,
			this.seventyWidth,
			this.seventyHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method SeventyVertThirtyHor
	 * @description Position window in bottom-left 70% vertical x 30% horizontal section
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	SeventyVertThirtyHor() {
		WinMove(
			this.zeroX,
			this.seventyY,
			this.seventyWidth,
			this.thirtyHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method SeventyHor
	 * @description Position window on top 70% horizontal section (full width)
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	SeventyHor() {
		WinMove(
			this.zeroX,
			this.zeroY,
			this.fullWidth,
			this.seventyHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	
	/**
	 * @method ThirtyHor
	 * @description Position window on bottom 30% horizontal section (full width)
	 * Automatically resizes controls if auto-resize is enabled
	 * @returns {WindowManager} This instance for method chaining
	 */
	ThirtyHor() {
		WinMove(
			this.zeroX,
			this.seventyY,
			this.fullWidth,
			this.thirtyHeight,
			this.winTitle,,
			this.excludeTitle
		)
		
		; Auto-resize controls if enabled
		if this.autoResize {
			this._ResizeTrackedControls()
		}
		
		return this
	}
	; @endregion Window Positioning Methods - 70/30 Split Horizontal
	
	; ---------------------------------------------------------------------------
	; @region Control Resizing Methods
	/**
	 * @method ApplyLayout
	 * @description Apply a window positioning layout by name, then optionally resize controls
	 * @param {String} layoutName Name of positioning method (e.g., "ThirtyVert", "LeftSide", "SeventyHor")
	 * @param {GuiControl|Array} controls Optional control(s) to resize after positioning
	 * @param {Object} resizeOptions Optional resize settings {marginX, marginY, bottomReserve}
	 * @returns {WindowManager} This instance for method chaining
	 * @example
	 *   wm.ApplyLayout("ThirtyVert", helpEdit, {marginX: 10, marginY: 10, bottomReserve: 60})
	 *   wm.ApplyLayout("LeftSide", [edit1, edit2], {marginX: 20, marginY: 20})
	 */
	ApplyLayout(layoutName, controls?, resizeOptions?) {
		try {
			; Apply the window positioning method by name
			if !this.HasMethod(layoutName) {
				throw Error("Unknown layout method: " layoutName, -1)
			}
			
			; Call the layout method
			this.%layoutName%()
			
			; If controls provided, resize them
			if IsSet(controls) {
				defaultOptions := {marginX: 20, marginY: 20, bottomReserve: 0}
				
				; Merge user options with defaults
				if IsSet(resizeOptions) {
					for prop, value in resizeOptions.OwnProps() {
						defaultOptions.%prop% := value
					}
				}
				
				; Handle single control or array of controls
				if Type(controls) = "Array" {
					for ctrl in controls {
						this.ResizeControl(ctrl, defaultOptions.marginX, defaultOptions.marginY, defaultOptions.bottomReserve)
					}
				} else {
					this.ResizeControl(controls, defaultOptions.marginX, defaultOptions.marginY, defaultOptions.bottomReserve)
				}
			}
			
			return this
		} catch Error as err {
			throw Error("Failed to apply layout: " err.Message, -1)
		}
	}
	
	/**
	 * @method ResizeControl
	 * @description Resize a control within the managed window to match window dimensions
	 * @param {GuiControl} control The control to resize
	 * @param {Integer|String} marginX Horizontal margin from window edges, or layout name (default: 20)
	 * @param {Integer} marginY Vertical margin from window edges (default: 20)
	 * @param {Integer} bottomReserve Space to reserve at bottom (e.g., for buttons) (default: 0)
	 * @returns {WindowManager} This instance for method chaining
	 * @example
	 *   ; Standard usage
	 *   wm.ThirtyVert().ResizeControl(helpEdit, 10, 10, 50)
	 *   
	 *   ; Integrated layout application
	 *   wm.ResizeControl(helpEdit, "ThirtyVert", 10, 50)
	 */
	ResizeControl(control, marginX := 20, marginY := 20, bottomReserve := 0) {
		try {
			; Check if marginX is actually a layout method name
			if (Type(marginX) = "String" && this.HasMethod(marginX)) {
				; Apply layout first, then resize with remaining params
				this.%marginX%()
				actualMarginX := (Type(marginY) = "Integer") ? marginY : 20
				actualMarginY := (Type(bottomReserve) = "Integer") ? bottomReserve : 20
				actualBottomReserve := 0
			} else {
				actualMarginX := marginX
				actualMarginY := marginY
				actualBottomReserve := bottomReserve
			}
			
			; Get current window dimensions
			WinGetPos(&winX, &winY, &winWidth, &winHeight, this.winTitle,, this.excludeTitle)
			
			; Calculate new control dimensions
			newWidth := winWidth - (actualMarginX * 2)
			newHeight := winHeight - (actualMarginY * 2) - actualBottomReserve
			
			; Resize the control
			control.Move(actualMarginX, actualMarginY, newWidth, newHeight)
			
			return this
		} catch Error as err {
			throw Error("Failed to resize control: " err.Message, -1)
		}
	}
	
	/**
	 * @method ResizeControls
	 * @description Resize multiple controls within the managed window
	 * @param {Array} controlConfigs Array of control configuration objects
	 * Each config object should have: {control, marginX, marginY, bottomReserve}
	 * @returns {WindowManager} This instance for method chaining
	 * @example
	 *   wm.ResizeControls([
	 *     {control: helpEdit, marginX: 10, marginY: 10, bottomReserve: 50},
	 *     {control: closeBtn, marginX: 0, marginY: 0, bottomReserve: 0}
	 *   ])
	 */
	ResizeControls(controlConfigs) {
		try {
			for config in controlConfigs {
				this.ResizeControl(
					config.control,
					config.HasOwnProp("marginX") ? config.marginX : 20,
					config.HasOwnProp("marginY") ? config.marginY : 20,
					config.HasOwnProp("bottomReserve") ? config.bottomReserve : 0
				)
			}
			return this
		} catch Error as err {
			throw Error("Failed to resize controls: " err.Message, -1)
		}
	}
	
	/**
	 * @method RepositionControl
	 * @description Reposition a control within the window (e.g., center a button at bottom)
	 * @param {GuiControl} control The control to reposition
	 * @param {String|Integer} x X position or "center" to center horizontally
	 * @param {String|Integer} y Y position or "bottom" to position at bottom
	 * @param {Integer} offsetX Horizontal offset from calculated position (default: 0)
	 * @param {Integer} offsetY Vertical offset from calculated position (default: -45)
	 * @returns {WindowManager} This instance for method chaining
	 * @example
	 *   wm.RepositionControl(closeBtn, "center", "bottom", 0, -45)
	 */
	RepositionControl(control, x := "center", y := "bottom", offsetX := 0, offsetY := -45) {
		try {
			; Get window and control dimensions
			WinGetPos(&winX, &winY, &winWidth, &winHeight, this.winTitle,, this.excludeTitle)
			control.GetPos(&ctrlX, &ctrlY, &ctrlWidth, &ctrlHeight)
			
			; Calculate X position
			if (x = "center") {
				newX := (winWidth - ctrlWidth) // 2 + offsetX
			} else {
				newX := x + offsetX
			}
			
			; Calculate Y position
			if (y = "bottom") {
				newY := winHeight + offsetY
			} else {
				newY := y + offsetY
			}
			
			; Reposition the control
			control.Move(newX, newY)
			
			return this
		} catch Error as err {
			throw Error("Failed to reposition control: " err.Message, -1)
		}
	}
	; @endregion Control Resizing Methods
}
; @endregion WindowManager Class
