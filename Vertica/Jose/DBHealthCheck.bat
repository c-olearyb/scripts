@echo off
Rem Uso: DBHealthcheck shr4-vrt-pro-006.houston.hp.com vertica vertic@o1 600
Rem Calculo de la fecha y hora actual
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "fullstamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"
set secs_to_wait=%4
Rem Asignar nombre al archivo
set file_name="DBHealthcheck_%1_%fullstamp%.txt"

:cycle
Rem Calculo de la fecha y hora actual
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "fullstamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"

echo "Database Health Check on %1 at %fullstamp%" >> %file_name%
echo "Database Health Check on %1 at %fullstamp%"

vsql -h %1 -U %2 -w "%3" -f Performance.sql >> %file_name%
echo "***** Completed at %fullstamp% on %1 *****" >> %file_name%
set /a "occurance=occurance+1"
echo "Occurance is = %occurance%" >> %file_name%
echo "Occurance is = %occurance%"
echo "Completed at %fullstamp% on %1"
echo "Waiting %secs_to_wait% seconds"
Timeout /t %secs_to_wait% /nobreak >nul
goto cycle

