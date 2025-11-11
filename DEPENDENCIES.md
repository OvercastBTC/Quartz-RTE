# Quartz-RTE Dependencies

## Overview

Quartz-RTE includes all necessary dependencies directly in the repository, making it completely self-contained and ready to use out of the box.

## Dependency Structure

```
Quartz-RTE/
├── src/
│   ├── Quartz.ahk          (Main script)
│   └── lib/                (All dependencies included)
│       ├── Pipe.ahk        
│       ├── TestLogger.ahk  
│       ├── Clipboard.ahk   
│       ├── Keys.ahk        
│       ├── WindowManager.ahk
│       ├── WebView2.ahk    
│       ├── ComVar.ahk
│       ├── Extensions/     (Sub-dependencies)
│       ├── System/         (Sub-dependencies)
│       └── Apps/           (Sub-dependencies)
```

## All Dependencies Included

All files are committed to Git and included in the repository:

### Direct Dependencies

1. **Pipe.ahk** - Module for pipe operations
   - Also needs: `jsongo.ahk` (included)

2. **TestLogger.ahk** - Debugging and logging utility
   - Also needs: `Array.ahk` (included)

3. **Clipboard.ahk** - Advanced clipboard operations
   - Also needs: `Paths.ahk`, `String.ahk`, `JSONS.ahk`, `FormatConverter.ahk`, `VSCode.ahk`, `Pandoc.ahk` (all included)

4. **Keys.ahk** - Keyboard input primitives
   - No additional dependencies

5. **WindowManager.ahk** - Window positioning and management
   - No additional dependencies

6. **WebView2.ahk** - WebView2 wrapper for AHK v2
   - Project-specific, always included

7. **ComVar.ahk** - COM variant helper
   - Project-specific, always included

## Setup Instructions

### For New Users

Simply clone and run - everything is included!

```bash
git clone https://github.com/OvercastBTC/Quartz-RTE.git
cd Quartz-RTE/src
# Run directly:
Quartz.ahk
# Or compile it
```

No setup required - all dependencies are in the repo!

### For Developers

If you need to update dependencies from your main AHK library:

```powershell
# Run the copy script from repo root
.\copy-dependencies.ps1
```

This will copy the latest versions from your AHK Lib folder.

## Why Copy Instead of Link?

**Advantages of including files:**

- ✅ Repository is self-contained
- ✅ Works immediately after clone
- ✅ No setup required for contributors
- ✅ Version controlled with the project
- ✅ Can be used as a submodule in other projects

**Considerations:**

- ⚠️ Files are duplicated on your dev machine
- ⚠️ Updates to main library don't auto-sync
- ⚠️ Use `copy-dependencies.ps1` to refresh when needed

## Compilation

When compiling Quartz-RTE to .exe, the `FileInstall` directives in `qSetup` class will bundle all dependencies into the executable.
