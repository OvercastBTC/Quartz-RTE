@echo off
REM Batch file to compile Quartz RTE

echo =================================
echo Quartz RTE Compilation Script
echo =================================
echo.

REM Check if AutoHotkey compiler exists
set "AHK_COMPILER=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
if not exist "%AHK_COMPILER%" (
    echo Error: AutoHotkey compiler not found at %AHK_COMPILER%
    echo Please install AutoHotkey v2 or update the path in this script.
    pause
    exit /b 1
)

REM Check if source file exists
if not exist "Quartz.ahk" (
    echo Error: Quartz.ahk not found in current directory
    echo Please run this script from the src directory
    pause
    exit /b 1
)

echo Found AutoHotkey compiler: %AHK_COMPILER%
echo Found source file: Quartz.ahk
echo.

REM Backup existing executable if it exists
if exist "Quartz.exe" (
    echo Backing up existing Quartz.exe to Quartz.exe.bak
    copy "Quartz.exe" "Quartz.exe.bak" >nul
    del "Quartz.exe"
)

echo Compiling Quartz.ahk to Quartz.exe...
echo.

REM Compile the script
"%AHK_COMPILER%" /in "Quartz.ahk" /out "Quartz.exe"

REM Check compilation result
if exist "Quartz.exe" (
    echo.
    echo ========================
    echo Compilation Successful!
    echo ========================
    echo.
    echo Output: Quartz.exe
    echo Size: 
    for %%I in (Quartz.exe) do echo   %%~zI bytes
    echo.
    echo The executable includes all necessary dependencies:
    echo - HTML, CSS, JS files
    echo - RTF parser library
    echo - Font resources
    echo.
    echo Note: WebView2 runtime required on target systems
    echo CDN resources require internet connection
    echo.
) else (
    echo.
    echo ===================
    echo Compilation Failed!
    ===================
    echo.
    echo Please check the AutoHotkey compiler output above for errors.
    echo Common issues:
    echo - Syntax errors in Quartz.ahk
    echo - Missing include files
    echo - File permission issues
)

echo.
echo Press any key to exit...
pause >nul
