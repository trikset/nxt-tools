@echo off
set PATH=
set B=%~dp0\mingw64\bin\bash.exe
%B% -c "echo OK" > NUL || goto ERROR_NOBASH
for %%I in (%B%) do set X=%%~dpI
set PATH=%X%;%PATH%
COPY "%cd%\kernel_id.h" "%2"
COPY "%cd%\kernel_cfg.c" "%2"
bash -c "source ./compile.sh '%1' '%2' '%cd%' GNUARM_ROOT='%3'"
goto NOERROR
:ERROR_NOBASH
echo bash interpreter not found
:NOERROR
