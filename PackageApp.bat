@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

set IS_AIR=1
set FILE_NAME=SpriteSatchel
set OPTIONS=

del "%AIR_PATH%\%FILE_NAME%.air"

set OPTIONS=
call bat\Packager.bat

pause