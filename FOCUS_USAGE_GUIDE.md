# Quartz Focus() Method - Script vs Compiled Usage

## Overview

The `Focus()` method in Quartz works identically in both script (.ahk) and compiled (.exe) forms. The compilation setup automatically handles file dependencies and path resolution, ensuring seamless operation regardless of execution mode.

## Focus() Method Implementation

### Instance Method

```autohotkey
/**
 * @description Focus the editor
 * @description Works in both script and compiled forms
 * @returns {Quartz} This instance for method chaining
 */
Focus() {
    if (!this.isLoaded) {
        TestLogger.Log("Focus", "WebView not loaded, waiting...")
        this.WaitForLoad()
    }
    
    try {
        ; Activate the GUI window first
        WinActivate(this.RTE.Hwnd)
        
        ; Focus the Quill editor within the WebView
        this.HTML.ExecuteScript("quill.focus()")
        
        TestLogger.Log("Focus", "Editor focused successfully")
        return this
    } catch Error as err {
        TestLogger.Log("Focus", "Error focusing editor: " err.Message)
        throw Error("Failed to focus editor: " err.Message, -1)
    }
}
```

### Static Method

```autohotkey
/**
 * @description Focus the editor (static version for external calls)
 * @description Works in both script and compiled forms
 * @returns {Quartz|false} Active instance if successful, false otherwise
 */
static Focus() {
    try {
        instance := Quartz.GetActiveInstance()
        if (instance) {
            return instance.Focus()
        } else {
            TestLogger.Log("Focus", "No active Quartz editor instance found")
            return false
        }
    } catch Error as err {
        TestLogger.Log("Focus", "Error in static Focus: " err.Message)
        throw err
    }
}
```

## Usage Examples

### Basic Usage

#### Instance Method (when you have a Quartz object)

```autohotkey
; Create editor instance
myEditor := Quartz("Initial content")

; Focus the editor
myEditor.Focus()

; Method chaining is supported
myEditor.Focus().SetText("Now focused!")
```

#### Static Method (when targeting active editor)

```autohotkey
; Focus the currently active Quartz editor
Quartz.Focus()

; Use in hotkeys
F1::Quartz.Focus()
```

### Advanced Usage with Error Handling

```autohotkey
; Comprehensive focus with error handling
F2::{
    try {
        result := Quartz.Focus()
        if (result) {
            ToolTip("Editor focused successfully!")
            SetTimer(() => ToolTip(), -2000)
        } else {
            ToolTip("No active editor found!")
            SetTimer(() => ToolTip(), -2000)
        }
    } catch Error as err {
        MsgBox("Error focusing editor: " err.Message, "Focus Error")
    }
}
```

### Integration with Other Methods

```autohotkey
; Focus and then perform actions
myEditor.Focus()
         .SetText("New content")
         .SelectAll()

; Or in separate calls
myEditor.Focus()
Sleep(100)  ; Small delay if needed
myEditor.InsertText("Additional text")
```

## Compilation Differences

### Script Mode (.ahk)

- **A_IsCompiled**: `false`
- **File Structure**: Uses relative paths (`../lib/`, `../fonts/`, etc.)
- **Dependencies**: Loaded from source directory structure
- **Focus() Behavior**: Finds WebView2 control in existing GUI

### Compiled Mode (.exe)

- **A_IsCompiled**: `true`
- **File Structure**: Files extracted to executable directory
- **Dependencies**: Loaded from embedded/extracted resources
- **Focus() Behavior**: **Identical to script mode**

### Key Points

1. **No functional difference** in Focus() behavior between modes
2. **File path resolution** handled automatically by compilation setup
3. **WebView2 interactions** work identically in both forms
4. **Error handling and logging** preserved in both modes
5. **Method chaining** supported in both forms

## Technical Implementation Details

### How Focus() Works

1. **Window Activation**: `WinActivate(this.RTE.Hwnd)` brings GUI to foreground
2. **WebView Focus**: `this.HTML.ExecuteScript("quill.focus()")` focuses Quill editor
3. **Error Handling**: Comprehensive try/catch with logging
4. **Load Checking**: Waits for WebView2 to be ready if needed

### Compilation Setup

The `FileInstall()` directives ensure all dependencies are available:

```autohotkey
If (A_IsCompiled) {
    FileInstall("index.html", A_ScriptDir "\index.html", 1)
    FileInstall("style.css", A_ScriptDir "\style.css", 1) 
    FileInstall("script.js", A_ScriptDir "\script.js", 1)
    FileInstall("..\lib\js\rtf-parser\rtf-parser.js", A_ScriptDir "\lib\js\rtf-parser\rtf-parser.js", 1)
    FileInstall("..\lib\quill.js", A_ScriptDir "\lib\quill.js", 1)
    FileInstall("..\lib\quill.css", A_ScriptDir "\lib\quill.css", 1)
    FileInstall("..\fonts\poppins.css", A_ScriptDir "\fonts\poppins.css", 1)
}
```

### Path Resolution

Automatic path resolution based on compilation status:

```autohotkey
; Path configuration that changes based on compilation status
static rootDir := A_IsCompiled ? A_ScriptDir : A_ScriptDir "\.."
static libDir := A_IsCompiled ? A_ScriptDir "\lib" : A_ScriptDir "\..\lib"
static fontDir := A_IsCompiled ? A_ScriptDir "\fonts" : A_ScriptDir "\..\fonts"
static srcDir := A_IsCompiled ? A_ScriptDir : A_ScriptDir
```

## Common Use Cases

### 1. Hotkey Integration

```autohotkey
; Global hotkey to focus any Quartz editor
#f::Quartz.Focus()

; Application-specific hotkey
#HotIf WinActive("ahk_class AutoHotkeyGUI") && WinActive("Quartz")
F1::Quartz.Focus()
#HotIf
```

### 2. Multi-Instance Management

```autohotkey
; Focus specific instance by window title
editor1 := Quartz("Document 1")
editor2 := Quartz("Document 2")

; Focus specific editor
editor1.Focus()
```

### 3. Automated Workflows

```autohotkey
; Automated editing sequence
workflow := () => {
    editor := Quartz("Starting content")
    editor.Focus()
         .SelectAll()
         .InsertText("Automated content")
         .Focus()  ; Ensure focus after operations
}
```

## Troubleshooting

### Common Issues

1. **WebView2 Not Loaded**
   - Focus() automatically waits via `WaitForLoad()`
   - Check TestLogger output for loading status

2. **Window Not Found**
   - Ensure Quartz instance exists and GUI is created
   - Use static Focus() to find active instance

3. **Script vs Compiled Differences**
   - Should be none for Focus() functionality
   - Check file paths and dependencies if issues occur

### Debug Information

```autohotkey
; Check current execution mode
if (A_IsCompiled) {
    MsgBox("Running as compiled executable", "Mode")
} else {
    MsgBox("Running as script", "Mode")
}

; Test Focus() with feedback
try {
    result := Quartz.Focus()
    MsgBox("Focus result: " . (result ? "Success" : "Failed"), "Focus Test")
} catch Error as err {
    MsgBox("Focus error: " . err.Message, "Focus Test")
}
```

## Performance Considerations

- **Minimal overhead**: Focus() is lightweight operation
- **WebView2 ready check**: May add slight delay on first call
- **Window activation**: Standard Windows API call overhead
- **Compilation**: No performance difference between script/compiled modes

## Best Practices

1. **Always check return values** when using static Focus()
2. **Use try/catch** for error handling in critical applications
3. **Allow small delays** after Focus() if performing immediate text operations
4. **Test both modes** during development to ensure compatibility
5. **Use method chaining** for cleaner code when appropriate
