@echo off
set "BASE=%~1"

if "%BASE%"=="" set "BASE="

set "JAVA_HOME=%BASE%\vscode\jdk25"
set "PATH=%JAVA_HOME%\bin;%BASE%\vscode\MinGW\bin;%PATH%"
start "" "%BASE%\vscode\vscode\Code.exe" "%BASE%\vscode\Workspace\Workspace.code-workspace" "%CD%\Workspace\Workspace.code-workspace"