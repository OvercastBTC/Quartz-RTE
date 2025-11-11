/**********************************************************************************
 * @fileoverview Format conversion utilities for RTF, HTML, Markdown, and Plain Text
 * @version 1.0.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-10-01
 * @license MIT
 * @name FormatConverter.ahk
 * @module FormatConverter
 * @link https://github.com/OvercastBTC/AHK-v2-libraries
 * 
 * @description
 * Comprehensive format conversion library supporting:
 * - RTF (Rich Text Format)
 * - HTML
 * - Markdown
 * - Plain Text
 * - CSV/TSV detection
 * - JSON detection
 * 
 * Includes helper classes:
 * - docProperties: Base class with font and formatting properties
 * - rtfHandler: RTF-specific operations and clipboard handling
 * - markdownHandler: Markdown to RTF conversion
 * - plainText: Plain text clipboard operations
 * 
 * @dependencies
 * - None (standalone module)
 * 
 * @example
 * ; Convert Markdown to RTF
 * rtf := FormatConverter.MarkdownToRTF("# Hello **World**")
 * 
 * ; Detect format
 * format := FormatConverter.DetectFormat(A_Clipboard)
 * 
 * ; Convert HTML to RTF
 * rtf := FormatConverter.HTMLToRTF("<h1>Title</h1><p>Content</p>")
*********************************************************************************/
#Requires AutoHotkey v2+
#Warn All, OutputDebug

;@region class docProperties
/**
 * @class docProperties
 * @description Base class providing shared document formatting properties
 * @version 1.0.0
 */
class docProperties {
	static Properties := {
		FontFamily: 'Times New Roman',
		FontSize: 11,
		FontColor: '000000',
		CharSet: 1252,
		DefaultFont: 'froman',
		DefaultPrq: 2,
		LineHeight: 1.2,
		DefaultMargin: 0,
		DefaultPadding: '0.5em 0',
		StyleMappings: Map(
			'strike', "\strike",
			'super', "\super",
			'sub', "\sub",
			'bullet', "• ",
			"align-left", "\ql",
			"align-right", "\qr",
			"align-center", "\qc",
			"align-justify", "\qj"
		)
	}
}
;@endregion class docProperties

;@region class rtfHandler
/**
 * @class rtfHandler
 * @extends docProperties
 * @description Handles RTF-specific operations including clipboard and header generation
 * @version 1.0.0
 */
class rtfHandler extends docProperties {

	/**
	 * Sets clipboard content as RTF format
	 * @param {String} rtfText The RTF formatted text
	 * @throws {OSError} If clipboard operations fail
	 * @returns {Boolean} True if successful
	 */
	static SetClipboardRTF(rtfText) {
		; Register RTF format if needed
		static CF_RTF := DllCall('RegisterClipboardFormat', 'Str', 'Rich Text Format', 'UInt')
		if !CF_RTF {
			throw OSError('Failed to register RTF clipboard format', -1)
		}

		; Try to open clipboard with retry logic
		maxAttempts := 5
		attempt := 0

		while attempt < maxAttempts {
			if DllCall('OpenClipboard', 'Ptr', 0) {
				break
			}
			attempt++
			if attempt = maxAttempts {
				throw OSError('Failed to open clipboard after ' maxAttempts ' attempts', -1)
			}
			Sleep(50)  ; Wait before next attempt
		}

		try {
			; Clear clipboard
			if !DllCall('EmptyClipboard') {
				throw OSError('Failed to empty clipboard', -1)
			}

			; Allocate global memory
			hGlobal := DllCall('GlobalAlloc', 'UInt', 0x42, 'Ptr', StrPut(rtfText, "UTF-8"))
			if !hGlobal {
				throw OSError('Failed to allocate memory', -1)
			}

			try {
				; Lock and write to memory
				pGlobal := DllCall('GlobalLock', 'Ptr', hGlobal, 'Ptr')
				if !pGlobal {
					throw OSError('Failed to lock memory', -1)
				}

				StrPut(rtfText, pGlobal, "UTF-8")

				; Unlock - ignore return value, check A_LastError instead
				DllCall('GlobalUnlock', 'Ptr', hGlobal)
				if A_LastError && A_LastError != 0x0B7 { ; ERROR_INVALID_PARAMETER (already unlocked)
					throw OSError('Failed to unlock memory', -1)
				}

				; Set clipboard data
				if !DllCall('SetClipboardData', 'UInt', CF_RTF, 'Ptr', hGlobal) {
					throw OSError('Failed to set clipboard data', -1)
				}

				; Ownership transferred to system, don't free the memory
				hGlobal := 0

				return true
			}
			catch Error as e {
				; Clean up on error
				if hGlobal {
					DllCall('GlobalFree', 'Ptr', hGlobal)
				}
				throw e
			}
		}
		finally {
			; Always close clipboard
			DllCall('CloseClipboard')
		}
	}

	/**
	 * @description Generate standard RTF header
	 * @returns {String} RTF header string
	 */
	static GetHeader() {
		props := this.Properties
		return Format('{\rtf1\ansi\ansicpg{1}\deff0\nouicompat\deflang1033{{\fonttbl{{\f0\{2}\fprq{3}\fcharset0 {4};}}}}{{\colortbl;\red0\green0\blue0;}}\viewkind4\uc1\pard\cf1\f0\fs{5}',
			props.CharSet,
			props.DefaultFont,
			props.DefaultPrq,
			props.FontFamily,
			props.FontSize * 2)
	}

	/**
	 * @description Generate RTF list table definition
	 * @returns {String} RTF list table string
	 */
	static GetListTableDef() {
		return "{\*\listtable{\list\listtemplateid2181{\listlevel\levelnfc23\leveljc0\li1910\fi-241{\leveltext\'01\uc1\u61548 ?;}{\levelnumbers;}\f2\fs14\b0\i0}{\listlevel\levelnfc23\leveljc0\li2808\fi-241{\leveltext\'01\'95;}{\levelnumbers;}}{\listlevel\levelnfc23\leveljc0\li3696\fi-241{\leveltext\'01\'95;}{\levelnumbers;}}\listid1026}}{\*\listoverridetable{\listoverride\listoverridecount0\listid1026\ls1}}"
	}
}
;@endregion class rtfHandler

;@region class markdownHandler
/**
 * @class markdownHandler
 * @extends docProperties
 * @description Handles Markdown to RTF conversion with formatting support
 * @version 1.0.0
 */
class markdownHandler extends docProperties {

	/**
	 * @description Convert Markdown to RTF format
	 * @param {String} markdown Markdown text to convert
	 * @returns {String} RTF formatted text
	 */
	static ToRTF(markdown := '') {
		if (!markdown) {
			return ''
		}

	rtf := RTFHandler.GetHeader()
	rtf .= RTFHandler.GetListTableDef()

	text := this._ProcessLists(markdown)
	text := this._ProcessTextFormatting(text)

	rtf .= text "}"
	return rtf
}

/**
	 * @description Process markdown text formatting to RTF with proper newline handling
	 * @param {String} text Markdown text to convert
	 * @returns {String} Text with RTF formatting codes applied
	 * @private
	 */
	static _ProcessTextFormatting(text) {
		props := this.Properties

		; Preserve end spaces and newlines
		text := RegExReplace(text, "(\s+)$", "\line ")  ; Preserve trailing spaces as RTF line breaks

	; Bold with newline preservation
	text := RegExReplace(text, "\*\*([^*]+?)\*\*(\r?\n|\r)", "\b $1\b0 \par")
	text := RegExReplace(text, "\*\*([^*]+?)\*\*", "\b $1\b0 ")

	; Italic handling with improved patterns
	text := RegExReplace(text, "(?<![*])\*([^*]+?)\*(?![*])", "\i $1\i0 ")
	text := RegExReplace(text, "(?<![_])_([^_]+?)_(?![_])", "\i $1\i0 ")

	; Underline with newline preservation - both patterns
	text := RegExReplace(text, "__([^_]+?)__(\r?\n|\r)", "\ul $1\ul0 \par")
	text := RegExReplace(text, "__([^_]+?)__", "\ul $1\ul0 ")
	text := RegExReplace(text, "~([^~]+?)~(\r?\n|\r)", "\ul $1\ul0 \par")
	text := RegExReplace(text, "~([^~]+?)~", "\ul $1\ul0 ")

	; Strikethrough
	text := RegExReplace(text, "~~([^~]+?)~~(\r?\n|\r)", "\strike $1\strike0 \par")
	text := RegExReplace(text, "~~([^~]+?)~~", "\strike $1\strike0 ")		; Headers with font sizes
		try {
			RegExMatch(text, 'm)((?<![#])#+)', &headermatch)
			if (headermatch.len > 0) {
				text := RegExReplace(text, 'm)#{' headermatch.len "}\s([\w]+\b[\w ]+)",
					Format("\line\f0\fs{1}\b $1\b0\f0\fs{2}\line\f0 ",
					props.FontSize[headermatch.len], props.DefaultFont))
			}
		}

	; Special characters
	text := StrReplace(text, "°", "\'b0")

	; Normalize line endings first
	text := RegExReplace(text, "\r\n", "`n")
	text := RegExReplace(text, "\r", "`n")
	
	; Convert blank lines (paragraph breaks) to RTF paragraph markers
	text := RegExReplace(text, "`n`n+", "\par\par ")
	
	; Convert single newlines to RTF line breaks within paragraphs
	text := RegExReplace(text, "(?<!\\par)\n(?!\s*\\par)", "\par ")

	return text
}	
/**
	 * @description Process list formatting with improved structure
	 * @param {String} text The text to process
	 * @returns {String} Processed text with RTF list formatting
	 * @private
	 */
	static _ProcessLists(text) {
		; Split text into lines for processing
		lines := StrSplit(text, "`n")
		processedLines := []
		inList := false
		listLevel := 0

		for i, line in lines {
			; Check if this is a bullet point
			if (RegExMatch(line, "^\s*[-*]\s+(.+)$", &match)) {
				; Determine indentation level
				indent := RegExMatch(line, "^(\s+)", &indentMatch) ? StrLen(indentMatch[1]) : 0
				level := Floor(indent / 2)  ; Convert spaces to logical level

			; Start a new list if needed
			if (!inList) {
				inList := true
				processedLines.Push("
				(
				{\*\listtable{\list\listtemplateid1{\listlevel\levelnfc23\leveljc0\levelfollow0{\leveltext\'01\uc1\u8226 ?;}{\levelnumbers;}\f2\fs20\cf0}{\listname ;}\listid1}})")
				processedLines.Push("{\listoverride\listid1\listoverridecount0\ls1}
				)"
				)
			}				; Output RTF bullet formatting
				if (level == 0) {
					; First level bullet
					processedLines.Push("{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-200\li200 " match[1] "}")
				} else {
					; Indented bullet (second level)
					processedLines.Push("{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-200\li" (200 + level*200) " " match[1] "}")
				}
			}
			else if (RegExMatch(line, "^\s*(\d+)\.?\s+(.+)$", &match)) {
				; Numbered list item
				indent := RegExMatch(line, "^(\s+)", &indentMatch) ? StrLen(indentMatch[1]) : 0
				level := Floor(indent / 2)

			if (!inList) {
				inList := true
				processedLines.Push("
				(
				{\*\listtable{\list\listtemplateid2{\listlevel\levelnfc0\leveljc0\levelfollow0{\leveltext\'02\'00.;}{\levelnumbers\'01;}\fi-200\li200}{\listname ;}\listid2}}
				)")
				processedLines.Push("{\listoverride\listid2\listoverridecount0\ls2}")
			}				; Output RTF numbered list formatting
				if (level == 0) {
					processedLines.Push("{" match[1] ".\tab} " match[2])
				} else {
					processedLines.Push("{\fi-200\li" (200 + level*200) " " match[1] ".\tab " match[2] "}")
				}
			}
			else {
				; Regular paragraph - end list if needed
				if (inList) {
					processedLines.Push("{\listtext\tab}")  ; End list
					inList := false
				}
				processedLines.Push(line)
			}
		}

		; End any open list
		if (inList) {
			processedLines.Push("{\listtext\tab}")
		}

		; Join lines back together - preserve original newlines
		; The _ProcessTextFormatting method will handle \par conversion
		processedText := ""
		for i, line in processedLines {
			if (InStr(line, "{\*\listtable") || InStr(line, "{\listoverride")) {
				processedText .= line  ; No line break for list definitions
			} else if (InStr(line, "{\pntext") || InStr(line, "{\fi-")) {
				processedText .= line "`n"  ; Use newline, will be converted later
			} else {
				processedText .= line "`n"  ; Use newline, will be converted later
			}
		}

		return processedText
	}
}
;@endregion class markdownHandler

;@region class plainText
/**
 * @class plainText
 * @description Handles plain text clipboard operations and pasting
 * @version 1.0.0
 */
class plainText {
	/**
	 * @description Set clipboard content as plain text
	 * @param {String} text Text to set in clipboard
	 * @returns {Boolean} True if successful
	 */
	static SetPlainText(text:='') {
		text := this
		CF_TEXT := 1

		if DllCall("OpenClipboard", "Ptr") {
			DllCall("EmptyClipboard")
			hMem := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", StrPut(text, "UTF-8"))
			pMem := DllCall("GlobalLock", "Ptr", hMem)
			StrPut(text, pMem, "UTF-8")
			DllCall("GlobalUnlock", "Ptr", hMem)
			DllCall("SetClipboardData", "UInt", CF_TEXT, "Ptr", hMem)
			DllCall("CloseClipboard")
			return true
		}
		return false
	}

	/**
	 * @description Send WM_PASTE message to control
	 * @param {Ptr} controlHwnd Handle to the control
	 * @returns {Integer} Result of SendMessage
	 */
	static wmPaste(controlHwnd) {
		WM_PASTE := 0x0302
		return DllCall("SendMessage", "Ptr", controlHwnd, "UInt", WM_PASTE, "Ptr", 0, "Ptr", 0)
	}

	/**
	 * @description Send EM_PASTESPECIAL message to control
	 * @param {Ptr} controlHwnd Handle to the control
	 * @param {Integer} format Format to paste
	 * @returns {Integer} Result of SendMessage
	 */
	static emPasteSpec(controlHwnd, format := 1) {
		EM_PASTESPECIAL := 0x0440
		return DllCall("SendMessage", "Ptr", controlHwnd, "UInt", EM_PASTESPECIAL, "Ptr", format, "Ptr", 0)
	}

	/**
	 * @constructor
	 * @param {String} text Text to paste
	 */
	__New(text := '') {
		hCtl := ''
		plainText.SetPlainText(text)
		try hCtl := ControlGetFocus("A")
		return plainText.emPasteSpec(hCtl)
	}
}
;@endregion class plainText

;@region class FormatConverter
/**
 * @class FormatConverter
 * @description Main format conversion class supporting multiple document formats
 * @version 1.0.0
 */
class FormatConverter {

	/**
	 * @class RTFFormat
	 * @description RTF-specific formatting properties and methods
	 * @memberof FormatConverter
	 */
	class RTFFormat {
		static Properties := {
			FontFamily: "Times New Roman",
			FontSize: 22,  ; RTF uses half-points
			FontColor: "000000",
			DefaultFont: "froman",
			DefaultPrq: 2,
			CharSet: 1252,
			StyleMappings: Map(
				"strike", "\strike",
				"super", "\super",
				"sub", "\sub",
				"bullet", "• ",
				"align-left", "\ql",
				"align-right", "\qr",
				"align-center", "\qc",
				"align-justify", "\qj"
			)
		}

		static GetHeader() {
			props := this.Properties
			return Format('
				(
					{\rtf1\ansi\ansicpg{1}\deff0\nouicompat\deflang1033
					{{\fonttbl{{\f0\{2}\fprq{3}\fcharset0 {4};}}}}
					{{\colortbl ;\red0\green0\blue0;}}
					\viewkind4\uc1\pard\cf1\f0\fs{5}
				)',
				props.CharSet,
				props.DefaultFont,
				props.DefaultPrq,
				props.FontFamily,
				props.FontSize)
		}

		static ApplyFontStyle(text, family := this.Properties.FontFamily, size := this.Properties.FontSize) {
			rtf := this.GetHeader()
			if (size != "")
				rtf .= "\fs" size
			if (family != "")
				rtf .= "\fname " family
			rtf .= " " text "`n}"
			return rtf
		}

		static ApplyFormatting(text, format) {
			props := this.Properties
			if props.StyleMappings.Has(format)
				return props.StyleMappings[format] . " " text . (format ~= "align" ? "" : "\" format "0")
			return text
		}
	}

	static Properties := RTFHandler.Properties

	; Define font sizes
	static dFont := 22  ; Default font size (11pt)

	static dS := this.dFont
	static h6 := this.dS + 2        ; Header 6 size (12pt * 2)
	static h5 := this.h6 + 2        ; Header 5 size (13pt * 2)
	static h4 := this.h5 + 2        ; Header 4 size (14pt * 2)
	static h3 := this.h4 + 2        ; Header 3 size (15pt * 2)
	static h2 := this.h3 + 2        ; Header 2 size (16pt * 2)
	static h1 := this.h2 + 2        ; Header 1 size (17pt * 2)
	static hSize := [this.h6, this.h5, this.h4, this.h3, this.h2, this.h1]

	/**
	 * @description Detects the format of provided text with enhanced clipboard integration
	 * @param {String} content Text content to analyze
	 * @param {Boolean} useClipboardHints Whether to use clipboard format hints if available
	 * @returns {String} Detected format: "rtf", "html", "markdown", "json", "csv", "tsv", or "plaintext"
	 * @throws {TypeError} If content is not a string
	 * @example
	 * format := FormatConverter.DetectFormat("{\rtf1\ansi...")  ; Returns "rtf"
	 * format := FormatConverter.DetectFormat(A_Clipboard, true)  ; Uses clipboard format hints
	 */
	static DetectFormat(content, useClipboardHints := true) {
		; Type validation
		if (!IsString(content)) {
			throw TypeError("Content must be a string", -1)
		}

		; Handle empty content
		if (content == "" || !IsSet(content)) {
			return "plaintext"
		}

		; Trim whitespace for accurate detection
		content := Trim(content)

		; Use existing RTF verification
		rtfResult := this.VerifyRTF(content)
		if (rtfResult.isRTF) {
			return "rtf"
		}

		; Use existing HTML verification
		htmlResult := this.VerifyHTML(content)
		if (htmlResult.isHTML) {
			return "html"
		}

		; JSON Detection - look for JSON structure
		jsonPatterns := [
			"i)^\s*{\s*[\`"']",           ; Object starting with quoted key
			"i)^\s*\[\s*[{\`"]",          ; Array starting with object or string
			"i)^\s*{\s*[\`"']\w+[\`"']\s*:", ; Key-value pair pattern
		]

		for pattern in jsonPatterns {
			if (RegExMatch(content, pattern)) {
				; Additional validation - simple structure check
				if (RegExMatch(content, "^\s*[{\[].*[}\]]\s*$")) {
					return "json"
				}
			}
		}

		; CSV/TSV Detection - analyze delimiter patterns
		lines := StrSplit(content, "`n", "`r")
		if (lines.Length >= 2) {
			firstLine := Trim(lines[1])
			secondLine := Trim(lines[2])

			; Check for consistent delimiter patterns
			commaCount1 := StrLen(firstLine) - StrLen(StrReplace(firstLine, ",", ""))
			commaCount2 := StrLen(secondLine) - StrLen(StrReplace(secondLine, ",", ""))
			tabCount1 := StrLen(firstLine) - StrLen(StrReplace(firstLine, "`t", ""))
			tabCount2 := StrLen(secondLine) - StrLen(StrReplace(secondLine, "`t", ""))

			; CSV detection (comma-separated with consistent comma count)
			if (commaCount1 > 0 && commaCount1 == commaCount2 && commaCount1 >= tabCount1) {
				return "csv"
			}

			; TSV detection (tab-separated with consistent tab count)
			if (tabCount1 > 0 && tabCount1 == tabCount2 && tabCount1 > commaCount1) {
				return "tsv"
			}
		}

			; Markdown Detection - check for markdown-specific patterns
		markdownPatterns := [
			"m)^#{1,6}\s+.+$",           ; Headers
			"m)^\s*[-*+]\s+",            ; Unordered lists
			"m)^\s*\d+\.\s+",            ; Ordered lists
			"\*\*[^*]+\*\*",             ; Bold text
			"(?<!\*)\*[^*]+\*(?!\*)",    ; Italic text (not bold)
			"~~[^~]+~~",                 ; Strikethrough
			"[^``]+``",                  ; Inline code (fixed backtick)
			"``````[\s\S]*?``````",      ; Code blocks (fixed backticks)
			"\[.+?\]\(.+?\)",            ; Links
			"!\[.*?\]\(.+?\)"            ; Images
		]		markdownScore := 0
		for pattern in markdownPatterns {
			if (RegExMatch(content, pattern)) {
				markdownScore++
			}
		}

		; If multiple markdown patterns found, likely markdown
		if (markdownScore >= 2) {
			return "markdown"
		}

		; Special case: Single markdown header
		if (RegExMatch(content, "m)^#{1,6}\s+.+") && lines.Length <= 3) {
			return "markdown"
		}

		; XML Detection (after HTML to avoid conflicts)
		if (RegExMatch(content, "i)^<\?xml") ||
			(RegExMatch(content, "^<[a-zA-Z]") && RegExMatch(content, "</[a-zA-Z]") && !RegExMatch(content, "i)<(html|body|head|div|p|span)"))) {
			return "xml"
		}

		; Default to plaintext if no specific format detected
		return "plaintext"
	}

	/**
	 * Verifies if content is RTF and validates its structure
	 * @param {String} content The content to verify
	 * @returns {Object} {isRTF: Boolean, content: String}
	 */
	static VerifyRTF(content) {
		; Type check
		if !(IsString(content)){
			return {isRTF: false, content: content}
		}

		if !(content ~= 'rtf1') {
			return {isRTF: false, content: content}
		}

		; More detailed RTF validation checks
		rtfChecks := [
			"\{\\rtf1",                     ; RTF version 1
			"\{\\fonttbl",                  ; Font table
			"\{\\colortbl",                 ; Color table
			"\\viewkind4",                  ; View kind
			"\\fs\d+",                      ; Font size
			"\\f\d+",                       ; Font number
			"\\cf\d+",                      ; Color reference
			"\\b(?!\w)",                    ; Bold
			"\\i(?!\w)",                    ; Italic
			"\\ul(?!\w)",                   ; Underline
			"\\strike(?!\w)",               ; Strikethrough
			"\\pard",                       ; Paragraph defaults
			"\\par\b",                      ; Paragraph break
			"\\q[lrcj]",					; Alignment
			"\\'[0-9a-fA-F]{2}",			; Hex character codes
			"\\u\d+",                       ; Unicode character
			"\{[^{}]*\}",                   ; Valid group structure
			"\\[a-z]+(?:-?\d+)?"            ; Valid control words
		]

		matchCount := 0
		for pattern in rtfChecks {
			if RegExMatch(content, "i)" pattern) || content ~= 'i)' pattern {
				matchCount++
			}
		}

		; Calculate confidence score (adjust threshold as needed)
		confidenceThreshold := 2  ; Minimum number of matches needed
		isRTF := matchCount >= confidenceThreshold

		; Validate basic structure integrity
		if isRTF {
			; Check for balanced braces
			braceCount := 0
			Loop Parse, content {
				if (A_LoopField = "{") {
					braceCount++
				}
				else if (A_LoopField = "}") {
					braceCount--
				}
				if (braceCount < 0) {
					return {isRTF: false, content: content}
				}
			}
			if (braceCount != 0) {
				return {isRTF: false, content: content}
			}
		}

		return {isRTF: isRTF, content: content}
	}

	/**
	 * Comprehensive RTF content check and standardization
	 * @param {String} content Content to check/standardize
	 * @param {Boolean} standardize Whether to force standardization
	 * @returns {String} Verified/standardized RTF or original content
	 */
	static IsRTF(content, standardize := true) {
		; Use VerifyRTF to check content
		result := this.VerifyRTF(content)

		; If standardization requested or content is RTF
		if (standardize || result.isRTF) {
			return this.RTFtoRTF(result.content)
		}

		return content
	}

	/**
	 * @description Verify if content is HTML and validate its structure
	 * @param {String} content The content to verify
	 * @returns {Object} {isHTML: Boolean, content: String}
	 */
	static VerifyHTML(content) {

		; HTML tags/structures checks
		arrHTML := [
			'i)^\s*<!DOCTYPE html|^<html|<body',
			'i)<(div|span|p|h[1-6]|table|ul|ol)[>\s]'
		]

		; Default result
		result := {isHTML: false, content: content}

		; Quick checks for HTML indicators
		if (content == ""){
			return result
		}
		; Check for common HTML tags/structures
		isHTML := false
		for _, htm in arrHTML {
			if RegExMatch(content, htm) || content ~= htm {
				isHTML := true
			}
		}

		result.isHTML := isHTML
		return result
	}

	/**
	 * @description Process text formatting elements
	 * @param {String} text The text to process
	 * @returns {String} Processed text with RTF formatting
	 * @private
	 */
	static _ProcessTextFormatting(text) {

		; Bold handling with non-greedy matching
		text := RegExReplace(text, "\*\*([^*]+?)\*\*", "\b $1\b0 ")

		; Italic handling with improved patterns
		text := RegExReplace(text, "(?<![*])\*([^*]+?)\*(?![*])", "\i $1\i0 ")
		text := RegExReplace(text, "(?<![_])_([^_]+?)_(?![_])", "\i $1\i0 ")

		; Strikethrough
		text := RegExReplace(text, "~~([^~]+?)~~", "\strike $1\strike0 ")

		; Underline with multiple patterns
		text := RegExReplace(text, "__([^_]+?)__", "\ul $1\ul0 ")
		text := RegExReplace(text, "~([^~]+?)~", "\ul $1\ul0 ")

		; Special characters
		text := StrReplace(text, "°", "\'b0")

		return text
	}

	/**
	 * @description Process list formatting with improved structure
	 * @param {String} text The text to process
	 * @returns {String} Processed text with RTF list formatting
	 * @private
	 */

	static _ProcessLists(text) {
		; Process headers first with proper RTF formatting
		text := this._ProcessHeaders(text)

		; RegEx pattern for bullet points - capture indentation level
		bulletPattern := 'm)^([\s]*)(- |• )(.*)'  ; Groups: (1)indent (2)bullet (3)text
		bulletPatternOnly := 'm)^([\s]*)(- |• )'

		; RTF list format patterns with \'B7 bullet
		firstLevelBullet := "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li360 $3 \par"

		secondLevelBullet := "\pard{\listtext\f2\'B7\tab}\ls1\ilvl1\fi-360\li720\tx360\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\tx9360 $3 \par"

		arrText := arrMatch := []
		t := match := ''

		arrText := StrSplit(text, '`n')

		; Collect bullet points
		for t in arrtext {
			if t ~= bulletPatternOnly {
				arrMatch.Push(t)
			}
		}

		; Process each bullet point
		for match in arrMatch {
			index := arrText.IndexOf(match)
			; Check if it's an indented bullet (second level)
			if RegExMatch(match, bulletPattern, &m) && m[1] {  ; Has indentation
				nText := RegExReplace(match, bulletPattern, secondLevelBullet)
			} else {  ; First level bullet
				nText := RegExReplace(match, bulletPattern, firstLevelBullet)
			}
			arrText.RemoveAt(index)
			arrText.InsertAt(index, nText)
		}

		text := ''
		for each, value in arrText {
			if value ~= "\\f2\\'B7\\tab" {
				text .= value (A_Index < arrText.Length ? "`n" : '')
			}
			else {
				code := "\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\tx9360\tx10080\f0\fs22 "
				if A_Index == 1 {
					text .= code value
				}
				else {
					text .= code value (A_Index < arrText.Length ? "`n" : '')
				}
			}
		}

		; Handle line breaks
		text := RegExReplace(text, "\R\R+", "\par ")
		text := RegExReplace(text, "(?<!\\par)\R", "\par ")

		; Clean up
		text := RegExReplace(text, "\s+$", "")

		return text
	}

	/**
	 * @description Convert plain text to RTF format
	 * @param {String} text Plain text to convert
	 * @returns {String} RTF formatted text
	 */
	static toRTF(text:=''){
		if !IsSet(text) || text := '' {
			text := this
		}
		; Auto-detect format and convert if needed
		if RegExMatch(text, "^{\rtf1"){ ; Already RTF
			return text
		}
		if RegExMatch(text, "^<!DOCTYPE html|^<html"){ ; HTML
			return FormatConverter.HTMLToRTF(text)
		}
		if RegExMatch(text, "^#|^\*\*|^- "){ ; Markdown
			return FormatConverter.MarkdownToRTF(text)
		}
		; Plain text - convert to RTF
		rtf := RTFHandler.GetHeader()

		; Escape special characters
		text := RegExReplace(text, "([\\{}\r\n])", "\\$1")
		text := StrReplace(text, "\n", "\par")

		; Add text and close
		rtf .= text . "}"
		return rtf
	}

	/**
	 * @description Enhanced RTF processing with proper formatting maintenance
	 * @param {String} rtf The RTF content to process
	 * @param {Boolean} standardize Whether to force standardization
	 * @returns {String} Processed RTF content
	 */
	static RTFtoRTF(rtf := '', standardize := true) {
		if (!rtf) {
			return ''
		}

		; Verify and process RTF content
		verifiedRTF := this.VerifyRTF(rtf)

		; If standardization requested or content is RTF
		if (standardize || verifiedRTF.isRTF) {
			; Start with standard header and list table
			standardRtf := RTFHandler.GetHeader()
			standardRtf .= RTFHandler.GetListTableDef()

			; Extract content after headers
			text := verifiedRTF.content
			if (RegExMatch(rtf, "\\viewkind4\\uc1.*?({[^{]+}|[^{]+)$", &match))
				text := match[1]

			; Clean up content
			text := RegExReplace(text, "^\s*{*\s*", "")  ; Remove leading braces/spaces
			text := RegExReplace(text, "\s*}*\s*$", "")  ; Remove trailing braces/spaces

			; Process line breaks
			text := StrReplace(text, "`r`n", "\line ")
			text := StrReplace(text, "`r", "\line ")

			; Process lists to maintain proper structure
			text := this._ProcessRTFLists(text)

			; Return assembled RTF
			return standardRtf . text . "}"
		}

		return rtf
	}

	/**
	 * @description Converts HTML to RTF with enhanced formatting support
	 * @param {String} html The HTML text to convert
	 * @returns {String} RTF formatted text
	 */
	static HTMLToRTF(html := '') {
		if (!IsSet(html) || html = '')
			return ''

		; Start with enhanced header
		rtf := RTFHandler.GetHeader()
		rtf .= RTFHandler.GetListTableDef()

		text := html

		; Pre-process line breaks for consistent handling
		text := StrReplace(text, "`n", "\line ")
		text := RegExReplace(text, '<br[^>]*>|<BR[^>]*>', '\line ')

		; Enhanced paragraph handling
		text := RegExReplace(text, '<p[^>]*>', '{\pard\plain\s1\nooverflow\nocwrap\lnbrkrule\li1909\sl230\slmult1 ')
		text := RegExReplace(text, '</p>', '\par}')

		; Improved heading handling with proper spacing
		text := RegExReplace(text, '<h1[^>]*>(.*?)</h1>',
			'{\pard\s2\li1689\sl232\slmult1\sb109\f1\fs' . (this.dFont + 4) . '\b1 $1\par}')
		text := RegExReplace(text, '<h2[^>]*>(.*?)</h2>',
			'{\pard\s2\li1689\sl232\slmult1\sb109\f1\fs' . (this.dFont + 2) . '\b1 $1\par}')

		; Enhanced list handling
		text := this._ProcessHTMLLists(text)

		; Style handling with spacing control
		text := RegExReplace(text, '<(b|bold|strong)[^>]*>', '\b ')
		text := RegExReplace(text, '</(b|bold|strong)>', '\b0 ')
		text := RegExReplace(text, '<(i|italics|em)[^>]*>', '\i ')
		text := RegExReplace(text, '</(i|italics|em)>', '\i0 ')
		text := RegExReplace(text, '<u>([^\n]+)</u>', '\ul $1\ul0')
		text := RegExReplace(text, '<s>([^\n]+)</s>', '\strike $1\strike0 ')

		; Special characters
		text := StrReplace(text, "°", "\'b0")

		; Clean up and return
		rtf .= text '}'
		return rtf
	}

	/**
	 * @description Process HTML lists with proper RTF formatting
	 * @param {String} text The text to process
	 * @returns {String} Processed text with RTF list formatting
	 * @private
	 */
	static _ProcessHTMLLists(text) {
		; Convert unordered lists
		text := RegExReplace(text, '<ul[^>]*>', '{\pard\plain\s3\ls1\ilvl0\nooverflow\nocwrap\lnbrkrule\li1909\fi-239\sl240\slmult1 ')
		text := RegExReplace(text, '</ul>', '\par}')

		; Convert list items with proper bullets
		text := RegExReplace(text, '<li[^>]*>', "{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li360 ")
		text := RegExReplace(text, '</li>', '\par')

		return text
	}

	/**
	 * Process markdown headers with proper RTF formatting
	 * @param {String} text Text to process
	 * @returns {String} Processed text with RTF header formatting
	 * @private
	 */
	static _ProcessHeaders(text) {
		; Header font sizes (RTF uses half-points)
		h1Size := 30  ; 15pt
		h2Size := 28  ; 14pt
		h3Size := 26  ; 13pt
		h4Size := 24  ; 12pt
		h5Size := 22  ; 11pt
		h6Size := 20  ; 10pt

		; Process headers with proper RTF formatting
		text := RegExReplace(text, "m)^# (.+)$", "\\pard\\sb240\\sa120\\b\\fs" h1Size " $1\\b0\\fs22\\par")
		text := RegExReplace(text, "m)^## (.+)$", "\\pard\\sb200\\sa100\\b\\fs" h2Size " $1\\b0\\fs22\\par")
		text := RegExReplace(text, "m)^### (.+)$", "\\pard\\sb160\\sa80\\b\\fs" h3Size " $1\\b0\\fs22\\par")
		text := RegExReplace(text, "m)^#### (.+)$", "\\pard\\sb120\\sa60\\b\\fs" h4Size " $1\\b0\\fs22\\par")
		text := RegExReplace(text, "m)^##### (.+)$", "\\pard\\sb100\\sa50\\b\\fs" h5Size " $1\\b0\\fs22\\par")
		text := RegExReplace(text, "m)^###### (.+)$", "\\pard\\sb80\\sa40\\b\\fs" h6Size " $1\\b0\\fs22\\par")

		return text
	}

	/**
	 * @description Process RTF lists maintaining proper structure
	 * @param {String} text The text to process
	 * @returns {String} Processed text with proper RTF list structure
	 * @private
	 */
	static _ProcessRTFLists(text) {
		; Convert basic bullets to properly formatted list items
		text := RegExReplace(text,
			"\\bullet\s+",
			"{\pntext\f2\'B7}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li360 ")

		; Handle list levels
		text := RegExReplace(text,
			"(?<=\\pard)\\plain\\s3\\ls1\\ilvl([0-9])\\nooverflow\\nocwrap\\lnbrkrule",
			"\plain\s3\ls1\ilvl$1\nooverflow\nocwrap\lnbrkrule\li1909\fi-239")

		return text
	}

	/**
	 * Converts Markdown text to RTF format with enhanced header and formatting support
	 * @param {String} markdown The markdown text to convert
	 * @returns {String} RTF formatted text
	 */
	static MarkdownToRTF(markdown := '') {
		if (!IsSet(markdown) || markdown = '') {
			return ''
		}

		; Process content first
		text := markdown
		text := markdownHandler._ProcessTextFormatting(text)
		text := this._ProcessLists(text)

		; Check if result already has RTF header
		if (!RegExMatch(text, "i)^{\s*\\rtf1\b")) {
			; Only add RTF header if needed
			rtf := RTFHandler.GetHeader()
			rtf .= RTFHandler.GetListTableDef()
			rtf .= text "}"
			return rtf
		}

		return text
	}

	/**
	 * @description Converts Markdown text to HTML with proper structure and formatting
	 * @param {String} markdown Markdown text to convert
	 * @returns {String} HTML formatted document
	 */
	static MarkdownToHTML(markdown := '') {
		; Handle empty input
		if (!IsSet(markdown) || markdown = '')
			return ''

		props := this.Properties

		; Pre-process linebreaks for consistent handling
		markdown := StrReplace(markdown, "`r`n", "`n")
		html := markdown

		; Process headers with proper hierarchy
		html := RegExReplace(html, "m)^# ([^`n]+)$", "<h1>$1</h1>")
		html := RegExReplace(html, "m)^## ([^`n]+)$", "<h2>$1</h2>")
		html := RegExReplace(html, "m)^### ([^`n]+)$", "<h3>$1</h3>")
		html := RegExReplace(html, "m)^#### ([^`n]+)$", "<h4>$1</h4>")
		html := RegExReplace(html, "m)^##### ([^`n]+)$", "<h5>$1</h5>")
		html := RegExReplace(html, "m)^###### ([^`n]+)$", "<h6>$1</h6>")

		; Text formatting with non-greedy matching for proper nesting
		html := RegExReplace(html, "\*\*([^*]+?)\*\*", "<strong>$1</strong>")
		html := RegExReplace(html, "__([^_]+?)__", "<strong>$1</strong>")
		html := RegExReplace(html, "(?<!\*)\*([^*]+?)\*(?!\*)", "<em>$1</em>")
		html := RegExReplace(html, "(?<!_)_([^_]+?)_(?!_)", "<em>$1</em>")
		html := RegExReplace(html, "~~([^~]+?)~~", "<del>$1</del>")
		html := RegExReplace(html, "``([^``]+?)``", "<code>$1</code>")

		; Process lists with proper structure
		; First convert list items
		html := RegExReplace(html, "m)^- (.+)$", "<li>$1</li>")
		html := RegExReplace(html, "m)^(\d+)\. (.+)$", "<li>$2</li>")

		; Then wrap consecutive list items in appropriate list containers
		html := RegExReplace(html, "(<li>.*</li>\n)+", "<ul>\n$0</ul>\n")

		; Handle paragraphs and line breaks
		html := RegExReplace(html, "(`n`n|^)(?!<[uo]l|<[hp]|<li)(.+?)(?=`n`n|$)", "<p>$2</p>")
		html := RegExReplace(html, "(?<!</p>|</li>|</h\d>)\n(?!<)(?!ul|li|/ul|p>|h\d)", "<br>\n")

		; Process links
		html := RegExReplace(html, "\[([^\]]+)\]\(([^)]+)\)", '<a href="$2">$1</a>')

		; Process images with alt text
		html := RegExReplace(html, "!\[([^\]]*)\]\(([^)]+)\)", '<img src="$2" alt="$1">')

		; Create complete HTML document with styling
		html := Format('
		(
			<!DOCTYPE html>
			<html>
			<head>
			<meta charset="utf-8">
			<title>Converted Markdown</title>
			<style>
			body {
				font-family: {1};
				font-size: {2}pt;
				line-height: 1.6;
				margin: 2em;
			}
			h1, h2, h3, h4, h5, h6 { margin-top: 1.5em; margin-bottom: 0.5em; }
			p { margin: 1em 0; }
			ul, ol { margin-left: 1em; padding-left: 1em; }
			li { margin: 0.25em 0; }
			code { background-color: #f6f8fa; padding: 0.2em 0.4em; border-radius: 3px; }
			a { color: #0366d6; text-decoration: none; }
			a:hover { text-decoration: underline; }
			img { max-width: 100%; }
			</style>
			</head>
			<body>
			{3}
			</body>
			</html>
		)',
		props.FontFamily,
		props.FontSize,
		html)

		return html
	}

	/**
	 * @description Convert RTF to Markdown format
	 * @param {String} rtfText RTF text to convert
	 * @returns {String} Markdown formatted text
	 */
	static RTFToMarkdown(rtfText) {
		; Check for valid input
		if (!rtfText)
			return ""

		plainText := ""

		; Create temporary files for the conversion process
		tempRtfFile := A_Temp "\temp_rtf_" A_TickCount ".rtf"
		tempTextFile := A_Temp "\temp_text_" A_TickCount ".txt"

		; Save RTF content to temp file
		try {
			FileOpen(tempRtfFile, "w").Write(rtfText).Close()
		} catch Error as e {
			return "Error creating temp file: " e.Message
		}

		; Use Word COM object to convert RTF to plain text
		try {
			word := ComObject("Word.Application")
			word.Visible := false
			doc := word.Documents.Open(tempRtfFile)

			; Extract formatting information
			markdownText := ""
			for idx in doc.Paragraphs.Count {
				para := doc.Paragraphs(idx)
				paraText := para.Range.Text

				; Handle basic formatting
				if (para.Range.Bold = -1)
					paraText := "**" paraText "**"
				if (para.Range.Italic = -1)
					paraText := "*" paraText "*"

				; Add the paragraph to our markdown
				markdownText .= paraText "`n`n"
			}

			; Cleanup
			doc.Close(0)  ; Don't save changes
			word.Quit()

			; Delete temp files
			try {
				FileDelete(tempRtfFile)
				FileDelete(tempTextFile)
			}

			return markdownText
		} catch Error as e {
			; Fallback method if COM fails
			return this._RTFToMarkdownFallback(rtfText)
		}
	}

	/**
	 * Fallback method that doesn't require COM objects
	 * @param {String} rtfText RTF text to convert
	 * @returns {String} Plain text with basic markdown
	 * @private
	 */
	static _RTFToMarkdownFallback(rtfText) {
		; Remove RTF control sequences
		plainText := RegExReplace(rtfText, "\\[a-zA-Z0-9]+\s?", "")

		; Remove curly braces
		plainText := RegExReplace(plainText, "[{}]", "")

		; Handle paragraph breaks
		plainText := RegExReplace(plainText, "\\par\b", "`n`n")

		return Trim(plainText)
	}

	/**
	 * @description Convert RTF to HTML format
	 * @param {String} rtfText RTF text to convert
	 * @returns {String} HTML formatted document
	 */
	static RTFToHTML(rtfText) {
		; Check for valid input
		if (!rtfText)
			return ""

		; Use existing conversion chain: RTF -> Markdown -> HTML
		markdownText := this.RTFToMarkdown(rtfText)
		return this.MarkdownToHTML(markdownText)
	}
}
;@endregion class FormatConverter
