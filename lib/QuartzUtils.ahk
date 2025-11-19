/************************************************************************
 * @description QuartzUtils - Consolidated utility class for Quartz RTE
 * @file QuartzUtils.ahk
 * @author Consolidated by Claude from multiple dependencies
 * @date 2025/11/18
 * @version 1.1.0
 * @requires AutoHotkey v2+
 ***********************************************************************/
#Requires AutoHotkey v2+

/**
 * @class QuartzUtils
 * @description Consolidated utility class with essential methods for Quartz RTE
 * Replaces: Clipboard.ahk, WindowManager.ahk, Pandoc.ahk (partial), Pipe.ahk, TestLogger.ahk
 */
class QuartzUtils {
	; ---------------------------------------------------------------------------
	; @region Static Properties
	; ---------------------------------------------------------------------------
	static Version := "1.1.0"
	static _delayCache := 50
	static _lastDelayUpdate := 0
	static _delayInterval := 5000
	; @endregion Static Properties
	; ---------------------------------------------------------------------------
	; @region Clipboard Utilities
	; ---------------------------------------------------------------------------
	/**
	 * @description Backup the clipboard contents
	 * @returns {Array} Clipboard backup data
	 */
	static BackupClipboard() {
		backup := []
		
		; Save clipboard formats
		if DllCall("OpenClipboard", "Ptr", 0) {
			format := 0
			while (format := DllCall("EnumClipboardFormats", "UInt", format)) {
				if (hData := DllCall("GetClipboardData", "UInt", format, "Ptr")) {
					size := DllCall("GlobalSize", "Ptr", hData, "UPtr")
					if (size > 0) {
						pData := DllCall("GlobalLock", "Ptr", hData, "Ptr")
						if (pData) {
							buf := Buffer(size)
							DllCall("RtlMoveMemory", "Ptr", buf, "Ptr", pData, "UPtr", size)
							backup.Push({format: format, data: buf, size: size})
							DllCall("GlobalUnlock", "Ptr", hData)
						}
					}
				}
			}
			DllCall("CloseClipboard")
		}
		
		return backup
	}
	
	/**
	 * @description Restore clipboard from backup
	 * @param {Array} backup Clipboard backup data
	 */
	static RestoreClipboard(backup) {
		if (!IsObject(backup) || backup.Length = 0)
			return
		
		DllCall("OpenClipboard", "Ptr", 0)
		DllCall("EmptyClipboard")
		
		for item in backup {
			hMem := DllCall("GlobalAlloc", "UInt", 0x0042, "UPtr", item.size, "Ptr")
			if (hMem) {
				pMem := DllCall("GlobalLock", "Ptr", hMem, "Ptr")
				if (pMem) {
					DllCall("RtlMoveMemory", "Ptr", pMem, "Ptr", item.data, "UPtr", item.size)
					DllCall("GlobalUnlock", "Ptr", hMem)
					DllCall("SetClipboardData", "UInt", item.format, "Ptr", hMem)
				}
			}
		}
		
		DllCall("CloseClipboard")
	}
	
	/**
	 * @description Wait for clipboard to have data
	 * @param {Integer} timeout Maximum wait time in milliseconds
	 * @returns {Boolean} True if clipboard has data, false if timeout
	 */
	static WaitForClipboard(timeout := 1000) {
		startTime := A_TickCount
		while (!ClipboardAll() && (A_TickCount - startTime < timeout)) {
			Sleep(10)
		}
		return ClipboardAll() ? true : false
	}
	
	/**
	 * @description Clear the clipboard
	 */
	static ClearClipboard() {
		if DllCall("OpenClipboard", "Ptr", 0) {
			DllCall("EmptyClipboard")
			DllCall("CloseClipboard")
		}
	}
	; @endregion Clipboard Utilities
	
	; ---------------------------------------------------------------------------
	; @region Window Management
	; ---------------------------------------------------------------------------
	/**
	 * @description Position window on left side of screen
	 * @param {Integer} hwnd Window handle
	 * @param {Float} widthPercent Width as percentage of screen (default 0.5 = 50%)
	 */
	static PositionWindowLeft(hwnd, widthPercent := 0.5) {
		MonitorGetWorkArea(, &left, &top, &right, &bottom)
		width := Floor((right - left) * widthPercent)
		height := bottom - top
		WinMove(left, top, width, height, "ahk_id " hwnd)
	}
	
	/**
	 * @description Position window on right side of screen
	 * @param {Integer} hwnd Window handle
	 * @param {Float} widthPercent Width as percentage of screen (default 0.5 = 50%)
	 */
	static PositionWindowRight(hwnd, widthPercent := 0.5) {
		MonitorGetWorkArea(, &left, &top, &right, &bottom)
		width := Floor((right - left) * widthPercent)
		height := bottom - top
		leftPos := right - width
		WinMove(leftPos, top, width, height, "ahk_id " hwnd)
	}
	
	/**
	 * @description Center window on screen
	 * @param {Integer} hwnd Window handle
	 * @param {Integer} width Optional width (uses current if not specified)
	 * @param {Integer} height Optional height (uses current if not specified)
	 */
	static CenterWindow(hwnd, width := 0, height := 0) {
		MonitorGetWorkArea(, &left, &top, &right, &bottom)
		
		if (width = 0 || height = 0) {
			WinGetPos(, , &currentWidth, &currentHeight, "ahk_id " hwnd)
			width := width = 0 ? currentWidth : width
			height := height = 0 ? currentHeight : height
		}
		
		centerX := left + ((right - left - width) / 2)
		centerY := top + ((bottom - top - height) / 2)
		
		WinMove(centerX, centerY, width, height, "ahk_id " hwnd)
	}
	; @endregion Window Management
	
	; ---------------------------------------------------------------------------
	; @region Format Conversion (Simplified from Pandoc)
	; ---------------------------------------------------------------------------
	/**
	 * @description Detect format of text content
	 * @param {String} text Text to analyze
	 * @returns {String} Detected format: "markdown", "html", "rtf", or "plain"
	 */
	static DetectFormat(text) {
		; Check for RTF
		if (SubStr(text, 1, 5) = "{\rtf")
			return "rtf"
		
		; Check for HTML
		if (RegExMatch(text, "i)<(!DOCTYPE html|html|<head|<body|<div|<p)"))
			return "html"
		
		; Check for Markdown patterns
		if (RegExMatch(text, "^#{1,6}\s+.+$", ) 
			|| RegExMatch(text, "^\*{1,2}.+\*{1,2}$")
			|| RegExMatch(text, "^\[.+\]\(.+\)$")
			|| RegExMatch(text, "^[-*+]\s+.+$"))
			return "markdown"
		
		return "plain"
	}
	
	/**
	 * @description Convert Markdown to HTML (basic conversion)
	 * @param {String} markdown Markdown text
	 * @returns {String} HTML text
	 */
	static MarkdownToHTML(markdown) {
		html := markdown
		
		; Headers
		html := RegExReplace(html, "m)^######\s+(.+)$", "<h6>$1</h6>")
		html := RegExReplace(html, "m)^#####\s+(.+)$", "<h5>$1</h5>")
		html := RegExReplace(html, "m)^####\s+(.+)$", "<h4>$1</h4>")
		html := RegExReplace(html, "m)^###\s+(.+)$", "<h3>$1</h3>")
		html := RegExReplace(html, "m)^##\s+(.+)$", "<h2>$1</h2>")
		html := RegExReplace(html, "m)^#\s+(.+)$", "<h1>$1</h1>")
		
		; Bold and Italic
		html := RegExReplace(html, "\*\*(.+?)\*\*", "<strong>$1</strong>")
		html := RegExReplace(html, "\*(.+?)\*", "<em>$1</em>")
		html := RegExReplace(html, "__(.+?)__", "<strong>$1</strong>")
		html := RegExReplace(html, "_(.+?)_", "<em>$1</em>")
		
		; Links
		html := RegExReplace(html, "\[(.+?)\]\((.+?)\)", "<a href='$2'>$1</a>")
		
		; Line breaks
		html := RegExReplace(html, "`r`n`r`n", "</p><p>")
		html := RegExReplace(html, "`n`n", "</p><p>")
		
		return "<p>" html "</p>"
	}
	
	/**
	 * @description Convert HTML to plain text (strip tags)
	 * @param {String} html HTML text
	 * @returns {String} Plain text
	 */
	static HTMLToText(html) {
		text := html
		
		; Replace common block elements with newlines
		text := RegExReplace(text, "i)<br\s*/?>", "`n")
		text := RegExReplace(text, "i)</p>", "`n`n")
		text := RegExReplace(text, "i)</div>", "`n")
		text := RegExReplace(text, "i)</h[1-6]>", "`n`n")
		
		; Remove all HTML tags
		text := RegExReplace(text, "<[^>]+>", "")
		
		; Decode common HTML entities
		text := StrReplace(text, "&nbsp;", " ")
		text := StrReplace(text, "&lt;", "<")
		text := StrReplace(text, "&gt;", ">")
		text := StrReplace(text, "&amp;", "&")
		text := StrReplace(text, "&quot;", '"')
		
		return Trim(text)
	}
	; @endregion Format Conversion
	
	; ---------------------------------------------------------------------------
	; @region Pipe Communication
	; ---------------------------------------------------------------------------
	/**
	 * @description Get system delay for operations
	 * @returns {Integer} Delay in milliseconds
	 */
	static GetSystemDelay() {
		return A_DefaultMouseSpeed
	}
	; @endregion Pipe Communication
	
	; ---------------------------------------------------------------------------
	; @region Delay Management (from DelayManager)
	; ---------------------------------------------------------------------------
	/**
	 * @property {Integer} Delay
	 * @description Gets the current cached delay value in ms.
	 * @returns {Integer} Delay in milliseconds
	 */
	static Delay {
		get {
			now := A_TickCount
			if (now - this._lastDelayUpdate > this._delayInterval) {
				this.RecalculateDelay()
			}
			return this._delayCache
		}
	}
	
	/**
	 * @description High-precision delay calibration using QueryPerformanceCounter.
	 * @param {Integer} iterations Number of iterations to run.
	 * @returns {Map} Map with keys: delay (ms), elapsed (ticks), freq (Hz)
	 * @throws {ValueError} If iterations is not a positive integer.
	 */
	static QueryPerformanceTime(iterations := 1000) {
		local freq := 0, start := 0, finish := 0, num := 0
		
		if !IsSet(iterations) || iterations < 1 {
			throw ValueError("Iterations must be a positive integer", -1)
		}
		
		DllCall("QueryPerformanceFrequency", "Int64*", &freq)
		DllCall("QueryPerformanceCounter", "Int64*", &start)
		
		Loop iterations {
			num := A_Index ** 2
			num /= 2
		}
		
		DllCall("QueryPerformanceCounter", "Int64*", &finish)
		local elapsed := finish - start
		local delay := Round((elapsed / freq) * 1000)
		
		return Map("delay", delay, "elapsed", elapsed, "freq", freq)
	}
	
	/**
	 * @description Calculate system delay time using specified method.
	 * @param {String} method Timing method ('query', 'tick', 'combined')
	 * @param {Integer} samples Number of samples to collect
	 * @param {Integer} iterations Iterations per sample
	 * @returns {Number} Calibrated delay time in milliseconds
	 * @throws {ValueError} If parameters are invalid.
	 */
	static GetDelayTime(method := 'combined', samples := 5, iterations := 1000) {
		local delays := []
		local delay := 0
		
		if !IsSet(method) {
			method := 'query'
		}
		if !IsSet(samples) || samples < 1 {
			samples := 5
		}
		if !IsSet(iterations) || iterations < 1 {
			iterations := 1000
		}
		
		Loop samples {
			switch method {
				case "query":
					result := this.QueryPerformanceTime(iterations)
					delay := result["delay"]
				case "tick":
					tickBefore := A_TickCount
					Loop iterations {
						num := A_Index ** 2
						num /= 2
					}
					delay := A_TickCount - tickBefore
				case "combined":
					qpResult := this.QueryPerformanceTime(iterations)
					tickBefore := A_TickCount
					Loop iterations {
						num := A_Index ** 2
						num /= 2
					}
					tickDelay := A_TickCount - tickBefore
					delay := Round((qpResult["delay"] + tickDelay) / 2)
				default:
					throw ValueError("Unknown timing method: " method, -1)
			}
			delays.Push(delay)
		}
		
		; Return median value for stability
		delays := this._SortArray(delays)
		return delays[Floor(delays.Length / 2) + 1]
	}
	
	/**
	 * @description Force recalculation of delay.
	 * @returns {QuartzUtils} This class for method chaining.
	 */
	static RecalculateDelay() {
		try {
			this._delayCache := this.GetDelayTime()
		} catch Error as err {
			this._delayCache := 50
		}
		this._lastDelayUpdate := A_TickCount
		return this
	}
	
	/**
	 * @description Set the delay update interval in ms.
	 * @param {Integer} ms Interval in milliseconds.
	 * @returns {QuartzUtils} This class for method chaining.
	 */
	static SetDelayInterval(ms) {
		if (!IsSet(ms) || ms < 100) {
			throw ValueError("Interval must be >= 100 ms", -1)
		}
		this._delayInterval := ms
		return this
	}
	
	/**
	 * @private
	 * @description Sort array helper method
	 * @param {Array} arr Array to sort
	 * @returns {Array} Sorted array
	 */
	static _SortArray(arr) {
		; Simple bubble sort for small arrays
		n := arr.Length
		Loop n - 1 {
			i := A_Index
			Loop n - i {
				j := A_Index
				if (arr[j] > arr[j + 1]) {
					temp := arr[j]
					arr[j] := arr[j + 1]
					arr[j + 1] := temp
				}
			}
		}
		return arr
	}
	; @endregion Delay Management
	
	; ---------------------------------------------------------------------------
	; @region Debug Utilities (replaces TestLogger)
	; ---------------------------------------------------------------------------
	/**
	 * @description Debug output to console or file
	 * @param {String} message Debug message
	 * @param {String} level Debug level (INFO, WARN, ERROR)
	 */
	static Debug(message, level := "INFO") {
		timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
		output := "[" timestamp "] [" level "] " message
		
		; Output to debug console (if available)
		OutputDebug(output)
		
		; Optionally write to log file
		; FileAppend(output "`n", "quartz_debug.log")
	}
	
	/**
	 * @description Show debug tooltip
	 * @param {String} message Message to display
	 * @param {Integer} duration Duration in milliseconds (default 2000)
	 */
	static DebugTooltip(message, duration := 2000) {
		ToolTip(message)
		SetTimer(() => ToolTip(), -duration)
	}
	; @endregion Debug Utilities
}

; ---------------------------------------------------------------------------
; Global Variables
; ---------------------------------------------------------------------------
/**
 * @global A_Delay
 * @description Global delay variable for system operations (dynamically updated)
 */
Global A_Delay := QuartzUtils.Delay
