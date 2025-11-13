/**
 * @fileoverview Unified JSON/YAML Processing System
 * @description Simple wrapper to switch between different JSON libraries with Pandoc integration
 * @class JSONS
 * @version 2.1.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-10-01
 * @requires AutoHotkey v2+
 * @link {@link file://./JSONS.ahk}
 * @link {@link file://./jsongo.ahk}
 * @link {@link file://./cJson.ahk}
 * @link {@link file://./json.ahk}
 * @example
 *   ; Basic JSON operations
 *   JSONS.Set(2)  ; Use jsongo backend
 *   json := JSONS.Stringify({name: "John"}, 2)
 *   obj := JSONS.Parse(json)
 *   
 *   ; Pandoc conversions
 *   html := JSONS.Convert("markdown", "html", "# Hello")
 *   jsonStr := JSONS.FromMarkdown("## Title\n- Item 1")
 *   markdown := JSONS.ToMarkdown(jsonStr)
 *   
 *   ; Format detection
 *   fmt := JSONS.DetectFormat(content)
 */

#Requires AutoHotkey v2+
;? this is my lib file, for Quartz-RTE, use the one below
;! for the local lib files, comment out the below and uncomment the ones after
; #Include <Extensions/.formats/jsongo>
; #Include <Extensions/.formats/cJson>
; #Include <Extensions/.formats/json>
; #Include <Apps/Pandoc>

;? this the local lib files, for Quartz-RTE, use this one
;! for the local lib files, uncomment the ones below
#Include jsongo.ahk
#Include cJson.ahk
#Include json.ahk
#Include ../../Apps/Pandoc.ahk

class JSONS {
    ; -----------------------------------------------------------------------
    ; @region Static Properties
    static CurrentBackend := 2  ; 1=cJson, 2=jsongo (default), 3=json
    
    static BackendNames := Map(
        1, "cJson",
        2, "jsongo", 
        3, "json",
        "cJson", 1,
        "jsongo", 2,
        "json", 3
    )
    ; @endregion Static Properties

    ; -----------------------------------------------------------------------
    ; @region Static Methods
    /**
     * @static
     * @method Set
     * @description Sets the active JSON backend
     * @param {Integer|String} backend - Backend number (1-3) or name ("cJson", "jsongo", "json")
     */
    static Set(backend) {
        if IsInteger(backend) {
            if backend >= 1 && backend <= 3 {
                JSONS.CurrentBackend := backend
            } else {
                throw ValueError("Backend must be 1 (cJson), 2 (jsongo), or 3 (json)", -1)
            }
        } else {
            if JSONS.BackendNames.Has(backend) {
                JSONS.CurrentBackend := JSONS.BackendNames[backend]
            } else {
                throw ValueError("Unknown backend: " backend, -1)
            }
        }
    }

    /**
     * @static
     * @method Get
     * @description Gets the current backend name
     * @returns {String} Current backend name
     */
    static Get() {
        return JSONS.BackendNames[JSONS.CurrentBackend]
    }

    /**
     * @static
     * @method Parse
     * @description Parses JSON string into object
     * @param {String} jsonString - JSON string to parse
     * @returns {Object} Parsed object
     */
    static Parse(jsonString) {
        switch JSONS.CurrentBackend {
            case 1: return cJson.Parse(jsonString)
            case 2: return jsongo.Parse(jsonString)
            case 3: return JSON.Parse(jsonString)
            default: return jsongo.Parse(jsonString)
        }
    }

    /**
     * @static
     * @method Stringify
     * @description Converts object to JSON string
     * @param {Object} obj - Object to stringify
     * @param {Integer} indent - Indentation level (optional)
     * @returns {String} JSON string
     */
    static Stringify(obj, indent := 0) {
        switch JSONS.CurrentBackend {
            case 1: return cJson.Stringify(obj, indent > 0)  ; cJson uses boolean for pretty print
            case 2: return jsongo.Stringify(obj, indent)
            case 3: return JSON.Stringify(obj, indent)
            default: return jsongo.Stringify(obj, indent)
        }
    }

    /**
     * @static
     * @method Load
     * @description Alias for Parse
     * @param {String} jsonString - JSON string to parse
     * @returns {Object} Parsed object
     */
    static Load(jsonString) => JSONS.Parse(jsonString)

    /**
     * @static
     * @method Dump
     * @description Alias for Stringify
     * @param {Object} obj - Object to stringify
     * @param {Integer} indent - Indentation level
     * @returns {String} JSON string
     */
    static Dump(obj, indent := 0) => JSONS.Stringify(obj, indent)

    /**
     * @static
     * @method LoadFile
     * @description Loads and parses JSON from file
     * @param {String} filePath - Path to file
     * @param {String} encoding - File encoding (default: UTF-8)
     * @returns {Object} Parsed object
     */
    static LoadFile(filePath, encoding := "UTF-8") {
        content := FileRead(filePath, encoding)
        return JSONS.Parse(content)
    }

    /**
     * @static
     * @method SaveFile
     * @description Saves object as JSON to file
     * @param {String} filePath - Path to save file
     * @param {Object} obj - Object to save
     * @param {Integer} indent - Indentation level (default: 2)
     * @param {String} encoding - File encoding (default: UTF-8)
     */
    static SaveFile(filePath, obj, indent := 2, encoding := "UTF-8") {
        content := JSONS.Stringify(obj, indent)
        file := FileOpen(filePath, "w", encoding)
        file.Write(content)
        file.Close()
    }

    /**
     * @static
     * @method toJson
     * @description Converts object to JSON (alias for Stringify)
     * @param {Object} obj - Object to convert
     * @param {Integer} indent - Indentation level
     * @returns {String} JSON string
     */
    static toJson(obj, indent := 0) => JSONS.Stringify(obj, indent)

    /**
     * @static
     * @method toString
     * @description Converts object to JSON string (alias for Stringify)
     * @param {Object} obj - Object to convert
     * @param {Integer} indent - Indentation level
     * @returns {String} JSON string
     */
    static toString(obj, indent := 0) => JSONS.Stringify(obj, indent)

    /**
     * @static
     * @method fromJson
     * @description Parses JSON string (alias for Parse)
     * @param {String} jsonString - JSON string
     * @returns {Object} Parsed object
     */
    static fromJson(jsonString) => JSONS.Parse(jsonString)
    ; @endregion Static Methods

    ; -----------------------------------------------------------------------
    ; @region Pandoc Integration Methods
    /**
     * @static
     * @method Convert
     * @description Convert between any formats using Pandoc
     * @param {String} from - Source format (markdown, html, json, etc.)
     * @param {String} to - Target format (markdown, html, json, etc.)
     * @param {String} content - Content to convert
     * @returns {String} Converted content
     * @throws {Error} If conversion fails
     * @example
     *   html := JSONS.Convert("markdown", "html", markdownText)
     *   json := JSONS.Convert("yaml", "json", yamlText)
     */
    static Convert(from, to, content) {
        return Pandoc.Convert(from, to, content)
    }

    /**
     * @static
     * @method ToMarkdown
     * @description Convert JSON to Markdown using Pandoc
     * @param {String} jsonString - JSON string
     * @returns {String} Markdown formatted text
     */
    static ToMarkdown(jsonString) {
        return Pandoc.Convert("json", "markdown", jsonString)
    }

    /**
     * @static
     * @method ToHTML
     * @description Convert JSON to HTML using Pandoc
     * @param {String} jsonString - JSON string
     * @returns {String} HTML formatted text
     */
    static ToHTML(jsonString) {
        return Pandoc.Convert("json", "html", jsonString)
    }

    /**
     * @static
     * @method FromMarkdown
     * @description Convert Markdown to JSON using Pandoc
     * @param {String} markdown - Markdown content
     * @returns {String} JSON string
     */
    static FromMarkdown(markdown) {
        return Pandoc.Convert("markdown", "json", markdown)
    }

    /**
     * @static
     * @method FromHTML
     * @description Convert HTML to JSON using Pandoc
     * @param {String} html - HTML content
     * @returns {String} JSON string
     */
    static FromHTML(html) {
        return Pandoc.Convert("html", "json", html)
    }

    /**
     * @static
     * @method DetectFormat
     * @description Detect format of content using Pandoc's FormatDetector
     * @param {String} content - Content to analyze
     * @returns {String} Detected format
     */
    static DetectFormat(content) {
        return Pandoc.DetectFormat(content)
    }
    ; @endregion Pandoc Integration Methods
}


