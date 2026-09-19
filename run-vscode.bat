@echo off
setlocal enabledelayedexpansion

set "BASE=%~1"
if "%BASE%"=="" set "BASE="

set "JAVA_HOME=%BASE%\vscode\jdk25"
set "PATH=%JAVA_HOME%\bin;%BASE%\vscode\MinGW\bin;%PATH%"

set "WS_DIR=%BASE%\vscode\Workspace"

:: Contar cuántos archivos .code-workspace existen en la carpeta
set "COUNT=0"
for %%F in ("%WS_DIR%\*.code-workspace") do (
    set /a COUNT+=1
    set "FILE_!COUNT!=%%~fF"
    set "NAME_!COUNT!=%%~nxF"
)

:: Caso 1: No se encontraron archivos .code-workspace
if %COUNT%==0 (
    echo No se encontraron archivos .code-workspace en "%WS_DIR%".
    pause
    goto :EOF
)

:: Caso 2: Existe solo UN archivo .code-workspace
if %COUNT%==1 (
    set "SELECTED_WS=!FILE_1!"
    goto :LAUNCH
)

:: Caso 3: Existen VARIOS archivos, mostrar menú de selección
echo ============================================
echo  Selecciona un Workspace para abrir:
echo ============================================
for /l %%I in (1,1,%COUNT%) do (
    echo   [%%I] !NAME_%%I!
)
echo ============================================

:ASK_CHOICE
set /p "CHOICE=Ingresa el numero de tu eleccion: "

:: Validar que la entrada sea válida dentro del rango
if not defined FILE_%CHOICE% (
    echo Opcion invalida. Intenta nuevamente.
    goto :ASK_CHOICE
)

set "SELECTED_WS=!FILE_%CHOICE%!"

:LAUNCH
start "" "%BASE%\vscode\vscode\Code.exe" "%SELECTED_WS%"
