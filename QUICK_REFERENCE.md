# Quartz RTE - Quick Reference Card

## 🎯 Hotkeys

| Hotkey | Action |
|--------|--------|
| `Alt+S` | Toggle strikethrough |
| `Ctrl+Shift+M` | Enable markdown mode |
| `Ctrl+Alt+M` | Disable markdown mode |
| `Ctrl+Shift+X` | Strikethrough (native Quill) |
| `Ctrl+B` | Bold (native Quill) |
| `Ctrl+I` | Italic (native Quill) |
| `Ctrl+U` | Underline (native Quill) |

## 📝 Markdown Syntax (when enabled)

| Type | Converts To |
|------|-------------|
| `## Heading` | H2 Header |
| `**bold**` | **Bold text** |
| `*italic*` | *Italic text* |
| `~~strike~~` | ~~Strikethrough~~ |
| `` `code` `` | `Inline code` |
| `- item` | • Bullet list |
| `1. item` | Numbered list |

## 💻 AHK Methods

```ahk
; Formatting
editor1.ApplyFormat("bold", "true")
editor1.ApplyFormat("italic", "true")
editor1.ToggleStrikethrough()

; Markdown
editor1.EnableMarkdownMode(true)
editor1.ImportMarkdown("# My **markdown** text")
```

## 📋 Paste Support

Automatically converts formatting from:

- Microsoft Word
- Web browsers
- Other rich text sources

Supported formats: Bold, Italic, Underline, Strike, Colors, Lists, Headers, Links
