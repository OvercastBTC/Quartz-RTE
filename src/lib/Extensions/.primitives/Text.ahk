/**
 * @file Text.ahk
 * @description Text manipulation utilities for AutoHotkey v2
 * @version 1.0.0
 * @author [Author Name]
 * @date 2025-09-27
 * @requires AutoHotkey v2.0+
 */

#Requires AutoHotkey v2+
#Include <Directives\__AE>

; --------------------------------------------------------------------------------
CompressSpaces(text) {
	return RegExReplace(text, ' {2,}', ' ')
}
