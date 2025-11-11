# Library Dependencies

This folder contains all the dependencies needed for Quartz-RTE to run.

## Structure

```
lib/
├── WebView2.ahk          (WebView2 wrapper)
├── ComVar.ahk            (COM variant helper)
├── Pipe.ahk              (Pipe operations)
├── TestLogger.ahk        (Debug logging)
├── Clipboard.ahk         (Clipboard operations)
├── Keys.ahk              (Keyboard primitives)
├── WindowManager.ahk     (Window management)
├── Extensions/           (Extension modules)
│   ├── .formats/         (Format converters)
│   ├── .structs/         (Data structures)
│   ├── .primitives/      (Basic utilities)
│   └── .modules/         (Feature modules)
├── System/               (System utilities)
└── Apps/                 (Application integrations)
```

## All Files Included

All dependencies and their sub-dependencies are included in this repository.
The repo is completely self-contained and ready to use!

### Direct Dependencies

- `Pipe.ahk` - Pipe communication module
- `TestLogger.ahk` - Debug logging utility  
- `Clipboard.ahk` - Advanced clipboard operations
- `Keys.ahk` - Keyboard input primitives
- `WindowManager.ahk` - Window positioning and management
- `WebView2.ahk` - WebView2 control wrapper
- `ComVar.ahk` - COM variant helper

### Sub-Dependencies (Automatically Included)

These are dependencies of the above files:

- `Extensions\.formats\jsongo.ahk` - JSON parsing (for Pipe)
- `Extensions\.structs\Array.ahk` - Array utilities (for TestLogger)
- `System\Paths.ahk` - Path utilities (for Clipboard)
- `Extensions\.primitives\String.ahk` - String utilities (for Clipboard)
- `Extensions\.formats\JSONS.ahk` - JSON utilities (for Clipboard)
- `Extensions\.formats\FormatConverter.ahk` - Format conversion (for Clipboard)
- `Apps\VSCode.ahk` - VS Code integration (for Clipboard)
- `Apps\Pandoc.ahk` - Pandoc integration (for Clipboard)

## For Developers

If you modify any of these files, consider whether:

1. The change should go back to your main AHK Lib folder
2. The change is Quartz-specific and should stay here

Use the included `copy-dependencies.ps1` script to refresh from your main AHK library if needed.
