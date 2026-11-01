@echo off
rem Compila o instalador MSI do Windows Helper (requer WiX Toolset v3.x instalado)
setlocal
cd /d "%~dp0"

set WIX=C:\Program Files (x86)\WiX Toolset v3.14\bin
if not exist "%WIX%\candle.exe" (
    echo [ER] WiX Toolset v3.x nao encontrado em "%WIX%"
    echo      Instale em https://wixtoolset.org/ ou ajuste a variavel WIX.
    exit /b 1
)

"%WIX%\candle.exe" -arch x64 -out WindowsHelper.wixobj WindowsHelper.wxs || exit /b 1
"%WIX%\light.exe" -out "Windows Helper 1.0.0.msi" WindowsHelper.wixobj || exit /b 1

echo [OK] Gerado: "Windows Helper 1.0.0.msi"
endlocal
