@echo off
echo INIT INVEROMENT.....
echo Please wait
:::  ________        __                                  __     ______                        _                  
::: |_   __  |      |  ]                                |  ]  .' ___  |                      / |_                
:::  | |_ \_|  .--.| | _   _   __  ,--.   _ .--.   .--.| |  / .'   \_| _ .--.  .---.  ,--. `| |-'.---.  _ .--.  
:::  |  _| _ / /'`\' |[ \ [ \ [  ]`'_\ : [ `/'`\]/ /'`\' |  | |       [ `/'`\]/ /__\\`'_\ : | | / /__\\[ `/'`\] 
:::  _| |__/ || \__/  | \ \/\ \/ / // | |, | |    | \__/  |  \ `.___.'\ | |    | \__.,// | |,| |,| \__., | |     
::: |________| '.__.;__] \__/\__/  \'-;__/[___]    '.__.;__]  `.____ .'[___]    '.__.'\'-;__/\__/ '.__.'[___]                                                                                                               
for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A
:INIT

if not exist %~dp0capturelite mkdir capturelite
if not exist %~dp0capturelite\data mkdir capturelite\data
if exist capturelite\tool\platform-tools (
   cd %~dp0capturelite\tool\platform-tools
    where adb.exe >nul 2>&1 &&(
        echo ADB is available.
        goto OPENADB
    ) ||(
        
         goto DOWNLOAD
    )
  
)
:DOWNLOAD
echo checking internet connection....
Ping www.google.nl -n 1 -w 1000
if errorlevel 1 (
    echo Not connected to internet 
    goto RETRY_AGAIN)
    goto CLEAR_TOOL
:DOWNLOAD_START
    powershell -command "Start-BitsTransfer -Source https://dl.google.com/android/repository/platform-tools-latest-windows.zip -Destination capturelite\folder.zip"
    
    echo Download ADB tools Completed.
    
    echo Extracting ADB file ....
    powershell -command "Expand-Archive capturelite\folder.zip capturelite\tool"
    
     echo Setup ADB completely!
    goto INIT


:OPENADB
cls
if exist "%~dp0capturelite\tool\platform-tools\devices.txt" del "%~dp0capturelite\tool\platform-tools\devices.txt"

echo List deviecs
for /f "delims=" %%A in ('adb shell getprop ro.product.brand') do SET brand=%%A
echo %brand% | FIND /I "ECHO">Nul && (goto RETRY_CONNECT  )
echo %brand%
echo %brand%>> %~dp0capturelite\tool\platform-tools\devices.txt
for /f %%a in ('type "%~dp0capturelite\tool\platform-tools\devices.txt"^|find "" /v /c') do set /a count=%%a

if %count% ==1 (goto ContiueCapture)

:RETRY_CONNECT
SET /P DOYOUWANTORETRY=Re connected (Y: reconnect, R: restart)?
IF /I "%DOYOUWANTORETRY%" NEQ "Y" GOTO RETRY_AGAIN
if /I not "!UserChoice!" == "Y" goto OPENADB

:ContiueCapture
SET /P AREYOUSURE=Capture screenshots (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END
if /I not "!UserChoice!" == "Y" set /a order=+1
set timestamp=%DATE:/=-%_%TIME::=-%
set timestamp=%timestamp: =%
adb exec-out screencap -p > %~dp0capturelite\data\%timestamp%.png
echo %~dp0capturelite\data\%timestamp%.png
goto ContiueCapture

:RETRY_AGAIN
SET /P DOYOUWANTORETRY=ReTry (Y/[N])?
IF /I "%DOYOUWANTORETRY%" NEQ "Y" GOTO END
if /I not "!UserChoice!" == "Y" goto INIT

:CLEAR_TOOL
@ECHO OFF

SET THEDIR=%~dp0capturelite\tool\

Echo Cleanning
if exist %~dp0capturelite\folder.zip( DEL %~dp0capturelite\folder.zip /F /Q /A)
if exist "%THEDIR%\*" (del "%THEDIR%\*" /f /q /s)
@ECHO Cleanned.
goto DOWNLOAD_START
:END
pause
