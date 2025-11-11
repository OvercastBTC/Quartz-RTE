# Instance Tracking System - Implementation Guide

## Overview

The Quartz Rich Text Editor now uses a robust **instance tracking system** instead of relying on global variables. This allows multiple editor instances to run simultaneously and ensures hotkeys work correctly with the active window.

---

## What Changed

### 🔴 **Old System (Removed)**

```ahk
global editor1  ; Single global variable
editor1 := Quartz()

#HotIf WinActive("Quartz Rich Text Editor")
!s::editor1.ToggleStrikethrough()  ; Direct reference to global
```

**Problems:**

- Only supported one instance
- Global variable scope issues
- Hotkeys failed if `editor1` wasn't set
- No way to track multiple windows

---

### 🟢 **New System (Current)**

#### Static Instance Tracking

```ahk
class Quartz {
    static instances := Map()      ; Map of HWND -> instance
    static instanceCount := 0      ; Unique ID counter
    
    ; Instance properties
    instanceID := 0
    hwnd := 0
    RTE := ""
    WV2 := ""
    HTML := ""
    isLoaded := false
}
```

#### Automatic Registration

```ahk
__New(initialText := "") {
    ; Assign unique ID
    Quartz.instanceCount++
    this.instanceID := Quartz.instanceCount
    
    this.SetupGUI()
    
    ; Store window handle
    this.hwnd := this.RTE.Hwnd
    
    ; Register in instance map
    Quartz.instances[this.hwnd] := this
}
```

#### Smart Instance Detection

```ahk
static GetActiveInstance() {
    ; Get the currently active window
    activeHwnd := WinGetID("A")
    
    ; Check if it's a registered Quartz window
    if Quartz.instances.Has(activeHwnd) {
        return Quartz.instances[activeHwnd]
    }
    
    ; Fallback: Check all instances
    for hwnd, instance in Quartz.instances {
        if WinActive("ahk_id " hwnd) {
            return instance
        }
    }
    
    return false
}
```

---

## Key Features

### ✅ **Multiple Instances**

You can now run multiple Quartz editors simultaneously:

```ahk
editor1 := Quartz()
editor2 := Quartz()
editor3 := Quartz()
```

Each instance is tracked independently by window handle (HWND).

### ✅ **Automatic Hotkey Routing**

Hotkeys automatically work with the active window:

```ahk
#HotIf WinActive("Quartz Rich Text Editor")
!s::Quartz.ToggleStrikethrough()
```

When you press `Alt+S`, it:

1. Detects which Quartz window is active
2. Gets that window's instance from the Map
3. Calls the method on the correct instance

### ✅ **Automatic Cleanup**

When a window closes, it unregisters itself:

```ahk
Exit() {
    ; Unregister this instance
    if Quartz.instances.Has(this.hwnd) {
        Quartz.instances.Delete(this.hwnd)
    }
    
    ; If no more instances, exit app
    if (Quartz.instances.Count = 0) {
        ExitApp()
    }
}
```

### ✅ **No Global Variables**

All instances are managed internally via the static `instances` Map. No need for `global editor1`.

---

## API Reference

### Static Methods

#### `Quartz.GetActiveInstance()`

Returns the Quartz instance for the currently active window.

**Returns:** `Quartz` instance or `false` if none found

**Example:**

```ahk
instance := Quartz.GetActiveInstance()
if (instance) {
    instance.ToggleStrikethrough()
}
```

#### `Quartz.GetInstance(hwnd)`

Get a specific instance by window handle.

**Parameters:**

- `hwnd` - Integer: Window handle

**Returns:** `Quartz` instance or `false`

**Example:**

```ahk
hwnd := WinGetID("Quartz Rich Text Editor")
instance := Quartz.GetInstance(hwnd)
```

#### `Quartz.GetAllInstances()`

Get all active instances.

**Returns:** `Map` of HWND → Quartz instance

**Example:**

```ahk
allInstances := Quartz.GetAllInstances()
for hwnd, instance in allInstances {
    MsgBox("Instance ID: " instance.instanceID "`nHWND: " hwnd)
}
```

### Instance Properties

- `instanceID` - Unique sequential ID (1, 2, 3...)
- `hwnd` - Window handle for this instance
- `RTE` - Gui object
- `WV2` - WebView2 control
- `HTML` - CoreWebView2 interface
- `isLoaded` - Boolean flag

---

## Usage Examples

### Example 1: Create Multiple Editors

```ahk
#Requires AutoHotkey v2.0+
#Include Quartz.ahk

; Create three editor instances
Quartz()  ; Instance 1
Quartz()  ; Instance 2
Quartz()  ; Instance 3

; Each has its own window and operates independently
; Hotkeys automatically work with the active window
```

### Example 2: Get Active Instance Info

```ahk
#HotIf WinActive("Quartz Rich Text Editor")
^i:: {  ; Ctrl+I - Show instance info
    instance := Quartz.GetActiveInstance()
    if (instance) {
        info := "Instance ID: " instance.instanceID
        info .= "`nWindow Handle: " instance.hwnd
        info .= "`nLoaded: " (instance.isLoaded ? "Yes" : "No")
        MsgBox(info, "Instance Information")
    }
}
#HotIf
```

### Example 3: List All Instances

```ahk
F1:: {  ; Press F1 to list all instances
    instances := Quartz.GetAllInstances()
    
    if (instances.Count = 0) {
        MsgBox("No Quartz instances running")
        return
    }
    
    list := "Active Quartz Instances:`n`n"
    for hwnd, instance in instances {
        list .= "ID: " instance.instanceID 
        list .= " | HWND: " hwnd
        list .= " | Loaded: " (instance.isLoaded ? "✓" : "✗")
        list .= "`n"
    }
    
    MsgBox(list)
}
```

### Example 4: Custom Hotkey for Specific Instance

```ahk
; Save content from all instances
^!s:: {
    instances := Quartz.GetAllInstances()
    for hwnd, instance in instances {
        if (instance.isLoaded) {
            content := instance.GetHTML()
            filename := "Quartz_Instance_" instance.instanceID ".html"
            FileAppend(content, filename)
        }
    }
    MsgBox("Saved all instances!")
}
```

---

## Hotkey Context Sensitivity

All hotkeys are now properly context-sensitive:

```ahk
#HotIf WinActive("Quartz Rich Text Editor")

; File operations
^+n::Quartz.NewFile()
^+o::Quartz.OpenFile()
^+s::{
    instance := Quartz.GetActiveInstance()
    if (instance) {
        Quartz.SaveFile(instance.GetHTML())
    }
}

; Formatting
!s::Quartz.ToggleStrikethrough()
^+x::Quartz.ToggleStrikethrough()

; Markdown
^+m::Quartz.EnableMarkdownMode(true)
^!m::Quartz.EnableMarkdownMode(false)

#HotIf  ; End context
```

**How it works:**

1. `#HotIf WinActive("Quartz Rich Text Editor")` - Only active when Quartz window has focus
2. Hotkey is pressed
3. `GetActiveInstance()` identifies which window is active
4. Method is called on that specific instance
5. Other instances are unaffected

---

## Migration Guide

### If You Had Custom Code Using `global editor1`

**Before:**

```ahk
global editor1
editor1 := Quartz()

; Later in code...
editor1.ToggleStrikethrough()
```

**After (Option 1 - Use GetActiveInstance):**

```ahk
Quartz()

; Later in code...
instance := Quartz.GetActiveInstance()
if (instance) {
    instance.ToggleStrikethrough()
}
```

**After (Option 2 - Store reference yourself):**

```ahk
myEditor := Quartz()

; Later in code...
myEditor.ToggleStrikethrough()
```

**After (Option 3 - Use static methods with hotkeys):**

```ahk
Quartz()

#HotIf WinActive("Quartz Rich Text Editor")
!s::Quartz.ToggleStrikethrough()  ; Automatically finds active instance
#HotIf
```

---

## Technical Details

### Instance Map Structure

```ahk
Quartz.instances := Map(
    123456 => QuartzInstance1,  ; HWND => Instance
    123789 => QuartzInstance2,
    124012 => QuartzInstance3
)
```

### Instance Lifecycle

1. **Creation**
   - `Quartz()` constructor called
   - Instance ID assigned (sequential)
   - GUI created and HWND obtained
   - Instance registered in Map

2. **Usage**
   - User interacts with window
   - Hotkeys detect active window
   - `GetActiveInstance()` retrieves instance
   - Methods called on correct instance

3. **Destruction**
   - User closes window or calls `Exit()`
   - Instance removed from Map
   - GUI destroyed
   - If no instances remain, app exits

### Performance

- **Instance lookup**: O(1) - Direct Map access by HWND
- **Active detection**: O(1) or O(n) - Direct lookup first, fallback iteration
- **Memory**: Minimal - Only stores references in Map
- **Overhead**: Negligible - Map operations are extremely fast

---

## Troubleshooting

### "No active Quartz editor instance found"

**Cause:** The active window is not a Quartz window, or the instance wasn't registered.

**Solutions:**

1. Make sure a Quartz window is active when using hotkeys
2. Check that `WinActive("Quartz Rich Text Editor")` matches your window title
3. Verify the instance was created successfully

**Debug:**

```ahk
^!d:: {  ; Ctrl+Alt+D - Debug
    MsgBox("Active HWND: " WinGetID("A") "`nInstances: " Quartz.instances.Count)
}
```

### Multiple Instances Not Working

**Cause:** Static properties being accessed incorrectly.

**Solution:** Always use instance properties, not static ones:

```ahk
; ❌ Wrong
Quartz.isLoaded

; ✅ Correct
instance := Quartz.GetActiveInstance()
instance.isLoaded
```

### Hotkeys Not Working

**Verify context:**

```ahk
#HotIf WinActive("Quartz Rich Text Editor")  ; Must match window title exactly
!s::Quartz.ToggleStrikethrough()
#HotIf  ; Don't forget to close the context!
```

---

## Benefits Summary

| Feature | Old System | New System |
|---------|-----------|------------|
| Multiple instances | ❌ No | ✅ Yes |
| No globals | ❌ Required `global editor1` | ✅ Fully self-contained |
| Hotkey context | ⚠️ Manual | ✅ Automatic |
| Instance tracking | ❌ None | ✅ Full tracking |
| Cleanup | ⚠️ Manual | ✅ Automatic |
| Scalability | ❌ Single instance | ✅ Unlimited instances |
| Debugging | ⚠️ Difficult | ✅ Easy (instance IDs, Map inspection) |

---

## Future Enhancements

### Possible Additions

1. **Persistent Instance Data**
   - Save instance state to INI file
   - Restore instances on app restart

2. **Instance Communication**
   - Send content between instances
   - Synchronize settings

3. **Instance Manager GUI**
   - List all instances
   - Switch between instances
   - Close specific instances

4. **Named Instances**

   ```ahk
   Quartz.Create("MainEditor")
   Quartz.Create("NotesSidebar")
   
   Quartz.GetInstance("MainEditor").SetText("Hello")
   ```

5. **Instance Events**

   ```ahk
   instance.OnActivate := (*) => MsgBox("Instance activated!")
   instance.OnClose := (*) => SaveContent()
   ```

---

## Conclusion

The new instance tracking system provides a robust, scalable foundation for Quartz. It eliminates the need for global variables, supports multiple instances, and ensures hotkeys always work with the active window.

**Key Takeaway:** You don't need to manage instances manually - the system handles everything automatically!
