/**
 * @file Gui.ahk
 * @description Library for GUI enhancements in AutoHotkey v2.0+
 * @requires AutoHotkey v2.0+
 * @author OvercastBTC
 * @license MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * @version 1.0.0
 *
 * @description:
 * This file serves as the central include point for all Tools library modules.
 * It provides access to various utility functions and classes through sub-modules.
 *
 * @module Gui2
 */
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; #Module Gui2
; #Include ErrorLog.ahk
#Include <Extensions/.structs/Any>
#Include <Extensions/.formats/JSONS>
#Include <Extensions/.ui/GuiResizer>
#Include <System/RichEdit>
#Include <Utilities/TestLogger>
; TestLogger.Enable()
; @region class Gui2
Gui.Prototype.Base := Gui2
class Gui2 {

	#Requires AutoHotkey v2+

	static WS_EX_NOACTIVATE 	=> '0x08000000L'	; Prevents window from being activated
	static WS_EX_TRANSPARENT 	=> '0x00000020L'	; Makes window transparent
	static WS_EX_COMPOSITED 	=> '0x02000000L'	; Enables double buffering
	static WS_EX_CLIENTEDGE 	=> '0x00000200L'	; Adds a 3D border
	static WS_EX_APPWINDOW 		=> '0x00040000L'	; Forces window to be an app window
	static WS_EX_LAYERED      	=> '0x00080000L'	; Layered window for transparency
	static WS_EX_TOOLWINDOW   	=> '0x00000080L'	; Creates a tool window (no taskbar button)
	static WS_EX_TOPMOST      	=> '0x00000008L'	; Always on top
	static WS_EX_ACCEPTFILES  	=> '0x00000010L'	; Accepts drag-drop files
	static WS_EX_CONTEXTHELP  	=> '0x00000400L'	; Has '?' button in titlebar

	static __New() {
		; Add all Gui2 methods to Gui prototype
		for methodName in Gui2.OwnProps() {
			if methodName != "__New" && HasMethod(Gui2, methodName) {
				; Check if method already exists
				if Gui.Prototype.HasOwnProp(methodName) {
					; Either skip, warn, or override based on your needs
					continue  ; Skip if method exists
					; Or override:
					; Gui.Prototype.DeleteProp(methodName)
				}
				Gui.Prototype.DefineProp(methodName, {
					Call: Gui2.%methodName%
				})
			}
		}
	}

	; @region Layered
	static Layered() {
		this.MakeLayered()
		return this
	}

	; @region ToolWindow
	static ToolWindow() {
		this.MakeToolWindow()
		return this
	}

	; @region AlwaysOnTop
	static AlwaysOnTop() {
		this.SetAlwaysOnTop()
		return this
	}

	; @region AppWindow
	static AppWindow() {
		this.ForceTaskbarButton()
		return this
	}

	; @region Transparent
	static Transparent() {
		this.MakeClickThrough()
		return this
	}

	; @region NoActivate
	static NoActivate() {
		this.PreventActivation()
		return this
	}

	; @region NeverFocusWindow
	static NeverFocusWindow() {
		this.NoActivate()
		return this
	}

	;@region DarkMode
	/**
	 * @method DarkMode
	 * @description Applies dark mode styling using ThemeMgr
	 * @version 2.0.0
	 * @author OvercastBTC (Adam Bacon)
	 * @date 2025-11-05
	 * @requires AutoHotkey v2.0+
	 * @param {Gui} [guiObj] GUI object to apply theme to (defaults to this)
	 * @returns {Gui} The styled Gui object for method chaining
	 * @throws {TypeError} If no valid Gui object is found
	 * @example
	 * gui := Gui()
	 * gui.DarkMode()  ; Apply dark theme from ThemeMgr
	 */
	static DarkMode(guiObj?) {
		if !IsSet(guiObj)
			guiObj := this

		if IsNotGui(guiObj) {
			throw TypeError("DarkMode: No valid Gui object provided. guiObj is: " Type(guiObj), -1)
		}

		; Use ThemeMgr to apply DarkMode theme
		try {
			ThemeMgr.GuiColors.ApplyTheme(guiObj, "DarkMode")
		} catch as err {
			; Fallback to basic dark theme if ThemeMgr fails
			guiObj.BackColor := "1E1E1E"
			guiObj.SetFont("cD4D4D4")
		}

		return guiObj
	}
	;@endregion DarkMode
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	;@region LightMode
	/**
	 * @method LightMode
	 * @description Applies light mode styling using ThemeMgr
	 * @version 1.0.0
	 * @author OvercastBTC (Adam Bacon)
	 * @date 2025-11-05
	 * @requires AutoHotkey v2.0+
	 * @param {Gui} [guiObj] GUI object to apply theme to (defaults to this)
	 * @returns {Gui} The styled Gui object for method chaining
	 * @throws {TypeError} If no valid Gui object is found
	 * @example
	 * gui := Gui()
	 * gui.LightMode()  ; Apply light theme from ThemeMgr
	 */
	static LightMode(guiObj?) {
		if !IsSet(guiObj)
			guiObj := this

		if IsNotGui(guiObj) {
			throw TypeError("LightMode: No valid Gui object provided. guiObj is: " Type(guiObj), -1)
		}

		; Use ThemeMgr to apply LightMode theme
		try {
			; ThemeMgr.GuiColors.ApplyTheme(guiObj, "LightMode")
			ThemeMgr.GuiColors.ApplyLightMode(guiObj)
		} catch as err {
			; Fallback to basic light theme if ThemeMgr fails
			guiObj.BackColor := "F3F2F1"
			guiObj.SetFont("c252423")
		}

		return guiObj
	}
	;@endregion LightMode
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	;@region VSCodeMode
	/**
	 * @method VSCodeMode
	 * @description Applies Visual Studio Code theme colors
	 * @version 1.0.0
	 * @author OvercastBTC (Adam Bacon)
	 * @date 2025-11-05
	 * @requires AutoHotkey v2.0+
	 * @param {Gui} [guiObj] GUI object to apply theme to (defaults to this)
	 * @returns {Gui} The styled Gui object for method chaining
	 * @throws {TypeError} If no valid Gui object is found
	 * @example
	 * gui := Gui()
	 * gui.VSCodeMode()  ; Apply VS Code theme colors
	 */
	static VSCodeMode(guiObj?) {
		if !IsSet(guiObj)
			guiObj := this

		if IsNotGui(guiObj) {
			throw TypeError("VSCodeMode: No valid Gui object provided. guiObj is: " Type(guiObj), -1)
		}

		; Use ThemeMgr VSCode colors
		try {
			vscodeTheme := ThemeMgr.GuiColors.VSCode
			guiObj.BackColor := vscodeTheme.Background
			guiObj.SetFont("c" vscodeTheme.TextNormal)
		} catch as err {
			; Fallback to DarkMode if VSCode theme fails
			ThemeMgr.GuiColors.ApplyTheme(guiObj, "DarkMode")
		}

		return guiObj
	}
	;@endregion VSCodeMode
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	;@region GitHubMode
	/**
	 * @method GitHubMode
	 * @description Applies GitHub theme colors
	 * @version 1.0.0
	 * @author OvercastBTC (Adam Bacon)
	 * @date 2025-11-05
	 * @requires AutoHotkey v2.0+
	 * @param {Gui} [guiObj] GUI object to apply theme to (defaults to this)
	 * @returns {Gui} The styled Gui object for method chaining
	 * @throws {TypeError} If no valid Gui object is found
	 * @example
	 * gui := Gui()
	 * gui.GitHubMode()  ; Apply GitHub theme colors
	 */
	static GitHubMode(guiObj?) {
		if !IsSet(guiObj)
			guiObj := this

		if IsNotGui(guiObj) {
			throw TypeError("GitHubMode: No valid Gui object provided. guiObj is: " Type(guiObj), -1)
		}

		; Use ThemeMgr GitHub colors
		try {
			githubTheme := ThemeMgr.GuiColors.GitHub
			guiObj.BackColor := githubTheme.Primary
			; Calculate appropriate text color for GitHub primary background
			textColor := ThemeMgr.GuiColors.GetTextColor("#" githubTheme.Primary)
			guiObj.SetFont("c" StrReplace(textColor, "#", ""))
		} catch as err {
			; Fallback to DarkMode if GitHub theme fails
			ThemeMgr.GuiColors.ApplyTheme(guiObj, "DarkMode")
		}

		return guiObj
	}
	;@endregion GitHubMode
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	;@region TerminalMode
	/**
	 * @method TerminalMode
	 * @description Applies Terminal theme colors
	 * @version 1.0.0
	 * @author OvercastBTC (Adam Bacon)
	 * @date 2025-11-05
	 * @requires AutoHotkey v2.0+
	 * @param {Gui} [guiObj] GUI object to apply theme to (defaults to this)
	 * @returns {Gui} The styled Gui object for method chaining
	 * @throws {TypeError} If no valid Gui object is found
	 * @example
	 * gui := Gui()
	 * gui.TerminalMode()  ; Apply Terminal theme colors
	 */
	static TerminalMode(guiObj?) {
		if !IsSet(guiObj)
			guiObj := this

		if IsNotGui(guiObj) {
			throw TypeError("TerminalMode: No valid Gui object provided. guiObj is: " Type(guiObj), -1)
		}

		; Use ThemeMgr Terminal colors
		try {
			termTheme := ThemeMgr.GuiColors.Terminal
			guiObj.BackColor := termTheme.Background
			guiObj.SetFont("c" termTheme.Foreground)
		} catch as err {
			; Fallback to DarkMode if Terminal theme fails
			ThemeMgr.GuiColors.ApplyTheme(guiObj, "DarkMode")
		}

		return guiObj
	}
	;@endregion TerminalMode
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	;@region HighContrastMode
	/**
	 * @method HighContrastMode
	 * @description Applies high contrast theme for accessibility
	 * @version 1.0.0
	 * @author OvercastBTC (Adam Bacon)
	 * @date 2025-11-05
	 * @requires AutoHotkey v2.0+
	 * @param {Gui} [guiObj] GUI object to apply theme to (defaults to this)
	 * @returns {Gui} The styled Gui object for method chaining
	 * @throws {TypeError} If no valid Gui object is found
	 * @example
	 * gui := Gui()
	 * gui.HighContrastMode()  ; Apply high contrast theme
	 */
	static HighContrastMode(guiObj?) {
		if !IsSet(guiObj)
			guiObj := this

		if IsNotGui(guiObj) {
			throw TypeError("HighContrastMode: No valid Gui object provided. guiObj is: " Type(guiObj), -1)
		}

		; Use ThemeMgr to apply HighContrast theme
		try {
			ThemeMgr.GuiColors.ApplyTheme(guiObj, "HighContrast")
		} catch as err {
			; Fallback to basic high contrast theme if ThemeMgr fails
			guiObj.BackColor := "000000"
			guiObj.SetFont("cFFFFFF")
		}

		return guiObj
	}
	;@endregion HighContrastMode
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region MakeFontNicer
	/**
	 * @method MakeFontNicer
	 * @description Improves font settings with comprehensive parameter parsing and reasonable defaults
	 * @version 2.0.0
	 * @author OvercastBTC (Adam Bacon)
	 * @date 2025-11-04
	 * @requires AutoHotkey v2.0+
	 * @param {...(Gui|String|Number|Object)} params* Variable parameters supporting:
	 *        - Gui object (if not using as instance method)
	 *        - Font size: "s12", "12", or numeric 12
	 *        - Font weight: "w700", "w400", "bold", "norm"
	 *        - Font quality: "q5", "q4" (0-5 scale)
	 *        - Font styles: "italic", "underline", "strike" (can combine: "bold italic")
	 *        - Space-separated options: "s12 bold italic q5"
	 *        - Font name: "Consolas", "Arial", etc.
	 *        - Config object with properties: {size, weight, quality, styles, fontName}
	 * @returns {Object} Configuration object with properties:
	 *          - gui: The Gui object (for method chaining: result.gui)
	 *          - size: Font size applied
	 *          - weight: Font weight (if specified)
	 *          - quality: Quality setting
	 *          - styles: Array of style names applied
	 *          - fontName: Font family name
	 * @throws {TypeError} If invalid Gui object provided
	 * @example
	 * ; Using defaults (s25 q5 Consolas)
	 * result := gui.MakeFontNicer()
	 *
	 * ; Setting size and styles
	 * result := gui.MakeFontNicer("14 bold italic")
	 *
	 * ; Full specification with space-separated options
	 * result := gui.MakeFontNicer("s16 q4 bold underline")
	 *
	 * ; Multiple styles with weight
	 * result := gui.MakeFontNicer("s12 w700 italic strike q5", "Arial")
	 *
	 * ; Using config object
	 * result := gui.MakeFontNicer({size: 14, styles: ["bold", "italic"], fontName: "Segoe UI"})
	 *
	 * ; Chain with returned gui property
	 * gui.MakeFontNicer("s12 bold").gui.Show()
	 */
	static MakeFontNicer(params*) {
		; Initialize config with defaults
		config := {
			size: 25,
			quality: 'q5',
			weight: '',
			styles: [],
			fontName: 'Consolas',
			guiObj: this
		}

		; Parse parameters
		for param in params {
			; Handle Gui object parameter
			if param is Gui {
				config.guiObj := param
				continue
			}

			; Handle config object with properties
			if IsObject(param) && !IsString(param) {
				if param.HasProp("size")
					config.size := param.size
				if param.HasProp("quality")
					config.quality := param.quality
				if param.HasProp("weight")
					config.weight := param.weight
				if param.HasProp("styles")
					config.styles := IsObject(param.styles) ? param.styles : [param.styles]
				if param.HasProp("fontName")
					config.fontName := param.fontName
				continue
			}

			; Handle numeric font size parameter
			if param is Number {
				config.size := param
				continue
			}

			; Handle string parameters
			if IsString(param) {
				; Check if it's a space-separated options string
				if InStr(param, " ") {
					; Parse each option in the string
					for opt in StrSplit(param, " ") {
						if !opt  ; Skip empty strings
							continue
						
						; Font size with 's' prefix
						if opt ~= 'i)^s\d+$' {
							config.size := SubStr(opt, 2)
						}
						; Font weight with 'w' prefix
						else if opt ~= 'i)^w\d+$' {
							config.weight := opt
						}
						; Quality setting
						else if opt ~= 'i)^q[0-5]$' {
							config.quality := opt
						}
						; Font styles
						else if opt ~= 'i)^(bold|italic|strike|underline|norm)$' {
							; Convert 'bold' to weight if not already set
							if opt = "bold" && !config.weight
								config.weight := "w700"
							else if opt = "norm" && !config.weight
								config.weight := "w400"
							else if !InStr(opt, "bold") && !InStr(opt, "norm")
								config.styles.Push(opt)
						}
						; Font name (remaining unmatched string)
						else if opt ~= '^[a-zA-Z][\w\s-]*$' {
							config.fontName := opt
						}
					}
					continue
				}

				; Single parameter parsing (no spaces)
				
				; Font size with 's' prefix
				if param ~= 'i)^s\d+$' {
					config.size := SubStr(param, 2)
					continue
				}

				; Font size without prefix (just digits)
				if param ~= '^\d+$' {
					config.size := param
					continue
				}

				; Font weight
				if param ~= 'i)^w\d+$' {
					config.weight := param
					continue
				}

				; Quality setting
				if param ~= 'i)^q[0-5]$' {
					config.quality := param
					continue
				}

				; Font styles
				if param ~= 'i)^(bold|italic|strike|underline|norm)$' {
					if param = "bold"
						config.weight := "w700"
					else if param = "norm"
						config.weight := "w400"
					else
						config.styles.Push(param)
					continue
				}

				; Font name (letters, spaces, hyphens)
				if param ~= '^[a-zA-Z][\w\s-]+$' {
					config.fontName := param
					continue
				}
			}
		}

		; Build font options string
		fontOpts := 's' config.size ' ' config.quality
		if config.weight
			fontOpts .= ' ' config.weight
		if config.styles.Length > 0
			fontOpts .= ' ' config.styles.Join(' ')

		; Apply font settings
		try {
			config.guiObj.SetFont(fontOpts, config.fontName)
		} catch Error as e {
			; Log error and rethrow for visibility
			if HasMethod(testlogger, "Log")
				testlogger.Log("MakeFontNicer failed: " e.Message)
			throw Error("Failed to apply font settings: " e.Message, -1)
		}

		; Return enhanced config object for inspection and chaining
		return {
			gui: config.guiObj,
			size: config.size,
			quality: config.quality,
			weight: config.weight,
			styles: config.styles,
			fontName: config.fontName
		}
	}
	; @endregion MakeFontNicer
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region Window Styles
	/**
	 * @description Prevents window from receiving focus or being activated
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.NoActivate()
	*/

	static PreventActivation() {
		WinSetExStyle('+' this.WS_EX_NOACTIVATE, this)
		return this
	}

	/**
	 * @description Makes window click-through (input passes to windows beneath)
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.MakeClickThrough()
	 */

	static MakeClickThrough() {
		WinSetExStyle('+' this.WS_EX_TRANSPARENT, this)
		return this
	}

	; @region EnableComposited()
	/**
	 * @description Enables double-buffered composited window rendering
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.EnableComposited()
	 */
	static EnableComposited() {
		WinSetExStyle('+' this.WS_EX_COMPOSITED, this)
		return this
	}

	; @region AddClientEdge()
	/**
	 * @description Adds 3D sunken edge border to window
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.AddClientEdge()
	 */
	static AddClientEdge() {
		WinSetExStyle('+' this.WS_EX_CLIENTEDGE, this)
		return this
	}

	; @region ForceTaskbarButton()
	/**
	 * @description Forces window to have a taskbar button
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.ForceTaskbarButton()
	 */
	static ForceTaskbarButton() {
		WinSetExStyle('+' this.WS_EX_APPWINDOW, this)
		return this
	}

	; @region MakeLayered()
	/**
	 * @description Makes window layered for transparency effects
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.MakeLayered()
	 */
	static MakeLayered() {
		WinSetExStyle('+' this.WS_EX_LAYERED, this)
		return this
	}

	; @region MakeToolWindow()
	/**
	 * @description Creates a tool window with no taskbar button
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.MakeToolWindow()
	 */
	static MakeToolWindow() {
		WinSetExStyle('+' this.WS_EX_TOOLWINDOW, this)
		return this
	}

	; @region SetAlwaysOnTop()
	/**
	 * @description Sets window to always stay on top
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.SetAlwaysOnTop()
	 */
	static SetAlwaysOnTop() {
		WinSetExStyle('+' this.WS_EX_TOPMOST, this)
		return this
	}

	; @region EnableDragDrop()
	/**
	 * @description Enables drag and drop file acceptance
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.EnableDragDrop()
	 */
	static EnableDragDrop() {
		WinSetExStyle('+' this.WS_EX_ACCEPTFILES, this)
		return this
	}

	; @region AddHelpButton()
	/**
	 * @description Adds help button (?) to titlebar
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.AddHelpButton()
	 */
	static AddHelpButton() {
		WinSetExStyle('+' this.WS_EX_CONTEXTHELP, this)
		return this
	}

	; @region SetTransparency(level)
	/**
	 * @description Sets window transparency level
	 * @param {Integer} level Transparency level (0-255, where 0 is invisible and 255 is opaque)
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.SetTransparency(180)  ; Set to 70% opacity
	 */
	static SetTransparency(level := 255) {
		if (level < 0 || level > 255)
			throw ValueError("Transparency level must be between 0 and 255")

		this.MakeLayered()  ; Window must be layered for transparency
		WinSetTransparent(level, this)
		return this
	}

	; static SetButtonWidth(input, bMargin := 1.5) {
	; 	return GuiButtonProperties.SetButtonWidth(input, bMargin)
	; }

	; @region CreateOverlay(options)
	/**
	 * @description Creates an overlay window combining multiple styles
	 * @param {Object} options Window style options
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.CreateOverlay({
	*    transparency: 200,
	*    clickThrough: true,
	*    alwaysOnTop: true
	* })
	*/
	static CreateOverlay(options := {}) {

		this.NoActivate()

		if (options.HasProp("transparency")){
			this.SetTransparency(options.transparency)
		}
		if (options.Get("clickThrough", false)){
			this.MakeClickThrough()
		}
		if (options.Get("alwaysOnTop", true)){
			this.SetAlwaysOnTop()
		}
		if (options.Get("composited", true)){
			this.EnableComposited()
		}

		return this
	}


	; @region CreateToolbar(options)
	/**
	 * @description Creates a floating toolbar window
	 * @param {Object} options Window style options
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.CreateToolbar({
	*    alwaysOnTop: true,
	*    dropShadow: true
	* })
	*/
	static CreateToolbar(options := {}) {

		this.MakeToolWindow()

		if (options.Get("alwaysOnTop", true)){
			this.SetAlwaysOnTop()
		}
		if (options.Get("acceptFiles", false)){
			this.EnableDragDrop()
		}
		if (options.Get("dropShadow", true)){
			this.AddClientEdge()
		}

		return this
	}

	; @region SetButtonWidth(params*)
	static SetButtonWidth(params*) {
		input := bMargin := ''

		; Parse parameters
		for i, param in params {
			if (i = 1) {
				input := param
			}
			else if (i = 2) {
				bMargin := param
			}
		}

		; Set default margin if not provided
		bMargin := bMargin ? bMargin : 1.5

		return GuiButtonProperties.SetButtonWidth(input, bMargin)
	}

	; static SetButtonHeight(rows := 1, vMargin := 1.2) {
	; 	return GuiButtonProperties.SetButtonHeight(rows, vMargin)
	; }

	; @region SetButtonHeight(params*)
	static SetButtonHeight(params*) {
		rows := vMargin := ''

		; Parse parameters
		for i, param in params {
			if (i = 1)
				rows := param
			else if (i = 2)
				vMargin := param
		}

		; Set defaults if not provided
		rows := rows ? rows : 1
		vMargin := vMargin ? vMargin : 1.2

		return GuiButtonProperties.SetButtonHeight(rows, vMargin)
	}


	; @region GetButtonDimensions(text, options)
	static GetButtonDimensions(text, options := {}) {
		return GuiButtonProperties.GetButtonDimensions(text, options)
	}


	; @region GetOptimalButtonLayout(totalButtons, containerWidth, containerHeight)
	static GetOptimalButtonLayout(totalButtons, containerWidth, containerHeight) {
		return GuiButtonProperties.GetOptimalButtonLayout(totalButtons, containerWidth, containerHeight)
	}


	; @region _AddButtonGroup(guiObj, buttonOptions, labelObj, groupOptions, columns)
	static _AddButtonGroup(guiObj, buttonOptions, labelObj, groupOptions := '', columns := 1) {
		buttons := Map()

		if (Type(labelObj) = 'String') {
			labelObj := StrSplit(labelObj, '|')
		}

		if (Type(labelObj) = 'Array' or Type(labelObj) = 'Map' or Type(labelObj) = 'Object') {
			totalButtons := labelObj.Length
			rows := Ceil(totalButtons / columns)

			; Parse groupOptions
			groupPos := '', groupSize := ''
			if (groupOptions != '') {
				RegExMatch(groupOptions, 'i)x\s*(\d+)', &xMatch)
				RegExMatch(groupOptions, 'i)y\s*(\d+)', &yMatch)
				RegExMatch(groupOptions, 'i)w\s*(\d+)', &wMatch)
				RegExMatch(groupOptions, 'i)h\s*(\d+)', &hMatch)

				groupPos := (xMatch ? 'x' . xMatch[1] : '') . ' ' . (yMatch ? 'y' . yMatch[1] : '')
				groupSize := (wMatch ? 'w' . wMatch[1] : '') . ' ' . (hMatch ? 'h' . hMatch[1] : '')
			}

			groupBox := guiObj.AddGroupBox(groupPos . ' ' . groupSize, 'Button Group')
			groupBox.GetPos(&groupX, &groupY, &groupW, &groupH)

			btnWidth := this.SetButtonWidth(labelObj)
			btnHeight := this.SetButtonHeight()

			xMargin := 10
			yMargin := 25
			xSpacing := 10
			ySpacing := 5

			for index, label in labelObj {
				col := Mod(A_Index - 1, columns)
				row := Floor((A_Index - 1) / columns)

				xPos := groupX + xMargin + (col * (btnWidth + xSpacing))
				yPos := groupY + yMargin + (row * (btnHeight + ySpacing))

				btnOptions := StrReplace(buttonOptions, 'xm', 'x' . xPos)
				btnOptions := StrReplace(btnOptions, 'ym', 'y' . yPos)
				btnOptions := 'x' . xPos . ' y' . yPos . ' w' . btnWidth . ' h' . btnHeight . ' ' . btnOptions

				btn := guiObj.AddButton(btnOptions, label)
				buttons[label] := btn
			}

			; Only resize the group box if buttons were actually added
			if (buttons.Count > 0) {
				lastButton := buttons[labelObj[labelObj.Length]]
				lastButton.GetPos(&lastX, &lastY, &lastW, &lastH)
				newGroupW := lastX + lastW + xMargin - groupX
				newGroupH := lastY + lastH + yMargin - groupY
				groupBox.Move(,, newGroupW, newGroupH)
			}
		}

		return buttons
	}

	; @region AddButtonGroup(params*)
	static AddButtonGroup(params*) {
		; Initialize default values
		config := {
			guiObj: '',
			buttonOptions: '',
			labelObj: '',
			groupOptions: '',
			columns: 1
		}

		; Parse parameters
		for i, param in params {
			if (param is Gui)
				config.guiObj := param
			else if (i = 2)
				config.buttonOptions := param
			else if (Type(param) = "String" && InStr(param, "x") || InStr(param, "y"))
				config.groupOptions := param
			else if (Type(param) = "Array" || Type(param) = "String")
				config.labelObj := param
			else if (Type(param) = "Integer")
				config.columns := param
		}

		; Call original implementation with parsed parameters
		return this._AddButtonGroup(config.guiObj, config.buttonOptions, config.labelObj, config.groupOptions, config.columns)
	}

	; @region AddCustomizationOptions(GuiObj)
	static OriginalPositions := Map()

	static AddCustomizationOptions(GuiObj) {
		; Get position for the new group box
		GuiObj.groupBox.GetPos(&gX, &gY, &gW, &gH)

		; Add a new group box for customization options
		GuiObj.AddGroupBox("x" gX " y" (gY + gH + 10) " w" gW " h100", "GUI Customization")

		; Add checkboxes for enabling customization and saving settings
		GuiObj.AddCheckbox("x" (gX + 10) " y+10 vEnableCustomization", "Enable Customization")
			.OnEvent("Click", (*) => this.ToggleCustomization(GuiObj))
		GuiObj.AddCheckbox("x+10 vSaveSettings", "Save Settings")
			.OnEvent("Click", (*) => this.ToggleSaveSettings(GuiObj))

		; Add button for adjusting positions
		GuiObj.AddButton("x" (gX + 10) " y+10 w100 vAdjustPositions", "Adjust Positions")
			.OnEvent("Click", (*) => this.ShowAdjustPositionsGUI(GuiObj))

		; Add text size control
		GuiObj.AddText("x+10 y+-15", "Text Size:")
		GuiObj.AddEdit("x+5 w30 vTextSize", "14")
			.OnEvent("Change", (*) => this.UpdateTextSize(GuiObj))

		; Add custom hotkey option
		GuiObj.AddText("x" (gX + 10) " y+10", "Custom Hotkey:")
		GuiObj.AddHotkey("x+5 w100 vCustomHotkey")
			.OnEvent("Change", (*) => this.UpdateCustomHotkey(GuiObj))

		; Store original positions
		this.StoreOriginalPositions(GuiObj)

		; Add methods to GuiObj
		GuiObj.DefineProp("ApplySettings", {Call: (self, settings) => this.ApplySettings(self, settings)})
		GuiObj.DefineProp("SaveSettings", {Call: (self) => this.SaveSettings(self)})
		GuiObj.DefineProp("LoadSettings", {Call: (self) => this.LoadSettings(self)})
	}

	; @region StoreOriginalPositions(GuiObj)
	static StoreOriginalPositions(GuiObj) {
		this.OriginalPositions[GuiObj.Hwnd] := Map()
		for ctrl in GuiObj {
			ctrl.GetPos(&x, &y)
			this.OriginalPositions[GuiObj.Hwnd][ctrl.Name] := {x: x, y: y}
		}
	}

	; @region ToggleCustomization(GuiObj)
	static ToggleCustomization(GuiObj) {
		isEnabled := GuiObj["EnableCustomization"].Value
		GuiObj["AdjustPositions"].Enabled := isEnabled
		GuiObj["TextSize"].Enabled := isEnabled
		GuiObj["CustomHotkey"].Enabled := isEnabled
	}

	; @region ToggleSaveSettings(GuiObj)
	static ToggleSaveSettings(GuiObj) {
		if (GuiObj["SaveSettings"].Value) {
			this.SaveSettings(GuiObj)
		}
	}

	; @region UpdateTextSize(GuiObj)
	static UpdateTextSize(GuiObj) {
		newSize := GuiObj["TextSize"].Value
		if (IsInteger(newSize) && newSize > 0) {
			GuiObj.SetFont("s" newSize)
			for ctrl in GuiObj {
				if (ctrl.Type == "Text" || ctrl.Type == "Edit" || ctrl.Type == "Button") {
					ctrl.SetFont("s" newSize)
				}
			}
		}
	}

	; @region UpdateCustomHotkey(GuiObj)
	static UpdateCustomHotkey(GuiObj) {
		newHotkey := GuiObj["CustomHotkey"].Value
		if (newHotkey) {
			Hotkey(newHotkey, (*) => this.ToggleVisibility(GuiObj))
		}
	}

	; @region ToggleVisibility(GuiObj)
	static ToggleVisibility(GuiObj) {
		if (GuiObj.Visible) {
			GuiObj.Hide()
		} else {
			GuiObj.Show()
		}
	}

	; @region ShowAdjustPositionsGUI(GuiObj)
	static ShowAdjustPositionsGUI(GuiObj) {
		adjustGui := Gui("+AlwaysOnTop", "Adjust Control Positions")

		for ctrl in GuiObj {
			if (ctrl.Type != "GroupBox") {
				adjustGui.AddText("w150", ctrl.Name)
				adjustGui.AddButton("x+5 w20 h20", "↑").OnEvent("Click", (*) => this.MoveControl(GuiObj, ctrl, 0, -5))
				adjustGui.AddButton("x+5 w20 h20", "↓").OnEvent("Click", (*) => this.MoveControl(GuiObj, ctrl, 0, 5))
				adjustGui.AddButton("x+5 w20 h20", "←").OnEvent("Click", (*) => this.MoveControl(GuiObj, ctrl, -5, 0))
				adjustGui.AddButton("x+5 w20 h20", "→").OnEvent("Click", (*) => this.MoveControl(GuiObj, ctrl, 5, 0))
				adjustGui.AddButton("x+10 w60", "Reset").OnEvent("Click", (*) => this.ResetControlPosition(GuiObj, ctrl))
			}
		}

		adjustGui.AddButton("x10 w100", "Save").OnEvent("Click", (*) => (this.SaveSettings(GuiObj), adjustGui.Destroy()))
		adjustGui.Show()
	}

	; @region MoveControl(GuiObj, ctrl, dx, dy)
	static MoveControl(GuiObj, ctrl, dx, dy) {
		ctrl.GetPos(&x, &y)
		ctrl.Move(x + dx, y + dy)
	}

	; @region ResetControlPosition(GuiObj, ctrl)
	static ResetControlPosition(GuiObj, ctrl) {
		if (this.OriginalPositions.Has(GuiObj.Hwnd) && this.OriginalPositions[GuiObj.Hwnd].Has(ctrl.Name)) {
			originalPos := this.OriginalPositions[GuiObj.Hwnd][ctrl.Name]
			ctrl.Move(originalPos.x, originalPos.y)
		}
	}

	; @region SaveSettings(GuiObj)
	static SaveSettings(GuiObj) {
		settings := Map(
			"GuiSize", {w: GuiObj.Pos.W, h: GuiObj.Pos.H},
			"ControlPositions", this.GetControlPositions(GuiObj),
			"TextSize", GuiObj["TextSize"].Value,
			"CustomHotkey", GuiObj["CustomHotkey"].Value
		)
		FileDelete(A_ScriptDir "\GUISettings.json")
		FileAppend(JSONS.Stringify(settings), A_ScriptDir "\GUISettings.json")
	}

	; @region LoadSettings(GuiObj)
	static LoadSettings(GuiObj) {
		if (FileExist(A_ScriptDir "\GUISettings.json")) {
			settings := JSONS.Load(FileRead(A_ScriptDir "\GUISettings.json"))
			this.ApplySettings(GuiObj, settings)
		}
	}

	; @region ApplySettings(GuiObj, settings)
	static ApplySettings(GuiObj, settings) {
		if (settings.Has("GuiSize")) {
			GuiObj.Move(,, settings.GuiSize.w, settings.GuiSize.h)
		}
		if (settings.Has("ControlPositions")) {
			this.SetControlPositions(GuiObj, settings.ControlPositions)
		}
		if (settings.Has("TextSize")) {
			GuiObj["TextSize"].Value := settings.TextSize
			this.UpdateTextSize(GuiObj)
		}
		if (settings.Has("CustomHotkey")) {
			GuiObj["CustomHotkey"].Value := settings.CustomHotkey
			this.UpdateCustomHotkey(GuiObj)
		}
	}

	; @region GetControlPositions(GuiObj)
	static GetControlPositions(GuiObj) {
		positions := Map()
		for ctrl in GuiObj {
			ctrl.GetPos(&x, &y)
			positions[ctrl.Name] := {x: x, y: y}
		}
		return positions
	}

	; @region SetControlPositions(GuiObj, positions)
	static SetControlPositions(GuiObj, positions) {
		for ctrlName, pos in positions {
			if (GuiObj.HasProp(ctrlName)) {
				GuiObj[ctrlName].Move(pos.x, pos.y)
			}
		}
	}

	; @region Static wrapper methods
	static AddCustomizationOptionsToGui(GuiObj?) {
		if !GuiObj {
			guiObj := this
		}
		GuiObj.AddCustomizationOptions()
		return this
	}

	static SaveGuiSettings(GuiObj?) {
		GuiObj.SaveSettings()
		return this
	}

	static LoadGuiSettings(GuiObj?) {
		GuiObj.LoadSettings()
		return this
	}

	; @region AddRichEdit(options, text, toolbar, showScrollBars)
	/**
	 *
	 * @param guiObj
	 * @param options
	 * @param text
	 */
	static AddRichEdit(options := '', text := "", toolbar := true, showScrollBars := false) {
		; 'this' refers to the Gui instance here
		guiObj := this
		; Create RichEdit control with default size if none specified
		if !IsSet(options) {
			options := "w400 r10"  ; Default size
		}

		; Create RichEdit control
		reObj := RichEdit(this, options)
		; Calculate positions
		; Set sizing properties
		reObj.WidthP := 1.0   ; Take full width
		reObj.HeightP := 1.0  ; Take full height after toolbar
		reObj.MinWidth := 200
		reObj.MinHeight := 100
		reObj.AnchorIn := true

		; Initialize GuiReSizer for the parent GUI
		guiObj.Init := 2  ; Force initial resize

		; Ensure parent GUI resizes properly
		guiObj.OnEvent("Size", GuiReSizer)
		btnW := 18, btnH := 15, margin := 1

		; If toolbar enabled, add it before the RichEdit
		if (toolbar) {
			toolbarH := btnH + margin*2
			x := margin
			y := margin

			; Bold
			boldBtn := guiObj.AddButton(Format("x{1} y{2} w{3} h{4}", x, y, btnW, btnH), "B")
			x += btnW + margin

			; Italic
			italicBtn := guiObj.AddButton(Format("x{1} y{2} w{3} h{4}", x, y, btnW, btnH), "I")
			x += btnW + margin

			; Underline
			underBtn := guiObj.AddButton(Format("x{1} y{2} w{3} h{4}", x, y, btnW, btnH), "U")
			x += btnW + margin

			; Strikethrough
			strikeBtn := guiObj.AddButton(Format("x{1} y{2} w{3} h{4}", x, y, btnW, btnH), "S")

			; Position RichEdit below toolbar
			options := "x" margin " y" (y + btnH + margin) " " options
		}

		; Create RichEdit control
		reObj := RichEdit(this, options)
		reObj.SetFont({Name: "Times New Roman", Size: 9})
		; Add GuiReSizer properties after creating RichEdit
		reObj.GetPos(&xPos, &yPos, &wGui, &hGui)

		; Add resizing properties for GUI
		if (toolbar) {
			; Account for toolbar space if present
			reObj.X := margin
			reObj.Y := btnH + margin*2
		} else {
			reObj.X := margin
			reObj.Y := margin
		}

		; Configure scrollbar visibility
		if (!showScrollBars) {
			reObj.SetOptions([
				"SELECTIONBAR",
				; "MULTILEVEL",
				"AUTOWORDSEL",
				; "-HSCROLL",  ; Disable horizontal scrollbar
				; "-VSCROLL"   ; Disable vertical scrollbar
				; "-AUTOVSCROLL",  ; Show vertical scrollbar when needed
				; "-AUTOHSCROLL"   ; Show horizontal scrollbar when needed
			])
		} else {
			reObj.SetOptions([
				"SELECTIONBAR",
				"MULTILEVEL",
				"AUTOWORDSEL",
				"AUTOVSCROLL",  ; Show vertical scrollbar when needed
				"AUTOHSCROLL"   ; Show horizontal scrollbar when needed
			])
		}

		; Enable features
		reObj.AutoURL(true)                 ; Enable URL detection
		reObj.SetEventMask([
			"SELCHANGE",                    ; Selection change events
			"LINK",                         ; Link click events
			"PROTECTED",                    ; Protected text events
			"CHANGE"                        ; Text change events
		])

		; @region  Add GuiReSizer properties for automatic sizing
		reObj.WidthP := 1.0      ; Take up full width
		reObj.HeightP := 1.0     ; Take up full height
		reObj.MinWidth := 200    ; Minimum dimensions
		reObj.MinHeight := 100
		reObj.AnchorIn := true   ; Stay within parent bounds

		; @region Add basic keyboard shortcuts
		HotIfWinactive("ahk_id " reObj.Hwnd)
		Hotkey("^b", (*) => reObj.ToggleFontStyle("B"))
		Hotkey("^i", (*) => reObj.ToggleFontStyle("I"))
		Hotkey("^u", (*) => reObj.ToggleFontStyle("U"))
		Hotkey("^+s", (*) => reObj.ToggleFontStyle("S"))
		Hotkey("^z", (*) => reObj.Undo())
		Hotkey("^y", (*) => reObj.Redo())
		HotIf()

		; Set initial text if provided
		if IsSet(text) {
			reObj.SetText(text)
		}

		; @region  Define button callbacks
		BoldText(*) {
			reObj.ToggleFontStyle("B")
			reObj.Focus()
		}

		ItalicText(*) {
			reObj.ToggleFontStyle("I")
			reObj.Focus()
		}

		UnderlineText(*) {
			reObj.ToggleFontStyle("U")
			reObj.Focus()
		}

		StrikeText(*) {
			reObj.ToggleFontStyle("S")
			reObj.Focus()
		}

		return reObj
	}

	; @region AddRTE(options, text)
	/**
	 * Extension method for Gui class
	 * @param {String} options Control options
	 * @param {String} text Initial text
	 * @returns {RichEdit} The created RichEdit control
	 */
	static AddRTE(options := "", text := "") {
		; Call AddRichEdit and return its result
		return this.AddRichEdit(options, text)
	}

	; @region AddRichTextEdit(options, text)
	/**
	 * Extension method for Gui class - alternate name for AddRichEdit
	 * @param {String} options Control options
	 * @param {String} text Initial text
	 * @returns {RichEdit} The created RichEdit control
	 */
	static AddRichTextEdit(options := "", text := "") {
		; Call AddRichEdit and return its result
		return this.AddRichEdit(options, text)
	}

	; @region AddRichText(options, text)
	/**
	 * @description Add a rich text control (simpler version of RichEdit)
	 * @param {String} options Control options
	 * @param {String} text Initial text content
	 * @returns {RichEdit} The created RichEdit control
	 */
	static AddRichText(options := "", text := "") {
		; Default size if not specified
		if !RegExMatch(options, "w\d+") {
			options := "w400 " options
		}

		; Create RichEdit with simplified settings
		reObj := RichEdit(this, options)

		; Configure for basic text display
		reObj.SetOptions([
			"READONLY",          ; Make it read-only like Text control
			"-HSCROLL",         ; Disable horizontal scrollbar
			"-VSCROLL",         ; Disable vertical scrollbar
			"MULTILINE",        ; Allow multiple lines like Text
			"SELECTIONBAR"      ; Enable selection bar
		])

		; Set initial text if provided
		if (text != "") {
			reObj.SetText(text)
		}

		return reObj
	}

	; @region SetDefaultFont(guiObj, fontObj)
	static SetDefaultFont(guiObj := this, fontObj := '') {
		if (guiObj is Gui) {

			if (IsObject(fontObj)) {
				; Use the provided font object
				size := fontObj.HasProp('Size') ? 's' . fontObj.Size : 's9'
				weight := fontObj.HasProp('Weight') ? ' w' . fontObj.Weight : ''
				italic := fontObj.HasProp('Italic') && fontObj.Italic ? ' Italic' : ''
				underline := fontObj.HasProp('Underline') && fontObj.Underline ? ' Underline' : ''
				strikeout := fontObj.HasProp('Strikeout') && fontObj.Strikeout ? ' Strike' : ''
				name := fontObj.HasProp('Name') ? fontObj.Name : 'Segoe UI'

				options := size . weight . italic . underline . strikeout
				guiObj.SetFont(options, name)
			} else if !guiObj.HasProp('Font') {
				; Use default settings if no font object is provided
				guiObj.SetFont('s9', 'Segoe UI')
			}
		}
		return this
	}
}
; @endregion Gui2
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region DisplaySettings
/**
 * @class DisplaySettings
 * @description Manages display settings for various GUI elements
 */
class DisplaySettings {
	; Store all settings maps
	static Settings := Map(
		"Base", {
			; Common base settings for all displays
			Font: {
				Name: "Consolas",
				Size: 10,
				Quality: 5,
				Color: "cBlue"
			},
			Colors: {
				Background: "cBlack",
				Text: '#000000'
			},
			Styles: "+AlwaysOnTop -Caption +ToolWindow",
			Margins: {
				X: 0,
				Y: 0
			},
			Grid: {
				Enabled: true,
				Columns: 3,
				Rows: 10,
				Spacing: 10
			}
		},
		"Infos", {
			; Infos-specific settings
			Font: {
				Size: 8,
				Quality: 5
			},
			Metrics: {
				Distance: 4,
				Unit: A_ScreenDPI / 144
			},
			Position: {
				Mode: "Grid",  ; "Grid", "Fixed", "Center"
				Column: 1,     ; Single column for traditional Infos
				MaxRows: Floor(A_ScreenHeight / (8 * (A_ScreenDPI / 144) * 4))
			},
			Limits: {
				MaxNumberedHotkeys: 12,
				MaxWidthInChars: 110
			}
		},
		"CleanInputBox", {
			; CleanInputBox-specific settings
			Size: {
				Width: Round(A_ScreenWidth / 3),
				MinHeight: 30
			},
			Position: {
				Mode: "Center",
				TopMargin: Round(A_ScreenHeight / 1080 * 800)
			},
			Font: {
				Size: 12
			},
			Input: {
				MinChars: 2,
				MaxMatches: 5,
				ShowMatchList: true
			}
		},
		"InputBox", {
			; Future InputBox-specific settings
			Size: {
				Width: Round(A_ScreenWidth / 4),
				Height: "Auto"
			},
			Position: {
				Mode: "Fixed",
				X: 100,
				Y: 100
			},
			Font: {
				Size: 11
			}
		}
	)

	/**
	 * Get settings for a specific display type
	 * @param {String} type The display type ("Infos", "CleanInputBox", etc)
	 * @returns {Object} Merged settings
	 */
	static GetSettings(type) {
		; Start with base settings
		mergedSettings := this.CloneMap(this.Settings["Base"])

		; Merge with type-specific settings if they exist
		if (this.Settings.Has(type)) {
			mergedSettings := this.MergeSettings(mergedSettings, this.Settings[type])
		}

		return mergedSettings
	}

	/**
	 * Update settings for a display type
	 * @param {String} type The display type
	 * @param {Object} newSettings New settings to apply
	 */
	static UpdateSettings(type, newSettings) {
		if (this.Settings.Has(type)) {
			this.Settings[type] := this.MergeSettings(this.Settings[type], newSettings)
		} else {
			this.Settings[type] := newSettings
		}
	}

	/**
	 * Deep clone a Map or Object
	 * @param {Map|Object} source Source to clone
	 * @returns {Map|Object} Cloned copy
	 */
	static CloneMap(source) {
		if (Type(source) = "Map") {
			result := Map()
			for key, value in source {
				result[key] := IsObject(value) ? this.CloneMap(value) : value
			}
			return result
		} else if (IsObject(source)) {
			result := {}
			for key, value in source.OwnProps() {
				result.%key% := IsObject(value) ? this.CloneMap(value) : value
			}
			return result
		}
		return source
	}

	/**
	 * Deep merge settings objects
	 * @param {Object} target Target object
	 * @param {Object} source Source object
	 * @returns {Object} Merged result
	 */
	static MergeSettings(target, source) {
		result := this.CloneMap(target)

		if (Type(source) = "Map") {
			for key, value in source {
				if (Type(value) = "Map" || IsObject(value)) {
					if (result.Has(key)) {
						result[key] := this.MergeSettings(result[key], value)
					} else {
						result[key] := this.CloneMap(value)
					}
				} else {
					result[key] := value
				}
			}
		} else if (IsObject(source)) {
			for key, value in source.OwnProps() {
				if (IsObject(value)) {
					if (result.HasProp(key)) {
						result.%key% := this.MergeSettings(result.%key%, value)
					} else {
						result.%key% := this.CloneMap(value)
					}
				} else {
					result.%key% := value
				}
			}
		}

		return result
	}

	/**
	 * Calculate derived settings (those that depend on other settings)
	 * @param {String} type Display type
	 * @param {Object} settings Base settings object
	 * @returns {Object} Settings with calculated values
	 */
	static CalculateDerivedSettings(type, settings) {
		derived := this.CloneMap(settings)

		switch type {
			case "Infos":
				; Calculate GUI width based on font metrics
				derived.guiWidth := derived.Font.Size
					* derived.Metrics.Unit
					* derived.Metrics.Distance

				; Calculate maximum instances based on screen height
				derived.maxInstances := Floor(A_ScreenHeight / derived.guiWidth)

			case "CleanInputBox":
				; Calculate centered position
				derived.Position.X := (A_ScreenWidth - derived.Size.Width) / 2
				derived.Position.Y := derived.Position.TopMargin
		}

		return derived
	}
}
; @endregion DisplaySettings
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; @region InfoBox

/**
 * @class InfoBox
 * @description Core GUI creation and management functionality
 */
class InfoBox {
	static Instances := Map()
	static Grid := Map()

	__New(settings) {
		this.settings := settings
		; this.InitializeGrid()
		this.position := this.GetPosition()

		if (!this.position) {
			return
		}

		this.gui := Gui(this.settings.Styles)
		this.SetupGui()
		InfoBox.Instances[this.gui.Hwnd] := this
	}

	InitializeGrid() {
		if (this.settings.Position.Mode = "Grid") {
			gridId := this.settings.Grid.ID

			; Initialize grid if not exists
			if (!InfoBox.Grid.Has(gridId)) {
				InfoBox.Grid[gridId] := Array(this.settings.Grid.Rows)
				loop this.settings.Grid.Rows {
					row := A_Index
					InfoBox.Grid[gridId][row] := Array(this.settings.Grid.Columns)
					loop this.settings.Grid.Columns {
						InfoBox.Grid[gridId][row][A_Index] := false
					}
				}
			}
		}
	}

	SetupGui() {
		; Apply base settings
		this.gui.MarginX := this.settings.Margins.X
		this.gui.MarginY := this.settings.Margins.Y
		this.gui.BackColor := this.settings.Colors.Background

		; Set font
		this.gui.SetFont(
			"s" this.settings.Font.Size " q" this.settings.Font.Quality
			" " this.settings.Font.Color,
			this.settings.Font.Name
		)
	}

	AddControl(type, options, text := "") {
		control := this.gui.Add(type, options, text)
		return control
	}

	GetPosition() {
		; if (this.settings.Position.Mode = "Grid") {
		; 	return this.GetGridPosition()
		; } else if (this.settings.Position.Mode = "Center") {
		; 	return this.GetCenteredPosition()
		; }
		; return {
		; 	x: this.settings.Position.X,
		; 	y: this.settings.Position.Y,
		; 	row: 0,
		; 	col: 0
		; }
		return this.GetCenteredPosition()
	}

	GetGridPosition() {
		gridId := this.settings.Grid.ID
		grid := InfoBox.Grid[gridId]

		loop this.settings.Grid.Rows {
			row := A_Index
			loop this.settings.Grid.Columns {
				col := A_Index
				if (!grid[row][col]) {
					grid[row][col] := true
					return {
						x: (col - 1) * (this.settings.Size.Width + this.settings.Grid.Spacing),
						y: (row - 1) * (this.settings.Size.Height + this.settings.Grid.Spacing),
						row: row,
						col: col
					}
				}
			}
		}
		return false
	}

	GetCenteredPosition() {
		return {
			x: (A_ScreenWidth - this.settings.Size.Width) / 2,
			y: this.settings.Position.HasProp("TopMargin") ? this.settings.Position.TopMargin : (A_ScreenHeight / 3),
			row: 0,
			col: 0
		}
	}

	Show(options := "") {
		if (this.position) {
			showOptions := options ? options
				: Format("x{1} y{2} AutoSize", this.position.x, this.position.y)
			this.gui.Show(showOptions)
		}
	}

	Hide() {
		this.gui.Hide()
	}

	Destroy() {
		; Release grid position if using grid
		if (this.position && this.settings.Position.Mode = "Grid") {
			gridId := this.settings.Grid.ID
			InfoBox.Grid[gridId][this.position.row][this.position.col] := false
		}

		; Remove from instances
		InfoBox.Instances.Delete(this.gui.Hwnd)

		; Destroy GUI
		this.gui.Destroy()
	}

	static DestroyAll() {
		for hwnd, instance in InfoBox.Instances.Clone() {
			instance.Destroy()
		}
	}
}
; @endregion InfoBox
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------

; Info(text, timeout?) => Infos(text, timeout ?? 2000)
; Info(text, timeout?) => Infos(text, timeout ?? 10000)
; @region UnifiedDisplayManager
/**
 * @class UnifiedDisplayManager
 * @description Manages stacked GUI displays with consistent positioning and styling
 * @version 1.0.0
 * @date 2024/02/16
 */
class UnifiedDisplayManager {
	; Static properties for display configuration
	static Instances := Map()
	static InstanceCount := 0
	static DefaultSettings := {
		Width: Round(A_ScreenWidth / 3),
		TopMargin: Round(A_ScreenHeight / 2),
		StackMargin: 30,
		Styles: "+AlwaysOnTop -Caption +ToolWindow",
		Font: {
			Name: "Consolas",
			Size: 10,
			Quality: 5
		},
		Colors: {
			Background: "#0x161821",
			Text: "cBlue"
		}
	}

	; Instance properties
	Gui := ""
	Input := ""
	IsWaiting := true
	Settings := Map()
	Controls := Map()

	/**
	 * @constructor
	 * @param {Object} options Configuration options
	 */
	__New(options := {}) {
		this.InitializeSettings(options)
		this.CreateGui()
		UnifiedDisplayManager.InstanceCount++
		UnifiedDisplayManager.Instances[this.Gui.Hwnd] := this
	}

	InitializeSettings(options) {
		; Merge provided options with defaults
		this.Settings := UnifiedDisplayManager.DefaultSettings.Clone()
		for key, value in options.OwnProps() {
			if IsObject(this.Settings.%key%) && IsObject(value)
				this.Settings.%key% := this.MergeObjects(this.Settings.%key%, value)
			else
				this.Settings.%key% := value
		}
	}

	MergeObjects(target, source) {
		for key, value in source.OwnProps() {
			if IsObject(value) && IsObject(target.%key%)
				target.%key% := this.MergeObjects(target.%key%, value)
			else
				target.%key% := value
		}
		return target
	}

	CreateGui() {
		; Create base GUI with specified styles
		this.Gui := Gui(this.Settings.Styles)
		this.Gui.BackColor := this.Settings.Colors.Background
		this.Gui.SetFont("s" this.Settings.Font.Size " q" this.Settings.Font.Quality,
						this.Settings.Font.Name)

		; Setup default GUI events
		this.Gui.OnEvent("Close", (*) => this.Destroy())
		this.Gui.OnEvent("Escape", (*) => this.Destroy())
	}

	AddControl(type, options, text := "") {
		control := this.Gui.Add(type, options, text)
		this.Controls[control.Hwnd] := control
		return control
	}

	AddEdit(options := "", text := "") {
		return this.AddControl("Edit", "x0 Center -E0x200 Background" this.Settings.Colors.Background
			" w" this.Settings.Width " " options, text)
	}

	AddComboBox(options := "", items := "") {
		if IsObject(items) {
			items := this.ProcessItems(items)
		}
		return this.AddControl("ComboBox", "x0 Center w" this.Settings.Width " " options, items)
	}

	ProcessItems(items) {
		result := []
		if Type(items) = "Array"
			result := items
		else if Type(items) = "Map" || Type(items) = "Object"
			for key, value in items
				result.Push(IsObject(value) ? key : value)
		return result
	}

	Show(params := "") {
		defaultPos := "y" this.CalculateYPosition() " w" this.Settings.Width
		this.Gui.Show(params ? params : defaultPos)
	}

	CalculateYPosition() {
		basePos := this.Settings.TopMargin
		stackOffset := (UnifiedDisplayManager.InstanceCount - 1) * this.Settings.StackMargin
		return basePos + stackOffset
	}

	; @section  WaitForInput
	/**
		* @method WaitForInput
		* @description Blocks until input is received
		* @returns {String} The input received
		*/
	WaitForInput() {
		this.Show()
		while this.IsWaiting {
			Sleep(10)
		}
		return this.Input
	}

	SetInput(value) {
		this.Input := value
		this.IsWaiting := false
	}

	RegisterHotkey(hotkeyStr, callback) {
		HotIfWinActive("ahk_id " this.Gui.Hwnd)
		Hotkey(hotkeyStr, callback)
	}

	Destroy() {
		; Clean up hotkeys
		HotIfWinActive("ahk_id " this.Gui.Hwnd)
		Hotkey("Enter", "Off")
		HotIf()

		; Remove from instances
		UnifiedDisplayManager.Instances.Delete(this.Gui.Hwnd)
		UnifiedDisplayManager.InstanceCount--

		; Destroy GUI
		this.Gui.Destroy()
	}

	; @section  EnableAutoComplete
	/**
		* @method EnableAutoComplete
		* @description Enables autocomplete functionality for an input control
		* @param {Gui.Control} control The control to enable autocomplete for
		* @param {Array|Map|Object} source The data source for autocomplete
		*/
	EnableAutoComplete(control, source) {
		; Process source data into a consistent format
		items := this.ProcessItems(source)

		; Bind autocomplete handler
		control.OnEvent("Change", (*) => this.HandleAutoComplete(control, items))
	}

	HandleAutoComplete(control, items) {
		static CB_GETEDITSEL := 320, CB_SETEDITSEL := 322

		if ((GetKeyState("Delete")) || (GetKeyState("Backspace")))
			return

		currContent := control.Text
		if (!currContent)
			return

		; Check for exact match
		for item in items {
			if (item = currContent)
				return
		}

		; Try to find matching item
		try {
			if (ControlChooseString(currContent, control) > 0) {
				start := StrLen(currContent)
				end := StrLen(control.Text)
				PostMessage(CB_SETEDITSEL, 0, this.MakeLong(start, end),, control.Hwnd)
			}
		}
	}

	MakeLong(low, high) => (high << 16) | (low & 0xffff)
}
; @endregion UnifiedDisplayManager
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region GuiButtonProperties
class GuiButtonProperties {

	static SetButtonWidth(input, bMargin := 1) {
		largestLength := 0

		if Type(input) = 'String' {
			return largestLength := StrLen(input)
		} else if Type(input) = 'Array' {
			for value in input {
				currentLength := StrLen(value)
				if (currentLength > largestLength) {
					largestLength := currentLength
				}
			}
		} else if Type(input) = 'Map' || Type(input) = 'Object' {
			for key, value in input {
				currentLength := StrLen(value)
				if (currentLength > largestLength) {
					largestLength := currentLength
				}
			}
		}

		return GuiButtonProperties.CalculateButtonWidth(largestLength, bMargin)
	}

	; Function to set button length based on various input types
	static SetButtonLength(input) {
		largestLength := 0

		if Type(input) = 'String' {
			return StrLen(input)
		} else if Type(input) = 'Array' {
			for value in input {
				currentLength := StrLen(value)
				if (currentLength > largestLength) {
					largestLength := currentLength
				}
			}
		} else if Type(input) = 'Map' || Type(input) = 'Object' {
			for key, value in input {
				currentLength := StrLen(value)
				if (currentLength > largestLength) {
					largestLength := currentLength
				}
			}
		} else if Type(input) = 'String' && (SubStr(input, -4) = '.json' || SubStr(input, -3) = '.ini') {
			; Read from JSON or INI file and process
			; (Implementation depends on file format and structure)
		}

		return largestLength
	}

	static CalculateButtonWidth(textLength, bMargin := 7.5) {
		; Using default values instead of FontProperties
		avgCharWidth := 6  ; Approximate average character width
		; fontSize := 9      ; Default font size
		fontSize := 1      ; Default font size
		return Round((textLength * avgCharWidth) + (2 * (bMargin * fontSize)))
	}

	static SetButtonHeight(rows := 1, vMargin := 7.5) {
		; Using default values instead of FontProperties
		fontSize := 15      ; Default font size
		return Round((fontSize * vMargin) * rows)
	}

	static GetButtonDimensions(text, options := {}) {
		width := options.HasOwnProp('width') ? options.width : GuiButtonProperties.CalculateButtonWidth(StrLen(text))
		height := options.HasOwnProp('height') ? options.height : GuiButtonProperties.SetButtonHeight()
		return {width: width, height: height}
	}

	static GetOptimalButtonLayout(totalButtons, containerWidth, containerHeight) {
		buttonDimensions := this.GetButtonDimensions('Sample')
		maxColumns := Max(1, Floor(containerWidth / buttonDimensions.width))
		maxRows := Max(1, Floor(containerHeight / buttonDimensions.height))

		columns := Min(maxColumns, totalButtons)
		columns := Max(1, columns)  ; Ensure columns is at least 1
		rows := Ceil(totalButtons / columns)

		if (rows > maxRows) {
			rows := maxRows
			columns := Ceil(totalButtons / rows)
		}

		return {rows: rows, columns: columns}
	}
}
; @endregion GuiButtonProperties
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; @region FontProperties
class FontProperties extends Gui {

	static Defaults := Map(
		'Name', 'Segoe UI',
		'Size', 9,
		'Weight', 400,
		'Italic', false,
		'Underline', false,
		'Strikeout', false,
		'Quality', 5,  ; 5 corresponds to CLEARTYPE_QUALITY
		'Charset', 1   ; 1 corresponds to DEFAULT_CHARSET
	)

	static GetDefault(key) {
		return this.Defaults.Has(key) ? this.Defaults[key] : ''
	}

	__New(guiObj := '') {
		this.LoadDefaults()
		if (guiObj != '') {
			this.UpdateFont(guiObj)
		}
		this.AvgCharW := this.CalculateAverageCharWidth()
	}

	LoadDefaults() {
		for key, value in FontProperties.Defaults {
			this.%key% := value
		}
	}

	UpdateFont(guiObj) {
		if !(guiObj is Gui) {
			return
		}

		hFont := SendMessage(0x31, 0, 0,, 'ahk_id ' guiObj.Hwnd)
		if (hFont = 0) {
			return
		}

		LOGFONT := Buffer(92, 0)
		if (!DllCall('GetObject', 'Ptr', hFont, 'Int', LOGFONT.Size, 'Ptr', LOGFONT.Ptr)) {
			return
		}

		this.Name := StrGet(LOGFONT.Ptr + 28, 32, 'UTF-16')
		this.Size := -NumGet(LOGFONT, 0, 'Int') * 72 / A_ScreenDPI
		this.Weight := NumGet(LOGFONT, 16, 'Int')
		this.Italic := NumGet(LOGFONT, 20, 'Char') != 0
		this.Underline := NumGet(LOGFONT, 21, 'Char') != 0
		this.Strikeout := NumGet(LOGFONT, 22, 'Char') != 0
		this.Quality := NumGet(LOGFONT, 26, 'Char')
		this.Charset := NumGet(LOGFONT, 23, 'Char')

		this.AvgCharW := this.CalculateAverageCharWidth()
	}

	CalculateAverageCharWidth() {
		hdc := DllCall('GetDC', 'Ptr', 0, 'Ptr')
		if (hdc == 0) {
			return 8  ; Default fallback value
		}

		hFont := DllCall('CreateFont'
			, 'Int', this.Size
			, 'Int', 0
			, 'Int', 0
			, 'Int', 0
			, 'Int', this.Weight
			, 'Uint', this.Italic
			, 'Uint', this.Underline
			, 'Uint', this.Strikeout
			, 'Uint', this.Charset
			, 'Uint', 0
			, 'Uint', 0
			, 'Uint', 0
			, 'Uint', 0
			, 'Str', this.Name)

		if (hFont == 0) {
			DllCall('ReleaseDC', 'Ptr', 0, 'Ptr', hdc)
			return 8  ; Default fallback value
		}

		hOldFont := DllCall('SelectObject', 'Ptr', hdc, 'Ptr', hFont)
		textMetrics := Buffer(56)
		if (!DllCall('GetTextMetrics', 'Ptr', hdc, 'Ptr', textMetrics)) {
			DllCall('SelectObject', 'Ptr', hdc, 'Ptr', hOldFont)
			DllCall('DeleteObject', 'Ptr', hFont)
			DllCall('ReleaseDC', 'Ptr', 0, 'Ptr', hdc)
			return 8  ; Default fallback value
		}

		averageCharWidth := NumGet(textMetrics, 20, 'Int')

		DllCall('SelectObject', 'Ptr', hdc, 'Ptr', hOldFont)
		DllCall('DeleteObject', 'Ptr', hFont)
		DllCall('ReleaseDC', 'Ptr', 0, 'Ptr', hdc)

		return averageCharWidth ? averageCharWidth : 8  ; Use fallback if averageCharWidth is 0
	}

	static CreateFontInfo(guiObj) {
		return FontProperties(guiObj)
	}
	static GetControlFontInfo(control) {
		if !(control is Gui.Control) {
			return FontProperties()
		}
		return FontProperties(control.Gui)
	}
}
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
/*
	Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
	Author: Nich-Cebolla
	Version: 1.0.0
	License: MIT
*/
;@region Align
/**
 * @class Align
 * @description Utility class for aligning and distributing GUI controls and windows.
 * @version 1.1.0
 * @author OvercastBTC, Nich-Cebolla
 * @license MIT
 * @date 2025-04-20
 * @requires AutoHotkey v2.0+
 */
class Align {

	static DPI_AWARENESS_CONTEXT := -4

	; --- Window-level alignment methods (from original) ---
	static CenterH(Subject, Target) {
		Subject.GetPos(&X1, &Y1, &W1)
		Target.GetPos(&X2, , &W2)
		Subject.Move(X2 + W2 / 2 - W1 / 2, Y1)
	}
	static CenterHSplit(Win1, Win2) {
		Win1.GetPos(&X1, &Y1, &W1)
		Win2.GetPos(&X2, &Y2, &W2)
		diff := X1 + 0.5 * W1 - X2 - 0.5 * W2
		X1 -= diff * 0.5
		X2 += diff * 0.5
		Win1.Move(X1, Y1)
		Win2.Move(X2, Y2)
	}
	static CenterV(Subject, Target) {
		Subject.GetPos(&X1, &Y1, , &H1)
		Target.GetPos( , &Y2, , &H2)
		Subject.Move(X1, Y2 + H2 / 2 - H1 / 2)
	}
	static CenterVSplit(Win1, Win2) {
		Win1.GetPos(&X1, &Y1, , &H1)
		Win2.GetPos(&X2, &Y2, , &H2)
		diff := Y1 + 0.5 * H1 - Y2 - 0.5 * H2
		Y1 -= diff * 0.5
		Y2 += diff * 0.5
		Win1.Move(X1, Y1)
		Win2.Move(X2, Y2)
	}

	; --- Control-level alignment methods (from your new class) ---

	/**
	 * Center a list of controls horizontally within a given width or container.
	 * @param {Array} controls Array of Gui.Control objects
	 * @param {Integer|Gui.Control|Gui} containerOrWidth Optional: container (GroupBox/Area/Gui) or width
	 * @param {Integer} y Optional Y position for all controls
	 */
	static CenterHList(controls, containerOrWidth := 0, y := unset) {
		if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
			throw ValueError("Align.CenterHList: controls must be a non-empty array", -1)
		local sumWidth := 0
		for _, ctrl in controls {
			if !ctrl.HasOwnProp("Hwnd")
				continue
			ctrl.GetPos(,, &w)
			sumWidth += w
		}
		; Determine container width
		local totalWidth := 0
		if (containerOrWidth is Gui.Control || containerOrWidth is Gui) {
			containerOrWidth.GetPos(,, &totalWidth)
		} else if (containerOrWidth > 0) {
			totalWidth := containerOrWidth
		} else {
			; fallback: use parent gui width
			parent := controls[1].Gui
			parent.GetClientPos(,, &totalWidth)
		}
		local spacing := 0
		if (totalWidth > 0 && controls.Length > 1)
			spacing := Floor((totalWidth - sumWidth) / (controls.Length + 1))
		else
			spacing := 5
		local x := spacing
		for _, ctrl in controls {
			ctrl.GetPos(,, &w, &h)
			if IsSet(y)
				ctrl.Move(x, y, w, h)
			else
				ctrl.Move(x, , w, h)
			x += w + spacing
		}
		return this
	}

	/**
	 * Center a list of controls vertically within a given height or container.
	 */
	static CenterVList(controls, containerOrHeight := 0, x := unset) {
		if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
			throw ValueError("Align.CenterVList: controls must be a non-empty array", -1)
		local sumHeight := 0
		for _, ctrl in controls {
			if !ctrl.HasOwnProp("Hwnd")
				continue
			ctrl.GetPos(,,, &h)
			sumHeight += h
		}
		local totalHeight := 0
		if (containerOrHeight is Gui.Control || containerOrHeight is Gui) {
			containerOrHeight.GetPos(,,, &totalHeight)
		} else if (containerOrHeight > 0) {
			totalHeight := containerOrHeight
		} else {
			parent := controls[1].Gui
			parent.GetClientPos(,,, &totalHeight)
		}
		local spacing := 0
		if (totalHeight > 0 && controls.Length > 1)
			spacing := Floor((totalHeight - sumHeight) / (controls.Length + 1))
		else
			spacing := 5
		local y := spacing
		for _, ctrl in controls {
			ctrl.GetPos(,, &w, &h)
			if IsSet(x)
				ctrl.Move(x, y, w, h)
			else
				ctrl.Move(, y, w, h)
			y += h + spacing
		}
		return this
	}

	/**
	 * Set all controls in a list to the same width (max width).
	 */
	static GroupWidth(controls) {
		if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
			throw ValueError("Align.GroupWidth: controls must be a non-empty array", -1)
		local maxWidth := 0
		for _, ctrl in controls {
			ctrl.GetPos(,, &w)
			if (w > maxWidth)
				maxWidth := w
		}
		for _, ctrl in controls {
			ctrl.GetPos(&x, &y, , &h)
			ctrl.Move(x, y, maxWidth, h)
		}
		return this
	}

	/**
	 * Evenly distribute controls horizontally within a given width or container.
	 */
	static DistributeH(controls, containerOrWidth, y := unset) {
		if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
			throw ValueError("Align.DistributeH: controls must be a non-empty array", -1)
		local sumWidth := 0
		for _, ctrl in controls {
			ctrl.GetPos(,, &w)
			sumWidth += w
		}
		local totalWidth := 0
		if (containerOrWidth is Gui.Control || containerOrWidth is Gui) {
			containerOrWidth.GetPos(,, &totalWidth)
		} else {
			totalWidth := containerOrWidth
		}
		local spacing := 0
		if (controls.Length > 1)
			spacing := Floor((totalWidth - sumWidth) / (controls.Length - 1))
		else
			spacing := 0
		local x := 0
		for _, ctrl in controls {
			ctrl.GetPos(,, &w, &h)
			if IsSet(y)
				ctrl.Move(x, y, w, h)
			else
				ctrl.Move(x, , w, h)
			x += w + spacing
		}
		return this
	}

	/**
	 * Evenly distribute controls vertically within a given height or container.
	 */
	static DistributeV(controls, containerOrHeight, x := unset) {
		if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
			throw ValueError("Align.DistributeV: controls must be a non-empty array", -1)
		local sumHeight := 0
		for _, ctrl in controls {
			ctrl.GetPos(,,, &h)
			sumHeight += h
		}
		local totalHeight := 0
		if (containerOrHeight is Gui.Control || containerOrHeight is Gui) {
			containerOrHeight.GetPos(,,, &totalHeight)
		} else {
			totalHeight := containerOrHeight
		}
		local spacing := 0
		if (controls.Length > 1)
			spacing := Floor((totalHeight - sumHeight) / (controls.Length - 1))
		else
			spacing := 0
		local y := 0
		for _, ctrl in controls {
			ctrl.GetPos(,, &w, &h)
			if IsSet(x)
				ctrl.Move(x, y, w, h)
			else
				ctrl.Move(, y, w, h)
			y += h + spacing
		}
		return this
	}

	; --- Optionally: Add methods for grid/column/row layout ---
	/**
	 * Arrange controls in a grid within a container.
	 * @param {Array} controls Array of controls
	 * @param {Integer} columns Number of columns
	 * @param {Gui.Control|Gui} container Container to arrange within
	 * @param {Integer} hSpacing Horizontal spacing
	 * @param {Integer} vSpacing Vertical spacing
	 */
	static Grid(controls, columns, container := unset, hSpacing := 5, vSpacing := 5) {
		if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
			throw ValueError("Align.Grid: controls must be a non-empty array", -1)
		local x0 := 0, y0 := 0, cW := 0, cH := 0
		if IsSet(container) && (container is Gui.Control || container is Gui) {
			container.GetPos(&x0, &y0, &cW, &cH)
		}
		local rows := Ceil(controls.Length / columns)
		local maxW := 0, maxH := 0
		; Find max width/height for uniform grid
		for _, ctrl in controls {
			ctrl.GetPos(,, &w, &h)
			if (w > maxW)
				maxW := w
			if (h > maxH)
				maxH := h
		}
		for i, ctrl in controls {
			local col := Mod(i-1, columns)
			local row := Floor((i-1)/columns)
			local x := x0 + col * (maxW + hSpacing)
			local y := y0 + row * (maxH + vSpacing)
			ctrl.Move(x, y, maxW, maxH)
		}
		return this
	}

	/**
	 * Arrange controls in a horizontal toolbar row within a given area.
	 * @param {Array} controls Array of Gui.Control objects
	 * @param {Gui|Gui.Control} area The area to arrange within (e.g. toolbar background Text, or Gui)
	 * @param {String} align "center" (default), "left", or "right"
	 * @param {Integer} spacing Space between controls (default 5)
	 * @param {Integer} y Optional Y position (defaults to vertical center of area)
	 * @returns {Align} For chaining
	 */
	static ToolbarRow(controls, area, align := "center", spacing := 5, y := unset) {
		if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
			throw ValueError("Align.ToolbarRow: controls must be a non-empty array", -1)
		; Get area rectangle
		area.GetPos(&ax, &ay, &aw, &ah)
		; Calculate total width of controls + spacing
		totalWidth := 0
		for _, ctrl in controls {
			ctrl.GetPos(,, &w)
			totalWidth += w
		}
		totalWidth += spacing * (controls.Length - 1)
		; Determine starting X based on alignment
		switch align {
			case "center":
				x := ax + Floor((aw - totalWidth) / 2)
			case "left":
				x := ax
			case "right":
				x := ax + aw - totalWidth
			default:
				x := ax
		}
		; Determine Y
		if !IsSet(y) {
			; Vertically center in area
			controls[1].GetPos(,,, &h)
			y := ay + Floor((ah - h) / 2)
		}
		; Position controls
		for _, ctrl in controls {
			ctrl.GetPos(,, &w, &h)
			ctrl.Move(x, y, w, h)
			x += w + spacing
		}
		return this
	}

	/**
	 * Arrange controls in a vertical toolbar column within a given area.
	 * @param {Array} controls Array of Gui.Control objects
	 * @param {Gui|Gui.Control} area The area to arrange within
	 * @param {String} align "center" (default), "top", or "bottom"
	 * @param {Integer} spacing Space between controls (default 5)
	 * @param {Integer} x Optional X position (defaults to horizontal center of area)
	 * @returns {Align} For chaining
	 */
	static ToolbarColumn(controls, area, align := "center", spacing := 5, x := unset) {
		if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
			throw ValueError("Align.ToolbarColumn: controls must be a non-empty array", -1)
		area.GetPos(&ax, &ay, &aw, &ah)
		totalHeight := 0
		for _, ctrl in controls {
			ctrl.GetPos(,,, &h)
			totalHeight += h
		}
		totalHeight += spacing * (controls.Length - 1)
		switch align {
			case "center":
				y := ay + Floor((ah - totalHeight) / 2)
			case "top":
				y := ay
			case "bottom":
				y := ay + ah - totalHeight
			default:
				y := ay
		}
		if !IsSet(x) {
			controls[1].GetPos(,, &w)
			x := ax + Floor((aw - w) / 2)
		}
		for _, ctrl in controls {
			ctrl.GetPos(,, &w, &h)
			ctrl.Move(x, y, w, h)
			y += h + spacing
		}
		return this
	}

	/**
	 * Get the client rectangle of a Gui or control (Text, Picture, etc.)
	 * @param {Gui|Gui.Control} area
	 * @returns {Object} {x, y, w, h}
	 */
	static Area(area) {
		if (area is Gui) {
			area.GetClientPos(&x, &y, &w, &h)
			return {x: x, y: y, w: w, h: h}
		} else if (area is Gui.Control) {
			area.GetPos(&x, &y, &w, &h)
			return {x: x, y: y, w: w, h: h}
		} else {
			throw ValueError("Align.Area: area must be a Gui or Gui.Control", -1)
		}
	}

	/**
	 * Pack controls tightly in a row, left to right, with optional spacing.
	 * @param {Array} controls
	 * @param {Integer} x Starting X
	 * @param {Integer} y Y position
	 * @param {Integer} spacing Space between controls (default 5)
	 * @returns {Align}
	 */
	static PackRow(controls, x, y, spacing := 5) {
		for _, ctrl in controls {
			ctrl.GetPos(,, &w, &h)
			ctrl.Move(x, y, w, h)
			x += w + spacing
		}
		return this
	}

	/**
	 * @class ControlGroupLayout
	 * @description Advanced toolbar/group layout manager for Word-like toolbars
	 * @version 1.0.0
	 * @author OvercastBTC
	 * @date 2025-04-20
	 * @requires AutoHotkey v2.0+
	 *
	 * @example
	 * ; Define groups and controls
	 * toolbarGroups := [
	 *   {name: "Clipboard", controls: [btnSave, btnCut, btnCopy, btnPaste]},
	 *   {name: "Font", controls: [btnBold, btnItalic, btnUnderline, btnStrike, btnNormal]},
	 *   {name: "Paragraph", controls: [btnAlignLeft, btnAlignCenter, btnAlignRight, btnAlignJustify]},
	 *   {name: "OpenGroup", controls: [btnOpenGroup]}
	 * ]
	 * ControlGroupLayout.ArrangeToolbar(gui, toolbarArea, toolbarGroups)
	 */
	class ControlGroupLayout {
		/**
		 * @description Arrange toolbar groups and controls in a Word-like toolbar.
		 * @param {Gui} gui The parent Gui object.
		 * @param {Gui.Control} toolbarArea The area (Text, GroupArea, etc.) to arrange within.
		 * @param {Array} groups Array of group objects: {name, controls, [expandable]}.
		 * @param {Integer} spacing Space between groups (default 12).
		 * @param {Integer} controlSpacing Space between controls in a group (default 4).
		 * @returns {ControlGroupLayout} This instance for chaining.
		 */
		static ArrangeToolbar(gui, toolbarArea, groups, spacing := 12, controlSpacing := 4) {
			; Validate parameters
			if !(gui is Gui)
				throw TypeError("gui must be a Gui object", -1)
			if !(toolbarArea is Gui.Control)
				throw TypeError("toolbarArea must be a Gui.Control", -1)
			if !IsObject(groups) || groups.Length = 0
				throw ValueError("groups must be a non-empty array", -1)

			; Get toolbar area dimensions
			toolbarArea.GetPos(&areaX, &areaY, &areaW, &areaH)

			; Calculate group widths (expandable group gets extra space)
			groupWidths := []
			totalFixedWidth := 0
			expandableIdx := 0
			for idx, group in groups {
				; Calculate width of controls in group
				groupWidth := 0
				for ctrl in group.controls {
					ctrl.GetPos(,, &w)
					groupWidth += w
				}
				groupWidth += controlSpacing * (group.controls.Length - 1)
				groupWidths.Push(groupWidth)
				if group.HasProp("expandable") && group.expandable
					expandableIdx := idx
				else
					totalFixedWidth += groupWidth
			}
			totalSpacing := spacing * (groups.Length - 1)
			remainingWidth := areaW - totalFixedWidth - totalSpacing
			if expandableIdx && remainingWidth > 0
				groupWidths[expandableIdx] += remainingWidth

			; Arrange groups left-to-right
			x := areaX
			for idx, group in groups {
				y := areaY + Floor((areaH - 28) / 2)  ; Vertically center (assume 28px button height)
				groupWidth := groupWidths[idx]
				; Arrange controls in group
				ctrlX := x
				for ctrlIdx, ctrl in group.controls {
					ctrl.GetPos(,, &w, &h)
					ctrl.Move(ctrlX, y, w, h)
					ctrlX += w + controlSpacing
				}
				; Optionally add group label below (Word-style)
				if group.HasProp("name") && group.name {
					labelY := areaY + areaH - 16
					labelW := groupWidth
					gui.AddText(Format("x{1} y{2} w{3} Center", x, labelY, labelW), group.name)
				}
				x += groupWidth + spacing
			}
			return this
		}

		/**
		 * @description Create an "open group" button for expanding/collapsing a group.
		 * @param {Gui} gui The parent Gui object.
		 * @param {String} label Button label (default: "▼").
		 * @param {Func} onClick Callback for expanding/collapsing.
		 * @param {String} options Button options.
		 * @returns {Gui.Button} The created button.
		 */
		static CreateOpenGroupButton(gui, label := "▼", onClick := unset, options := "w24 h24") {
			btn := gui.AddButton(options, label)
			if IsSet(onClick)
				btn.OnEvent("Click", onClick)
			return btn
		}
	}

	; --- Window proxy for non-AHK windows (from original) ---
	__New(Hwnd) {
		this.Hwnd := Hwnd
	}
	GetPos(&X?, &Y?, &W?, &H?) {
		WinGetPos(&X, &Y, &W, &H, this.Hwnd)
	}
	Move(X?, Y?, W?, H?) {
		WinMove(X ?? unset, Y ?? unset, W ?? unset, H ?? unset, this.Hwnd)
	}
}
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ; @region RTFMsgBox
; /**
; * Enhanced message box with rich text support using Gui2.AddRichEdit
; */
; class RTFMsgBox {
; 	static Instances := Map()
; 	static InstanceCount := 0  ; Add counter for debugging

; 	; Default settings
; 	DefaultSettings := {
; 		Width: 400,
; 		MinHeight: 150,
; 		MaxHeight: 600,
; 		ButtonHeight: 30,
; 		MarginX: 20,
; 		MarginY: 15,
; 		Font: {
; 			Name: "Segoe UI",
; 			Size: 10
; 		},
; 		Colors: {
; 			Background: 0xFFFFFF,
; 			Text: 0x000000,
; 			Button: 0xF0F0F0
; 		}
; 	}

; 	; static rtfgui := this.rtfgui

; 	__New(text, title := "", options := "", owner := "") {

; 		; Debug output
; 		RTFMsgBox.InstanceCount += 1

; 		OutputDebug("RTFMsgBox instance created. Count: " RTFMsgBox.InstanceCount "`n")
; 		OutputDebug("Call stack: `n" this._GetCallStack() "`n")

; 		MB_TYPES := Map(
; 			"OK", ["OK"],
; 			"OKCancel", ["OK", "Cancel"],
; 			"YesNo", ["Yes", "No"],
; 			"YesNoCancel", ["Yes", "No", "Cancel"],
; 			"RetryCancel", ["Retry", "Cancel"],
; 			"AbortRetryIgnore", ["Abort", "Retry", "Ignore"]
; 		)

; 		; Create GUI
; 		title := (title ? title : "RTFMsgBox_" RTFMsgBox.InstanceCount)
; 		this.rtfGui := Gui("+Owner" (owner ? owner : "") " +AlwaysOnTop -MinimizeBox")
; 		this.rtfGui.Title := title
; 		this.rtfGui.BackColor := this.DefaultSettings.Colors.Background
; 		this.rtfGui.SetFont("s" this.DefaultSettings.Font.Size, this.DefaultSettings.Font.Name)

; 		; Parse options
; 		buttons := MB_TYPES["OK"]  ; Default buttons
; 		for type, btnSet in MB_TYPES {
; 			if InStr(options, type) {
; 				buttons := btnSet
; 				break
; 			}
; 		}

; 		; Calculate dimensions
; 		margin := this.DefaultSettings.MarginX
; 		width := this.DefaultSettings.Width
; 		editWidth := width - 2*margin

; 		; Add RichEdit using the enhanced method
; 		reOptions := Format("x{1} y{2} w{3} h{4}",
; 			margin,
; 			margin,
; 			editWidth,
; 			this.DefaultSettings.MinHeight
; 		)

; 		this.RE := this.rtfGui.AddRichEdit(,reOptions, text)
; 		this.RE.ReadOnly := true

; 		; Calculate heights
; 		textHeight := min(max(10, this.DefaultSettings.MinHeight), this.DefaultSettings.MaxHeight)

; 		; Add buttons
; 		buttonY := textHeight + margin
; 		buttonWidth := (width - (buttons.Length + 1)*margin) / buttons.Length

; 		for i, buttonText in buttons {
; 			x := margin + (i-1)*(buttonWidth + margin)
; 			btn := this.rtfGui.AddButton(Format("x{1} y{2} w{3} h{4}",
; 				x, buttonY, buttonWidth, this.DefaultSettings.ButtonHeight),
; 				buttonText)
; 			btn.OnEvent("Click", this.ButtonClick.Bind(this))
; 		}

; 		; Set up result storage
; 		this.Result := ""

; 		; Calculate final height
; 		height := buttonY + this.DefaultSettings.ButtonHeight + margin

; 		; Set window title
; 		this.rtfGui.Title := title

; 		; ; Store instance
; 		; RTFMsgBox.Instances[this.rtfGui.Hwnd] := this

; 		; Store instance with the unique identifier
; 		RTFMsgBox.Instances[this.rtfGui.Hwnd] := {
; 			instance: this,
; 			createTime: A_TickCount
; 		}

; 		; Show the window and return immediately if we already have another instance waiting
; 		if (RTFMsgBox.InstanceCount > 1) {
; 			OutputDebug("Multiple RTFMsgBox instances detected - check for duplicate calls`n")
; 		}

; 		; Show the window
; 		this.rtfGui.Show(Format("w{1} h{2} Center", width, height))

; 		; Wait for result
; 		while !this.Result {
; 			Sleep(10)
; 		}

; 		return this.Result
; 		; return this
; 	}

; 	_Cleanup() {
; 		RTFMsgBox.InstanceCount--
; 		RTFMsgBox.Instances.Delete(this.rtfGui.Hwnd)
; 		OutputDebug("RTFMsgBox instance destroyed. Remaining count: " RTFMsgBox.InstanceCount "`n")
; 	}

; 	ButtonClick(GuiCtrl, *) {
; 		this.Result := GuiCtrl.Text
; 		this.rtfGui.Destroy()
; 	}

; 	static Show(text, title := "", options := "", owner := "") {
; 		return RTFMsgBox(text, title, options, owner)
; 	}

; 	/**
; 	 * @description Gets a simple call stack for debugging
; 	 * @returns {String} Call stack information
; 	 */
; 	_GetCallStack() {
; 		try {
; 			; Complex call stack with detailed information
; 			stack := []

; 			; Get current script info
; 			stack.Push(Format("Current: {1}:{2}", A_LineFile, A_LineNumber))

; 			; Try to get more detailed stack information
; 			try {
; 				; Create a temporary error to capture stack trace
; 				throw Error("Stack trace", -1)
; 			} catch Error as e {
; 				if (e.HasProp("Stack") && e.Stack) {
; 					stackLines := StrSplit(e.Stack, "`n")
; 					for line in stackLines {
; 						if (line && !InStr(line, "_GetCallStack")) {
; 							stack.Push(line)
; 						}
; 					}
; 				}
; 			}

; 			; Add process and thread information
; 			stack.Push(Format("Process: {1} (PID: {2})", A_ScriptName, DllCall("GetCurrentProcessId")))
; 			stack.Push(Format("Thread: {1}", DllCall("GetCurrentThreadId")))

; 			; Add timing information
; 			stack.Push(Format("Tick Count: {1}", A_TickCount))
; 			stack.Push(Format("Time: {1}", FormatTime(, "yyyy-MM-dd HH:mm:ss.fff")))

; 			; Add memory information
; 			try {
; 				VarSetStrCapacity(&memInfo, 64)
; 				if (DllCall("kernel32\GetProcessMemoryInfo", "Ptr", DllCall("GetCurrentProcess"), "Ptr", &memInfo, "UInt", 64)) {
; 					workingSet := NumGet(memInfo, 12, "UInt")
; 					stack.Push(Format("Working Set: {1} KB", Round(workingSet / 1024)))
; 				}
; 			}

; 			; Add AutoHotkey version and system info
; 			stack.Push(Format("AHK Version: {1}", A_AhkVersion))
; 			stack.Push(Format("OS Version: {1}", A_OSVersion))
; 			stack.Push(Format("Is 64-bit: {1}", A_Is64bitOS))

; 			; Add script execution context
; 			stack.Push(Format("Script Dir: {1}", A_ScriptDir))
; 			stack.Push(Format("Working Dir: {1}", A_WorkingDir))
; 			stack.Push(Format("User: {1}@{2}", A_UserName, A_ComputerName))

; 			; Add instance tracking information
; 			stack.Push(Format("RTFMsgBox Instances: {1}", RTFMsgBox.InstanceCount))
; 			stack.Push(Format("Active GUIs: {1}", RTFMsgBox.Instances.Count))

; 			; Check for potential recursion or multiple calls
; 			if (RTFMsgBox.InstanceCount > 1) {
; 				stack.Push("⚠️ WARNING: Multiple RTFMsgBox instances detected!")
; 				stack.Push("This may indicate recursive calls or memory leaks.")
; 			}

; 			; Add caller analysis
; 			try {
; 				; Analyze the stack to find the actual caller
; 				callerInfo := this._AnalyzeCaller()
; 				if (callerInfo) {
; 					stack.Push("Caller Analysis:")
; 					stack.Push("  " . callerInfo)
; 				}
; 			}

; 			return stack.ToStr("`n")
; 		} catch {
; 			return "Call stack unavailable"
; 		}
; 	}
; }
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region Class StackedDisplay
class StackedDisplay {
	width := A_ScreenWidth/3
	topMargin := A_ScreenHeight/2
	stackMargin := 30

	guiSD := []
	selected := false
	result := 0

	__New() {
		this.guiSD := []
	}

	/**
		* Adds an option to the stacked display
		* @param {String} text The text to display
		* @param {Integer} value The value to return if selected
		* @param {Integer} index Position in stack (1-based)
		* @returns {Gui} The created GUI object
		*/
	AddOption(text, value, index) {
		guiObj := Gui("+AlwaysOnTop -Caption +ToolWindow")
		guiObj.SetFont("s10", "Segoe UI")
		guiObj.AddText("x10 y5", text)

		; Store data
		guiObj.value := value

		; Calculate position
		y := this.topMargin + (index-1)*this.stackMargin
		guiObj.Show(Format("y{1} w{2}", y, this.width))

		; Add to tracking
		this.guiSD.Push(guiObj)

		; Setup hotkey
		this.SetupHotkeys(guiObj, index)

		return guiObj
	}

	SetupHotkeys(guiObj, index) {
		; F-key hotkey
		HotIfWinExist("ahk_id " guiObj.Hwnd)
		Hotkey("F" index, this.HandleSelection.Bind(this, guiObj))

		; Click handler (using ContextMenu for general window clicks)
		guiObj.OnEvent("ContextMenu", this.HandleSelection.Bind(this, guiObj))
	}

	HandleSelection(guiObj, *) {
		this.selected := true
		this.result := guiObj.value
		this.CleanupGuis()
	}

	WaitForSelection(timeout := 0) {
		startTime := A_TickCount
		while !this.selected {
			if (timeout && (A_TickCount - startTime > timeout)) {
				this.CleanupGuis()
				return 0
			}
			Sleep(10)
		}
		return this.result
	}

	CleanupGuis() {
		for guiObj in this.guiSD
			guiObj.Destroy()
		this.guis := []
	}

	__Delete() {
		this.CleanupGuis()
	}
}
; --------------------------------------------------------------------------
; @region trayNotify
trayNotify(title, message, options := 0) {
	TrayTip(message, title, options)
}

; ;No dependencies

; ;----------------------------------------------------------------------------------------------
; ; 									Theme
; ;----------------------------------------------------------------------------------------------
; DarkMode(guiObj) {
; 	guiObj.BackColor := ThemeMgr.theme["Background_Color"] ; Brand Palette => Stone 20
; 	return guiObj
; }
; Gui.Prototype.DefineProp("DarkMode", {Call: DarkMode})

; MakeFontNicer(guiObj, fontSize := 22) {
; 	guiObj.SetFont("s" fontSize " c" ThemeMgr.theme["Text_Color"], "Aptos") ; Brand Palette => Steel 70
; 	return guiObj
; }

; ; ;----------------------------------------------------------------------------------------------
; ; ; 									Light Mode Theme
; ; ;----------------------------------------------------------------------------------------------
; ; DarkMode(guiObj) {
; ; 	guiObj.BackColor := "f2f0e9" ; Brand Palette => Stone 20
; ; 	return guiObj
; ; }
; ; Gui.Prototype.DefineProp("DarkMode", {Call: DarkMode})

; ; MakeFontNicer(guiObj, fontSize := 22) {
; ; 	guiObj.SetFont("s" fontSize " c0d102b", "Aptos") ; Brand Palette => Steel 70
; ; 	return guiObj
; ; }

; ; ;----------------------------------------------------------------------------------------------
; ; ; 									Dark Mode Theme
; ; ;----------------------------------------------------------------------------------------------
; ; DarkMode(guiObj) {
; ; 	guiObj.BackColor := "0d102b" ; Brand Palette => Steel 70
; ; 	return guiObj
; ; }
; ; Gui.Prototype.DefineProp("DarkMode", {Call: DarkMode})

; ; MakeFontNicer(guiObj, fontSize := 22) {
; ; 	guiObj.SetFont("s" fontSize " ce9e6db", "Aptos") ; Brand Palette => Stone 30
; ; 	return guiObj
; ; }

; Gui.Prototype.DefineProp("MakeFontNicer", {Call: MakeFontNicer})

; PressTitleBar(guiObj) {
; 	PostMessage(0xA1, 2,,, guiObj)
; 	return guiObj
; }
; Gui.Prototype.DefineProp("PressTitleBar", {Call: PressTitleBar})

; NeverFocusWindow(guiObj) {
; 	WinSetExStyle("0x08000000L", guiObj)
; 	return guiObj
; }
; Gui.Prototype.DefineProp("NeverFocusWindow", {Call: NeverFocusWindow})

; MakeClickthrough(guiObj) {
; 	WinSetTransparent(255, guiObj)
; 	guiObj.Opt("+E0x20")
; 	return guiObj
; }
; Gui.Prototype.DefineProp("MakeClickthrough", {Call: MakeClickthrough})
