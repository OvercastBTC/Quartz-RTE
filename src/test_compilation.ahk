#Requires AutoHotkey v2.0+

; Simple test to verify FileInstall and compilation directives work correctly

; Test FileInstall directives (only active during compilation)
FileInstall("index.html", A_ScriptDir "\index.html", 1)
FileInstall("style.css", A_ScriptDir "\style.css", 1)
FileInstall("script.js", A_ScriptDir "\script.js", 1)

; Test script to show compilation vs non-compilation behavior
MsgBox("Testing Compilation Setup`n`n" .
       "A_IsCompiled: " . A_IsCompiled . "`n" .
       "A_ScriptDir: " . A_ScriptDir . "`n" .
       "Current working directory: " . A_WorkingDir . "`n`n" .
       "Expected file paths:`n" .
       "- index.html: " . A_ScriptDir . "\index.html`n" .
       "- style.css: " . A_ScriptDir . "\style.css`n" .
       "- script.js: " . A_ScriptDir . "\script.js`n`n" .
       "File existence check:`n" .
       "- index.html exists: " . FileExist(A_ScriptDir . "\index.html") . "`n" .
       "- style.css exists: " . FileExist(A_ScriptDir . "\style.css") . "`n" .
       "- script.js exists: " . FileExist(A_ScriptDir . "\script.js"), 
       "Quartz Compilation Test")

ExitApp
