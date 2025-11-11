# Quartz Rich Text Editor

A powerful rich text editor built with AutoHotkey v2 and WebView2 that offers advanced RTF handling capabilities.

## Overview

Quartz is a rich text editor that leverages WebView2 to provide a modern editing experience with robust RTF handling. It can:

* Open and edit RTF files with formatting preserved
* Import and export Word documents (DOC/DOCX)
* Copy and paste formatted text between applications
* Save content in multiple formats (RTF, HTML, TXT)

## Components

The Quartz system consists of several specialized components:

### 1. Core Editor (Quartz.ahk)

The main editor class that provides:

* WebView2-based rich text editing
* File operations (open/save)
* Text manipulation functions
* GUI setup and event handling

### 2. RTF Handler (RTFHandler.ahk)

A specialized class for handling RTF content that offers:

* RTF file opening with preserved formatting
* Conversion between formats
* RTF extraction and manipulation
* Word document integration

### 3. RTF Clipboard Handler (RTFClip.ahk)

Enhanced clipboard operations specific to RTF content:

* Getting RTF content from clipboard
* Setting RTF content to clipboard
* Advanced paste operations
* Format detection and conversion

### 4. Integration Helper (QuartzIntegration.ahk)

A helper class that ties everything together:

* Simplified file import/export
* Enhanced copy/paste operations
* Hotkey configuration
* Format conversion utilities

## Installation


1. Ensure you have AutoHotkey v2.0+ installed
2. Make sure Microsoft Edge WebView2 Runtime is installed on your system
3. Download all Quartz files to a directory
4. Include the required libraries in your AHK library path:
   * WebView2.ahk
   * WebView2Loader.dll (both 32-bit and 64-bit versions)
   * Basic.ahk (for clipboard operations)

## Getting Started

### Basic Usage

```autohotkey
; Include the main Quartz class
#Include "Quartz.ahk"

; Create a new editor instance
editor := Quartz()

; Open a file
editor.OpenFile("path/to/your/file.rtf")

; Get content
htmlContent := editor.GetHTML()
textContent := editor.GetText()

; Save content
editor.SaveFile(htmlContent)
```

### Using the Integration Helper

```autohotkey
; Include the integration helper
#Include "QuartzIntegration.ahk"

; Create integration instance
integration := QuartzIntegration()

; Setup hotkeys
integration.SetupHotkeys()

; Import files with automatic format detection
integration.ImportFile("path/to/document.rtf")
integration.ImportFile("path/to/document.docx")

; Export with format selection
integration.ExportFile("output.rtf", "rtf")
integration.ExportFile("output.html", "html")
integration.ExportFile("output.txt", "txt")
```

## RTF Handling Implementation

The RTF handling in Quartz works as follows:


1. When opening an RTF file:
   * Creates a COM object for Microsoft Word
   * Opens the document and copies formatted content to clipboard
   * Activates the editor window and pastes with formatting preserved
   * Restores the clipboard to its previous state
2. When saving as RTF:
   * Gets HTML content from the editor
   * Creates a temporary HTML file
   * Uses Word to open the HTML and save as RTF
   * Cleans up temporary files
3. For clipboard operations:
   * Uses specialized Win32 API calls to work with RTF format
   * Provides backup and restoration of clipboard content
   * Handles format detection and conversion

## Hotkeys

Default hotkeys when using the integration helper:

* **Ctrl+O**: Open file dialog
* **Ctrl+S**: Save file
* **Ctrl+Shift+S**: Save file as
* **Ctrl+N**: New file
* **Ctrl+Q**: Exit application

When using the base Quartz class:

* **Ctrl+Shift+N**: New file
* **Ctrl+Shift+O**: Open file dialog
* **Ctrl+Shift+S**: Save file
* **Ctrl+Shift+T**: Display plain text content
* **Ctrl+Shift+H**: Display HTML content
* **Ctrl+Shift+Q**: Exit application
* **Ctrl+Shift+A**: Show About information

## Requirements

* AutoHotkey v2.0+
* Microsoft Edge WebView2 Runtime
* Microsoft Word (for RTF handling with full formatting)

## Advanced Usage Examples

### Custom RTF Processing

```autohotkey
; Include RTF handler
#Include "RTFHandler.ahk"

; Create RTF handler instance
handler := RTFHandler()

; Extract plain text from RTF
rtfContent := FileRead("document.rtf")
plainText := handler.ExtractTextFromRTF(rtfContent)

; Process RTF file with custom window target
handler.ProcessRTFFile("document.rtf", "ahk_exe notepad.exe")
```

### Working with RTF Clipboard Format

```autohotkey
; Include RTF clipboard handler
#Include "RTFClip.ahk"

; Check if clipboard has RTF content
if (RTFClip.HasRTF()) {
    ; Get RTF content
    rtfContent := RTFClip.GetRTF()
    
    ; Process content...
    
    ; Set modified RTF back to clipboard
    RTFClip.SetRTF(modifiedRTF)
}
```

## Troubleshooting

### Common Issues


1. **WebView2 not loading**: Ensure Microsoft Edge WebView2 Runtime is installed
2. **RTF formatting lost**: Check if Microsoft Word is installed and accessible
3. **File operations failing**: Verify file paths and permissions
4. **COM errors**: Make sure Microsoft Office components are properly registered

### Debug Tips

* Enable detailed error messages:

  ```autohotkey
  #Warn All
  ```
* Check COM object state:

  ```autohotkey
  MsgBox("COM object type: " ComObjType(obj) " value: " ComObjValue(obj))
  ```
* Test clipboard operations with:

  ```autohotkey
  MsgBox("Has RTF: " RTFClip.HasRTF())
  ```

## Contributing

Contributions to improve Quartz are welcome! Please consider:


1. Adding support for more file formats
2. Enhancing the WebView2 interface
3. Improving RTF handling accuracy
4. Adding more formatting features

## License

This project is available under the MIT License.

## Credits

* Original implementation by Laser Made
* Enhanced RTF handling implementation by Claude
* Built with AutoHotkey v2 and WebView2


