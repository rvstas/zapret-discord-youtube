@echo off
chcp 65001 >nul
:: 65001 - UTF-8

:: Path check
set scriptPath=%~dp0
set "path_no_spaces=%scriptPath: =%"
if not "%scriptPath%"=="%path_no_spaces%" (
    echo Путь содержит пробелы. 
    echo Пожалуйста, переместите скрипт в директорию без пробелов.
    pause
    exit /b
)

:: Cyrillic check
echo %scriptPath% | findstr /r "[А-Яа-яЁё]" >nul
if %errorLevel% equ 0 (
    echo Путь содержит кирилицу. Пожалуйста, переместите скрипт в директорию без кириллических символов.
    echo Кириллица - Русский алфавит.
    pause
    exit /b
)

:: Admin rights check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Запуск от имени администратора...
    powershell start -verb runas '%0'
    exit /b
)


set ARGS=--wf-tcp=443-65535 --wf-udp=443-65535 ^
--wf-tcp=443 --wf-udp=443,50000-65535 ^
--filter-udp=443 --hostlist=\"%~dp0list-discord.txt\" --dpi-desync=fake --dpi-desync-udplen-increment=10 --dpi-desync-repeats=6 --dpi-desync-udplen-pattern=0xDEADBEEF --dpi-desync-fake-quic=\"%~dp0quic_initial_www_google_com.bin\" --new ^
--filter-udp=50000-65535 --dpi-desync=fake,tamper --dpi-desync-any-protocol --dpi-desync-fake-quic=\"%~dp0quic_initial_www_google_com.bin\" --new ^
--filter-tcp=443 --hostlist=\"%~dp0list-discord.txt\" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls=\"%~dp0tls_clienthello_www_google_com.bin\"

set SRVCNAME=zapret

net stop "%SRVCNAME%"
sc delete "%SRVCNAME%"
sc create "%SRVCNAME%" binPath= "%~dp0winws.exe %ARGS%" DisplayName= "zapret DPI bypass : winws1" start= auto
sc description "%SRVCNAME%" "zapret DPI bypass software"
sc start "%SRVCNAME%"


echo Серис был установлен и запущен.
pause