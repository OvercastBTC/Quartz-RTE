# Quartz RTE Compilation Guide

## Overview

This guide explains how to compile the Quartz Rich Text Editor into a standalone executable that includes all necessary dependencies.

## Dependencies Included

When compiled, the following files are automatically embedded using `FileInstall()`:

### Core Application Files

- `index.html` - Main HTML interface
- `style.css` - Application styling
- `script.js` - JavaScript functionality

### Library Dependencies

- `lib/js/rtf-parser/rtf-parser.js` - RTF parsing functionality
- `lib/quill.js` - Quill editor library (local copy)
- `lib/quill.css` - Quill editor styles (local copy)

### Font Resources

- `fonts/poppins.css` - Local font definitions

## External Dependencies (CDN)

The following resources are loaded from CDN and require internet connection:

- Quill Editor 2.0.2 (<https://cdn.jsdelivr.net/npm/quill@2.0.2/>)
- Highlight.js 11.9.0 (<https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/>)
- Google Fonts (various)

## Compilation Process

### Prerequisites

1. AutoHotkey v2.0+ installed
2. All source files present in the workspace
3. WebView2 runtime installed on target machines

### Steps to Compile

1. **Navigate to Source Directory**

   ```
   cd "c:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Extensions\.ui\RichEditors\Quartz-RTE\src"
   ```

2. **Compile using Ahk2Exe**

   ```
   "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "Quartz.ahk" /out "Quartz.exe"
   ```

3. **Optional: Include Icon**

   ```
   "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "Quartz.ahk" /out "Quartz.exe" /icon "icon.ico"
   ```

### Compilation Behavior

The `FileInstall()` directives automatically:

- Create necessary directory structure (`lib/`, `lib/js/`, `lib/js/rtf-parser/`, `fonts/`)
- Extract embedded files to correct locations
- Adjust path references for compiled vs. non-compiled execution

### Path Handling

The application uses `A_IsCompiled` to detect compilation status and adjusts paths accordingly:

**When Running as Script (.ahk)**:

- Files referenced relative to `A_ScriptDir`
- Dependencies loaded from `../lib/`, `../fonts/`, etc.

**When Running as Executable (.exe)**:

- Files extracted to same directory as executable
- Dependencies loaded from `lib/`, `fonts/`, etc.

## Distribution

When distributing the compiled executable:

### Required Files

- `Quartz.exe` (the compiled executable)
- All embedded files are automatically included

### Target System Requirements

- Windows 10/11
- WebView2 Runtime (usually pre-installed on Windows 11)
- Internet connection (for CDN resources)

### Optional

- Custom configuration files
- Additional themes or plugins

## Troubleshooting

### Common Issues

1. **Missing WebView2 Runtime**
   - Download from Microsoft's official site
   - Install WebView2 Evergreen Runtime

2. **CDN Resources Not Loading**
   - Check internet connection
   - Consider embedding CDN resources for offline use

3. **File Permissions**
   - Ensure executable has write permissions for temp directories
   - May need to run as administrator on restricted systems

### Debug Mode

To enable debug logging in compiled version:

- TestLogger functionality is preserved in compiled builds
- Check application logs for initialization status

## Advanced Configuration

### Custom File Locations

To modify embedded file locations, update the `FileInstall()` directives in `Quartz.ahk`:

```autohotkey
FileInstall("source_file", "destination_in_compiled_exe", 1)
```

### Additional Dependencies

To include additional files:

1. Add `FileInstall()` directive
2. Update path handling in `InitializeCompiledStructure()`
3. Modify application logic to reference new paths

## Performance Considerations

- Compiled executable includes all dependencies
- Startup time may be slightly longer due to file extraction
- File extraction happens once per application start
- Subsequent file access is from local disk

## Security Notes

- All embedded files are extracted to temporary locations
- Ensure sensitive data is not included in FileInstall directives
- Consider code signing for production distributions
