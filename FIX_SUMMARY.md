# Fix Summary - Instance Tracking & Context-Sensitive Hotkeys

## Issues Fixed

### ✅ 1.0 - "No active quartz editor instance found" Error

**Problem:** Hotkeys couldn't find the active editor instance even when a Quartz window was open.

**Root Cause:**

- Relied on `global editor1` variable
- Static methods checked if `editor1` was set, but scope issues prevented access

**Solution:**

- Implemented instance tracking system using `Map`
- Each instance registers itself with its window handle (HWND)
- `GetActiveInstance()` automatically finds the active window's instance
- No more global variables needed!

---

### ✅ 1.1 - Removed Global Variables & Added Instance Tracker

**Changes Made:**

1. **Added Static Instance Tracking:**

   ```ahk
   static instances := Map()      ; HWND -> Instance mapping
   static instanceCount := 0      ; Unique ID counter
   ```

2. **Added Instance Properties:**

   ```ahk
   instanceID := 0    ; Unique sequential ID
   hwnd := 0          ; Window handle for this instance
   ```

3. **Automatic Registration in Constructor:**

   ```ahk
   __New(initialText := "") {
       Quartz.instanceCount++
       this.instanceID := Quartz.instanceCount
       this.SetupGUI()
       this.hwnd := this.RTE.Hwnd
       Quartz.instances[this.hwnd] := this  ; Register!
   }
   ```

4. **Smart Instance Detection:**

   ```ahk
   static GetActiveInstance() {
       activeHwnd := WinGetID("A")
       if Quartz.instances.Has(activeHwnd) {
           return Quartz.instances[activeHwnd]
       }
       ; Fallback: check all instances
       for hwnd, instance in Quartz.instances {
           if WinActive("ahk_id " hwnd) {
               return instance
           }
       }
       return false
   }
   ```

5. **Updated All Static Methods:**
   - Replaced `global editor1` with `GetActiveInstance()`
   - All static methods now automatically work with the active window

---

### ✅ 2.0 - Context-Sensitive Hotkeys

**Problem:** Some hotkeys weren't properly context-sensitive.

**Solution:** All hotkeys now wrapped in proper `#HotIf` context:

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

**Benefits:**

- Hotkeys ONLY work when Quartz window is active
- No interference with other applications
- Automatic routing to correct instance
- Clean, consistent behavior

---

## How It Works Now

### Creating Instances

```ahk
; Create one or more instances
Quartz()
Quartz()
Quartz()

; Each gets a unique ID and is tracked automatically
```

### Using Hotkeys

```ahk
; Press Alt+S while Quartz window is active
; 1. #HotIf checks: Is "Quartz Rich Text Editor" active? ✓
; 2. GetActiveInstance() finds the specific window
; 3. ToggleStrikethrough() is called on that instance
; 4. Other instances are unaffected
```

### Instance Lifecycle

```
Create: Quartz() 
  ↓
Register: instances[hwnd] = this
  ↓
Use: Hotkeys route to active instance
  ↓
Close: instances.Delete(hwnd)
  ↓
Exit: If instances.Count = 0, ExitApp()
```

---

## New API Methods

### `Quartz.GetActiveInstance()`

Returns the instance for the currently active Quartz window.

### `Quartz.GetInstance(hwnd)`

Get a specific instance by window handle.

### `Quartz.GetAllInstances()`

Get Map of all active instances.

---

## Benefits

| Feature | Before | After |
|---------|--------|-------|
| Multiple instances | ❌ | ✅ |
| Global variables | `global editor1` required | ✅ None needed |
| Hotkey context | ⚠️ Partial | ✅ Complete |
| Instance detection | ❌ Failed | ✅ Automatic |
| Error messages | "No active instance" | ✅ Works reliably |

---

## Testing

### Test Alt+S Strikethrough

1. Open Quartz
2. Type some text
3. Select the text
4. Press `Alt+S`
5. ✅ Text should be strikethrough
6. Press `Alt+S` again
7. ✅ Strikethrough should toggle off

### Test Multiple Instances

1. Run script - creates first instance
2. Call `Quartz()` again - creates second instance
3. Switch between windows
4. Press `Alt+S` in each window
5. ✅ Each window's formatting works independently

### Test Context Sensitivity

1. Open Quartz
2. Switch to another app (e.g., Notepad)
3. Press `Alt+S`
4. ✅ Should NOT trigger (different app)
5. Switch back to Quartz
6. Press `Alt+S`
7. ✅ Should work (Quartz is active)

---

## Files Modified

- **`src/Quartz.ahk`**
  - Added instance tracking system
  - Removed all `global editor1` references
  - Updated all static methods
  - Improved hotkey context sensitivity
  - Added `GetActiveInstance()`, `GetInstance()`, `GetAllInstances()`

---

## Documentation Created

- **`INSTANCE_TRACKING.md`** - Comprehensive guide to the instance tracking system

---

## Summary

✅ **Fixed:** "No active quartz editor instance found" error  
✅ **Removed:** All global variable dependencies  
✅ **Added:** Automatic instance tracking via Map  
✅ **Improved:** Hotkey context sensitivity  
✅ **Enabled:** Multiple simultaneous instances  
✅ **Enhanced:** Automatic cleanup and lifecycle management  

The system is now more robust, scalable, and user-friendly! 🎉
