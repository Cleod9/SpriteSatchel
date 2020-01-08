@echo off
if not exist %CERT_FILE% goto certificate

:: AIR output
if not exist %AIR_PATH% md %AIR_PATH%
set OUTPUT=%AIR_PATH%\%FILE_NAME%

:: Package
echo.
echo Packaging %FILE_NAME% using certificate %CERT_FILE%...
call adt -package %CERT_TSA% %OPTIONS% %SIGNING_OPTIONS% %AIR_TARGET% %OUTPUT% %APP_XML% %FILE_OR_DIR%
:: if defined IS_AIR echo "Applying certificate migration %CERT_FILE_MIGRATE%"
:: if defined IS_AIR call adt -migrate -storetype pkcs12 -storepass %CERT_PASS% -keystore %CERT_FILE_MIGRATE% %OUTPUT%.air %OUTPUT%.air
if errorlevel 1 goto failed
goto end

:certificate
echo.
echo Certificate not found: %CERT_FILE%
echo.
echo Troubleshooting: 
echo - generate a default certificate using 'bat\CreateCertificate.bat'
echo.
if %PAUSE_ERRORS%==1 pause
exit

:failed
echo AIR setup creation FAILED.
echo.
echo Troubleshooting: 
echo - did you build your project in FlashDevelop?
echo - verify AIR SDK target version in %APP_XML%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:end
echo.