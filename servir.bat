@echo off
rem ===========================================================================
rem  Document AI - version web
rem
rem  Los navegadores bloquean el codigo JavaScript de las paginas abiertas con
rem  doble clic (protocolo file://), asi que la aplicacion necesita servirse
rem  por HTTP. Este script levanta un servidor local y abre el navegador.
rem
rem  Sin acentos a proposito: la consola de Windows no siempre usa UTF-8.
rem ===========================================================================
setlocal enableextensions
cd /d "%~dp0"

set "PUERTO=8080"

echo ===========================================
echo   Document AI - servidor local
echo ===========================================
echo.

rem --- Buscar un Python utilizable -----------------------------------------
set "PY="
python --version >nul 2>&1 && set "PY=python"
if not defined PY py --version >nul 2>&1 && set "PY=py"

if not defined PY (
    echo [ERROR] No se encontro Python en el PATH.
    echo.
    echo Alternativas:
    echo   - Instala Python desde https://www.python.org  ^(marca "Add to PATH"^)
    echo   - O publica la aplicacion en GitHub Pages y abrela desde alli
    echo   - O usa cualquier otro servidor estatico ^(npx serve, etc.^)
    echo.
    goto :fin
)

rem --- Avisar si el puerto ya esta ocupado ----------------------------------
netstat -ano | findstr /r /c:":%PUERTO% .*LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo [AVISO] El puerto %PUERTO% ya esta en uso.
    echo         Si es una instancia anterior de este mismo script, cierrala.
    echo         Probando de todas formas...
    echo.
)

echo Sirviendo esta carpeta en:
echo.
echo     http://localhost:%PUERTO%
echo.
echo Deja esta ventana abierta mientras uses la aplicacion.
echo Ctrl+C para detener el servidor.
echo.

rem Abrir el navegador tras un instante, para que el servidor ya responda.
start "" /b cmd /c "timeout /t 2 >nul & start http://localhost:%PUERTO%"

%PY% -m http.server %PUERTO% --bind 127.0.0.1

:fin
echo.
pause
endlocal
