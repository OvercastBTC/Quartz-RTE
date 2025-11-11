# Copy all AHK library dependencies for Quartz-RTE
# This makes the repository completely self-contained

$sourceBase = "C:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib"
$destLib = "C:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Extensions\.ui\RichEditors\Quartz-RTE\src\lib"

Write-Host "Copying AHK library dependencies to Quartz-RTE..." -ForegroundColor Green

# Create lib subdirectories
$dirs = @(
    "Extensions\.formats",
    "Extensions\.structs", 
    "Extensions\.primitives",
    "Extensions\.modules",
    "System",
    "Apps",
    "Utilities"
)

foreach ($dir in $dirs) {
    $destDir = Join-Path $destLib $dir
    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        Write-Host "Created: $destDir" -ForegroundColor Cyan
    }
}

# Files to copy (with their subdirectories)
$filesToCopy = @(
    # Direct dependencies (already as hardlinks, will overwrite)
    @{Source="Extensions\.modules\Pipe.ahk"; Dest="Pipe.ahk"},
    @{Source="Utilities\TestLogger.ahk"; Dest="TestLogger.ahk"},
    @{Source="Extensions\.modules\Clipboard.ahk"; Dest="Clipboard.ahk"},
    @{Source="Extensions\.primitives\Keys.ahk"; Dest="Keys.ahk"},
    @{Source="Abstractions\WindowManager.ahk"; Dest="WindowManager.ahk"},
    
    # Pipe.ahk dependencies
    @{Source="Extensions\.formats\jsongo.ahk"; Dest="Extensions\.formats\jsongo.ahk"},
    
    # TestLogger.ahk dependencies  
    @{Source="Extensions\.structs\Array.ahk"; Dest="Extensions\.structs\Array.ahk"},
    
    # Clipboard.ahk dependencies
    @{Source="System\Paths.ahk"; Dest="System\Paths.ahk"},
    @{Source="Extensions\.primitives\String.ahk"; Dest="Extensions\.primitives\String.ahk"},
    @{Source="Extensions\.formats\JSONS.ahk"; Dest="Extensions\.formats\JSONS.ahk"},
    @{Source="Extensions\.formats\FormatConverter.ahk"; Dest="Extensions\.formats\FormatConverter.ahk"},
    @{Source="Apps\VSCode.ahk"; Dest="Apps\VSCode.ahk"},
    @{Source="Apps\Pandoc.ahk"; Dest="Apps\Pandoc.ahk"}
)

foreach ($file in $filesToCopy) {
    $sourcePath = Join-Path $sourceBase $file.Source
    $destPath = Join-Path $destLib $file.Dest
    
    if (Test-Path $sourcePath) {
        # Remove hardlink if it exists
        if (Test-Path $destPath) {
            Remove-Item $destPath -Force
        }
        
        Copy-Item $sourcePath $destPath -Force
        Write-Host "Copied: $($file.Source) -> $($file.Dest)" -ForegroundColor Yellow
    } else {
        Write-Host "WARNING: Source not found: $sourcePath" -ForegroundColor Red
    }
}

Write-Host "`nDone! All dependencies copied." -ForegroundColor Green
Write-Host "The repository is now self-contained and ready to commit." -ForegroundColor Green
