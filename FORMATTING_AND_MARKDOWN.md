# Quartz RTE - Formatting & Markdown Features

## Overview

This document describes the enhanced formatting and markdown features added to Quartz Rich Text Editor.

---

## 1.0 Strikethrough Formatting via Quill API

### What Changed

Instead of using keyboard simulation (`Send("^+x")`), strikethrough now uses Quill's native JavaScript API for more reliable formatting.

### Implementation

- **AHK Method**: `Quartz.ToggleStrikethrough()` - Calls JavaScript to toggle strikethrough
- **AHK Method**: `Quartz.ApplyFormat(formatName, value)` - Generic formatting method
- **JavaScript Function**: `toggleStrikethrough()` - Toggles strike formatting on selected text
- **JavaScript Function**: `applyFormat(formatName, value)` - Generic formatting function

### Hotkeys

- **Alt+S** (`!s`) - Toggle strikethrough on selected text
- **Ctrl+Shift+X** (`^+x`) - Native Quill hotkey (still works)

### Usage Example (AHK)

```ahk
; Toggle strikethrough
editor1.ToggleStrikethrough()

; Apply bold formatting
editor1.ApplyFormat("bold", "true")

; Remove italic formatting
editor1.ApplyFormat("italic", "false")
```

### Usage Example (JavaScript)

```javascript
// Toggle strikethrough
toggleStrikethrough();

// Apply any format
applyFormat('bold', true);
applyFormat('italic', true);
applyFormat('underline', true);
```

---

## 2.0 Enhanced Paste Handling

### What Changed

Added automatic conversion of pasted content from various formats (HTML, RTF, plain text) into Quill's Delta format.

### Features

- **Automatic HTML → Delta conversion** - Preserves formatting from web pages, Word docs, etc.
- **Format sanitization** - Only supported formats are preserved
- **RTF detection** - Detects RTF content (parser library needed for full conversion)
- **Clipboard monitoring** - Logs what type of content is being pasted

### Supported Formats on Paste

- Bold, Italic, Underline, Strikethrough
- Font family, size, color, background color
- Headers (H1-H6)
- Lists (ordered & unordered)
- Links, Code blocks, Blockquotes
- Alignment, Indentation

### Implementation

- **JavaScript Function**: `setupPasteHandler()` - Configures clipboard handlers
- **Quill Clipboard Matcher**: Processes pasted HTML nodes and converts to Delta
- **Event Listener**: Monitors paste events for different content types

### How It Works

1. User pastes content (Ctrl+V)
2. Paste event is captured
3. Content type is detected (HTML, RTF, or plain text)
4. HTML content is automatically converted to Quill Delta format
5. Unsupported formatting is stripped
6. Content is inserted into editor with preserved formatting

---

## 3.0 Markdown Support

### Question Answered: **YES! Quill can accept markdown and live convert it!**

### Features

#### 3.1 Live Markdown Conversion (Real-time)

Type markdown syntax and it automatically converts to rich text formatting as you type!

**Supported Markdown Syntax:**

- **Headers**: `## Heading` → Formatted header (H1-H6)
- **Bold**: `**text**` → **bold text**
- **Italic**: `*text*` → *italic text*
- **Strikethrough**: `~~text~~` → ~~strikethrough text~~
- **Code**: `` `text` `` → `inline code`
- **Bullet Lists**: `- item` or `* item` → • item
- **Ordered Lists**: `1. item` → 1. item

#### 3.2 Import Full Markdown Documents

Convert entire markdown documents to rich text in one go.

**AHK Method**: `editor1.ImportMarkdown(markdownText)`

**JavaScript Function**: `importMarkdown(markdown)`

#### 3.3 Toggle Markdown Mode

Enable/disable live markdown conversion on the fly.

**AHK Method**: `editor1.EnableMarkdownMode(true/false)`

**Hotkeys:**

- **Ctrl+Shift+M** (`^+m`) - Enable markdown mode
- **Ctrl+Alt+M** (`^!m`) - Disable markdown mode

### Usage Examples

#### Enable Live Markdown Mode

```ahk
; From AHK
editor1.EnableMarkdownMode(true)

; Or use hotkey: Ctrl+Shift+M
```

```javascript
// From JavaScript
enableMarkdownMode(true);
```

#### Import Markdown Document

```ahk
markdown := "
(
# My Document
This is **bold** and this is *italic*.

## Features
- Live conversion
- Full formatting support
- Easy to use

~~This is crossed out~~
)"

editor1.ImportMarkdown(markdown)
```

#### How Live Conversion Works

1. User types markdown syntax (e.g., `**bold**`)
2. Text-change event fires
3. Current line is analyzed for markdown patterns
4. Markdown syntax is removed (e.g., `**`)
5. Rich text formatting is applied
6. User sees formatted text instead of markdown

### Markdown Conversion Details

The `markdownToDelta()` function processes:

- **Block-level elements**: Headers, lists, code blocks, blockquotes
- **Inline elements**: Bold, italic, strikethrough, code, links
- **Complex structures**: Nested formatting, multi-line content

### Advanced Features

#### Custom Markdown Patterns

You can extend the markdown parser by modifying the `markdownToDelta()` function in `script.js`.

#### Markdown + Rich Text Hybrid

Because markdown mode is toggleable, you can:

1. Type in markdown mode for speed
2. Disable markdown mode
3. Use rich text toolbar for fine-tuning

---

## Architecture Overview

### File Structure

```
Quartz-RTE/
├── src/
│   ├── Quartz.ahk          # Main AHK class with formatting methods
│   ├── index.html          # HTML with paste event handlers
│   ├── script.js           # JavaScript with formatting & markdown functions
│   └── style.css           # Styling
└── lib/
    ├── WebView2.ahk        # WebView2 wrapper
    └── quill.js            # Quill editor library (CDN)
```

### Data Flow

#### Strikethrough Example

```
User presses Alt+S
    ↓
AHK: Quartz.ToggleStrikethrough()
    ↓
AHK: HTML.ExecuteScript("toggleStrikethrough();")
    ↓
JavaScript: toggleStrikethrough()
    ↓
JavaScript: quill.format('strike', true/false)
    ↓
Quill: Applies formatting to Delta
    ↓
User sees formatted text
```

#### Paste Example

```
User pastes HTML content
    ↓
Browser: paste event fires
    ↓
JavaScript: setupPasteHandler() intercepts
    ↓
JavaScript: quill.clipboard.addMatcher() processes HTML
    ↓
JavaScript: Converts HTML → Delta format
    ↓
Quill: Inserts formatted Delta content
    ↓
User sees rich text with formatting preserved
```

#### Markdown Example

```
User types: **bold**
    ↓
Quill: text-change event fires
    ↓
JavaScript: markdownListener() analyzes text
    ↓
JavaScript: Detects **text** pattern
    ↓
JavaScript: Removes ** markers
    ↓
JavaScript: quill.formatText(start, length, 'bold', true)
    ↓
User sees: bold text (formatted)
```

---

## API Reference

### AHK Methods

#### `ApplyFormat(formatName, value := "true")`

Apply any Quill-supported format to selected text.

**Parameters:**

- `formatName` - String: 'bold', 'italic', 'underline', 'strike', 'code', etc.
- `value` - String/Boolean: true/false or specific value (e.g., color hex)

**Example:**

```ahk
editor1.ApplyFormat("bold", "true")
editor1.ApplyFormat("color", "#ff0000")
```

#### `ToggleStrikethrough()`

Toggle strikethrough formatting on selected text.

**Example:**

```ahk
editor1.ToggleStrikethrough()
```

#### `EnableMarkdownMode(enable := true)`

Enable or disable live markdown conversion.

**Parameters:**

- `enable` - Boolean: true to enable, false to disable

**Example:**

```ahk
editor1.EnableMarkdownMode(true)  ; Enable
editor1.EnableMarkdownMode(false) ; Disable
```

#### `ImportMarkdown(markdown)`

Import a complete markdown document and convert to rich text.

**Parameters:**

- `markdown` - String: Markdown-formatted text

**Example:**

```ahk
markdown := "# Title`n`nThis is **bold**"
editor1.ImportMarkdown(markdown)
```

### JavaScript Functions

#### `applyFormat(formatName, value = true)`

Apply formatting to selected text.

#### `toggleStrikethrough()`

Toggle strikethrough on selection.

#### `setupPasteHandler()`

Initialize paste event handlers for format conversion.

#### `enableMarkdownMode(enable = true)`

Enable/disable live markdown conversion.

#### `importMarkdown(markdown)`

Convert markdown string to Delta and insert into editor.

#### `markdownToDelta(markdown)`

Convert markdown text to Quill Delta format.

**Returns:** Delta object

---

## Hotkey Reference

| Hotkey | Action | Notes |
|--------|--------|-------|
| `Alt+S` | Toggle Strikethrough | Via Quill API |
| `Ctrl+Shift+X` | Toggle Strikethrough | Native Quill hotkey |
| `Ctrl+Shift+M` | Enable Markdown Mode | Live conversion ON |
| `Ctrl+Alt+M` | Disable Markdown Mode | Live conversion OFF |

---

## Future Enhancements

### Potential Improvements

1. **Full RTF Parser Integration** - Currently uses placeholder, could integrate rtf.js library
2. **More Markdown Syntax** - Tables, horizontal rules, images
3. **Markdown Export** - Convert Delta → Markdown for saving
4. **Custom Markdown Shortcuts** - User-definable markdown patterns
5. **Syntax Highlighting in Code Blocks** - Already has highlight.js, could enhance
6. **Smart Paste Detection** - Auto-detect markdown vs rich text in clipboard
7. **Markdown Preview Mode** - Side-by-side markdown source and preview

### Libraries to Consider

- **rtf.js** - RTF parsing for better paste support
- **turndown** - HTML to Markdown conversion
- **marked** - Enhanced markdown parsing
- **quill-markdown-shortcuts** - Pre-built markdown module for Quill

---

## Troubleshooting

### Strikethrough Not Working

- Ensure editor window is active (title: "Quartz Rich Text Editor")
- Check that WebView2 is loaded (`editor1.isLoaded` should be true)
- Try using `Ctrl+Shift+X` (native Quill hotkey) instead

### Markdown Not Converting

- Enable markdown mode: `Ctrl+Shift+M` or `editor1.EnableMarkdownMode(true)`
- Check browser console for errors (F12 in WebView2)
- Ensure you're typing the complete pattern (e.g., both `**` for bold)

### Paste Not Preserving Formatting

- Check that the source has actual formatting (not just plain text)
- Look in browser console to see what format was detected
- Try pasting from different sources (Word, web browser, etc.)

---

## Technical Notes

### Quill Delta Format

Quill uses Delta format internally. A Delta is a series of operations:

```javascript
{
  ops: [
    { insert: "Hello " },
    { insert: "World", attributes: { bold: true } },
    { insert: "\n" }
  ]
}
```

### WebView2 Communication

AHK ↔ JavaScript communication uses:

- `ExecuteScript()` - AHK calls JavaScript
- `hostObjects.ahk` - JavaScript calls AHK methods

### Event Flow

1. User interaction (keyboard, paste, etc.)
2. Browser/Quill events fire
3. JavaScript handlers process
4. Quill Delta is updated
5. Editor re-renders

---

## Version History

**Version 0.5 - Beta 1** (Current)

- ✅ Added Quill API-based strikethrough formatting
- ✅ Added generic `ApplyFormat()` method
- ✅ Enhanced paste handling with auto-conversion
- ✅ Implemented live markdown conversion
- ✅ Added markdown import functionality
- ✅ Added markdown mode toggle
- ✅ Fixed hotkey context sensitivity

---

## Credits

- **Quill Editor**: <https://quilljs.com/>
- **WebView2**: Microsoft Edge WebView2
- **AutoHotkey v2**: <https://www.autohotkey.com/>
- **Original Quartz**: LaserMade
- **Enhancements**: Claude (Anthropic)

---

## License

See main project LICENSE file.
