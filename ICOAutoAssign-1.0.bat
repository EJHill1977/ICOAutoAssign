@echo off
setlocal enabledelayedexpansion

echo Scanning Desktop and all SUBFOLDERS for icons...
echo.

:: Use PowerShell to perform a recursive search (-Recurse)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Desktop');" ^
    "$folders = Get-ChildItem -Path $desktopPath -Directory -Recurse;" ^
    "foreach ($folder in $folders) {" ^
    "    $iconFile = Get-ChildItem -Path $folder.FullName -Filter '*.ico' | Select-Object -First 1;" ^
    "    if ($iconFile) {" ^
    "        $iniPath = Join-Path -Path $folder.FullName -ChildPath 'desktop.ini';" ^
    "        if (Test-Path $iniPath) {" ^
    "            $attribs = (Get-Item $iniPath -Force).Attributes;" ^
    "            Set-ItemProperty -Path $iniPath -Name Attributes -Value 'Archive' -Force;" ^
    "            Remove-Item $iniPath -Force;" ^
    "        };" ^
    "        $iniContent = '[.ShellClassInfo]', \"IconResource=$($iconFile.FullName),0\";" ^
    "        $iniContent | Out-File -FilePath $iniPath -Encoding unicode;" ^
    "        (Get-Item $iniPath -Force).Attributes = 'Hidden, System';" ^
    "        (Get-Item $folder.FullName).Attributes = 'ReadOnly';" ^
    "        Write-Host 'Applied: ' $iconFile.Name ' to ' $folder.FullName -ForegroundColor Green;" ^
    "    }" ^
    "}"

echo.
echo Refreshing Desktop and Explorer...
taskkill /f /im explorer.exe >nul
start explorer.exe

echo Done! Everything is updated.
pause >nul