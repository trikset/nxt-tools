@echo off
set PATH=
set B=%~dp0\mingw64\bin\bash.exe
%B% -c "echo OK" > NUL || goto ERROR_NOBASH
for %%I in (%B%) do set X=%%~dpI
set PATH=%X%;%PATH%
bash -c "source ./compile.sh '%1' '%2' '%cd%'"
goto NOERROR
:ERROR_NOBASH
echo bash interpreter not found
:NOERROR