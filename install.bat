@echo off
setlocal

:: Create 'temp' Directory
if not exist "%~dp0\bin\temp" mkdir "%~dp0\bin\temp"

:: Set Current Version Number
set /p current=<version.txt

:: Get Latest Version File
echo Comparing versions...
type NUL > "%~dp0\bin\temp\version_new.txt"
powershell -c "(Invoke-WebRequest -URI 'https://raw.githubusercontent.com/Lewwy95/mod-peak/main/version.txt').Content | Set-Content -Path '%~dp0\bin\temp\version_new.txt'"
cls

:: Set Latest Version Number
set /p new=<"%~dp0\bin\temp\version_new.txt"

:: Print Version Information
echo Checking for updates...
echo.
echo Current: v%current%
echo Latest: v%new%
timeout /t 2 /nobreak >nul
cls

:: Clear New Version File
del /s /q "%~dp0\bin\temp\version_new.txt"
cls

:: Check For Different Version Files
if %new% neq %current% (
    echo Update required! Downloading...
    timeout /t 2 /nobreak >nul
    cls
    goto download
)

:: Check For Install
if exist "%~dp0..\BepInEx" goto launch

:: Not Installed
echo Not installed! Installing...
timeout /t 2 /nobreak >nul
cls
goto install

:: Downloader
:download
echo Downloading latest revision...
echo.
powershell -c "(New-Object System.Net.WebClient).DownloadFile('https://github.com/Lewwy95/mod-peak/archive/refs/heads/main.zip','%~dp0\bin\temp\mod-peak-main.zip')"
cls

:: Extract Latest Revision
echo Extracting latest revision...
powershell -c "Expand-Archive '%~dp0\bin\temp\mod-peak-main.zip' -Force '%~dp0\bin\temp'"
cls

:: Deploy Latest Revision
echo Deploying latest revision...
xcopy /s /y "%~dp0\bin\temp\mod-peak-main\*" "%~dp0"
cls

:: Apply New Version File
break>version.txt
powershell -c "(Invoke-WebRequest -URI 'https://raw.githubusercontent.com/Lewwy95/mod-peak/main/version.txt').Content | Set-Content -Path '%~dp0\version.txt'"
cls

:: Uninstall All Mods
:install
call "%~dp0\uninstall.bat"

:: Move New Mods
echo Installing mods...
if not exist "%~dp0..\BepInEx" (
    :: Create the core folders and move the files
    powershell -c "Expand-Archive '%~dp0\bin\mods\BepInEx.zip' -Force '%~dp0\bin\temp'"
    xcopy /s /y /i "%~dp0\bin\temp\*" "%~dp0..\"

    :: Copy mods and dependencies over
    xcopy /s /y /i "%~dp0\bin\mods\*.dll" "%~dp0..\BepInEx\plugins"
    xcopy /s /y /i "%~dp0\bin\configs\*" "%~dp0..\BepInEx\config"

    :: Delete left over files (if any)
    del /s /q "%~dp0..\mod-peak-main.zip"
    rmdir /s /q "%~dp0..\mod-peak-main"
)
cls

:: Create Text File With Mods
:modlist
if exist "%~dp0\modlist.txt" del /s /q "%~dp0\modlist.txt"
echo Creating mods text file...
echo - PEAKUnlimited>> modlist.txt
cls

:: Clear 'temp' Folder
echo Cleaning up...
del /s /q "%~dp0\bin\temp\*"
rmdir /s /q "%~dp0\bin\temp"
mkdir "%~dp0\bin\temp"
cls

:: Launch Game
:launch
echo Launching game...
timeout /t 2 /nobreak >nul
start "" "steam://rungameid/3527290"

:: Finish
endlocal
