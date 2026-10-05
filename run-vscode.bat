@echo off
setlocal enabledelayedexpansion

:: Extraer la unidad de la ruta completa del propio script (%~dp0 -> primeros 2 caracteres)
set "SCRIPT_DRIVE=%~dp0"
set "SCRIPT_DRIVE=%SCRIPT_DRIVE:~0,2%"

:: Si se pasó un parámetro, usarlo. Si no, usar la unidad del script.
set "BASE=%~1"
if "%BASE%"=="" set "BASE=%SCRIPT_DRIVE%"

:: Quitar barras diagonales sobrantes por si el usuario pasó "D:\"
set "BASE=%BASE:\=%"

set "JAVA_HOME=%BASE%\vscode\jdk17"
set "PATH=%JAVA_HOME%\bin;%BASE%\vscode\MinGW\bin;%PATH%"

set "WS_DIR=%BASE%\vscode\Workspace"

:: Ruta al archivo de almacenamiento local de VS Code Portable
set "VSCODE_STORAGE=%BASE%\vscode\vscode\data\user-data\User\globalStorage\storage.json"
set "LAST_WS="

:: ---------------------------------------------------------
:: 1. Intentar obtener el último .code-workspace desde la data portable
:: ---------------------------------------------------------
if exist "%VSCODE_STORAGE%" (
    for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command ^
        "$file = '%VSCODE_STORAGE:\=\\%'; " ^
        "$content = Get-Content -Raw -Path '%VSCODE_STORAGE%' -ErrorAction SilentlyContinue; " ^
        "if ($content) { " ^
        "  $matches = [regex]::Matches($content, 'file:///(.*?\.(?:code-workspace))'); " ^
        "  if ($matches.Count -gt 0) { " ^
        "    $lastMatch = $matches[$matches.Count - 1].Groups[1].Value; " ^
        "    [System.Uri]::UnescapeDataString($lastMatch); " ^
        "  } " ^
        "}"`) do (
        set "LAST_WS=%%A"
    )
)

:: Normalizar la ruta devuelta (convertir / a \) y verificar si el archivo existe
if defined LAST_WS (
    set "LAST_WS=!LAST_WS:/=\!"
    if exist "!LAST_WS!" (
        echo Abriendo ultimo workspace usado: "!LAST_WS!"
        set "SELECTED_WS=!LAST_WS!"
        goto :LAUNCH
    )
)

:: ---------------------------------------------------------
:: 2. Si es la primera vez o no hay historial, mostrar menú
:: ---------------------------------------------------------
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
    echo    [%%I] !NAME_%%I!
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
