/**
 * @fileoverview Unified Theme Management System
 * @description Comprehensive theme management with color utilities, Windows theme detection, and GUI theming
 * @class ThemeMgr
 * @version 2.1.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-11-04
 * @requires AutoHotkey v2.0+
 * @link {@link file://./ThemeMgr.ahk}
 */
#Requires AutoHotkey v2+
#SingleInstance Force

#Include <Extensions/.formats/JSONS>
#Include <System/Paths>
#Include <Utilities/TestLogger>

; Create singleton TestLogger instance for ThemeMgr
; This will be shared by all scripts that include ThemeMgr
themeLogger := TestLogger(A_LineFile)
if !WinExist('Theme') {
	; themeLogger.Enable
}
else {
	themeLogger.SetState("Complete")
}
class ThemeMgr {
	; -----------------------------------------------------------------------
	; @region Core Configuration
	static ThemeJsonPath := Paths.UserData "\Theme.json"
	static thememap := JSONS.Parse(FileRead(this.ThemeJsonPath, 'UTF-8-RAW'))
	
	; Initialize ObjectSettings if not present in loaded JSON
	static _InitializeObjectSettings() {
		themeLogger.Log("ThemeMgr", "Initializing ObjectSettings...")
		
		if !this.thememap.Has("ObjectSettings") {
			themeLogger.Log("ThemeMgr", "ObjectSettings not found in JSON - creating defaults")
			this.thememap["ObjectSettings"] := Map(
				"General", Map("UseSystemTheme", true, "Theme", "Auto"),
				"Omnibar", Map("OverrideGeneral", false, "Theme", "DarkMode"),
				"Infos", Map("OverrideGeneral", false, "Theme", "DarkMode"),
				"HSM", Map("OverrideGeneral", false, "Theme", "LightMode"),
				"RecLib", Map("OverrideGeneral", false, "Theme", "DarkMode"),
				"NotesLib", Map("OverrideGeneral", false, "Theme", "DarkMode"),
				"LinksLib", Map("OverrideGeneral", false, "Theme", "DarkMode"),
				"Polaris", Map("OverrideGeneral", false, "Theme", "DarkMode"),
				"TestLogger", Map("OverrideGeneral", false, "Theme", "DarkMode")
			)
			; Save the initialized settings
			this.WriteThemeJson()
			themeLogger.Log("ThemeMgr", "ObjectSettings created and saved to JSON")
		} else {
			themeLogger.Log("ThemeMgr", "ObjectSettings loaded from JSON successfully")
			
			; Check if Polaris and TestLogger exist, add them if missing
			objectSettings := this.thememap["ObjectSettings"]
			needsSave := false
			
			if !objectSettings.Has("Polaris") {
				objectSettings["Polaris"] := Map("OverrideGeneral", false, "Theme", "DarkMode")
				themeLogger.Log("ThemeMgr", "Added missing Polaris object settings")
				needsSave := true
			}
			
			if !objectSettings.Has("TestLogger") {
				objectSettings["TestLogger"] := Map("OverrideGeneral", false, "Theme", "DarkMode")
				themeLogger.Log("ThemeMgr", "Added missing TestLogger object settings")
				needsSave := true
			}
			
			if needsSave {
				this.WriteThemeJson()
				themeLogger.Log("ThemeMgr", "Updated ObjectSettings saved to JSON")
			}
		}
		return true
	}
	static _ObjectSettingsInitialized := ThemeMgr._InitializeObjectSettings()
	
	; Determine current theme name from loaded settings
	static CurrentThemeName := ThemeMgr._InitializeCurrentTheme()
	
	/**
	 * @static
	 * @method _InitializeCurrentTheme
	 * @description Initialize current theme name from loaded JSON settings
	 * @returns {String} Theme name ("Light" or "Dark")
	 * @private
	 */
	static _InitializeCurrentTheme() {
		themeLogger.Log("ThemeMgr", "Determining current theme from settings...")
		
		try {
			; Check if ObjectSettings exists and has General settings
			if this.thememap.Has("ObjectSettings") && this.thememap["ObjectSettings"].Has("General") {
				generalSettings := this.thememap["ObjectSettings"]["General"]
				
				if generalSettings["UseSystemTheme"] {
					; Detect from system
					detectedTheme := this.DetectSystemTheme()
					themeLogger.Log("ThemeMgr", "Using system theme: " detectedTheme)
					return detectedTheme
				} else {
					; Use saved theme preference
					savedTheme := generalSettings.Get("Theme", "Auto")
					resolvedTheme := savedTheme == "Dark" ? "Dark" : "Light"
					themeLogger.Log("ThemeMgr", "Using saved theme: " savedTheme " -> " resolvedTheme)
					return resolvedTheme
				}
			}
			
			; Fallback: check legacy Text_Color to determine theme
			if this.thememap.Has("Text_Color") {
				textColor := this.thememap["Text_Color"]
				; Light text = dark theme, dark text = light theme
				legacyTheme := (textColor == "f2f0e9") ? "Dark" : "Light"
				themeLogger.Log("ThemeMgr", "Using legacy Text_Color to determine theme: " legacyTheme)
				return legacyTheme
			}
		} catch as err {
			; If any error, default to Light
			themeLogger.Error("ThemeMgr", "Error determining theme: " err.Message)
		}
		
		themeLogger.Log("ThemeMgr", "Defaulting to Light theme (final fallback)")
		return "Light"  ; Final fallback
	}
	; @endregion Core Configuration

	; -----------------------------------------------------------------------
	; @region Windows UxTheme Integration
	/**
	 * @static
	 * @method DetectSystemTheme
	 * @description Detects Windows system theme (Light/Dark mode)
	 * @returns {String} "Dark" or "Light"
	 */
	static DetectSystemTheme() {
		try {
			; Check Windows Registry for dark mode setting
			AppsUseLightTheme := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
			return AppsUseLightTheme ? "Light" : "Dark"
		} catch {
			; Default to Light if detection fails
			return "Light"
		}
	}

	/**
	 * @static
	 * @method IsSystemDarkMode
	 * @description Check if Windows is in dark mode
	 * @returns {Boolean} True if dark mode is active
	 */
	static IsSystemDarkMode() {
		return this.DetectSystemTheme() == "Dark"
	}

	/**
	 * @static
	 * @method ApplySystemTheme
	 * @description Auto-apply theme based on Windows system settings
	 * @param {Gui} gui - GUI object to theme (optional)
	 * @returns {String} Applied theme name
	 */
	static ApplySystemTheme(guiObj?) {
		themeName := this.DetectSystemTheme()
		this.CurrentThemeName := themeName
		
		if IsSet(guiObj) {
			this.GuiColors.ApplyTheme(guiObj, themeName == "Dark" ? "DarkMode" : "LightMode")
		}
		
		; Update JSON storage
		colors := themeName == "Dark" 
			? {Text: "f2f0e9", Background: "0d102b"} 
			: {Text: "0d102b", Background: "f2f0e9"}
		
		this.thememap.Set("Text_Color", colors.Text, "Background_Color", colors.Background)
		this.WriteThemeJson()
		
		return themeName
	}
	; @endregion Windows UxTheme Integration

	; -----------------------------------------------------------------------
	; @region File I/O
	static WriteThemeJson() {
		fileObj := FileOpen(this.ThemeJsonPath, "w", "UTF-8-RAW")
		fileObj.Write(JSONS.Stringify(this.thememap))
		fileObj.Close()
	}
	; @endregion File I/O

	; -----------------------------------------------------------------------
	; @region GUI Theme Selector
	/**
	 * @static
	 * @method GUI_Theme
	 * @description Opens comprehensive theme settings GUI with object-specific configuration
	 * @param {String} [startTab="General"] - Which tab to show initially (General, Omnibar, Infos, HSM, RecLib, NotesLib, LinksLib)
	 * @example
	 * ThemeMgr.GUI_Theme()           ; Open to General tab
	 * ThemeMgr.GUI_Theme("Omnibar")  ; Open to Omnibar-specific settings
	 */
	static GUI_Theme(startTab := "General") {
		; Create main GUI with tab control
		myGui := Gui(, "Theme Manager - Application Settings")
		myGui.Opt("AlwaysOnTop")
		myGui.SetFont("s11")
		
		; Detect current system theme
		systemTheme := this.DetectSystemTheme()
		currentIsLight := this.CurrentThemeName == "Light"
		
		; ObjectSettings are now guaranteed to exist from class initialization
		objectSettings := this.thememap["ObjectSettings"]
		
		; Debug: Output current settings to verify they're loading
		OutputDebug("`n=== Theme Manager GUI Opening ===")
		OutputDebug("Current Theme: " this.CurrentThemeName)
		for objName in ["General", "Omnibar", "Infos", "HSM", "RecLib", "NotesLib", "LinksLib"] {
			if objectSettings.Has(objName) {
				settings := objectSettings[objName]
				if objName == "General" {
					OutputDebug(objName ": UseSystemTheme=" settings["UseSystemTheme"] ", Theme=" settings["Theme"])
				} else {
					OutputDebug(objName ": Override=" settings["OverrideGeneral"] ", Theme=" settings["Theme"])
				}
			}
		}
		
		; Create Tab control with increased height for new color selection controls
		tabControl := myGui.AddTab3("w600 h550", ["General", "Omnibar (CleanInputBox)", "Infos", "HSM", "Rec Library", "Notes Library", "Links Library", "Polaris", "TestLogger"])
		
		; ===================================================================
		; @region General Tab
		; ===================================================================
		tabControl.UseTab("General")
		
		myGui.AddText("x20 y+15 w560", "These settings apply to all GUI elements unless overridden by object-specific settings below.")
		myGui.AddText("x20 y+10 w560", "Current System Theme: " systemTheme)
		
		myGui.AddGroupBox("x20 y+15 w560 h120", "Global Theme Settings")
		myGui.AddRadio("vRadioLightTheme x30 y+10" (currentIsLight && !objectSettings["General"]["UseSystemTheme"] ? " Checked" : ""), "Light Theme")
		myGui.AddRadio("vRadioDarkTheme x30 y+5" (!currentIsLight && !objectSettings["General"]["UseSystemTheme"] ? " Checked" : ""), "Dark Theme")
		myGui.AddRadio("vRadioAutoTheme x30 y+5" (objectSettings["General"]["UseSystemTheme"] ? " Checked" : ""), "Auto (Follow Windows System Theme)")
		
		myGui.AddText("x20 y+25 w560", "Note: Object-specific overrides take precedence over the global theme.")
		; @endregion General Tab
		
		; ===================================================================
		; @region Omnibar Tab
		; ===================================================================
		tabControl.UseTab("Omnibar (CleanInputBox)")
		
		this._CreateObjectSettingsTab(myGui, "Omnibar", "Omnibar / CleanInputBox", 
			"Controls the theme for the Omnibar search/input box. The Omnibar can be triggered with CapsLock or CapsLock+Space depending on your user settings (configurable via tray menu).")
		; @endregion Omnibar Tab
		
		; ===================================================================
		; @region Infos Tab
		; ===================================================================
		tabControl.UseTab("Infos")
		
		this._CreateObjectSettingsTab(myGui, "Infos", "Info Notifications", 
			"Controls the theme for temporary info/notification windows.")
		; @endregion Infos Tab
		
		; ===================================================================
		; @region HSM Tab
		; ===================================================================
		tabControl.UseTab("HSM")
		
		this._CreateObjectSettingsTab(myGui, "HSM", "Hotstring Manager", 
			"Controls the theme for the Hotstring Manager GUI.")
		; @endregion HSM Tab
		
		; ===================================================================
		; @region Recommendation Library Tab
		; ===================================================================
		tabControl.UseTab("Rec Library")
		
		this._CreateObjectSettingsTab(myGui, "RecLib", "Recommendation Library", 
			"Controls the theme for the Recommendation Library management interface.")
		; @endregion Recommendation Library Tab
		
		; ===================================================================
		; @region Notes Library Tab
		; ===================================================================
		tabControl.UseTab("Notes Library")
		
		this._CreateObjectSettingsTab(myGui, "NotesLib", "Notes Library", 
			"Controls the theme for the Notes Library management interface.")
		; @endregion Notes Library Tab
		
		; ===================================================================
		; @region Links Library Tab
		; ===================================================================
		tabControl.UseTab("Links Library")
		
		this._CreateObjectSettingsTab(myGui, "LinksLib", "Links Library", 
			"Controls the theme for the Links Library management interface.")
		; @endregion Links Library Tab
		
		; ===================================================================
		; @region Polaris Tab
		; ===================================================================
		tabControl.UseTab("Polaris")
		
		this._CreateObjectSettingsTab(myGui, "Polaris", "Polaris (FM App)", 
			"Controls the theme for Polaris location management GUIs.")
		; @endregion Polaris Tab
		
		; ===================================================================
		; @region TestLogger Tab
		; ===================================================================
		tabControl.UseTab("TestLogger")
		
		this._CreateObjectSettingsTab(myGui, "TestLogger", "Test Logger", 
			"Controls the theme for the Test Logger diagnostic GUI.")
		; @endregion TestLogger Tab
		
		; Finish tab setup
		tabControl.UseTab()
		
		; Add action buttons at bottom (buttons will be at y~570 after tab control)
		myGui.AddButton("x20 y+20 w280 h35 +default", "&Save All Settings").OnEvent("Click", ClickedSave)
		myGui.AddButton("x+20 w280 h35", "&Cancel").OnEvent("Click", ClickedCancel)
		
		; Show the GUI with the requested starting tab
		if startTab != "General" {
			tabNames := ["General", "Omnibar (CleanInputBox)", "Infos", "HSM", "Rec Library", "Notes Library", "Links Library", "Polaris", "TestLogger"]
			for index, name in tabNames {
				if InStr(name, startTab) {
					tabControl.Choose(index)
					break
				}
			}
		}
		
		myGui.Show("w640 h650")
		
		; ===================================================================
		; @region Event Handlers
		; ===================================================================
		ClickedSave(*) {
			saved := myGui.Submit()
			
			; Save General settings
			if saved.RadioAutoTheme {
				objectSettings["General"]["UseSystemTheme"] := true
				objectSettings["General"]["Theme"] := "Auto"
				this.ApplySystemTheme()
			} else if saved.RadioDarkTheme {
				objectSettings["General"]["UseSystemTheme"] := false
				objectSettings["General"]["Theme"] := "Dark"
				this.CurrentThemeName := "Dark"
				this.thememap.Set("Text_Color", "f2f0e9", "Background_Color", "0d102b")
			} else {
				objectSettings["General"]["UseSystemTheme"] := false
				objectSettings["General"]["Theme"] := "Light"
				this.CurrentThemeName := "Light"
				this.thememap.Set("Text_Color", "0d102b", "Background_Color", "f2f0e9")
			}
			
			; Save object-specific settings (including custom colors)
			for objName in ["Omnibar", "Infos", "HSM", "RecLib", "NotesLib", "LinksLib", "Polaris", "TestLogger"] {
				checkboxName := "vOverride" objName
				themeName := "vTheme" objName
				
				if saved.HasOwnProp(checkboxName) {
					objectSettings[objName]["OverrideGeneral"] := saved.%checkboxName%
				}
				if saved.HasOwnProp(themeName) {
					; Convert DDL index to theme name
					themeNames := ["DarkMode", "LightMode", "HighContrast", "SoftDark", "SoftLight", "BlueTheme", "GreenTheme", "SepiaTheme"]
					objectSettings[objName]["Theme"] := themeNames[saved.%themeName%]
				}
			}
			
			; Write updated settings to JSON
			this.thememap["ObjectSettings"] := objectSettings
			this.WriteThemeJson()
			
			try {
				Infos("Theme settings saved. Application will reload to apply changes.", 2000)
			} catch {
				MsgBox("Theme settings saved. Application will reload to apply changes.", "Theme Manager")
			}
			
			myGui.Destroy()
			Sleep(2000)
			Reload()
		}
		
		ClickedCancel(*) {
			myGui.Destroy()
		}
		; @endregion Event Handlers
	}
	
	/**
	 * @static
	 * @method _CreateObjectSettingsTab
	 * @description Helper to create consistent object-specific settings tabs
	 * @param {Gui} gui - The GUI object
	 * @param {String} objKey - The object key in settings (e.g., "Omnibar")
	 * @param {String} displayName - User-friendly display name
	 * @param {String} description - Description of what this object is
	 * @private
	 */
	static _CreateObjectSettingsTab(gui, objKey, displayName, description) {
		objectSettings := this.thememap["ObjectSettings"]
		currentOverride := objectSettings[objKey]["OverrideGeneral"]
		currentTheme := objectSettings[objKey]["Theme"]
		
		; Convert theme name to DDL index
		themeNames := ["DarkMode", "LightMode", "HighContrast", "SoftDark", "SoftLight", "BlueTheme", "GreenTheme", "SepiaTheme"]
		themeIndex := 1
		for index, name in themeNames {
			if name == currentTheme {
				themeIndex := index
				break
			}
		}
		
		gui.AddText("x20 y+15 w560", description)
		
		gui.AddGroupBox("x20 y+15 w560 h500", displayName " Theme Settings")
		
		; Override checkbox
		overrideCheckbox := gui.AddCheckbox("vOverride" objKey " x30 y+10" (currentOverride ? " Checked" : ""), 
			"Override Global Theme (use " displayName "-specific theme)")
		
		; Theme dropdown (Pre-assigned themes)
		gui.AddText("x30 y+15", "Preset Theme:")
		themeDropdown := gui.AddDropDownList("vTheme" objKey " x+10 w200 Choose" themeIndex (currentOverride ? "" : " Disabled"), 
			["Dark Mode", "Light Mode", "High Contrast", "Soft Dark", "Soft Light", "Blue Theme", "Green Theme", "Sepia Theme"])
		
		; Enable/disable dropdown based on checkbox and update preview
		overrideCheckbox.OnEvent("Click", (*) => (
			themeDropdown.Enabled := overrideCheckbox.Value,
			this._UpdateTabPreview(objKey, themeDropdown, overrideCheckbox, gui)
		))
		themeDropdown.OnEvent("Change", (*) => this._UpdateTabPreview(objKey, themeDropdown, overrideCheckbox, gui))
		
		; Get effective theme for display
		effectiveTheme := currentOverride ? currentTheme : (this.CurrentThemeName == "Dark" ? "DarkMode" : "LightMode")
		
		; Get colors from the theme object
		if this.GuiColors.Themes.HasOwnProp(effectiveTheme) {
			themeObj := this.GuiColors.Themes.%effectiveTheme%
		} else {
			; Fallback to safe defaults
			themeObj := this.GuiColors.Themes.DarkMode
		}
		
		; ===================================================================
		; @region Individual Color Component Selection
		; ===================================================================
		gui.AddGroupBox("x30 y+20 w530 h160", "Customize Individual Colors (Optional)")
		gui.AddText("x40 y+10 w510", "Override specific color components below. Leave blank to use preset theme colors.")
		
		; Create compact 2-column layout for color selections
		leftCol := 40
		rightCol := 300
		rowHeight := 25
		startY := 315  ; Fixed Y position for color inputs
		
		; Background Color
		gui.AddText("x" leftCol " y" startY " w120", "Background:")
		gui.AddEdit("vBgColor" objKey " x+5 w100 h20", themeObj.Background)
		gui.AddButton("x+5 w60 h20", "Pick...").OnEvent("Click", (*) => this._ShowColorPicker(gui, "BgColor" objKey, objKey))
		
		; Text Color
		gui.AddText("x" rightCol " y" startY " w80", "Text:")
		gui.AddEdit("vTextColor" objKey " x+5 w100 h20", themeObj.Text)
		gui.AddButton("x+5 w60 h20", "Pick...").OnEvent("Click", (*) => this._ShowColorPicker(gui, "TextColor" objKey, objKey))
		
		; Selection Color
		gui.AddText("x" leftCol " y" (startY + rowHeight) " w120", "Selection:")
		gui.AddEdit("vSelColor" objKey " x+5 w100 h20", themeObj.Selection)
		gui.AddButton("x+5 w60 h20", "Pick...").OnEvent("Click", (*) => this._ShowColorPicker(gui, "SelColor" objKey, objKey))
		
		; Button Color
		gui.AddText("x" rightCol " y" (startY + rowHeight) " w80", "Button:")
		gui.AddEdit("vButtonColor" objKey " x+5 w100 h20", themeObj.Button)
		gui.AddButton("x+5 w60 h20", "Pick...").OnEvent("Click", (*) => this._ShowColorPicker(gui, "ButtonColor" objKey, objKey))
		
		; ButtonText Color
		gui.AddText("x" leftCol " y" (startY + rowHeight * 2) " w120", "Button Text:")
		gui.AddEdit("vButtonTextColor" objKey " x+5 w100 h20", themeObj.ButtonText)
		gui.AddButton("x+5 w60 h20", "Pick...").OnEvent("Click", (*) => this._ShowColorPicker(gui, "ButtonTextColor" objKey, objKey))
		
		; Border Color
		gui.AddText("x" rightCol " y" (startY + rowHeight * 2) " w80", "Border:")
		gui.AddEdit("vBorderColor" objKey " x+5 w100 h20", themeObj.Border)
		gui.AddButton("x+5 w60 h20", "Pick...").OnEvent("Click", (*) => this._ShowColorPicker(gui, "BorderColor" objKey, objKey))
		
		; Reset to Preset button
		gui.AddButton("x" leftCol " y" (startY + rowHeight * 3 + 5) " w150 h25", "Reset to Preset").OnEvent("Click", (*) => this._ResetColorsToPreset(objKey, themeDropdown, gui))
		; @endregion Individual Color Component Selection
		
		; Live Preview area with actual themed colors
		gui.AddGroupBox("x30 y+20 w530 h130", "Live Preview")
		
		; Create preview container with theme colors
		previewContainer := gui.AddText("vPreviewBg" objKey " x40 y+10 w510 h100 +0x201 Background" themeObj.Background)
		previewText := gui.AddText("vPreviewText" objKey " x50 yp+15 w490 h70 c" themeObj.Text " BackgroundTrans", 
			"Sample text in " displayName " theme`n`nThis shows how your " displayName " interface will appear with the selected colors.")
	}
	
	/**
	 * @static
	 * @method _UpdateTabPreview
	 * @description Updates the preview area when theme settings change in a tab
	 * @param {String} objKey - Object key (Omnibar, Infos, etc.)
	 * @param {GuiControl} themeDropdown - The theme dropdown control
	 * @param {GuiControl} overrideCheckbox - The override checkbox control
	 * @param {Gui} gui - The GUI object
	 * @private
	 */
	static _UpdateTabPreview(objKey, themeDropdown, overrideCheckbox, gui) {
		; Get selected theme
		themeNames := ["DarkMode", "LightMode", "HighContrast", "SoftDark", "SoftLight", "BlueTheme", "GreenTheme", "SepiaTheme"]
		selectedTheme := themeNames[themeDropdown.Value]
		
		; Determine effective theme
		effectiveTheme := overrideCheckbox.Value ? selectedTheme : (this.CurrentThemeName == "Dark" ? "DarkMode" : "LightMode")
		
		; Get colors from the theme object (check for custom colors first)
		if this.GuiColors.Themes.HasOwnProp(effectiveTheme) {
			themeObj := this.GuiColors.Themes.%effectiveTheme%
			
			; Check for custom overrides in edit fields
			try {
				bgEdit := gui["BgColor" objKey]
				textEdit := gui["TextColor" objKey]
				bgColor := bgEdit.Value != "" ? bgEdit.Value : themeObj.Background
				textColor := textEdit.Value != "" ? textEdit.Value : themeObj.Text
			} catch {
				bgColor := themeObj.Background
				textColor := themeObj.Text
			}
		} else {
			; Fallback to safe defaults
			textColor := "D4D4D4"
			bgColor := "1E1E1E"
		}
		
		; Update preview background
		try {
			previewBg := gui["PreviewBg" objKey]
			previewBg.Opt("Background" bgColor)
		}
		
		; Update preview text
		try {
			previewText := gui["PreviewText" objKey]
			previewText.Opt("c" textColor)
			; Force redraw
			gui.Show()
		}
	}
	
	/**
	 * @static
	 * @method _ShowColorPicker
	 * @description Shows a basic color picker (placeholder for future enhancement)
	 * @param {Gui} gui - The GUI object
	 * @param {String} editControlName - Name of the edit control to update
	 * @param {String} objKey - Object key for preview update
	 * @private
	 */
	static _ShowColorPicker(gui, editControlName, objKey) {
		; For now, use InputBox - can be enhanced with a full color picker later
		try {
			currentColor := gui[editControlName].Value
			result := InputBox("Enter hex color code (without #):`nExample: 1E1E1E or D4D4D4", "Color Picker", "w300 h150", currentColor)
			
			if result.Result != "Cancel" && result.Value != "" {
				; Validate hex color (6 characters, valid hex)
				if RegExMatch(result.Value, "^[0-9A-Fa-f]{6}$") {
					gui[editControlName].Value := result.Value
					; Update preview
					; Note: Would need to pass themeDropdown and checkbox references for full preview update
				} else {
					MsgBox("Invalid hex color code. Please use 6 hexadecimal characters (0-9, A-F).", "Invalid Color")
				}
			}
		}
	}
	
	/**
	 * @static
	 * @method _ResetColorsToPreset
	 * @description Resets custom colors to the selected preset theme
	 * @param {String} objKey - Object key (Omnibar, Infos, etc.)
	 * @param {GuiControl} themeDropdown - The theme dropdown control
	 * @param {Gui} gui - The GUI object
	 * @private
	 */
	static _ResetColorsToPreset(objKey, themeDropdown, gui) {
		; Get selected theme
		themeNames := ["DarkMode", "LightMode", "HighContrast", "SoftDark", "SoftLight", "BlueTheme", "GreenTheme", "SepiaTheme"]
		selectedTheme := themeNames[themeDropdown.Value]
		
		; Get colors from the theme object
		if this.GuiColors.Themes.HasOwnProp(selectedTheme) {
			themeObj := this.GuiColors.Themes.%selectedTheme%
			
			; Reset all color edit fields to preset values
			try gui["BgColor" objKey].Value := themeObj.Background
			try gui["TextColor" objKey].Value := themeObj.Text
			try gui["SelColor" objKey].Value := themeObj.Selection
			try gui["ButtonColor" objKey].Value := themeObj.Button
			try gui["ButtonTextColor" objKey].Value := themeObj.ButtonText
			try gui["BorderColor" objKey].Value := themeObj.Border
			
			; Update preview
			try {
				previewBg := gui["PreviewBg" objKey]
				previewBg.Opt("Background" themeObj.Background)
				previewText := gui["PreviewText" objKey]
				previewText.Opt("c" themeObj.Text)
				gui.Show()
			}
		}
	}
	
	/**
	 * @static
	 * @method GetObjectTheme
	 * @description Gets the effective theme for a specific object
	 * @param {String} objectName - Name of the object (Omnibar, Infos, HSM, RecLib, NotesLib, LinksLib)
	 * @returns {String} Theme name to use (DarkMode, LightMode, etc.)
	 * @example
	 * theme := ThemeMgr.GetObjectTheme("Omnibar")
	 * ThemeMgr.GuiColors.ApplyTheme(myGui, theme)
	 */
	static GetObjectTheme(objectName) {
		themeLogger.Log("ThemeMgr.GetObjectTheme", "Requested theme for: " objectName)
		
		if !this.thememap.Has("ObjectSettings") {
			; No object settings yet, use global theme
			defaultTheme := this.CurrentThemeName == "Dark" ? "DarkMode" : "LightMode"
			themeLogger.Log("ThemeMgr.GetObjectTheme", objectName " - No ObjectSettings, using global: " defaultTheme)
			return defaultTheme
		}
		
		objectSettings := this.thememap["ObjectSettings"]
		
		if !objectSettings.Has(objectName) {
			; Object not configured, use global theme
			defaultTheme := this.CurrentThemeName == "Dark" ? "DarkMode" : "LightMode"
			themeLogger.Log("ThemeMgr.GetObjectTheme", objectName " - Not configured, using global: " defaultTheme)
			return defaultTheme
		}
		
		objSetting := objectSettings[objectName]
		
		if objSetting["OverrideGeneral"] {
			; Use object-specific theme (already in theme name format like "DarkMode", "HighContrast", etc.)
			overrideTheme := objSetting["Theme"]
			themeLogger.Log("ThemeMgr.GetObjectTheme", objectName " - Override enabled, using: " overrideTheme)
			return overrideTheme
		} else {
			; Use global theme (CurrentThemeName is already set correctly from _InitializeCurrentTheme)
			globalTheme := this.CurrentThemeName == "Dark" ? "DarkMode" : "LightMode"
			themeLogger.Log("ThemeMgr.GetObjectTheme", objectName " - Using global theme: " globalTheme)
			return globalTheme
		}
	}
	; @endregion GUI Theme Selector

	; -----------------------------------------------------------------------
	; @region Legacy Compatibility
	static theme := Map(
		'Text_Color', this.thememap["Text_Color"],
		'Background_Color', this.thememap["Background_Color"],
	)
	; @endregion Legacy Compatibility

	; -----------------------------------------------------------------------
	; @region GuiColors Class (Merged from Gui.ahk)
	class GuiColors {
		; -----------------------------------------------------------------------
		; @region Static Properties
		static __New(color*) {
			if IsObject(color) {
				if IsArray(color) {
					for value in color {
						color := StrReplace(value, '#', '')
					}
				} else if IsString(color) {
					color := StrReplace(color, '#', '')
				} else if IsMap(color) {
					for key, value in color {
						if !IsString(value) {
							throw TypeError("Invalid color value for key: " key, -1)
						}
						color[key] := StrReplace(value, '#', '')
					}
				} else {
					for key, value in color {
						if this.HasOwnProp(key) {
							color.value := StrReplace(value, '#', '')
						} else {
							throw ValueError("Invalid property: " key, -1)
						}
					}
				}
			}
		}

		static FM := {
			Orange: 'C93102',
			Gray: '808080',
			Blue: '0066CC'
		}

		; Individual app theme colors as separate static properties
		static VSCode := {
			Background: "1E1E1E",
			Foreground: "D4D4D4",
			Selection: "264F78",
			LineNumber: "858585",
			ActiveTab: "2D2D2D",
			TextNormal: "D4D4D4"
		}

		static GitHub := {
			Primary: "24292E",
			Secondary: "2188FF",
			Success: "28A745",
			Warning: "FFA500",
			Error: "D73A49"
		}

		static Git := {
			Added: "28A745",
			Modified: "DBAB09",
			Deleted: "D73A49",
			Renamed: "6F42C1"
		}

		static Terminal := {
			Background: "0C0C0C",
			Foreground: "CCCCCC",
			Selection: "264F78",
			Cursor: "FFFFFF",
			Black: "0C0C0C",
			DarkBlue: "0037DA",
			DarkGreen: "13A10E",
			DarkCyan: "3A96DD",
			DarkRed: "C50F1F",
			DarkMagenta: "881798",
			DarkYellow: "C19C00",
			Gray: "CCCCCC",
			DarkGray: "767676",
			Blue: "3B78FF",
			Green: "16C60C",
			Cyan: "61D6D6",
			Red: "E74856",
			Magenta: "B4009E",
			Yellow: "F9F1A5",
			White: "F2F2F2"
		}

		static Discord := {
			Primary: "7289DA",
			Background: "36393F",
			ChatBg: "2F3136",
			TextArea: "40444B"
		}

		static Slack := {
			Primary: "4A154B",
			Background: "F8F8F8",
			Text: "2C2D30",
			Selection: "E1E1E1"
		}

		static Office := {
			Word: "185ABD",
			Excel: "107C41",
			PowerPoint: "CB4A32",
			Outlook: "0F65A6",
			OneNote: "7719AA",
			Teams: "6264A7",
			Background: "F3F2F1",
			Text: "252423",
			Selection: "CFE8FC"
		}

		; Map of all app themes for programmatic access
		static Apps := {
			VSCode: ThemeMgr.GuiColors.VSCode,
			GitHub: ThemeMgr.GuiColors.GitHub,
			Git: ThemeMgr.GuiColors.Git,
			Terminal: ThemeMgr.GuiColors.Terminal,
			Discord: ThemeMgr.GuiColors.Discord,
			Slack: ThemeMgr.GuiColors.Slack,
			Office: ThemeMgr.GuiColors.Office
		}

		; Theme combinations with paired background and text colors
		static Themes := {
			DarkMode: {
				Background: "1E1E1E",
				Text: "D4D4D4",
				Selection: "264F78",
				Button: "2D2D2D",
				ButtonText: "CCCCCC",
				Border: "4D4D4D"
			},
			LightMode: {
				Background: "F3F2F1",
				Text: "252423",
				Selection: "CFE8FC",
				Button: "E1E1E1",
				ButtonText: "323130",
				Border: "C8C6C4"
			},
			HighContrast: {
				Background: "000000",
				Text: "FFFFFF",
				Selection: "1AEBFF",
				Button: "2D2D2D",
				ButtonText: "FFFFFF",
				Border: "FFFFFF"
			},
			SoftDark: {
				Background: "2D2D30",
				Text: "E1E1E1",
				Selection: "3E3E42",
				Button: "3F3F46",
				ButtonText: "E1E1E1",
				Border: "555555"
			},
			SoftLight: {
				Background: "F5F5F5",
				Text: "333333",
				Selection: "B8D6FB",
				Button: "E5E5E5",
				ButtonText: "333333",
				Border: "CCCCCC"
			},
			BlueTheme: {
				Background: "1A2733",
				Text: "E1EFFF",
				Selection: "4373AA",
				Button: "2B5278",
				ButtonText: "FFFFFF",
				Border: "4373AA"
			},
			GreenTheme: {
				Background: "1E3B2C",
				Text: "C5E8D5",
				Selection: "2D7D4D",
				Button: "2D5F3F",
				ButtonText: "FFFFFF",
				Border: "2D7D4D"
			},
			SepiaTheme: {
				Background: "F4ECD8",
				Text: "5B4636",
				Selection: "D9C9A7",
				Button: "E0D3B8",
				ButtonText: "5B4636",
				Border: "C9B99A"
			}
		}
		; @endregion Static Properties

		; -----------------------------------------------------------------------
		; @region Color Utility Methods
		/**
		 * @description Get color value without '#' prefix for AHK compatibility
		 * @param {String} colorName Color name or hex value
		 * @returns {String} Hex color value without # prefix
		 */
		static GetAhkColor(colorName) {
			hexColor := this.GetColor(colorName)
			return (hexColor ~= "^#") ? SubStr(hexColor, 2) : hexColor
		}

		/**
		 * @description Convert color name to RGB hex value
		 * @param {String} colorName Color name or hex value
		 * @returns {String} Hex color value
		 */
		static GetColor(colorName) {
			if (InStr(colorName, "#") == 1)
				return colorName

			if (this.mColors.Has(colorName))
				return this.mColors[colorName]

			return "#000000"  ; Default to black if color not found
		}

		/**
		 * @description Convert hex color to RGB values
		 * @param {String} hexColor Hex color value
		 * @returns {Object} Object with r, g, b properties
		 */
		static HexToRGB(hexColor) {
			; Remove # if present
			if (InStr(hexColor, "#") == 1)
				hexColor := SubStr(hexColor, 2)

			; Ensure 6 characters
			if (StrLen(hexColor) != 6)
				return {r: 0, g: 0, b: 0}

			; Convert to RGB (hex strings are auto-converted to integers in v2)
			r := "0x" SubStr(hexColor, 1, 2)
			g := "0x" SubStr(hexColor, 3, 2)
			b := "0x" SubStr(hexColor, 5, 2)

			return {r: r, g: g, b: b}
		}
		; ---------------------------------------------------------------------------
		/**
		 * @description Convert decimal color to hex
		 * @param {Integer} color Decimal color value
		 * @returns {String} Hex color value
		 */
		static DecToHex(color) {
			return "#" Format("{:06X}", color)
		}

		/**
		 * @description Convert RGB to hex color
		 * @param {Integer} r Red value (0-255)
		 * @param {Integer} g Green value (0-255)
		 * @param {Integer} b Blue value (0-255)
		 * @returns {String} Hex color value
		 */
		static RGBToHex(r, g, b) {
			return "#" Format("{:02X}{:02X}{:02X}", r, g, b)
		}

		/**
		 * @description Calculate luminance of a color (for contrast calculations)
		 * @param {String} hexColor Hex color value
		 * @returns {Float} Luminance value (0-1)
		 */
		static GetLuminance(hexColor) {
			rgb := this.HexToRGB(hexColor)

			; Convert RGB to relative luminance using sRGB formula
			r := rgb.r / 255
			g := rgb.g / 255
			b := rgb.b / 255

			r := (r <= 0.03928) ? r/12.92 : ((r+0.055)/1.055) ** 2.4
			g := (g <= 0.03928) ? g/12.92 : ((g+0.055)/1.055) ** 2.4
			b := (b <= 0.03928) ? b/12.92 : ((b+0.055)/1.055) ** 2.4

			return 0.2126 * r + 0.7152 * g + 0.0722 * b
		}

		/**
		 * @description Calculate contrast ratio between two colors
		 * @param {String} color1 First hex color
		 * @param {String} color2 Second hex color
		 * @returns {Float} Contrast ratio (1-21)
		 */
		static GetContrast(color1, color2) {
			lum1 := this.GetLuminance(color1)
			lum2 := this.GetLuminance(color2)

			; Calculate contrast ratio
			if (lum1 > lum2)
				return (lum1 + 0.05) / (lum2 + 0.05)
			else
				return (lum2 + 0.05) / (lum1 + 0.05)
		}

		/**
		 * @description Get text color (black/white) for best contrast with background
		 * @param {String} bgColor Background hex color
		 * @returns {String} Text color (#000000 or #FFFFFF)
		 */
		static GetTextColor(bgColor) {
			lum := this.GetLuminance(bgColor)
			return (lum > 0.5) ? "#000000" : "#FFFFFF"
		}

		/**
		 * @description Adjusts color brightness
		 * @param {String} color Color value
		 * @param {Number} amount Adjustment amount (-1.0 to 1.0)
		 * @returns {String} Hex color string
		 */
		static Adjust(color, amount) {
			rgb := this.HexToRGB(color)
			amount := Min(1.0, Max(-1.0, amount))

			rgb.r := Min(255, Max(0, Round(rgb.r * (1 + amount))))
			rgb.g := Min(255, Max(0, Round(rgb.g * (1 + amount))))
			rgb.b := Min(255, Max(0, Round(rgb.b * (1 + amount))))

			return this.RGBToHex(rgb.r, rgb.g, rgb.b)
		}

		/**
		 * @description Mixes two colors together
		 * @param {String} color1 First color
		 * @param {String} color2 Second color
		 * @param {Number} ratio Mix ratio (0.0 to 1.0)
		 * @returns {String} Hex color string
		 */
		static Mix(color1, color2, ratio := 0.5) {
			c1 := this.HexToRGB(color1)
			c2 := this.HexToRGB(color2)
			ratio := Min(1, Max(0, ratio))

			return this.RGBToHex(
				Round(c1.r * (1 - ratio) + c2.r * ratio),
				Round(c1.g * (1 - ratio) + c2.g * ratio),
				Round(c1.b * (1 - ratio) + c2.b * ratio)
			)
		}
		; @endregion Color Utility Methods

		; -----------------------------------------------------------------------
		; @region GUI Application Methods
		/**
		 * @description Apply color to a GUI or control
		 * @param {Gui|GuiControl} target Target object
		 * @param {String} color Color value
		 * @param {String} type Color type (Background|Text)
		 */
		static Apply(target, color, type := "Background") {
			if !(target is Gui || target is Gui.Control)
				throw ValueError("Target must be a Gui or GuiControl")

			hexColor := this.GetAhkColor(color)

			switch type {
				case "Background": target.BackColor := "0x" hexColor
				case "Text": target.SetFont("c" hexColor)
				default: throw ValueError("Invalid color type")
			}
		}

		/**
		 * @description Apply a complete theme to a GUI
		 * @param {Gui} gui GUI object to theme
		 * @param {String} themeName Name of the theme to apply
		 * @returns {Gui} The themed GUI for method chaining
		 */
		static ApplyTheme(gui, themeName := "DarkMode") {
			if (!this.Themes.HasProp(themeName)) {
				themeName := "DarkMode"  ; Default to DarkMode if theme not found
			}

			theme := this.Themes.%themeName%

			; Apply background color
			gui.BackColor := "0x" this.GetAhkColor(theme.Background)

			; Apply text color to all controls
			gui.SetFont("c" this.GetAhkColor(theme.Text))

			; Apply specific styling to button types
			for ctrl in gui {
				if (ctrl.Type = "Button") {
					ctrl.SetFont("c" this.GetAhkColor(theme.ButtonText))
				}
			}

			return gui  ; Return GUI for method chaining
		}

		/**
		 * @description Get a complete theme object by name
		 * @param {String} themeName Name of the theme
		 * @returns {Object} Theme object with color properties
		 */
		static GetTheme(themeName := "DarkMode") {
			if (!this.Themes.HasProp(themeName))
				return this.Themes.DarkMode

			return this.Themes.%themeName%
		}

		/**
		 * @description Create a custom theme with specified colors
		 * @param {String} name Theme name
		 * @param {Object} colors Theme colors
		 * @returns {Object} The created theme
		 */
		static CreateTheme(name, colors) {
			; Ensure required colors are present
			if (!colors.HasProp("Background"))
				colors.Background := "FFFFFF"
			if (!colors.HasProp("Text"))
				colors.Text := this.GetTextColor(colors.Background)

			; Create theme
			this.Themes.%name% := colors
			return colors
		}

		/**
		 * @description Apply dark mode to a GUI
		 * @param {Gui} gui GUI to apply dark mode to
		 * @returns {Gui} The themed GUI for method chaining
		 */
		static ApplyDarkMode(gui) {
			return this.ApplyTheme(gui, "DarkMode")
		}

		/**
		 * @description Apply light mode to a GUI
		 * @param {Gui} gui GUI to apply light mode to
		 * @returns {Gui} The themed GUI for method chaining
		 */
		static ApplyLightMode(gui) {
			return this.ApplyTheme(gui, "LightMode")
		}

		/**
		 * @description Apply high contrast mode to a GUI
		 * @param {Gui} gui GUI to apply high contrast to
		 * @returns {Gui} The themed GUI for method chaining
		 */
		static ApplyHighContrast(gui) {
			return this.ApplyTheme(gui, "HighContrast")
		}

		/**
		 * @description Generate a color palette based on a primary color
		 * @param {String} baseColor Primary color to base palette on
		 * @returns {Object} Color palette with variants
		 */
		static GeneratePalette(baseColor) {
			rgb := this.HexToRGB(baseColor)

			return {
				Base: baseColor,
				Lighter: this.Adjust(baseColor, 0.3),
				Darker: this.Adjust(baseColor, -0.3),
				Complementary: this.RGBToHex(255 - rgb.r, 255 - rgb.g, 255 - rgb.b),
				Text: this.GetTextColor(baseColor)
			}
		}
		; @endregion GUI Application Methods

		; -----------------------------------------------------------------------
		; @region App-Specific Theme Methods
		/**
		 * Get app theme color
		 * @param {String} app App name
		 * @param {String} colorName Color name
		 * @returns {String} Hex color
		 */
		static GetThemeColor(app, colorName) {
			if this.Apps.HasOwnProp(app) && this.Apps.%app%.HasOwnProp(colorName)
				return this.Apps.%app%.%colorName%
			throw ValueError("Invalid app or color name")
		}

		/**
		 * Apply app theme to GUI
		 * @param {Gui} gui GUI object
		 * @param {String} app App name
		 */
		static ApplyAppTheme(gui, app) {
			if !this.Apps.HasOwnProp(app)
				throw ValueError("Invalid app name")

			theme := this.Apps.%app%
			if theme.HasOwnProp("Background")
				this.Apply(gui, theme.Background, "Background")
			if theme.HasOwnProp("Foreground") || theme.HasOwnProp("TextNormal")
				this.Apply(gui, theme.HasOwnProp("Foreground") ? theme.Foreground : theme.TextNormal, "Text")
		}
		; @endregion App-Specific Theme Methods

		; -----------------------------------------------------------------------
		; @region Named Colors Database
		; Common named colors map
		static mColors := Map(
			"aliceblue", "F0F8FF",
			"antiquewhite", "FAEBD7",
			"aqua", "00FFFF",
			"aquamarine", "7FFFD4",
			"azure", "F0FFFF",
			"beige", "F5F5DC",
			"bisque", "FFE4C4",
			"black", "000000",
			"blanchedalmond", "FFEBCD",
			"blue", "0000FF",
			"blueviolet", "8A2BE2",
			"brown", "A52A2A",
			"burlywood", "DEB887",
			"cadetblue", "5F9EA0",
			"chartreuse", "7FFF00",
			"chocolate", "D2691E",
			"coral", "FF7F50",
			"cornflowerblue", "6495ED",
			"cornsilk", "FFF8DC",
			"crimson", "DC143C",
			"cyan", "00FFFF",
			"darkblue", "00008B",
			"darkcyan", "008B8B",
			"darkgoldenrod", "B8860B",
			"darkgray", "A9A9A9",
			"darkgreen", "006400",
			"darkkhaki", "BDB76B",
			"darkmagenta", "8B008B",
			"darkolivegreen", "556B2F",
			"darkorange", "FF8C00",
			"darkorchid", "9932CC",
			"darkred", "8B0000",
			"darksalmon", "E9967A",
			"darkseagreen", "8FBC8F",
			"darkslateblue", "483D8B",
			"darkslategray", "2F4F4F",
			"darkturquoise", "00CED1",
			"darkviolet", "9400D3",
			"deeppink", "FF1493",
			"deepskyblue", "00BFFF",
			"dimgray", "696969",
			"dodgerblue", "1E90FF",
			"firebrick", "B22222",
			"floralwhite", "FFFAF0",
			"forestgreen", "228B22",
			"fuchsia", "FF00FF",
			"gainsboro", "DCDCDC",
			"ghostwhite", "F8F8FF",
			"gold", "FFD700",
			"goldenrod", "DAA520",
			"gray", "808080",
			"green", "008000",
			"greenyellow", "ADFF2F",
			"honeydew", "F0FFF0",
			"hotpink", "FF69B4",
			"indianred", "CD5C5C",
			"indigo", "4B0082",
			"ivory", "FFFFF0",
			"khaki", "F0E68C",
			"lavender", "E6E6FA",
			"lavenderblush", "FFF0F5",
			"lawngreen", "7CFC00",
			"lemonchiffon", "FFFACD",
			"lightblue", "ADD8E6",
			"lightcoral", "F08080",
			"lightcyan", "E0FFFF",
			"lightgoldenrodyellow", "FAFAD2",
			"lightgray", "D3D3D3",
			"lightgreen", "90EE90",
			"lightpink", "FFB6C1",
			"lightsalmon", "FFA07A",
			"lightseagreen", "20B2AA",
			"lightskyblue", "87CEFA",
			"lightslategray", "778899",
			"lightsteelblue", "B0C4DE",
			"lightyellow", "FFFFE0",
			"lime", "00FF00",
			"limegreen", "32CD32",
			"linen", "FAF0E6",
			"magenta", "FF00FF",
			"maroon", "800000",
			"mediumaquamarine", "66CDAA",
			"mediumblue", "0000CD",
			"mediumorchid", "BA55D3",
			"mediumpurple", "9370DB",
			"mediumseagreen", "3CB371",
			"mediumslateblue", "7B68EE",
			"mediumspringgreen", "00FA9A",
			"mediumturquoise", "48D1CC",
			"mediumvioletred", "C71585",
			"midnightblue", "191970",
			"mintcream", "F5FFFA",
			"mistyrose", "FFE4E1",
			"moccasin", "FFE4B5",
			"navajowhite", "FFDEAD",
			"navy", "000080",
			"oldlace", "FDF5E6",
			"olive", "808000",
			"olivedrab", "6B8E23",
			"orange", "FFA500",
			"orangered", "FF4500",
			"orchid", "DA70D6",
			"palegoldenrod", "EEE8AA",
			"palegreen", "98FB98",
			"paleturquoise", "AFEEEE",
			"palevioletred", "DB7093",
			"papayawhip", "FFEFD5",
			"peachpuff", "FFDAB9",
			"peru", "CD853F",
			"pink", "FFC0CB",
			"plum", "DDA0DD",
			"powderblue", "B0E0E6",
			"purple", "800080",
			"rebeccapurple", "663399",
			"red", "FF0000",
			"rosybrown", "BC8F8F",
			"royalblue", "4169E1",
			"saddlebrown", "8B4513",
			"salmon", "FA8072",
			"sandybrown", "F4A460",
			"seagreen", "2E8B57",
			"seashell", "FFF5EE",
			"sienna", "A0522D",
			"silver", "C0C0C0",
			"skyblue", "87CEEB",
			"slateblue", "6A5ACD",
			"slategray", "708090",
			"snow", "FFFAFA",
			"springgreen", "00FF7F",
			"steelblue", "4682B4",
			"tan", "D2B48C",
			"teal", "008080",
			"thistle", "D8BFD8",
			"tomato", "FF6347",
			"turquoise", "40E0D0",
			"violet", "EE82EE",
			"wheat", "F5DEB3",
			"white", "FFFFFF",
			"whitesmoke", "F5F5F5",
			"yellow", "FFFF00",
			"yellowgreen", "9ACD32"
		)
		; @endregion Named Colors Database
	}
	; @endregion GuiColors Class
}
