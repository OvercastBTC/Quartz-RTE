;? this is my lib file, for Quartz-RTE, use the one below
;! for the local lib files, comment out the below and uncomment the ones after
; #Include <Extensions\.structs\Array>
; #Include <Extensions\.ui\Gui>
; #Include <Extensions\.primitives\String>
; #Include <Managers/ThemeMgr>

;? this the local lib files, for Quartz-RTE, use this one
;! for the local lib files, uncomment the ones below
#Include ../.structs/Array.ahk
#Include Gui.ahk
#Include ../../Extensions/.primitives/String.ahk
#Include ../../Managers/ThemeMgr.ahk

; ============================================================================
; @region Class Definition
; ============================================================================
/**
 * @class Infos
 * @description Creates temporary notification windows with extended hotkey support and clipboard integration
 * @version 2.1.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-11-04
 * @requires AutoHotkey v2.0+
 * 
 * @features
 * - Auto-stacking info windows (up to screen height limit)
 * - Extended hotkey support: 60 total combinations
 *   • F1-F12 (indices 1-12)
 *   • Shift+F1-F12 (indices 13-24)
 *   • Ctrl+F1-F12 (indices 25-36)
 *   • Ctrl+Shift+F1-F12 (indices 37-48)
 *   • Alt+Shift+F1-F12 (indices 49-60)
 * - Click to copy text to clipboard and close
 * - Right-click context menu with copy/close options
 * - Auto-close with configurable timeout
 * - Escape to close active window, Ctrl+Escape to close all
 * 
 * @example
 * ; Basic usage - show temporary info
 * info := Infos("Processing complete!")
 * 
 * ; With auto-close after 3 seconds
 * info := Infos("Task finished", 3000)
 * 
 * ; Multiple options - user can select with extended hotkeys
 * options := ["Option 1", "Option 2", "Option 3"]
 * for text in options
 *     Infos(text)
 * 
 * ; Click any window to copy its text to clipboard
 * ; Right-click for menu: Copy, Keep Open, Close This, Close All
 * ; Press Esc to close focused window, Ctrl+Esc to close all
 */
class Infos {
	; ========================================================================
	; @region Constructor
	; ========================================================================
	/**
	 * @constructor
	 * @description Creates a new Info notification window
	 * @param {String} text - The text to display in the info window
	 * @param {Integer} [autoCloseTimeout=0] - Auto-close timeout in milliseconds (0 = no auto-close)
	 * @example
	 * info := Infos("Hello World")
	 * info := Infos("Auto-closing in 2 seconds", 2000)
	 */
	__New(text, autoCloseTimeout := 0) {
		this.autoCloseTimeout := autoCloseTimeout
		this.text := text
		
		; Get available space index first (needed for GUI creation)
		if !this._GetAvailableSpace() {
			; No space available - cannot create Info
			return
		}
		
		; Now create GUI with correct hotkey display
		this._CreateGui()
		this.hwnd := this.gInfo.hwnd
		
		this._SetupHotkeysAndEvents()
		this._SetupAutoclose()
		this._Show()
	}
	; @endregion Constructor
	; ========================================================================
	; @region Properties
	; ========================================================================
	; ========================================================================
	; ========================================================================
	; ========================================================================
	; ========================================================================
	; ========================================================================
	; ========================================================================
	; ========================================================================
	; @region Static Props
	; ========================================================================
	/**
	 * @static {Integer} fontSize - Default font size for Info windows
	 */
	static fontSize     := 11
	
	/**
	 * @static {Integer} distance - Spacing distance between Info windows
	 */
	static distance     := 4
	
	/**
	 * @static {Number} unit - DPI scaling unit
	 */
	static unit         := A_ScreenDPI / 144
	
	/**
	 * @static {Integer} guiWidth - Width of each Info window in pixels
	 */
	static guiWidth     := 30
	
	/**
	 * @static {Integer} maximumInfos - Maximum number of Info windows that can fit on screen
	 */
	static maximumInfos := Floor(A_ScreenHeight / Infos.guiWidth)
	
	/**
	 * @static {Array} spots - Array tracking occupied Info window positions
	 */
	static spots        := Infos._GeneratePlacesArray()
	
	/**
	 * @static {Func} foDestroyAll - Bound function reference for DestroyAll
	 */
	static foDestroyAll := (*) => Infos.DestroyAll()
	
	/**
	 * @static {Integer} maxNumberedHotkeys - Maximum number of hotkey-enabled Info windows
	 * Supports 61 slots: Index 1 (no hotkey), plus 60 F-key combinations (F1-F12, Shift+F1-F12, Ctrl+F1-F12, Ctrl+Shift+F1-F12, Alt+Shift+F1-F12)
	 */
	static maxNumberedHotkeys := 61
	
	/**
	 * @static {Integer} maxWidthInChars - Maximum width in characters before text wraps
	 */
	static maxWidthInChars := A_ScreenWidth
	; @endregion Static Props
	; ========================================================================
	; ========================================================================
	; @region Instance Props
	; ========================================================================
	/**
	 * @property {Integer} autoCloseTimeout - Auto-close timeout in milliseconds (0 = no auto-close)
	 */
	autoCloseTimeout := 0
	
	/**
	 * @property {Func} bfDestroy - Bound function reference for Destroy method
	 */
	bfDestroy := this.Destroy.Bind(this)
	; @endregion Instance Props
	; ========================================================================
	; ========================================================================
	; ========================================================================
	; @region Static Methods
	; ========================================================================
	/**
	 * @static
	 * @method DestroyAll
	 * @description Destroys all active Info windows
	 * @returns {void}
	 * @example
	 * ; Create multiple info windows
	 * Infos("Message 1")
	 * Infos("Message 2")
	 * Infos("Message 3")
	 * 
	 * ; Close all at once
	 * Infos.DestroyAll()
	 * 
	 * ; Or use Ctrl+Esc hotkey while any Info window is active
	 */
	; @region DestroyAll
	static DestroyAll() {
		for index, infoObj in Infos.spots {
			if !infoObj {
				continue
			}
			infoObj.Destroy()
		}
	}
	; @endregion DestroyAll
	/**
	 * @static
	 * @method _GeneratePlacesArray
	 * @description Generates an array to track available Info window positions
	 * @returns {Array} Array of false values representing available slots
	 * @private
	 */
	; @region _Gen Plcs Arr
	static _GeneratePlacesArray() {
		availablePlaces := []
		loop Infos.maximumInfos {
			availablePlaces.Push(false)
		}
		return availablePlaces
	}
	; @endregion _Gen Plcs Arr
	/**
	 * @static
	 * @method _GetHotkeyString
	 * @description Generates the hotkey string for a given index
	 * @param {Integer} index - The space index (1 = no hotkey, 2-61 for various F-key combinations)
	 * @returns {String} The hotkey string (e.g., "F1", "+F5", "^F12", "^+F3", "!+F7")
	 * @private
	 * @example
	 * Infos._GetHotkeyString(1)   ; Returns "" (no hotkey - "Press Esc to Clear")
	 * Infos._GetHotkeyString(2)   ; Returns "F1"
	 * Infos._GetHotkeyString(14)  ; Returns "+F1" (Shift+F1)
	 * Infos._GetHotkeyString(26)  ; Returns "^F1" (Ctrl+F1)
	 * Infos._GetHotkeyString(38)  ; Returns "^+F1" (Ctrl+Shift+F1)
	 * Infos._GetHotkeyString(50)  ; Returns "!+F1" (Alt+Shift+F1)
	 */
	; @region _Get Hotkey Str
	static _GetHotkeyString(index) {
		; Index 1 has no hotkey (reserved for "Press Esc to Clear")
		if index <= 1 || index > 61
			return ""
		
		; Adjust index to start F1 at index 2
		adjustedIndex := index - 1
		
		; F1-F12 (indices 2-13) -> adjusted 1-12
		if adjustedIndex <= 12
			return "F" adjustedIndex
		
		; Shift+F1-F12 (indices 14-25) -> adjusted 13-24
		if adjustedIndex <= 24
			return "+F" (adjustedIndex - 12)
		
		; Ctrl+F1-F12 (indices 26-37) -> adjusted 25-36
		if adjustedIndex <= 36
			return "^F" (adjustedIndex - 24)
		
		; Ctrl+Shift+F1-F12 (indices 38-49) -> adjusted 37-48
		if adjustedIndex <= 48
			return "^+F" (adjustedIndex - 36)
		
		; Alt+Shift+F1-F12 (indices 50-61) -> adjusted 49-60
		if adjustedIndex <= 60
			return "!+F" (adjustedIndex - 48)
		
		return ""
	}
	; @endregion _Get Hotkey Str
	
	/**
	 * @static
	 * @method _GetHotkeyDisplayString
	 * @description Generates a user-friendly display string for the hotkey
	 * @param {Integer} index - The space index
	 * @returns {String} The display string (e.g., "F1", "Shift+F5", "Ctrl+F12", "CtrlShift+F3", "AltShift+F7")
	 * @private
	 * @remarks Uses switch-case to convert AHK hotkey syntax to readable format
	 */
	; @region _Get Hk Display Str
	static _GetHotkeyDisplayString(index) {
		hotkeyStr := Infos._GetHotkeyString(index)
		if !hotkeyStr
			return ""
		
		; Use switch-case for clean, unambiguous conversion
		; Extract the modifier prefix and F-key number
		if RegExMatch(hotkeyStr, "^(\^?\+?!?)F(\d+)$", &match) {
			modifiers := match[1]
			fkey := "F" match[2]
			
			; Convert modifier symbols to readable text
			switch modifiers {
				case "":     return fkey                    ; F1-F12
				case "+":    return "Shift+" fkey           ; Shift+F1-F12
				case "^":    return "Ctrl+" fkey            ; Ctrl+F1-F12
				case "^+":   return "Ctrl+Shift+" fkey       ; Ctrl+Shift+F1-F12
				case "!+":   return "Alt+Shift+" fkey        ; Alt+Shift+F1-F12
				default:     return hotkeyStr               ; Fallback to original
			}
		}
		
		return hotkeyStr  ; Fallback if regex doesn't match
	}
	; @endregion _Get Hk Display Str
	; @endregion Static Methods

	; ========================================================================
	; @region Public Methods
	; ========================================================================


	/**
	 * @method ReplaceText
	 * @description Updates the text in the Info window
	 * @param {String} newText - The new text to display
	 * @returns {Infos} The Info object (new instance if recreated, otherwise current instance)
	 * @remarks 
	 * - If window is destroyed, creates a new Info
	 * - If new text is same length, updates in place (efficient)
	 * - If new text is different length, recreates GUI in same position
	 * @example
	 * info := Infos("Processing...")
	 * Sleep(1000)
	 * info.ReplaceText("Complete!")
	 */
	ReplaceText(newText) {

		try WinExist(this.gInfo)
		catch
			return Infos(newText, this.autoCloseTimeout)

		if StrLen(newText) = StrLen(this.gcText.Text) {
			this.gcText.Text := newText
			this._SetupAutoclose()
			return this
		}

		Infos.spots[this.spaceIndex] := false
		return Infos(newText, this.autoCloseTimeout)
	}

	/**
	 * @method Destroy
	 * @description Destroys the Info window and cleans up hotkeys
	 * @returns {Boolean} True if destroyed successfully, false if already destroyed
	 */
	Destroy(*) {
		try HotIfWinExist("ahk_id " this.gInfo.Hwnd)
		catch Any {
			return false
		}
		Hotkey("Escape", "Off")
		Hotkey("^Escape", "Off")
		
		; Turn off numbered hotkey if applicable
		if this.spaceIndex <= Infos.maxNumberedHotkeys {
			hotkeyStr := Infos._GetHotkeyString(this.spaceIndex)
			if hotkeyStr
				Hotkey(hotkeyStr, "Off")
		}
		
		this.gInfo.Destroy()
		Infos.spots[this.spaceIndex] := false
		return true
	}
	; @endregion Public Methods

	; ========================================================================
	; @region Private Methods - GUI Creation
	; ========================================================================
	/**
	 * @method _CreateGui
	 * @description Creates the GUI window with appropriate text and hotkey display
	 * @private
	 */
	_CreateGui() {
		; Get the theme for Infos from ThemeMgr
		infosTheme := ThemeMgr.GetObjectTheme("Infos")
		
		this.gInfo := Gui("AlwaysOnTop -Caption +ToolWindow")
		
		; Apply object-specific theme with safe color validation
		try {
			ThemeMgr.GuiColors.ApplyTheme(this.gInfo, infosTheme)
			
			; Extract and validate colors to prevent black-on-black issues
			textColor := ""
			bgColor := ""
			
			try {
				textColor := ThemeMgr.GuiColors.GetColor("Text_Color", infosTheme)
				bgColor := ThemeMgr.GuiColors.GetColor("Background_Color", infosTheme)
			} catch {
				; Fallback to safe defaults if extraction fails
				textColor := "D4D4D4"
				bgColor := "1E1E1E"
				OutputDebug("Infos: Color extraction failed, using safe defaults")
			}
			
			; Validate colors are valid and different (prevent same-color issue)
			if (!textColor || !bgColor || StrLen(textColor) < 6 || StrLen(bgColor) < 6 || textColor == bgColor) {
				; Use safe contrasting defaults
				textColor := "D4D4D4"  ; Light gray
				bgColor := "1E1E1E"    ; Dark gray
				OutputDebug("Infos: Invalid or identical colors detected, using safe defaults")
			}
			
			; Reapply validated colors
			this.gInfo.BackColor := bgColor
			this.gInfo.SetFont("c" textColor)
			
		} catch as err {
			; Ultimate fallback: use safe dark theme colors
			this.gInfo.BackColor := "1E1E1E"
			this.gInfo.SetFont("cD4D4D4")
			OutputDebug("Infos: Theme application failed - " err.Message)
		}
		
		result := this.gInfo.MakeFontNicer(Infos.fontSize)
		this.gInfo := result.gui  ; Get the gui back from the result object
		this.gInfo.NeverFocusWindow()
		
		; Determine display text based on position
		displayText := this._FormatText()
		
		; Add "Press Esc to Clear" instruction ONLY for the very first Info (spaceIndex == 1)
		if this.spaceIndex == 1 {
			displayText := 'Press Esc to Clear`n`n' displayText
		}
		; Add hotkey prefix if within numbered hotkey range
		else if this.spaceIndex <= Infos.maxNumberedHotkeys {
			hotkeyDisplay := Infos._GetHotkeyDisplayString(this.spaceIndex)
			if hotkeyDisplay
				displayText := hotkeyDisplay ': ' displayText
		}
		
		this.gcText := this.gInfo.AddText(, displayText)
	}

	/**
	 * @method _FormatText
	 * @description Formats the text for display (wraps long lines, escapes ampersands)
	 * @returns {String} Formatted text
	 * @private
	 */
	_FormatText() {
		text := String(this.text)
		lines := text.Split("`n")
		if lines.Length > 1 {
			text := this._FormatByLine(lines)
		}
		else {
			text := this._LimitWidth(text)
		}
		return text.Replace("&", "&&")
	}

	/**
	 * @method _FormatByLine
	 * @description Formats multi-line text by limiting width of each line
	 * @param {Array} lines - Array of text lines
	 * @returns {String} Formatted multi-line text
	 * @private
	 */
	_FormatByLine(lines) {
		newLines := []
		for index, line in lines {
			newLines.Push(this._LimitWidth(line))
		}
		text := ""
		for index, line in newLines {
			if index = newLines.Length {
				text .= line
				break
			}
			text .= line "`n"
		}
		return text
	}

	/**
	 * @method _LimitWidth
	 * @description Limits text width by inserting line breaks at maximum character count
	 * @param {String} text - Text to limit
	 * @returns {String} Text with line breaks inserted
	 * @private
	 */
	_LimitWidth(text) {
		if StrLen(text) < Infos.maxWidthInChars {
			return text
		}
		insertions := 0
		while (insertions + 1) * Infos.maxWidthInChars + insertions < StrLen(text) {
			insertions++
			text := text.Insert("`n", insertions * Infos.maxWidthInChars + insertions)
		}
		return text
	}
	; @endregion Private Methods - GUI Creation

	; ========================================================================
	; @region Private Methods - Window Management
	; ========================================================================
	/**
	 * @method _GetAvailableSpace
	 * @description Finds an available slot for the Info window
	 * @returns {Boolean} True if space found, false otherwise
	 * @private
	 */
	_GetAvailableSpace() {
		spaceIndex := unset
		for index, isOccupied in Infos.spots {
			if isOccupied
				continue
			spaceIndex := index
			Infos.spots[spaceIndex] := this
			break
		}
		if !IsSet(spaceIndex)
			return false
		this.spaceIndex := spaceIndex
		return true
	}

	/**
	 * @method _CalculateYCoord
	 * @description Calculates the Y coordinate for the Info window based on its index
	 * @returns {Integer} Y coordinate in pixels
	 * @private
	 */
	_CalculateYCoord() => Round(this.spaceIndex * Infos.guiWidth - Infos.guiWidth)

	/**
	 * @method _StopDueToNoSpace
	 * @description Destroys GUI when no space is available (legacy method, no longer used)
	 * @private
	 * @deprecated
	 */
	_StopDueToNoSpace() => this.gInfo.Destroy()
	; @endregion Private Methods - Window Management

	; ========================================================================
	; @region Private Methods - Event Handling
	; ========================================================================

	/**
	 * @method _SetupHotkeysAndEvents
	 * @description Sets up hotkeys and event handlers for the Info window
	 * @remarks Hotkeys include: Esc (close), Ctrl+Esc (close all), F1-F12/Shift+F1-F12/Ctrl+F1-F12/Ctrl+Shift+F1-F12/Alt+Shift+F1-F12 (select)
	 * @remarks Click events: Left-click copies to clipboard and closes, Right-click shows context menu
	 * @private
	 */
	_SetupHotkeysAndEvents() {
		HotIfWinExist("ahk_id " this.gInfo.Hwnd)
		Hotkey("Escape", this.bfDestroy, "On")
		Hotkey("^Escape", Infos.foDestroyAll, "On")
		
		; Set up numbered hotkey if within range
		if this.spaceIndex <= Infos.maxNumberedHotkeys {
			hotkeyStr := Infos._GetHotkeyString(this.spaceIndex)
			if hotkeyStr
				Hotkey(hotkeyStr, this.bfDestroy, "On")
		}
		
		; Click event - copy to clipboard and close
		this.gcText.OnEvent("Click", (*) => this._OnClick())
		
		; Context menu event - show menu options
		this.gcText.OnEvent("ContextMenu", (*) => this._OnContextMenu())
		
		this.gInfo.OnEvent("Close", this.bfDestroy)
	}

	/**
	 * @method _OnClick
	 * @description Handles left-click event - copies text to clipboard and closes window
	 * @private
	 */
	_OnClick() {
		A_Clipboard := this.text
		this.Destroy()
	}

	/**
	 * @method _OnContextMenu
	 * @description Handles right-click event - shows context menu with options
	 * @private
	 */
	_OnContextMenu() {
		contextMenu := Menu()
		contextMenu.Add("Copy to Clipboard", (*) => (A_Clipboard := this.text, this.Destroy()))
		contextMenu.Add("Keep Open (Copy)", (*) => A_Clipboard := this.text)
		contextMenu.Add()
		contextMenu.Add("Close This", (*) => this.Destroy())
		contextMenu.Add("Close All", (*) => Infos.DestroyAll())
		contextMenu.Show()
	}

	/**
	 * @method _SetupAutoclose
	 * @description Sets up auto-close timer if timeout is configured
	 * @private
	 */
	_SetupAutoclose() {
		if this.autoCloseTimeout {
			SetTimer(this.bfDestroy, -this.autoCloseTimeout)
		}
	}

	/**
	 * @method _Show
	 * @description Displays the Info window at the calculated position
	 * @private
	 */
	_Show() => this.gInfo.Show("AutoSize NA x0 y" this._CalculateYCoord())
	; @endregion Private Methods - Event Handling
}
; @endregion Class Definition

; ============================================================================
; @region Helper Functions
; ============================================================================
/**
 * @function Info
 * @description Convenience function to create Info windows (alias for Infos)
 * @param {String} text - The text to display
 * @param {Integer} [timeout=0] - Auto-close timeout in milliseconds
 * @returns {Infos} The created Info object
 * @example
 * Info("Quick message")
 * Info("Auto-closing message", 2000)
 */
Info(text, timeout?) => Infos(text, timeout ?? 0)
; @endregion Helper Functions
