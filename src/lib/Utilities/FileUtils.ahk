/**
 * @file FileUtils.ahk
 * @description Consolidated file utility functions for AutoHotkey v2
 * @version 1.0.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-09-29
 * @requires AutoHotkey v2.0+
 *
 * This file consolidates functionality from:
 * - FileSystemSearch.ahk (GUI-based file search)
 * - GetFileTimes.ahk (File timestamp retrieval)
 * - GetFilesSortedByDate.ahk (File sorting by date)
 */

#Requires AutoHotkey v2+
#Include <Extensions\.ui\Gui>
#Include <Extensions\.ui\CleanInputBox>
#Include <Extensions\.ui\Infos>
#Include <Extensions\.primitives\String>

; ------------------------------------------------------------------------------
; @region File Time Utilities (from GetFileTimes.ahk)
; ------------------------------------------------------------------------------

/**
 * Get file creation, access, and modification times
 * @param {String} filePath Path to the file
 * @returns {Object} Object with CreationTime, AccessedTime, and ModificationTime properties
 */
GetFileTimes(filePath) {
	oFile := FileOpen(filePath, 0x700)
	DllCall("GetFileTime",
		"Ptr",    oFile.Handle,
		"int64*", &creationTime     := 0,
		"int64*", &accessedTime     := 0,
		"int64*", &modificationTime := 0
	)
	return {
		CreationTime:     creationTime,
		AccessedTime:     accessedTime,
		ModificationTime: modificationTime
	}
}

; ------------------------------------------------------------------------------
; @endregion File Time Utilities
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; @region File Sorting Utilities (from GetFilesSortedByDate.ahk)
; ------------------------------------------------------------------------------

/**
 * Get files sorted by modification date
 * @param {String} pattern File pattern to search (e.g., "*.txt", "C:\folder\*.*")
 * @param {Boolean} newToOld Whether to sort newest first (default: true)
 * @returns {Array} Array of file paths sorted by modification date
 */
GetFilesSortedByDate(pattern, newToOld := true) {
	files := Map()
	loop files pattern {
		modificationTime := GetFileTimes(A_LoopFileFullPath).ModificationTime
		if (newToOld)
			modificationTime *= -1
		files.Set(modificationTime, A_LoopFileFullPath)
	}
	arr := []
	for , fullPath in files
		arr.Push(fullPath)
	return arr
}

; ------------------------------------------------------------------------------
; @endregion File Sorting Utilities
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; @region File System Search (from FileSystemSearch.ahk)
; ------------------------------------------------------------------------------

/**
 * GUI-based file system search utility
 * Find all matches of a search request within the currently opened folder in explorer.
 * Recurses into all subfolders and searches for both files and folders.
 */
; class FileSystemSearch extends Gui {
class FileSystemSearch {

	gui := ''  ; Placeholder for Gui object
	list := '' ; Placeholder for ListView object
	/**
	 * Find all the matches of your search request within the currently
	 * opened folder in the explorer.
	 * The searcher recurses into all the subfolders.
	 * Will search for both files and folders.
	 * After the search is completed, will show all the matches in a list.
	 * Call StartSearch() after creating the class instance if you can pass
	 * the input yourself.
	 * Call GetInput() after creating the class instance if you want to have
	 * an input box to type in your search into.
	 */
	__New(searchWhere?, caseSense := "Off") {
		this.gui := Gui("+Resize", "These files match your search:")

		this.gui.MakeFontNicer(14)
		this.gui.DarkMode()

		this.List := this.gui.AddText(, "
		(
			Right click on a result to copy its full path.
			Double click to open it in explorer.
		)")

		this.WidthOffset  := 35
		this.HeightOffset := 80

		this.list := this.gui.AddListView(
			"Count50 Background" this.gui.BackColor,
			/**
			 * Count50 — we're not losing much by allocating more memory
			 * than needed,
			 * and on the other hand we improve the performance by a lot
			 * by doing so
			 */
			["File", "Folder", "Directory"]
		)

		this.caseSense := caseSense

		if !IsSet(searchWhere) {
			this.ValidatePath()
		} else {
			this.path := searchWhere
		}

		this.SetOnEvents()
	}

	/**
	 * Get an input box to type in your search request into.
	 * Get a list of all the matches that you can open in explorer.
	 */
	GetInput() {
		if !input := CleanInputBox().WaitForInput() {
			return false
		}
		this.StartSearch(input)
	}

	ValidatePath() {
		SetTitleMatchMode("RegEx")
		try this.path := WinGetTitle("^[A-Z]: ahk_exe explorer\.exe")
		catch Any {
			Info("Open an explorer window first!")
			Exit()
		}
	}

	/**
	 * Get a list of all the matches of *input*.
	 * You can either open them in explorer or copy their path.
	 * @param input *String*
	 */
	StartSearch(input) {
		/**
		 * Improves performance rather than keeping on adding rows
		 * and redrawing for each one of them
		 */
		this.List.Opt("-Redraw")

		;To remove the worry of "did I really start the search?"
		gInfo := Infos("The search is in progress")

		if this.path ~= "^[A-Z]:\\$" {
			this.path := this.path[1, -2]
		}

		loop files this.path "\*.*", "FDR" {
			if !A_LoopFileName.Find(input, this.caseSense) {
				continue
			}
			if A_LoopFileAttrib.Find("D")
				this.list.Add(, , A_LoopFileName, A_LoopFileDir)
			else if A_LoopFileExt
				this.list.Add(, A_LoopFileName, , A_LoopFileDir)
		}

		gInfo.Destroy()

		this.list.Opt("+Redraw")
		this.list.ModifyCol() ;It makes the columns fit the data — @rbstrachan

		this.gui.Show("AutoSize")
	}

	DestroyResultListGui() {
		this.gui.Minimize()
		this.gui.Destroy()
	}

	SetOnEvents() {
		this.list.OnEvent("DoubleClick",
			(guiCtrlObj, selectedRow) => this.ShowResultInFolder(selectedRow)
		)
		this.list.OnEvent("ContextMenu",
			(guiCtrlObj, rowNumber, var:=0) => this.CopyPathToClip(rowNumber)
		)
		this.gui.OnEvent("Size",
			(guiObj, minMax, width, height) => this.FixResizing(width, height)
		)
		this.gui.OnEvent("Escape", (guiObj) => this.DestroyResultListGui())
	}

	FixResizing(width, height) {
		this.list.Move(,, width - this.WidthOffset, height - this.HeightOffset)
		/**
		 * When you resize the main gui, the listview also gets resize to have the same
		 * borders as usual.
		 * So, on resize, the onevent passes *what* you resized and the width and height
		 * that's now the current one.
		 * Then you can use that width and height to also resize the listview in relation
		 * to the gui
		 */
	}

	ShowResultInFolder(selectedRow) {
		try Run("explorer.exe /select," this.GetPathFromList(selectedRow))
		/**
		 * By passing select, we achieve the cool highlighting thing when the file / folder
		 * gets opened. (You can pass command line parameters into the run function)
		 */
	}

	CopyPathToClip(rowNumber) {
		A_Clipboard := this.GetPathFromList(rowNumber)
		Info("Path copied to clipboard!")
	}

	GetPathFromList(rowNumber) {
		/**
		 * The OnEvent passes which row we interacted with automatically
		 * So we read the text that's on the row
		 * And concoct it to become the full path
		 * This is much better performance-wise than adding all the full paths to an array
		 * while adding the listviews (in the loop) and accessing it here.
		 * Arguably more readable too
		 */

		file := this.list.GetText(rowNumber, 1)
		dir  := this.list.GetText(rowNumber, 2)
		path := this.list.GetText(rowNumber, 3)

		return path "\" file dir ; No explanation required, it's just logic — @rbstrachan
	}
}

; ------------------------------------------------------------------------------
; @endregion File System Search
; ------------------------------------------------------------------------------

/**
 * Creates a directory if it doesn't exist'
 * @param basePath 
 * @param appendPath 
 * @returns {String}
 */
DirAppend(basePath, appendPath := '') {
	if (SubStr(basePath, 0) != "\") {
		basePath .= "\"
	}
	path := basePath . appendPath
	if (!DirExist(path)) {
		DirCreate(path)
	}
	return path
}
