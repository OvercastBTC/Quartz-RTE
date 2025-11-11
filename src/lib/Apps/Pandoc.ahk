/**
 * @class Pandoc
 * @description Utility class for Pandoc conversions and format detection with enhanced RTF bullet formatting.
 * Provides specialized conversion methods for different input formats.
 * 
 * Supported Formatting Patterns:
 * - Bold: **text** or <b>text</b>
 * - Italic: *text* or _text_ or <i>text</i>
 * - Bold+Italic: ***text*** or _**text**_
 * - Underline: <u>text</u> or ~text~ (custom preprocessing)
 * - Strikethrough: ~~text~~ or <s>text</s>
 * - Bullets: - item or * item
 * 
 * Note: __text__ is treated as BOLD (standard markdown), not underline.
 * Use <u>text</u> or ~text~ for underline formatting.
 * 
 * @version 1.12.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-11-03
 * @requires AutoHotkey v2.0+
 * @dependency FormatDetector
 * @example
 *   ; Main conversion method (auto-detects format)
 *   rtf := Pandoc.toRTF(content)
 *
 *   ; Generic conversion between any formats
 *   rtf := Pandoc.Convert("markdown", "rtf", content)
 *   html := Pandoc.Convert("rtf", "html", content)
 *   md := Pandoc.Convert("html", "markdown", content)
 *
 *   ; Specialized converters
 *   rtf := Pandoc.MarkdownToRTF(markdownContent)
 *   rtf := Pandoc.HTMLToRTF(htmlContent)
 *   rtf := Pandoc.PlainTextToRTF(textContent)
 *   md := Pandoc.RTFtoMarkdown(rtfContent)
 *   html := Pandoc.MarkdownToHTML(markdownContent)
 *   html := Pandoc.md2html(markdownContent)  ; Short wrapper
 *
 *   ; Underline support examples
 *   md := "This is <u>underlined</u> text"  ; HTML u tag (recommended)
 *   md := "This is ~underlined~ text"       ; Tilde pattern (custom)
 *   rtf := Pandoc.MarkdownToRTF(md)         ; Both patterns work
 *   
 *   ; NOTE: __text__ is BOLD in standard markdown, NOT underline
 *
 *   ; Other formats
 *   md := Pandoc.toMD(rtfContent)
 *   html := Pandoc.toHTML(content)
 *   fmt := Pandoc.DetectFormat(content)
 */

#Include <System\Paths>
#Include <Extensions/.modules/Clipboard>
#Include <Extensions/.formats/FormatConverter>

class Pandoc {
	static dirPandoc 	:= Paths.Pandoc
	static zipFile 		:= this.dirPandoc '\pandoc.zip'
	static exe 			:= this._GetPandocExe()
	static temp 		:= A_Temp '\temp'
	static tempRTF 		:= this.temp ".rtf"
	static tempMD 		:= this.temp '.md'
	static tempJSON 	:= this.temp '.json'
	static tempHTML 	:= this.temp '.html'
	static tempXML 		:= this.temp '.xml'
	static tempCSV 		:= this.temp '.csv'
	static tempXLSX 	:= this.temp '.xlsx'
	static tempDOCX 	:= this.temp '.docx'
	static tempDOC 		:= this.temp '.doc'
	static tempTXT 		:= this.temp '.txt'
	static tempPDF 		:= this.temp '.pdf'
	static tempODT 		:= this.temp '.odt'
	static tempODP 		:= this.temp '.odp'
	static tempODG 		:= this.temp '.odg'
	static tempODF 		:= this.temp '.odf'

	/**
	 * Get or extract pandoc.exe from zip if needed
	 * @returns {String} Path to pandoc.exe
	 * @private
	 */
	static _GetPandocExe() {
		; Check if pandoc.exe already exists (unzipped)
		exePath := this.dirPandoc '\pandoc.exe'
		if FileExist(exePath) {
			return exePath
		}

		; The pandoc.zip should be in the repo at Extensions\.formats\pandoc\pandoc.zip
		zipPath := this.zipFile
		
		if !FileExist(zipPath) {
			throw Error("Pandoc zip file not found: " zipPath 
				. "`n`nThe pandoc.zip file should be in the repository at:"
				. "`n" this.dirPandoc "\pandoc.zip"
				. "`n`nPlease ensure the repository is properly synced.")
		}

		; Extract pandoc.exe from zip to permanent location in dirPandoc
		return this._ExtractPandocFromZip(zipPath, exePath)
	}

	/**
	 * Extract pandoc.exe from zip file using optimized PowerShell method
	 * Handles both root-level and nested folder structures (e.g., pandoc-3.1.11/pandoc.exe)
	 * @param {String} zipPath Path to source zip file
	 * @param {String} exePath Path where exe should be extracted
	 * @returns {String} Path to extracted pandoc.exe
	 * @throws {Error} If extraction fails
	 * @private
	 */
	static _ExtractPandocFromZip(zipPath, exePath) {
		; Enhanced PowerShell extraction - handles nested folders
		; Searches for pandoc.exe anywhere in the zip, not just at root
		psCmd := Format('
		(
			Add-Type -AssemblyName System.IO.Compression.FileSystem
			$zip = [System.IO.Compression.ZipFile]::OpenRead(''{1}'')
			
			# Find pandoc.exe anywhere in the zip (handles versioned folders)
			$entry = $zip.Entries | Where-Object {{ $_.Name -eq ''pandoc.exe'' }} | Select-Object -First 1
			
			if ($entry) {{
				try {{
					[System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, ''{2}'', $true)
					Write-Output "SUCCESS: Extracted from $($entry.FullName)"
				}} catch {{
					Write-Output "ERROR: $($_.Exception.Message)"
				}}
			}} else {{
				Write-Output "ERROR: pandoc.exe not found in zip"
			}}
			
			$zip.Dispose()
		)', zipPath, exePath)

		; Execute extraction using ComObject for better control
		extractResult := ""
		try {
			shell := ComObject("WScript.Shell")
			exec := shell.Exec('powershell.exe -NoProfile -Command "' psCmd '"')
			extractResult := exec.StdOut.ReadAll()
		} catch as err {
			throw Error("PowerShell extraction failed: " err.Message 
				. "`n`nZip file: " zipPath
				. "`n`nTarget: " exePath)
		}

		; Verify extraction succeeded
		if !FileExist(exePath) {
			errorMsg := "Failed to extract pandoc.exe from " zipPath 
			
			; Include PowerShell output for debugging
			if (extractResult && InStr(extractResult, "ERROR:")) {
				errorMsg .= "`n`nExtraction error: " Trim(extractResult)
			} else if (extractResult) {
				errorMsg .= "`n`nExtraction output: " Trim(extractResult)
			}
			
			errorMsg .= "`n`nPossible solutions:"
				. "`n1. Manually extract pandoc.exe to: " this.dirPandoc
				. "`n2. Download from: https://pandoc.org/installing.html"
				. "`n3. Ensure zip file is not corrupted"
				. "`n4. Check antivirus/security software is not blocking extraction"
			
			throw Error(errorMsg)
		}

		return exePath
	}

	/**
	 * Converts markdown or other content to JSON using Pandoc.
	 * @param {String} content Input content
	 * @returns {String} JSON string
	 * @throws {Error} If conversion fails
	 */
	static toJSON(content) {
		txtFormat := this.DetectFormat(content)
		srcFile := this._GetTempFile(txtFormat)
		FileAppend(content, srcFile)
		exitCode := RunWait(this.exe ' "' srcFile '" -o "' this.tempJSON '" --from ' txtFormat ' --to json -s',, "Hide")
		if (exitCode != 0) {
			throw Error("Failed to convert " txtFormat " to JSON (exit code: " exitCode ")")
		}
		; return FileRead(this.tempJSON, 'UTF-8')
	}

	/**
	 * Converts RTF or other content to Markdown using Pandoc.
	 * @param {String} content Input content
	 * @returns {String} Markdown string
	 * @throws {Error} If conversion fails
	 */
	static toMD(content) {
		txtFormat := this.DetectFormat(content)
		srcFile := this._GetTempFile(txtFormat)
		FileAppend(content, srcFile)
		exitCode := RunWait(this.exe ' "' srcFile '" -o "' this.tempMD '" --from ' txtFormat ' --to markdown -s',, "Hide")
		if (exitCode != 0) {
			throw Error("Failed to convert " txtFormat " to Markdown (exit code: " exitCode ")")
		}
		return FileRead(this.tempMD, 'UTF-8')
	}

	/**
	 * Converts Markdown or other content to HTML using Pandoc.
	 * @param {String} content Input content
	 * @returns {String} HTML string
	 * @throws {Error} If conversion fails
	 */
	static toHTML(content) {
		txtFormat := this.DetectFormat(content)
		srcFile := this._GetTempFile(txtFormat)
		FileAppend(content, srcFile)
		exitCode := RunWait(this.exe ' "' srcFile '" -o "' this.tempHTML '" --from ' txtFormat ' --to html -s',, "Hide")
		if (exitCode != 0) {
			throw Error("Failed to convert " txtFormat " to HTML (exit code: " exitCode ")")
		}
		return FileRead(this.tempHTML, 'UTF-8')
	}

	/**
	 * Main RTF conversion method that routes to appropriate specialized converter.
	 * @param {String} content Input content
	 * @returns {String} RTF string with proper bullet formatting
	 * @throws {Error} If conversion fails
	 */
	static toRTF(content) {
		txtFormat := this.DetectFormat(content)

		; Route to specialized converters based on format
		switch txtFormat {
			case "markdown":
				return this.MarkdownToRTF(content)
			case "html":
				return this.HTMLToRTF(content)
			case "rtf":
				return this.RTFToRTF(content)
			case "plaintext", "plain":
				return this.PlainTextToRTF(content)
			default:
				; Use Pandoc for other formats
				return this.PandocToRTF(content, txtFormat)
		}
	}

	/**
	 * Convert Markdown to RTF using internal converter for best bullet formatting.
	 * Supports custom underline patterns: __text__ (when not used for bold), ~text~, and <u>text</u>
	 * @param {String} content Markdown content
	 * @returns {String} RTF formatted content
	 * @throws {Error} If conversion fails
	 */
	static MarkdownToRTF(content) {
		if (!content) {
			throw Error("Empty markdown content provided")
		}

		; ; Pre-process markdown to handle underline patterns
		; ; Standard markdown doesn't support underline, so we convert custom patterns to HTML <u> tags
		; processedContent := this._PreprocessMarkdownUnderline(content)

		; ; Clean up any existing temp files first
		; if FileExist(this.tempMD) {
		; 	FileDelete(this.tempMD)
		; }
		; if FileExist(this.tempRTF) {
		; 	FileDelete(this.tempRTF)
		; }

		; ; Write processed markdown content to temp file
		; FileAppend(processedContent, this.tempMD)

		; ; Use Pandoc to convert markdown to RTF with better formatting options
		; ; Enable raw HTML parsing so <u> tags are processed
		; pandocCmd := this.exe ' "' this.tempMD '" -o "' this.tempRTF '" --from markdown+raw_html --to rtf --standalone --wrap=auto'

		; exitCode := RunWait(pandocCmd,, "Hide")
		; if (exitCode != 0) {
		; 	try {
		; 		; Clean up temp files on error
		; 		FileDelete(this.tempMD)
		; 		FileDelete(this.tempRTF)
		; 	} catch {
		; 		; Ignore cleanup errors
		; 	}
		; 	throw Error("Failed to convert Markdown to RTF using Pandoc (exit code: " exitCode ")")
		; }

		; ; Read the converted RTF content
		; result := FileRead(this.tempRTF, 'UTF-8')

		; ; Clean up temp files
		; try {
		; 	FileDelete(this.tempMD)
		; } catch {
		; 	; Ignore cleanup errors
		; }
		; try {
		; 	FileDelete(this.tempRTF)
		; } catch {
		; 	; Ignore cleanup errors
		; }

		; Use the generic Convert method which handles all the temp file management
		return this.Convert("markdown", "html", content)

		; ; Post-process to fix bullet formatting if needed
		; if (result && InStr(result, '\bullet')) {
		; 	result := this._FixRTFBullets(result)
		; }

		; return result
	}

	/**
	 * Generic conversion method between any supported formats
	 * @param {String} from Source format identifier (markdown, rtf, html, etc.)
	 * @param {String} to Target format identifier (markdown, rtf, html, etc.)
	 * @param {String} content Content to convert
	 * @returns {String} Converted content
	 * @throws {Error} If conversion fails or unsupported format
	 */
	static Convert(from, to, content) {
		if (!content) {
			throw Error("Empty content provided for conversion")
		}

		; Normalize format identifiers
		fromFormat := this._NormalizeFormat(from)
		toFormat := this._NormalizeFormat(to)

		; Validate supported formats
		if (!this._IsValidFormat(fromFormat)) {
			throw Error("Unsupported source format: " from)
		}
		if (!this._IsValidFormat(toFormat)) {
			throw Error("Unsupported target format: " to)
		}

		; Get temp file paths for source and target
		srcFile := this._GetTempFile(fromFormat)
		targetFile := this._GetTempFile(toFormat)

		; Clean up any existing temp files first
		try {
			FileDelete(srcFile)
		} catch {
			; Ignore cleanup errors
		}
		try {
			FileDelete(targetFile)
		} catch {
			; Ignore cleanup errors
		}

		; Write content to source temp file
		FileAppend(content, srcFile)

		; Build Pandoc command with format-specific options
		pandocCmd := this.exe ' "' srcFile '" -o "' targetFile '" --from ' fromFormat ' --to ' toFormat

		; Add format-specific options
		if (toFormat == "rtf") {
			pandocCmd .= " --standalone --wrap=auto"
		} else if (toFormat == "html") {
			pandocCmd .= " --standalone"
		} else if (toFormat == "markdown") {
			pandocCmd .= " --standalone --wrap=auto"
		} else {
			pandocCmd .= " --standalone"
		}

		; Execute conversion
		; RunWait returns exit code: 0 = success, non-zero = failure
		exitCode := RunWait(pandocCmd,, "Hide")
		if (exitCode != 0) {
			; Cleanup temp files on error
			try FileDelete(srcFile)
			try FileDelete(targetFile)
			throw Error("Failed to convert " from " to " to " using Pandoc (exit code: " exitCode ")")
		}

		; Read the converted content
		result := FileRead(targetFile, 'UTF-8')

		; Clean up temp files
		try {
			FileDelete(srcFile)
		}
		catch {
			; Ignore cleanup errors
		}
		try {
			FileDelete(targetFile)
		} catch {
			; Ignore cleanup errors
		}

		; Apply format-specific post-processing
		if (toFormat == "rtf" && result && InStr(result, '\bullet')) {
			result := this._FixRTFBullets(result)
		}

		return result
	}

	/**
	 * Convert HTML to RTF using Pandoc with post-processing.
	 * @param {String} content HTML content
	 * @returns {String} RTF formatted content
	 * @throws {Error} If conversion fails
	 */
	static HTMLToRTF(content) {
		if (!content) {
			throw Error("Empty HTML content provided")
		}
		return this._PandocConvertAndProcess(content, "html")
	}

	/**
	 * Process and standardize existing RTF content.
	 * @param {String} content RTF content
	 * @returns {String} Standardized RTF formatted content
	 * @throws {Error} If conversion fails
	 */
	static RTFToRTF(content) {
		if (!content) {
			throw Error("Empty RTF content provided")
		}
		; Validate RTF format
		if (!RegExMatch(content, "i)^{\\s*\\\\rtf1\\b")) {
			throw Error("Invalid RTF format detected")
		}
		; Apply bullet formatting fixes if needed
		return this._FixRTFBullets(content)
	}

	/**
	 * Convert plain text to RTF with basic formatting.
	 * @param {String} content Plain text content
	 * @returns {String} RTF formatted content
	 * @throws {Error} If conversion fails
	 */
	static PlainTextToRTF(content) {
		if (!content) {
			throw Error("Empty text content provided")
		}
		; Simple text conversion with paragraph formatting
		processedText := "\\pard\\f0\\fs22 " . StrReplace(content, "`n", "\\par`n") . "\\par "
		return this._BuildRTFDocument(processedText)
	}

	/**
	 * Convert any format to RTF using Pandoc with post-processing.
	 * @param {String} content Input content
	 * @param {String} format Source format
	 * @returns {String} RTF formatted content
	 * @throws {Error} If conversion fails
	 */
	static PandocToRTF(content, format) {
		if (!content) {
			throw Error("Empty content provided for Pandoc conversion")
		}
		return this._PandocConvertAndProcess(content, format)
	}

	/**
	 * Convert RTF to Markdown using Pandoc.
	 * @param {String} content RTF content
	 * @returns {String} Markdown formatted content
	 * @throws {Error} If conversion fails
	 */
	static RTFtoMarkdown(content) {
		if (!content) {
			throw Error("Empty RTF content provided")
		}

		; Validate RTF format
		if (!RegExMatch(content, "i)^{\\s*\\\\rtf1\\b")) {
			throw Error("Invalid RTF format detected")
		}

		; Write RTF content to temp file
		srcFile := this._GetTempFile("rtf")
		FileAppend(content, srcFile)

		; Convert using Pandoc
		exitCode := RunWait(this.exe ' "' srcFile '" -o "' this.tempMD '" --from rtf --to markdown -s',, "Hide")
		if (exitCode != 0) {
			throw Error("Failed to convert RTF to Markdown using Pandoc (exit code: " exitCode ")")
		}

		; Read and return the converted markdown
		result := FileRead(this.tempMD, 'UTF-8')

		; Clean up temp files
		try {
			FileDelete(srcFile)
		} catch {
			; Ignore cleanup errors
		}
		try {
			FileDelete(this.tempMD)
		} catch {
			; Ignore cleanup errors
		}

		return result
	}

	/**
	 * Convert Markdown to HTML using Pandoc.
	 * @param {String} content Markdown content
	 * @returns {String} HTML formatted content
	 * @throws {Error} If conversion fails
	 */
	static MarkdownToHTML(content) {
		if (!content) {
			throw Error("Empty Markdown content provided")
		}

		; Use the generic Convert method which handles all the temp file management
		return this.Convert("markdown", "html", content)
	}

	/**
	 * Convert Markdown to HTML using Pandoc (short wrapper).
	 * @param {String} content Markdown content
	 * @returns {String} HTML formatted content
	 * @throws {Error} If conversion fails
	 */
	static md2html(content) => this.MarkdownToHTML(content)

	/**
	 * Converts Markdown or other content to XML (DocBook) using Pandoc.
	 * @param {String} content Input content
	 * @returns {String} XML string
	 * @throws {Error} If conversion fails
	 */
	static toXML(content) {
		txtFormat := this.DetectFormat(content)
		srcFile := this._GetTempFile(txtFormat)
		FileAppend(content, srcFile)
		exitCode := RunWait(this.exe ' "' srcFile '" -o "' this.tempXML '" --from ' txtFormat ' --to docbook -s',, "Hide")
		if (exitCode != 0) {
			throw Error("Failed to convert " txtFormat " to XML (exit code: " exitCode ")")
		}
		return FileRead(this.tempXML, 'UTF-8')
	}

	/**
	 * Sends content to clipboard.
	 * @param {String} content Content to send
	 * @returns {Boolean} Success
	 */
	static Send(content) {
		if !IsSet(content) && IsString(this) {
			content := this
		}
		return Clipboard.Send(content)
	}

	/**
	 * Writes content to a file.
	 * @param {String} content Content to write
	 * @param {String} filePath File path
	 * @returns {Boolean} Success
	 * @throws {Error} If parameters missing
	 */
	static toFile(content, filePath) {
		if !IsSet(content) || !IsSet(filePath) {
			throw Error("Content and file path must be provided")
		}
		return FileAppend(content, filePath)
	}

	/**
	 * Sends content using Input mode.
	 * @param {String} content Content to send
	 * @returns {Boolean} Success
	 */
	static SendInput(content) {
		SendMode('Input')
		if !IsSet(content) && IsString(this) {
			content := this
		}
		return Send(content)
	}

	/**
	 * Sends content using Event mode.
	 * @param {String} content Content to send
	 * @returns {Boolean} Success
	 */
	static SendEvent(content) {
		SendMode('Event')
		SetKeyDelay(-1, -1)
		if !IsSet(content) && IsString(this) {
			content := this
		}
		return Send(content)
	}

	/**
	 * Detects the format of the given input using FormatDetector.
	 * @param {Any} input Input to detect
	 * @returns {String} Format type
	 */
	static DetectFormat(input) {
		return FormatDetector.DetectFormat(input)
	}

	/**
	 * Fix RTF bullet formatting to Horizon-compatible format
	 * @param {String} rtfContent RTF content with incorrect bullets
	 * @returns {String} RTF content with corrected bullets
	 * @private
	 */
	static _FixRTFBullets(rtfContent) {
		; Modern Pandoc versions often generate correct RTF bullets already
		; Only fix obvious \bullet symbols that need conversion
		result := rtfContent

		; Only replace raw \bullet symbols with proper RTF format
		; This is much more conservative than the previous approach
		if (InStr(result, '\bullet')) {
			result := RegExReplace(result, "\\\\bullet\\s*", "{\\pntext\\f2\\'B7\\tab}")
		}

		return result
	}

	/**
	 * Debug method to analyze RTF bullet formatting
	 * @param {String} rtfContent RTF content to analyze
	 * @returns {String} Analysis report
	 */
	static DebugRTFBullets(rtfContent) {
		analysis := "=== RTF Bullet Analysis ===`n"
		analysis .= "Content Length: " . StrLen(rtfContent) . " characters`n"
		analysis .= "Contains \\bullet: " . (InStr(rtfContent, '\bullet') ? "Yes" : "No") . "`n"
		analysis .= "Contains \'B7: " . (InStr(rtfContent, "\'B7") ? "Yes" : "No") . "`n"
		analysis .= "Contains pntext: " . (InStr(rtfContent, "pntext") ? "Yes" : "No") . "`n"
		analysis .= "Contains pnlvlblt: " . (InStr(rtfContent, "pnlvlblt") ? "Yes" : "No") . "`n`n"

		; Count bullet patterns
		bulletCount := 0
		pntextCount := 0

		; Count \bullet occurrences
		pos := 1
		while (pos := InStr(rtfContent, '\bullet', , pos)) {
			bulletCount++
			pos++
		}

		; Count {\pntext patterns
		pos := 1
		while (pos := InStr(rtfContent, '{\pntext', , pos)) {
			pntextCount++
			pos++
		}

		analysis .= "Raw \\bullet count: " . bulletCount . "`n"
		analysis .= "Proper {\\pntext count: " . pntextCount . "`n`n"

		; Show sample bullet formatting if found
		if (pntextCount > 0) {
			; Extract a sample of proper bullet formatting
			startPos := InStr(rtfContent, '{\pntext')
			if (startPos > 0) {
				; Extract about 100 characters around the bullet
				sampleStart := Max(1, startPos - 20)
				sampleEnd := Min(StrLen(rtfContent), startPos + 80)
				sample := SubStr(rtfContent, sampleStart, sampleEnd - sampleStart)
				analysis .= "Sample proper bullet format:`n" . sample . "`n`n"
			}
		}

		if (bulletCount > 0) {
			; Extract a sample of raw bullet formatting
			startPos := InStr(rtfContent, '\bullet')
			if (startPos > 0) {
				sampleStart := Max(1, startPos - 20)
				sampleEnd := Min(StrLen(rtfContent), startPos + 40)
				sample := SubStr(rtfContent, sampleStart, sampleEnd - sampleStart)
				analysis .= "Sample raw bullet format:`n" . sample . "`n"
			}
		}

		return analysis
	}

	/**
	 * Common method for Pandoc conversion with post-processing
	 * @param {String} content Input content
	 * @param {String} format Source format
	 * @returns {String} RTF formatted content with corrected bullets
	 * @throws {Error} If conversion fails
	 * @private
	 */
	static _PandocConvertAndProcess(content, format) {
		srcFile := this._GetTempFile(format)
		FileAppend(content, srcFile)

		exitCode := RunWait(this.exe ' "' srcFile '" -o "' this.tempRTF '" --from ' format ' --to rtf -s',, "Hide")
		if (exitCode != 0) {
			throw Error("Failed to convert " format " to RTF using Pandoc (exit code: " exitCode ")")
		}

		result := FileRead(this.tempRTF, 'UTF-8')

		; Post-process RTF to fix bullet formatting
		if (result && InStr(result, '\bullet')) {
			result := this._FixRTFBullets(result)
		}

		return result
	}

	/**
	 * Build complete RTF document with header, list definitions, and content
	 * @param {String} processedContent RTF-formatted content body
	 * @returns {String} Complete RTF document
	 * @private
	 */
	static _BuildRTFDocument(processedContent) {
		rtf := this._GetRTFHeader()
		rtf .= this._GetListTableDef()
		rtf .= processedContent "}`n}"
		return rtf
	}

	/**
	 * Process markdown content for RTF conversion
	 * @param {String} markdown Markdown content
	 * @returns {String} RTF-formatted content body (without header/footer)
	 * @private
	 */
	static _ProcessMarkdownContent(markdown) {
		; Clean up any existing temp files first
		if FileExist(this.tempMD)
			FileDelete(this.tempMD)
		if FileExist(this.tempRTF)
			FileDelete(this.tempRTF)

		; Write markdown content to temp file
		FileAppend(markdown, this.tempMD)

		srcFile := this.tempMD
		docFormat := 'markdown'
		; Use Pandoc to convert markdown to RTF
		exitCode := RunWait(this.exe ' "' srcFile '" -o "' this.tempRTF '" --from ' docFormat ' --to rtf -s',, "Hide")
		if (exitCode != 0) {
			throw Error("Failed to convert " docFormat " to RTF using Pandoc (exit code: " exitCode ")")
		}

		; Read the converted RTF content
		text := FileRead(this.tempRTF, 'UTF-8')

		; Clean up temp files
		FileDelete(this.tempMD)
		FileDelete(this.tempRTF)

		; Only post-process lists for proper bullet formatting
		text := this._ProcessLists(text)

		; return this._BuildRTFDocument(text)
		return text
	}

	/**
	 * Convert Markdown to RTF with proper bullet formatting
	 * @param {String} markdown Markdown content
	 * @returns {String} RTF formatted content
	 * @private
	 * @deprecated Use MarkdownToRTF() instead
	 */
	static _MarkdownToRTF(markdown) {
		; Redirect to new public method for backward compatibility
		return this.MarkdownToRTF(markdown)
	}

	/**
	 * Get standard RTF header
	 * @returns {String} RTF header
	 * @private
	 */
	static _GetRTFHeader() {
		return "{\\rtf1\\ansi\\ansicpg1252\\deff0\\nouicompat\\deflang1033" .
			   "{\\fonttbl{\\f0\\froman\\fprq2\\fcharset0 Times New Roman;}{\\f2\\fmodern\\fprq1\\fcharset0 Courier New;}}" .
			   "{\\colortbl;\\red0\\green0\\blue0;}\\viewkind4\\uc1\\pard\\cf1\\f0\\fs22"
	}

	/**
	 * Get RTF list table definition
	 * @returns {String} RTF list table
	 * @private
	 */
	static _GetListTableDef() {
		return "{\\*\\listtable{\\list\\listtemplateid2181{\\listlevel\\levelnfc23\\leveljc0\\li1910\\fi-241" .
			   "{\\leveltext\\'01\\uc1\\u61548 ?;}{\\levelnumbers;}\\f2\\fs14\\b0\\i0}{\\listlevel\\levelnfc23" .
			   "\\leveljc0\\li2808\\fi-241{\\leveltext\\'01\\'95;}{\\levelnumbers;}}{\\listlevel\\levelnfc23" .
			   "\\leveljc0\\li3696\\fi-241{\\leveltext\\'01\\'95;}{\\levelnumbers;}}\\listid1026}}" .
			   "{\\*\\listoverridetable{\\listoverride\\listoverridecount0\\listid1026\\ls1}}"
	}

	/**
	 * Process text formatting elements
	 * @param {String} text Text to process
	 * @returns {String} Processed text with RTF formatting
	 * @private
	 * @deprecated Manual formatting deprecated - let Pandoc handle formatting
	 */
	static _ProcessTextFormatting(text) {
		; Process headers first with proper RTF formatting
		text := this._ProcessHeaders(text)

		; UNDERLINE - Process FIRST to avoid conflicts with italic underscore patterns
		; Support both markdown double underscore and HTML <u> tag
		; HTML underline tags (case-insensitive)
		text := RegExReplace(text, "i)<u>([^<]+?)</u>", "\\ul $1\\ul0 ")
		
		; Markdown double underscore - but preserve triple underscores for placeholders
		; text := StrReplace(text, "___", "TRIPLE_UNDERSCORE_PLACEHOLDER")
		text := RegExReplace(text, "__([^_]+?)__", "\\ul $1\\ul0 ")
		; text := StrReplace(text, "TRIPLE_UNDERSCORE_PLACEHOLDER", "___")
		
		; Alternative underline pattern with tilde
		text := RegExReplace(text, "~([^~]+?)~", "\\ul $1\\ul0 ")

		; Bold+Italic handling - must come BEFORE separate bold and italic patterns
		; Handle ***text*** (bold and italic combined)
		text := RegExReplace(text, "\*\*\*([^*]+?)\*\*\*", "\\b\\i $1\\i0\\b0 ")
		; Handle _**text**_ (italic wrapper around bold)
		text := RegExReplace(text, "_\*\*([^*]+?)\*\*_", "\\b\\i $1\\i0\\b0 ")

		; Bold handling with non-greedy matching
		text := RegExReplace(text, "\*\*([^*]+?)\*\*", "\\b $1\\b0 ")

		; Italic handling with safer patterns (avoiding variable-length lookbehind)
		; Handle single asterisks for italic (not part of double asterisks)
		text := RegExReplace(text, "\*([^*\s][^*]*?[^*\s]|\w)\*", "\\i $1\\i0 ")
		; Handle single underscores for italic (not part of double underscores)
		; Note: Double underscores already handled above for underline
		text := RegExReplace(text, "([^_]|^)_([^_\s][^_]*?[^_\s]|\w)_([^_]|$)", "$1\\i $2\\i0 $3")

		; Strikethrough
		text := RegExReplace(text, "~~([^~]+?)~~", "\\strike $1\\strike0 ")

		; Special characters
		text := StrReplace(text, "°", "\\'b0 ")

		return text
	}

	/**
	 * Process markdown headers with proper RTF formatting
	 * @param {String} text Text to process
	 * @returns {String} Processed text with RTF header formatting
	 * @private
	 * @deprecated Manual header formatting deprecated - let Pandoc handle formatting
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
		text := RegExReplace(text, "m)^# (.+)$", "\\pard\\sb240\\sa120\\b\\fs" h1Size " $1\\b0\\fs22\\par ")
		text := RegExReplace(text, "m)^## (.+)$", "\\pard\\sb200\\sa100\\b\\fs" h2Size " $1\\b0\\fs22\\par ")
		text := RegExReplace(text, "m)^### (.+)$", "\\pard\\sb160\\sa80\\b\\fs" h3Size " $1\\b0\\fs22\\par ")
		text := RegExReplace(text, "m)^#### (.+)$", "\\pard\\sb120\\sa60\\b\\fs" h4Size " $1\\b0\\fs22\\par ")
		text := RegExReplace(text, "m)^##### (.+)$", "\\pard\\sb100\\sa50\\b\\fs" h5Size " $1\\b0\\fs22\\par ")
		text := RegExReplace(text, "m)^###### (.+)$", "\\pard\\sb80\\sa40\\b\\fs" h6Size " $1\\b0\\fs22\\par ")

		return text
	}

	/**
	 * Process list formatting with proper RTF bullets
	 * @param {String} text Text to process
	 * @returns {String} Processed text with RTF list formatting
	 * @private
	 */
	static _ProcessLists(text) {
		; RegEx pattern for bullet points - capture indentation level
		bulletPattern := "m)^([\\s]*)(- |• )(.*)"  ; Groups: (1)indent (2)bullet (3)text
		bulletPatternOnly := "m)^([\\s]*)(- |• )"

		; RTF list format patterns with \'B7 bullet - using working format from FormatConverter
		firstLevelBullet := "{\\pntext\\f2\\'B7\\tab}{\\*\\pn\\pnlvlblt\\pnf2\\pnindent0{\\pntxtb\\'B7}}\\fi-360\\li360 $3\\par"

		secondLevelBullet := "{\\pntext\\f2\\'B7\\tab}{\\*\\pn\\pnlvlblt\\pnf2\\pnindent0{\\pntxtb\\'B7}}\\fi-360\\li720 $3\\par"

		arrText := []
		arrMatch := []

		arrText := StrSplit(text, "`n")

		; Collect bullet points
		for t in arrText {
			if RegExMatch(t, bulletPatternOnly) {
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

		text := ""
		for each, value in arrText {
			if RegExMatch(value, "\\\\f2\\\\'B7\\\\tab") {
				text .= value (A_Index < arrText.Length ? "`n" : "")
			}
			else {
				code := "\\pard\\tx720\\tx1440\\tx2160\\tx2880\\tx3600\\tx4320\\tx5040\\tx5760\\tx6480\\tx7200\\tx7920\\tx8640\\tx9360\\tx10080\\f0\\fs22 "
				if A_Index == 1 {
					text .= code value
				}
				else {
					text .= code value (A_Index < arrText.Length ? "`n" : "")
				}
			}
		}

		; Handle line breaks
		text := RegExReplace(text, "\\R\\R+", "\\par ")
		text := RegExReplace(text, "(?<!\\\\par)\\R", "\\par ")

		; Clean up
		text := RegExReplace(text, "\\s+$", "")

		return text
	}

	/**
	 * Returns the appropriate temp file path for the given format.
	 * @param {String} txtFormat Format string
	 * @returns {String} File path
	 */
	static _GetTempFile(txtFormat) {
		; Normalize format names
		switch txtFormat {
			case "md", "markdown":
				return this.tempMD
			case "rtf":
				return this.tempRTF
			case "html":
				return this.tempHTML
			case "txt":
				return this.tempTXT
			case "json":
				return this.tempJSON
			case "xml":
				return this.tempXML
			case "csv":
				return this.tempCSV
			case "xlsx":
				return this.tempXLSX
			case "docx":
				return this.tempDOCX
			case "doc":
				return this.tempDOC
			default:
				return this.tempRTF
		}
	}

	/**
	 * Normalize format identifier to standard Pandoc format name
	 * @param {String} format Format identifier to normalize
	 * @returns {String} Normalized format name
	 * @private
	 */
	static _NormalizeFormat(format) {
		format := StrLower(Trim(format))

		; Format aliases and normalization
		switch format {
			case "md":
				return "markdown"
			case "htm":
				return "html"
			case "txt", "text", "plain", "plaintext":
				return "plain"
			case "js":
				return "javascript"
			case "rtf", "html", "markdown", "json", "xml", "csv", "docx", "doc", "plain", "javascript", "latex", "epub", "pdf":
				return format
			default:
				return format  ; Pass through unknown formats to let Pandoc handle them
		}
	}

	/**
	 * Check if format is supported by Pandoc
	 * @param {String} format Format to validate
	 * @returns {Boolean} True if format is supported
	 * @private
	 */
	static _IsValidFormat(format) {
		supportedFormats := [
			"markdown", "html", "rtf", "json", "xml", "csv", "docx", "doc",
			"plain", "javascript", "latex", "epub", "pdf", "odt", "odp",
			"pptx", "xlsx", "rst", "asciidoc", "textile", "org", "mediawiki",
			"twiki", "tikiwiki", "creole", "docbook", "opml", "haddock",
			"commonmark", "gfm", "muse", "jira", "man", "ms", "tei", "zimwiki"
		]

		return supportedFormats.IndexOf(format) > 0
	}

	/**
	 * Preprocess markdown to convert custom underline patterns to HTML <u> tags
	 * Handles: ~text~ patterns (tilde underline)
	 * Note: __text__ is ambiguous (could be bold emphasis or underline)
	 * @param {String} markdown Raw markdown content
	 * @returns {String} Processed markdown with <u> tags for underlines
	 * @private
	 */
	static _PreprocessMarkdownUnderline(markdown) {
		processed := markdown

		; Convert tilde underline pattern: ~text~ → <u>text</u>
		; Use non-greedy matching to avoid consuming multiple instances
		processed := RegExReplace(processed, "~([^~\s][^~]*?)~", "<u>$1</u>")

		; OPTIONAL: Convert double underscore to underline when NOT used for emphasis
		; This is context-sensitive and may conflict with standard markdown bold
		; Only enable if you explicitly want __ to mean underline instead of bold
		; processed := RegExReplace(processed, "__([^_\s][^_]*?)__", "<u>$1</u>")

		return processed
	}

	/**
	 * Test method to debug markdown to RTF conversion
	 * @param {String} content Markdown content to test
	 * @returns {String} Debug information about the conversion
	 */
	static DebugMarkdownToRTF(content) {
		debugInfo := "=== Pandoc Debug Information ===`n"
		debugInfo .= "Input Format Detected: " . this.DetectFormat(content) . "`n"
		debugInfo .= "Input Length: " . StrLen(content) . " characters`n"
		debugInfo .= "Pandoc Executable: " . this.exe . "`n"
		debugInfo .= "Pandoc Exists: " . (FileExist(this.exe) ? "Yes" : "No") . "`n`n"

		; Test Pandoc availability
		try {
			RunWait('pandoc --version',, "Hide")
			debugInfo .= "Pandoc Available: Yes`n"
		} catch {
			debugInfo .= "Pandoc Available: No`n"
		}

		; Test conversion
		try {
			result := this.MarkdownToRTF(content)
			debugInfo .= "Conversion Success: Yes`n"
			debugInfo .= "Output Length: " . StrLen(result) . " characters`n"
			debugInfo .= "Contains RTF Header: " . (InStr(result, "{\rtf1") ? "Yes" : "No") . "`n"
			debugInfo .= "Contains Bullet Symbols: " . (InStr(result, "\bullet") ? "Yes" : "No") . "`n"
			debugInfo .= "Contains Fixed Bullets: " . (InStr(result, "\'B7") ? "Yes" : "No") . "`n"
		} catch Error as err {
			debugInfo .= "Conversion Success: No`n"
			debugInfo .= "Error: " . err.Message . "`n"
		}

		return debugInfo
	}
}

/**
 * @class FormatDetector
 * @description Enhanced format detection utility for better content analysis.
 * @version 1.1.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-07-30
 * @example
 *   fmt := FormatDetector.DetectFormat(someInput)
 */
class FormatDetector {
	/**
	 * Detects the format of the given input with enhanced markdown detection.
	 * @param {Any} input The input to detect the format of.
	 * @returns {String} The detected format (e.g., "rtf", "html", "json", "markdown", "plain", etc.).
	 */
	static DetectFormat(input) {
		if IsObject(input) {
			if input.HasOwnProp("__Class") {
				return "class"
			} else if input.HasOwnProp("Count") {
				return "map" ; Likely a Map or Array
			} else {
				return "object"
			}
		} else if IsString(input) {
			if (!input || input == "") {
				return "plaintext"
			}

			input := Trim(input)

			; RTF Detection
			if RegExMatch(input, "i)^{\\s*\\\\rtf1\\b") {
				return "rtf"
			}

			; HTML Detection
			if RegExMatch(input, "i)^\\s*<!DOCTYPE html|^<html|<body") ||
			   RegExMatch(input, "i)<(div|span|p|h[1-6]|table|ul|ol)[>\\s]") {
				return "html"
			}

			; JSON Detection
			if RegExMatch(input, "^\\s*[{\\[].*[}\\]]\\s*$") {
				return "json"
			}

			; Enhanced Markdown Detection
			markdownPatterns := [
				"m)^#{1,6}\\s+.+$",           ; Headers
				"m)^\\s*[-*+]\\s+",            ; Unordered lists
				"m)^\\s*\\d+\\.\\s+",            ; Ordered lists
				"\\*\\*[^*]+\\*\\*",             ; Bold text
				"([^*]|^)\\*[^*]+\\*([^*]|$)",  ; Italic text (fixed: no variable-length lookbehind)
				"~~[^~]+~~",                 ; Strikethrough
				"``[^``]+``",                   ; Inline code
				"``````[\\s\\S]*?``````",            ; Code blocks
				"\\[.+?\\]\\(.+?\\)",            ; Links
				"!\\[.*?\\]\\(.+?\\)"            ; Images
			]

			markdownScore := 0
			for pattern in markdownPatterns {
				if RegExMatch(input, pattern) {
					markdownScore++
				}
			}

			if markdownScore >= 2 {
				return "markdown"
			}

			; CSV Detection
			lines := StrSplit(input, "`n", "`r")
			if lines.Length >= 2 {
				firstLine := Trim(lines[1])
				secondLine := Trim(lines[2])

				commaCount1 := StrLen(firstLine) - StrLen(StrReplace(firstLine, ",", ""))
				commaCount2 := StrLen(secondLine) - StrLen(StrReplace(secondLine, ",", ""))

				if commaCount1 > 0 && commaCount1 == commaCount2 {
					return "csv"
				}
			}

			; Check for XML
			if RegExMatch(input, "^<\\?xml") {
				return "xml"
			}

			; Check for YAML front matter
			if RegExMatch(input, "^---") {
				return "markdown" ; YAML front matter
			}

			return "plaintext"
		} else if FileExist(input) {
			SplitPath(input, , , &ext)
			ext := StrLower(ext)
			for extType in ["rtf", "html", "md","txt","xml","json","csv","xlsx","xls","docx","doc"] {
				if ext = extType
					return extType
			}
			return "unknown-file"
		} else {
			return "unknown"
		}
	}
}

; ==============================================================================
; @region PandocFormatGUI Class
; ==============================================================================

/**
 * @class PandocFormatGUI
 * @description Auto-sized GUI for Pandoc format conversions with vertically aligned buttons
 * @version 1.0.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-08-04
 * @requires AutoHotkey v2.0+
 * @example PandocFormatGUI.Show()
 */
class PandocFormatGUI {
	static gui := ""
	static clipbackup := ""

	/**
	 * @description Available conversion formats with display names and Pandoc methods
	 */
	static Formats := [
		{name: "RTF (Rich Text Format)", method: "toRTF", extension: "rtf", description: "Convert to RTF with proper formatting"},
		{name: "HTML (Web Page)", method: "toHTML", extension: "html", description: "Convert to HTML format"},
		{name: "JSON (JavaScript Object)", method: "toJSON", extension: "json", description: "Convert to JSON format"},
		{name: "Markdown (GitHub Style)", method: "toMD", extension: "md", description: "Convert to Markdown format"},
		{name: "XML (DocBook)", method: "toXML", extension: "xml", description: "Convert to XML DocBook format"},
		{name: "Plain Text", method: "toPlainText", extension: "txt", description: "Convert to plain text"},
		{name: "Word Document (DOCX)", method: "toDOCX", extension: "docx", description: "Convert to Word document"},
		{name: "PDF Document", method: "toPDF", extension: "pdf", description: "Convert to PDF document"}
	]

	/**
	 * @description Show the Pandoc conversion GUI
	 */
	static Show() {
		; Backup clipboard content
		this.clipbackup := ClipboardAll()

		; Create auto-sized GUI
		this.gui := Gui("+Resize +MinSize300x400", "Pandoc Format Converter")
		this.gui.BackColor := "White"
		this.gui.SetFont("s10", "Segoe UI")

		; Header section
		this.gui.Add("Text", "x20 y15 w260 Center", "Convert Clipboard Content")
		this.gui.Add("Text", "x20 y35 w260 Center c0x666666", "Choose output format:")

		; Divider line
		this.gui.Add("Text", "x20 y55 w260 h1 0x10")  ; SS_ETCHEDHORZ

		; Preview current clipboard content
		clipText := A_Clipboard
		if (StrLen(clipText) > 100) {
			clipText := SubStr(clipText, 1, 100) . "..."
		}

		this.gui.Add("Text", "x20 y70 w260", "Current clipboard:")
		this.gui.Add("Edit", "x20 y90 w260 h60 ReadOnly VScroll", clipText)

		; Format buttons - vertically aligned
		yPos := 165
		buttonHeight := 35
		buttonSpacing := 5

		for format in this.Formats {
			; Create button with format name
			btn := this.gui.Add("Button",
				"x20 y" yPos " w260 h" buttonHeight,
				format.name)

			; Bind the conversion method to the button
			btn.OnEvent("Click", this.CreateConversionHandler(format))

			; Add description text below button
			this.gui.Add("Text",
				"x25 y" (yPos + buttonHeight - 15) " w250 h15 c0x666666",
				format.description)

			yPos += buttonHeight + buttonSpacing + 15  ; Account for description text
		}

		; Bottom section with Cancel button
		yPos += 10
		cancelBtn := this.gui.Add("Button", "x20 y" yPos " w120 h30", "&Cancel")
		cancelBtn.OnEvent("Click", (*) => this.Close())

		; Help button
		helpBtn := this.gui.Add("Button", "x160 y" yPos " w120 h30", "&Help")
		helpBtn.OnEvent("Click", (*) => this.ShowHelp())

		; Auto-size the GUI
		finalHeight := yPos + 50
		this.gui.Move(, , 300, finalHeight)

		; Center on screen
		this.gui.Opt("+LastFound")
		WinGetPos(, , &screenWidth, &screenHeight, "A")
		guiX := (screenWidth - 300) // 2
		guiY := (screenHeight - finalHeight) // 2
		this.gui.Move(guiX, guiY)

		; Show GUI
		this.gui.Show()

		; Set up close event
		this.gui.OnEvent("Close", (*) => this.Close())
		this.gui.OnEvent("Escape", (*) => this.Close())
	}

	/**
	 * @description Create a conversion handler for a specific format
	 * @param {Object} format Format configuration object
	 * @returns {Function} Event handler function
	 */
	static CreateConversionHandler(format) {
		return (*) => this.ConvertToFormat(format)
	}

	/**
	 * @description Convert clipboard content to specified format
	 * @param {Object} format Format configuration object
	 */
	static ConvertToFormat(format) {
		this.Close()  ; Close GUI first

		try {
			; Get current clipboard content
			sourceContent := A_Clipboard

			if (!sourceContent) {
				MsgBoxGUI.Show("No content found in clipboard!", "Conversion Error", "IconX")
				return
			}

			; Determine conversion method
			convertedContent := ""

			switch format.method {
				case "toRTF":
					convertedContent := Pandoc.toRTF(sourceContent)
					; Apply additional RTF processing
					rtfData := FormatConverter._ProcessRTFLists(convertedContent)
					Clipboard._SetClipboardRTF(rtfData)
					Infos("Content converted to RTF using Pandoc")
					return

				case "toHTML":
					convertedContent := Pandoc.toHTML(sourceContent)

				case "toJSON":
					convertedContent := Pandoc.toJSON(sourceContent)

				case "toMD":
					convertedContent := Pandoc.toMD(sourceContent)

				case "toXML":
					convertedContent := Pandoc.toXML(sourceContent)

				case "toPlainText":
					; For plain text, detect source format and convert
					detectedFormat := Pandoc.DetectFormat(sourceContent)
					if (detectedFormat == "markdown") {
						; Convert markdown to plain text by removing formatting
						convertedContent := this.MarkdownToPlainText(sourceContent)
					} else {
						convertedContent := sourceContent  ; Already plain text
					}

				case "toDOCX":
					; For DOCX, we'll use Pandoc command line since it's not in our class
					convertedContent := this.ConvertWithPandocCLI(sourceContent, "docx")

				case "toPDF":
					; For PDF, we'll use Pandoc command line
					convertedContent := this.ConvertWithPandocCLI(sourceContent, "pdf")

				default:
					throw Error("Unknown conversion method: " format.method)
			}

			; Set converted content to clipboard
			if (convertedContent) {
				A_Clipboard := convertedContent
				Infos("Content converted to " format.name . " using Pandoc")
			} else {
				MsgBoxGUI.Show("Conversion resulted in empty content!", "Conversion Warning", "IconExclamation")
			}

		} catch Error as e {
			MsgBoxGUI.Show("Conversion to " format.name " failed:`n" e.Message, "Conversion Error", "IconX")
		}
	}

	/**
	 * @description Convert markdown to plain text by removing formatting
	 * @param {String} markdown Markdown content
	 * @returns {String} Plain text content
	 */
	static MarkdownToPlainText(markdown) {
		text := markdown

		; Remove headers
		text := RegExReplace(text, "m)^#{1,6}\s+(.+)$", "$1")

		; Remove bold and italic
		text := RegExReplace(text, "\*\*([^*]+)\*\*", "$1")
		text := RegExReplace(text, "__([^_]+)__", "$1")
		text := RegExReplace(text, "\*([^*]+)\*", "$1")
		text := RegExReplace(text, "_([^_]+)_", "$1")

		; Remove strikethrough
		text := RegExReplace(text, "~~([^~]+)~~", "$1")

		; Remove links
		text := RegExReplace(text, "\[([^\]]+)\]\([^)]+\)", "$1")

		; Remove images
		text := RegExReplace(text, "!\[([^\]]*)\]\([^)]+\)", "$1")

		; Remove code blocks and inline code
		text := RegExReplace(text, "``````[^``]*``````", "")
		text := RegExReplace(text, "``([^``]+)``", "$1")

		; Clean up bullet points
		text := RegExReplace(text, "m)^[\s]*[-*+]\s+", "• ")

		; Clean up numbered lists
		text := RegExReplace(text, "m)^[\s]*\d+\.\s+", "")

		return Trim(text)
	}

	/**
	 * @description Convert using Pandoc command line for formats not in our class
	 * @param {String} content Source content
	 * @param {String} outputFormat Output format (docx, pdf, etc.)
	 * @returns {String} Converted content or path to output file
	 */
	static ConvertWithPandocCLI(content, outputFormat) {
		; This is a placeholder - implementing full CLI would require file handling
		; For now, we'll return a message
		return "Conversion to " outputFormat " requires file-based processing. Feature coming soon!"
	}

	/**
	 * @description Show help information
	 */
	static ShowHelp() {
		helpText := "
(
Pandoc Format Converter Help

This tool converts clipboard content between different formats using Pandoc.

Supported Conversions:
• RTF - Best for rich text editors and word processors
• HTML - For web pages and browsers
• JSON - For data interchange and APIs
• Markdown - For documentation and GitHub
• XML - For structured documents
• Plain Text - Removes all formatting

Tips:
• Content is automatically detected and converted
• RTF conversion includes proper bullet formatting
• Original clipboard is preserved if conversion fails
• Press Ctrl+Shift+P anytime to show this dialog

Hotkeys:
• Ctrl+Shift+M - Direct Markdown to RTF
• Ctrl+Shift+R - Direct RTF to HTML
• Ctrl+Shift+L - Process with FormatConverter

For more conversion options, use the format-specific hotkeys
or the clipboard format tester (press F1).
)"

		MsgBoxGUI.Show(helpText, "Pandoc Format Converter Help", "IconInfo")
	}

	/**
	 * @description Close the GUI and restore clipboard if needed
	 */
	static Close() {
		if (this.gui) {
			this.gui.Destroy()
			this.gui := ""
		}
	}
}

; @endregion PandocFormatGUI Class
