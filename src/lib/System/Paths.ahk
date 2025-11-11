; ------------------------------------------------------------
/**
 * @class Paths
 * @file Utils.ahk
 * @description Centralized path management system (Merged from Paths.ahk into System/Paths.ahk)
 * @version 2.2.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-09-25
 * @requires AutoHotkey v2.0+
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
 * @module Paths
 * @key
 */

; #Include <Extensions/Pipe>
; ------------------------------------------------------------
#Include <Utilities/GetFilesSortedByDate>
#Include <Extensions\.ui/Infos>

class Paths {
	; ---------------------------------------------------------------------------
	#Requires AutoHotkey v2+
	; Core System Paths
	; ---------------------------------------------------------------------------
	static System32         := "C:\Windows\System32"                    					; ✓ Same in both
	static User             := "C:\Users\" A_UserName                   					; ✓ Same in both

	; ---------------------------------------------------------------------------
	; AppData Structure
	; ---------------------------------------------------------------------------
	static AppData          := this.User "\AppData"                     					; ✓ Same in both
	static LocalAppData     := this.AppData "\Local"                    					; ✓ Same in both
	static RoamingAppData   := this.AppData "\Roaming"                  					; ✓ Same in both
	static AppDataProgs     := this.LocalAppData "\Programs"            					; ✓ Same in both

	; ---------------------------------------------------------------------------
	; Start Menu & Programs
	; ---------------------------------------------------------------------------
	static RoamingProgs     := this.RoamingAppData '\Microsoft\Windows\Start Menu\Programs' ; From System/Paths
	static Startup          := this.RoamingProgs '\Startup\'            					; System/Paths has '\Startup\', Lib/Paths has '\Startup' - Using System version
	static ChromeApps       := this.RoamingProgs '\Chrome Apps\'        					; System/Paths adds trailing slash
	static OutlookPWA       := this.ChromeApps '\Outlook (PWA).lnk'     					; From Paths.backup

	; ---------------------------------------------------------------------------
	; Documents & User Folders
	; ---------------------------------------------------------------------------
	static Documents        := A_MyDocuments                            					; From System/Paths
	static MyDocumentsAHK   := this.Documents '\AutoHotkey'            						; From System/Paths

	; ---------------------------------------------------------------------------
	; OneDrive Structure
	; ---------------------------------------------------------------------------
	static OneDrive         := this.User . '\OneDrive - FM Global'      					; ✓ Same in both
	static AutomationProjects := this.OneDrive "\Automation Projects"   					; ✓ Same in both
	static Clients          := this.OneDrive "\Client Files"            					; ✓ Same in both
	static DSP              := this.OneDrive "\DSP"                     					; ✓ Same in both
	static Expenses         := this.OneDrive "\Expenses\" A_YYYY        					; ✓ Same in both
	static Desktop          := this.OneDrive "\Desktop"                 					; ✓ Same in both
	static Pictures         := this.OneDrive "\Pictures"                					; ✓ Same in both
	static Captor           := this.Pictures "\Captor\Captured"         					; ✓ Same in both
	static Downloads        := this.OneDrive '\Downloads'               					; ✓ Same in both
	static Music            := this.OneDrive '\Music'                   					; ✓ Same in both
	static UserData         := this.OneDrive '\Efficiency Assistant User Data'  			; ✓ Same in both
	; static Data             := this.OneDrive '\Data'  			; ✓ Same in both
	static Polaris          := this.OneDrive '\Polaris'                						; ✓ Same in both

	; ---------------------------------------------------------------------------
	; FM Global Structure
	; ---------------------------------------------------------------------------
	static FMGlobal         := this.User '\FM Global'                   					; ✓ Same in both
	static FMGDocuments     := this.FMGlobal '\Operating Standards - Documents\general'  	; From System/Paths
	static OR               := this.FMGlobal '\Operating Requirements with Guides - Documents'  ; ✓ Same in both
	static OR_Contents      := this.OR '\Contents.pdf'                  					; ✓ Same in both
	static OSdocs           := this.FMGlobal '\Operating Standards - Documents'  			; ✓ Same in both
	static OS_Contents      := this.OSdocs '\Contents.pdf'              					; ✓ Same in both
	static DS               := this.OSdocs '\ds'                        					; ✓ Same in both
	static OS               := this.OSdocs '\opstds'                    					; ✓ Same in both
	static WTParameters     := this.OS '\WTParameters Spreadsheet.xlsx' 					; From Paths.backup

	; ---------------------------------------------------------------------------
	; Applications & VS Code
	; ---------------------------------------------------------------------------
	static VSCode           := this.AppDataProgs '\Microsoft VS Code'   					; System/Paths has 'VS', Lib/Paths has 'VSCode' - Using Lib version
	static VS               := this.AppDataProgs '\Microsoft VS Code'   					; From System/Paths (alias)
	static code             := this.VSCode '\Code.exe '                 					; System/Paths has 'Code', Lib/Paths has 'code' - Using Lib version
	; static Code             := this.VS '\Code.exe'                      					; From System/Paths (alias) - Commented out due to duplicate with 'code'

	; ---------------------------------------------------------------------------
	; Program Files Applications
	; ---------------------------------------------------------------------------
	static Notepadpp        := A_ProgramFiles "\Notepad++\notepad++.exe"  					; ✓ Same in both
	static Horizon          := A_ProgramFiles '\FMGlobal\Horizon'        					; ✓ Same in both
	static Outlook          := A_ProgramFiles " (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE"  ; ✓ Same in both
	static OneNote          := A_ProgramFiles " (x86)\Microsoft Office\root\Office16\ONENOTE.EXE"  ; ✓ Same in both

	; ---------------------------------------------------------------------------
	; AutoHotkey Paths
	; ---------------------------------------------------------------------------
	static StandardAhkLibLocation 	:= A_MyDocuments 		'\AutoHotkey\Lib'    			; ✓ Same in both
	static UserLib          		:= this.MyDocumentsAHK 	'\Lib'               			; From System/Paths
	static Prog             		:= this.AppDataProgs 	'\AutoHotkey\v2'       			; From System/Paths
	static v2Prog           		:= this.AppDataProgs 	'\AutoHotkey\v2'       			; From System/Paths
	static v1Prog           		:= this.AppDataProgs 	'\AutoHotkey'          			; From System/Paths
	static AHKv1           			:= this.AppDataProgs 	'\AutoHotkey'          			; From System/Paths
	static v1Proj           		:= this.AHKv1 			'\AHK.Projects.v1'          	; From System/Paths
	static v2Proj           		:= this.v2Prog 			'\AHK.Projects.v2'          	; From System/Paths
	static v2Lib            		:= this.v2Prog 			'\Lib'                      	; From System/Paths
	static StandardLib      		:= this.v2Prog 			'\Lib'                      	; From System/Paths
	static LocalLib         		:= A_ScriptDir 			'\Lib'                      	; From System/Paths
	static v1tov2           		:= this.v2Prog 			'\AHK.Projects.v1_to_v2'    	; From System/Paths
	static v2Convert        		:= this.v1tov2 			'\AHK-v2-script-converter'  	; From System/Paths

	static Lib              		:= this.StandardLib										; System/Paths uses StandardLib, Lib/Paths uses StandardAhkLibLocation
	static Data             		:= this.Lib '\Data'											; Lib\Data folder for JSON/config files
	static Pandoc              		:= this.Lib '\Extensions\.formats\pandoc'		; Fixed: lowercase folder name

	; ---------------------------------------------------------------------------
	; Logging Structure
	; ---------------------------------------------------------------------------
	static Loggers          := this.StandardLib '\.Loggers'									; Central logging directory
	static MsgBoxLogs       := this.Loggers '\.msgbox'										; MsgBox usage logs
	static ErrorLogs        := this.Loggers '\.errorlog'									; Error logging directory
	static GUILogs          := this.Loggers '\.gui'											; GUI interaction logs
	static FileLogs         := this.Loggers '\.file'										; File operation logs
	static RegistryLogs     := this.Loggers '\.registry'									; Registry operation logs
	static NetworkLogs      := this.Loggers '\.network'										; Network operation logs

	; ---------------------------------------------------------------------------
	; Script Paths
	; ---------------------------------------------------------------------------
	static Runner           := this.StandardLib '\Scr\Runner.ahk'       					; From System/Paths
	static mainScript       := this.StandardLib '\AHK Script.v2.ahk'    					; From System/Paths
	static Main             := this.OneDrive . 'AHK.Main'               					; From System/Paths
	static Shows            := this.Lib 'App\Shows.ahk'                 					; From System/Paths
	static Info             := this.Lib '\Tools\Info.ahk'               					; ✓ Same in both
	static Test             := "C:\Programming\test"                     					; From System/Paths
	static Reg              := this.Lib '\Abstractions\Registers.ahk'   					; ✓ Same in both
	static lnchr            := this.v2Proj '\LNCHR'                     					; From System/Paths

	; ---------------------------------------------------------------------------
	; Folder Maps (From System/Paths)
	; ---------------------------------------------------------------------------
	static folder := Map(
		'Notes',   (this.Lib '\Notes'),
		'Links',   (this.Lib '\Links'),
		'RecLibs', (this.Lib '\RecLibs'),
		'Common',  (this.v2Lib 'Common_'),
	)

	; ---------------------------------------------------------------------------
	; Additional Paths (From System/Paths)
	; ---------------------------------------------------------------------------
	static Files            := this.Main "\Files"
	static Tools            := this.Main "\Tools"
	static Audio            := this.User . '\Music' 										; ✓ Same in both
	static Sounds           := this.Audio "\Sounds"

	; ---------------------------------------------------------------------------
	; System Extensions
	; ---------------------------------------------------------------------------
	static VsCodeExtensions := "C:\Users\" A_UserName "\.vscode\extensions"  				; ✓ Same in both
	static SavedScreenshots := this.LocalAppData "\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\TempState\ScreenClip"  ; From System/Paths

	; ---------------------------------------------------------------------------
	; File Maps (From System/Paths)
	; ---------------------------------------------------------------------------
	static Ptf := Map(
		"playlist-sorter", this.Files "\Innit\playlist-sorter.txt",
		"test-state",      this.Files "\Innit\test-state.txt",
		"time-agent",      this.Files "\Innit\time-agent.txt",
		"BlankPic",        this.Files "\img\BlankPic.png",
		"Hub",             this.Main "\Hub.ahk",
		"Tests",           this.Tools "\Tests.ahk",
		"Timer",           this.Tools "\Timer.ahk",
		"AhkTest",         this.Test "\AhkTest.ahk",
		"vine boom",       this.Sounds "\vine boom.wav",
		"faded than a hoe", this.Sounds "\faded than a hoe.wav",
		"heheheha",        this.Sounds "\heheheha.wav",
		"shall we",        this.Sounds "\shall we.wav",
		"slip and crash",  this.Sounds "\slip and crash.wav",
		"cartoon running", this.Sounds "\cartoon running.wav",
		"rizz",            this.Sounds "\rizz.wav",
		"bruh sound effect", this.Sounds "\bruh sound effect.wav",
		"cartoon",         this.Sounds "\cartoon.wav",
		"hohoho",          this.Sounds "\hohoho.wav",
		"bing chilling 1", this.Sounds "\bing chilling 1.wav",
		"bing chilling 2", this.Sounds "\bing chilling 2.wav",
		"oh fr on god",    this.Sounds "\oh fr on god.wav",
		"sus",             this.Sounds "\sus.wav",
		"i just farted",   this.Sounds "\i just farted.wav",
		"ting",            this.Sounds "\ting.wav",
		"shutter",         this.Sounds "\shutter.wav",
		"was that his cock", this.Sounds "\was that his cock.wav",
		"cyberpunk",       this.Sounds "\cyberpunk.wav",
		"better call saul", this.Sounds "\better call saul short.wav",

		; Log Files
		"msgbox-log",      this.MsgBoxLogs "\msgbox_usage.log",
		"error-log",       this.ErrorLogs "\errorlog_usage.log",
		"gui-log",         this.GUILogs "\gui_usage.log",
		"file-log",        this.FileLogs "\file_usage.log",
		"registry-log",    this.RegistryLogs "\registry_usage.log",
		"network-log",     this.NetworkLogs "\network_usage.log",
	)

	; ---------------------------------------------------------------------------
	; Apps Map (From System/Paths)
	; ---------------------------------------------------------------------------
	static Apps := Map(
		"Sound mixer",       "SndVol.exe",
		"Slide to shutdown", "SlideToShutDown.exe",
	)

	; ---------------------------------------------------------------------------
	; Methods (From Paths.backup)
	; ---------------------------------------------------------------------------
	/**
	 * @description Opens the B+M Loss Expectancy Guide Excel file
	 * @returns {Void}
	 * @throws {Error} When file cannot be found or opened
	 */
	static bmle() {
		WinL := [], val := [], WinE := ''
		try WinL := WinGetList('B+M Loss Expectancy Guide')
		for each, value in WinL {
			WinE := WinExist(value)
			If WinE {
				try WinActivate(WinE)
				return
			}
		}
		bnmleg_file := ''
		fName := ''
		bnmleg_folder := this.OSdocs '\general\'
		pFile := 'B+M Loss Expectancy Guide*'
		bnmleg_seachpattern := bnmleg_folder '\' pFile
		val := GetFilesSortedByDate(bnmleg_seachpattern)
		for each, value in val {
			bnmleg_file .= value
		}
		bnmleg_file := '"' bnmleg_file '"'
		SplitPath(bnmleg_file, &fName)
		Infos('Now opening "' fName '. Please wait.', 5000)
		Run('excel.exe /e ' bnmleg_file)
	}
}

; ---------------------------------------------------------------------------
; Compatibility Alias (Keep Paths2 for existing code)
; ---------------------------------------------------------------------------
class Paths2 extends Paths {
	; This allows existing code using Paths2 to continue working
}

/**
 * @class FileOpener
 * @description Opens files and directories based on input terms (From System/Paths)
 * @version 1.0.0
 * @author OvercastBTC (Adam Bacon)
 */
class FileOpener {
	static systemPaths := Map(
		"documents", 	A_MyDocuments,
		"mydocuments", 	A_MyDocuments,
		"desktop", 		A_Desktop,
		"pictures", 	Paths.Pictures,
		"downloads", 	A_Desktop "\..\Downloads",
		"appdata", 		A_AppData,
		"temp", 		A_Temp,
		"startup", 		A_Startup,
		"startmenu", 	A_StartMenu,
		"programs", 	A_Programs,
		"programfiles", A_ProgramFiles,
		"recyclebin", 	"shell:RecycleBinFolder",
		"trash", 		"shell:RecycleBinFolder"
	)

	static workspaces := Map(
		"common", Paths.StandardLib "\Common\Common.code-workspace",
		"message", Paths.StandardLib "\Tools\Message.code-workspace",
		"richeditor", Paths.StandardLib "\RichEditor.code-workspace",
		"alllibs", Paths.StandardLib "\Lib_AllLibs.code-workspace",
		"hznplus", Paths.StandardLib "\HznPlus.code-workspace",
		"horizon", Paths.StandardLib "\hznHorizoncode-workspace.code-workspace",
		"clipboard", Paths.StandardLib "\Extensions\Clipboard.code-workspace"
	)

	/**
	 * @description Process user input and open matching location
	 * @param {String} input User input term to match against paths
	 * @returns {Boolean} Success status
	 */
	static ProcessInput(input) {
		input := StrLower(input)

		; Check exact matches in Paths class first
		for prop in Paths.OwnProps() {
			if (StrLower(prop) == input) {
				try {
					this.OpenLocation(Paths.%prop%)
					return true
				} catch Error as e {
					; Log error instead of using Infos (removed dependency)
					OutputDebug("Paths: Error opening " prop ": " e.Message)
					return false
				}
			}
		}

		; Check in system paths
		if this.systemPaths.Has(input) {
			try {
				this.OpenLocation(this.systemPaths[input])
				return true
			} catch Error as e {
				; Log error instead of using Infos (removed dependency)
				OutputDebug("Paths: Error opening system path " input ": " e.Message)
				return false
			}
		}

		; Check in workspaces
		if this.workspaces.Has(input) {
			try {
				this.OpenLocation(this.workspaces[input])
				return true
			} catch Error as e {
				; Log error instead of using Infos (removed dependency)
				OutputDebug("Paths: Error opening workspace " input ": " e.Message)
				return false
			}
		}

		; Check in Paths.Apps
		if Paths.Apps.Has(input) {
			try {
				Run(Paths.Apps[input])
				return true
			} catch Error as e {
				; Log error instead of using Infos (removed dependency)
				OutputDebug("Paths: Error running app " input ": " e.Message)
				return false
			}
		}

		; Check in Paths.Ptf
		if Paths.Ptf.Has(input) {
			try {
				this.OpenLocation(Paths.Ptf[input])
				return true
			} catch Error as e {
				; Log error instead of using Infos (removed dependency)
				OutputDebug("Paths: Error opening file " input ": " e.Message)
				return false
			}
		}

		; Check in Paths.folder
		if Paths.folder.Has(input) {
			try {
				this.OpenLocation(Paths.folder[input])
				return true
			} catch Error as e {
				; Log error instead of using Infos (removed dependency)
				OutputDebug("Paths: Error opening folder " input ": " e.Message)
				return false
			}
		}

		; If no exact match, try partial matches
		for prop in Paths.OwnProps() {
			if InStr(StrLower(prop), input) {
				try {
					this.OpenLocation(Paths.%prop%)
					return true
				} catch Error as e {
					continue
				}
			}
		}

		; Try fuzzy matching if needed
		matches := this.GetFuzzyMatches(input)
		if matches.Length > 0 {
			return this.ShowMatchOptions(matches)
		}

		; Log when no matching location is found instead of using Infos (removed dependency)
		OutputDebug("Paths: No matching location found: " input)
		return false
	}

	/**
	 * @description Open a location using appropriate method based on path type
	 * @param {String} path Path to open
	 */
	static OpenLocation(path) {
		; Check if it's a file or directory
		try {
			if FileExist(path) {
				Run(path)
				return true
			} else {
				Run('explorer.exe "' path '"')
				return true
			}
		} catch Error as e {
			throw Error("Failed to open location: " path " - " e.Message)
		}
	}

	/**
	 * @description Get fuzzy matches for input term
	 * @param {String} input User input term
	 * @returns {Array} Array of match objects
	 */
	static GetFuzzyMatches(input) {
		matches := []
		maxDistance := 3

		; Check Paths class properties
		for prop in Paths.OwnProps() {
			distance := this.LevenshteinDistance(StrLower(input), StrLower(prop))
			if (distance <= maxDistance) {
				matches.Push({name: prop, path: Paths.%prop%, distance: distance, type: "property"})
			}
		}

		; Check system paths
		for key, value in this.systemPaths {
			distance := this.LevenshteinDistance(StrLower(input), StrLower(key))
			if (distance <= maxDistance) {
				matches.Push({name: key, path: value, distance: distance, type: "system"})
			}
		}

		; Check workspaces
		for key, value in this.workspaces {
			distance := this.LevenshteinDistance(StrLower(input), StrLower(key))
			if (distance <= maxDistance) {
				matches.Push({name: key, path: value, distance: distance, type: "workspace"})
			}
		}

		; Sort matches by distance
		matches.Sort(((a, b) => a.distance - b.distance))

		return matches
	}

	/**
	 * @description Calculate Levenshtein distance between two strings
	 * @param {String} s1 First string
	 * @param {String} s2 Second string
	 * @returns {Number} Edit distance
	 */
	static LevenshteinDistance(s1, s2) {
		len1 := StrLen(s1)
		len2 := StrLen(s2)

		if (len1 == 0)
			return len2
		if (len2 == 0)
			return len1

		matrix := []
		Loop len1 + 1 {
			matrix.Push([])
			Loop len2 + 1 {
				matrix[A_Index].Push(0)
			}
		}

		Loop len1 + 1 {
			matrix[A_Index][1] := A_Index - 1
		}
		Loop len2 + 1 {
			matrix[1][A_Index] := A_Index - 1
		}

		Loop len1 {
			i := A_Index
			Loop len2 {
				j := A_Index
				cost := (SubStr(s1, i, 1) == SubStr(s2, j, 1)) ? 0 : 1
				matrix[i+1][j+1] := Min(
					matrix[i][j+1] + 1,     ; deletion
					matrix[i+1][j] + 1,     ; insertion
					matrix[i][j] + cost     ; substitution
				)
			}
		}

		return matrix[len1+1][len2+1]
	}

	/**
	 * @description Show options for multiple matches
	 * @param {Array} matches Array of match objects
	 * @returns {Boolean} Whether a selection was made
	 */
	static ShowMatchOptions(matches) {
		; For now, just open the best match
		if (matches.Length > 0) {
			bestMatch := matches[1]
			try {
				this.OpenLocation(bestMatch.path)
				return true
			} catch Error as e {
				; Log error instead of using Infos (removed dependency)
				OutputDebug("Paths: Error opening best match " bestMatch.name ": " e.Message)
				return false
			}
		}

		return false
	}
}

; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ----------------------- testjson -------------------------------------------
; @region testjson
/**
 * @description Test JSON paths
 */
; @module testjson
class testjson extends Paths {
	static testdirname := 'WriteFileTest'
	static testdir := Paths.Lib '\' testjson.testdirname
	static json_dir := testjson.testdir
	static json_dirname := testjson.json_dir '\WriteToJSONTest'
	static jsongo_dirname := testjson.json_dir '\WriteToJSONGOTest'
}
; ---------------------------------------------------------------------------
