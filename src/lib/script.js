// add tooltips on hover - not finished yet!!

const options = document.querySelectorAll('.ql-formats');
options.forEach(opt => {
    let numFonts = 0;
    let numHeaders = 0;
    opt.childNodes.forEach(child => {
        child.name = child.className.replace('ql-', '')
        const span = document.createElement('span')
        span.classList.add('tooltip')
        switch(child.name) {
            // case 'bold': span.textContent = 'Bold text'
            case 'bold': span.textContent = 'Ctrl +B: Bold text'
            break;
            case 'italic': span.textContent = 'Ctrl +I: Italic text'
            break;
            case 'underline': span.textContent = 'Ctrl +U: Underline text'
            break;
            case 'strike': span.textContent = 'Ctrl +Shift +X: Strikethrough text'
            break;
            case 'blockquote': span.textContent = 'Ctrl +Q: Blockquote'
            break;
            case 'code-block': span.textContent = 'Ctrl +K: Code block'
            break;
            case 'list': span.textContent = 'Ctrl +L: List'
            break;
            case 'indent': span.textContent = 'Ctrl +M: Indent'
            break;
            case 'link': span.textContent = 'Ctrl +K: Link'
            break;
            case 'image': span.textContent = 'Ctrl +Shift +I: Image'
            break;
            case 'video': span.textContent = 'Ctrl +Shift +V: Video'
            break;
            case 'clean': span.textContent = 'Remove formatting'
            break;
        }
        if (child.name.includes('font')){
            span.textContent = numFonts==0 ? 'Font' : ''
            numFonts++;
        } else if (child.name.includes('header')) {
            span.textContent = numHeaders==0 ? 'Header/Size' : ''
            numHeaders++;
        } else if (child.name.includes('align')) {
            span.textContent = 'Align'
        } else if (child.name.includes('color')) {
            span.textContent = 'Font color'
        } else if (child.name.includes('background')) {
            span.textContent = 'Background color'
        }
        child.appendChild(span)
        child.addEventListener('mouseover', () => {
            if (!child.classList.toString().includes('expanded')){
                span.classList.add('active')
            }
            child.addEventListener('click', () => {
                span.classList.remove('active')
            })
        })
        child.addEventListener('mouseleave', () => {
            span.classList.remove('active')
        })
    })
}); 

function newFile() {
    quill.setContents(new Delta());
    quill.focus();
}

function openFile() {
    obj = chrome.webview.hostObjects.ahk;
    obj.OpenFile();
}

function saveFile() {
    obj = chrome.webview.hostObjects.ahk;
    obj.SaveFile(quill.getText());
}

function passText() {
    console.log(`We are going to pass the editor contents to AHK...
The contents are: 
${quill.getText()}`);
    obj = chrome.webview.hostObjects.ahk;
    obj.get(quill.getText());
}

function exitApp() {
    obj = chrome.webview.hostObjects.ahk;
    obj.exit();
}

function passHTML() {
    console.log(`We are going to pass the editor HTML contents to AHK...
The contents are: 
${quill.getSemanticHTML()}`);
    obj = chrome.webview.hostObjects.ahk;
    obj.getHTML(quill.getSemanticHTML());
}

function about() {
    obj = chrome.webview.hostObjects.ahk;
    obj.about();
}

/**
 * Toggle strikethrough formatting for selected text
 * Uses Quill's formatting API directly
 */
function toggleStrikethrough() {
    const range = quill.getSelection();
    if (range) {
        const format = quill.getFormat(range);
        // Toggle the strike format
        quill.format('strike', !format.strike);
    } else {
        console.log('No text selected for strikethrough');
    }
}

/**
 * Apply formatting to selected text
 * @param {string} formatName - The format to apply (e.g., 'bold', 'italic', 'strike', 'underline')
 * @param {any} value - The value for the format (true/false for toggles, or specific values)
 */
function applyFormat(formatName, value = true) {
    const range = quill.getSelection();
    if (range && range.length > 0) {
        quill.formatText(range.index, range.length, formatName, value);
    } else {
        // If no selection, set format for next input
        quill.format(formatName, value);
    }
}

/**
 * Import RTF content as HTML
 * @param {string} rtfContent - RTF content to import
 */
function importRTFasHTML(rtfContent) {
    // You'll need to include rtf.js or similar library for this to work
    try {
        // This is a placeholder - actual implementation depends on the RTF parser library
        const htmlContent = convertRTFtoHTML(rtfContent);
        quill.clipboard.dangerouslyPasteHTML(htmlContent);
        return true;
    } catch (error) {
        console.error('Error importing RTF as HTML:', error);
        return false;
    }
}

/**
 * Import RTF content as Delta format
 * @param {string} rtfContent - RTF content to import
 */
function importRTFasDelta(rtfContent) {
    try {
        // First convert RTF to HTML (using an RTF parser library)
        const htmlContent = convertRTFtoHTML(rtfContent);
        
        // Create temporary div to hold HTML
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = htmlContent;
        document.body.appendChild(tempDiv);
        
        // Convert to Delta format
        const delta = quill.clipboard.convert(tempDiv.innerHTML);
        
        // Apply delta to editor
        quill.setContents(delta);
        
        // Clean up
        document.body.removeChild(tempDiv);
        return true;
    } catch (error) {
        console.error('Error importing RTF as Delta:', error);
        return false;
    }
}

/**
 * Convert RTF to HTML (placeholder - needs actual RTF parser)
 * @param {string} rtfContent - RTF content
 * @returns {string} HTML content
 */
function convertRTFtoHTML(rtfContent) {
    // This function is deprecated - RTF conversion is now handled by AHK via Word COM
    console.log('RTF conversion requested - should be handled by AHK');
    return '';
}

/**
 * Enhanced paste handler for rich text content
 * Converts various formats to Quill's Delta format
 */
function setupPasteHandler() {
    // Custom matcher for preserving formatting from various sources
    quill.clipboard.addMatcher(Node.ELEMENT_NODE, (node, delta) => {
        // Process the delta to ensure compatibility
        const ops = delta.ops.map(op => {
            // Preserve supported formatting
            if (op.attributes) {
                const cleanAttrs = {};
                const supportedAttrs = ['bold', 'italic', 'underline', 'strike', 'code', 'link', 
                                       'color', 'background', 'font', 'size', 'header', 'list', 
                                       'align', 'indent', 'blockquote', 'code-block'];
                
                Object.keys(op.attributes).forEach(attr => {
                    if (supportedAttrs.includes(attr)) {
                        cleanAttrs[attr] = op.attributes[attr];
                    }
                });
                
                return { ...op, attributes: cleanAttrs };
            }
            return op;
        });
        
        return new Delta(ops);
    });
    
    // Listen for paste events to handle special cases
    quill.root.addEventListener('paste', (event) => {
        const clipboardData = event.clipboardData || window.clipboardData;
        
        // Check for RTF content
        if (clipboardData.types.includes('text/rtf')) {
            const rtfData = clipboardData.getData('text/rtf');
            console.log('RTF content detected in paste');
            // RTF conversion would happen here if we have a parser
        }
        
        // Check for HTML content
        if (clipboardData.types.includes('text/html')) {
            const htmlData = clipboardData.getData('text/html');
            console.log('HTML content detected in paste');
            // Quill automatically handles HTML to Delta conversion
        }
        
        // Plain text fallback
        if (clipboardData.types.includes('text/plain')) {
            console.log('Plain text content detected in paste');
        }
    });
}

// Initialize paste handler when page loads
if (typeof quill !== 'undefined') {
    setupPasteHandler();
}

/**
 * Convert Markdown to Quill Delta format
 * @param {string} markdown - Markdown text to convert
 * @returns {Object} Delta object for Quill
 */
function markdownToDelta(markdown) {
    const lines = markdown.split('\n');
    const delta = new Delta();
    
    lines.forEach((line, index) => {
        let ops = [];
        
        // Headers
        const headerMatch = line.match(/^(#{1,6})\s+(.+)$/);
        if (headerMatch) {
            const level = headerMatch[1].length;
            delta.insert(headerMatch[2]);
            delta.insert('\n', { header: level });
            return;
        }
        
        // Blockquotes
        if (line.startsWith('> ')) {
            delta.insert(line.substring(2));
            delta.insert('\n', { blockquote: true });
            return;
        }
        
        // Code blocks
        if (line.startsWith('```')) {
            // Handle code block start/end
            delta.insert(line.substring(3));
            delta.insert('\n', { 'code-block': true });
            return;
        }
        
        // Lists - ordered
        const orderedListMatch = line.match(/^(\d+)\.\s+(.+)$/);
        if (orderedListMatch) {
            delta.insert(orderedListMatch[2]);
            delta.insert('\n', { list: 'ordered' });
            return;
        }
        
        // Lists - unordered
        const unorderedListMatch = line.match(/^[-*+]\s+(.+)$/);
        if (unorderedListMatch) {
            delta.insert(unorderedListMatch[1]);
            delta.insert('\n', { list: 'bullet' });
            return;
        }
        
        // Process inline formatting
        let processedLine = line;
        let currentIndex = 0;
        
        // Bold with **text** or __text__
        const boldRegex = /(\*\*|__)(.*?)\1/g;
        processedLine = processInlineFormat(processedLine, boldRegex, 'bold');
        
        // Italic with *text* or _text_
        const italicRegex = /(\*|_)(.*?)\1/g;
        processedLine = processInlineFormat(processedLine, italicRegex, 'italic');
        
        // Strikethrough with ~~text~~
        const strikeRegex = /~~(.*?)~~/g;
        processedLine = processInlineFormat(processedLine, strikeRegex, 'strike');
        
        // Code with `text`
        const codeRegex = /`([^`]+)`/g;
        processedLine = processInlineFormat(processedLine, codeRegex, 'code');
        
        // Links [text](url)
        const linkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
        processedLine = processedLine.replace(linkRegex, (match, text, url) => {
            delta.insert(text, { link: url });
            return '';
        });
        
        // Add the processed line
        if (processedLine) {
            delta.insert(processedLine);
        }
        
        // Add newline if not last line
        if (index < lines.length - 1) {
            delta.insert('\n');
        }
    });
    
    return delta;
}

/**
 * Helper function to process inline markdown formatting
 * @param {string} text - Text to process
 * @param {RegExp} regex - Regular expression to match
 * @param {string} format - Format to apply
 * @returns {string} Text with format markers for Delta processing
 */
function processInlineFormat(text, regex, format) {
    // This is a simplified version - a full implementation would build Delta ops
    return text.replace(regex, (match, marker, content) => {
        // Store format information for Delta conversion
        return content || match;
    });
}

/**
 * Enable live markdown conversion as you type
 * @param {boolean} enable - Whether to enable markdown conversion
 */
function enableMarkdownMode(enable = true) {
    if (!enable) {
        // Remove markdown listener if it exists
        if (quill.markdownListener) {
            quill.off('text-change', quill.markdownListener);
            quill.markdownListener = null;
        }
        return;
    }
    
    // Create markdown conversion listener
    quill.markdownListener = function(delta, oldDelta, source) {
        if (source !== 'user') return;
        
        // Get the current line
        const selection = quill.getSelection();
        if (!selection) return;
        
        const [line, offset] = quill.getLine(selection.index);
        const text = quill.getText(line.offset(), line.length());
        
        // Check for markdown patterns
        // Headers: ## text -> Header
        if (text.match(/^#{1,6}\s/)) {
            const match = text.match(/^(#{1,6})\s+(.*)$/);
            if (match) {
                const level = match[1].length;
                const content = match[2];
                
                // Replace with formatted header
                quill.deleteText(line.offset(), line.length());
                quill.insertText(line.offset(), content);
                quill.formatLine(line.offset(), 1, 'header', level);
            }
        }
        
        // Bold: **text** -> bold text
        if (text.includes('**')) {
            const match = text.match(/\*\*([^*]+)\*\*/);
            if (match) {
                const start = line.offset() + text.indexOf(match[0]);
                quill.deleteText(start, 2); // Remove opening **
                quill.deleteText(start + match[1].length, 2); // Remove closing **
                quill.formatText(start, match[1].length, 'bold', true);
            }
        }
        
        // Italic: *text* -> italic text
        if (text.match(/(?<!\*)\*(?!\*)([^*]+)\*(?!\*)/)) {
            const match = text.match(/(?<!\*)\*(?!\*)([^*]+)\*(?!\*)/);
            if (match) {
                const start = line.offset() + text.indexOf(match[0]);
                quill.deleteText(start, 1); // Remove opening *
                quill.deleteText(start + match[1].length, 1); // Remove closing *
                quill.formatText(start, match[1].length, 'italic', true);
            }
        }
        
        // Strikethrough: ~~text~~ -> strikethrough text
        if (text.includes('~~')) {
            const match = text.match(/~~([^~]+)~~/);
            if (match) {
                const start = line.offset() + text.indexOf(match[0]);
                quill.deleteText(start, 2); // Remove opening ~~
                quill.deleteText(start + match[1].length, 2); // Remove closing ~~
                quill.formatText(start, match[1].length, 'strike', true);
            }
        }
        
        // Code: `text` -> code text
        if (text.includes('`')) {
            const match = text.match(/`([^`]+)`/);
            if (match) {
                const start = line.offset() + text.indexOf(match[0]);
                quill.deleteText(start, 1); // Remove opening `
                quill.deleteText(start + match[1].length, 1); // Remove closing `
                quill.formatText(start, match[1].length, 'code', true);
            }
        }
        
        // Lists: - text or * text or 1. text
        if (text.match(/^[-*+]\s/) || text.match(/^\d+\.\s/)) {
            const isBullet = text.match(/^[-*+]\s/);
            const isOrdered = text.match(/^\d+\.\s/);
            
            if (isBullet) {
                const content = text.substring(2);
                quill.deleteText(line.offset(), 2);
                quill.formatLine(line.offset(), 1, 'list', 'bullet');
            } else if (isOrdered) {
                const match = text.match(/^(\d+)\.\s(.*)$/);
                if (match) {
                    const content = match[2];
                    quill.deleteText(line.offset(), match[1].length + 2);
                    quill.formatLine(line.offset(), 1, 'list', 'ordered');
                }
            }
        }
    };
    
    quill.on('text-change', quill.markdownListener);
}

/**
 * Import markdown text into the editor
 * @param {string} markdown - Markdown text to import
 */
function importMarkdown(markdown) {
    const delta = markdownToDelta(markdown);
    quill.setContents(delta);
}

// Ctrl+Scroll handler is in index.html after Quill initialization


