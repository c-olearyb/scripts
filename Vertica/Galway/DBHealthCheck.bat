@echo off
Rem Paramenters: Node or Load Balancer  User  Password  Timeout
Rem Calculate the actual Date and Time
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "fullstamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"
REM Assigning the wait period before running again and also the number of runs to make
set secs_to_wait=%4
set times_to_run=%5
Rem Assign the name of the archive
set file_name="DBHealthcheckGal_%1_%fullstamp%.txt"

:cycle
Rem Calculate the actual Date and Time
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "fullstamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"

echo "Database Health Check on %1 at %fullstamp%" >> %file_name%
echo "Database Health Check on %1 at %fullstamp%"

vsql -h %1 -U %2 -w "%3" -f healthcheck.sql >> %file_name%
echo "***** Completed at %fullstamp% on %1 *****" >> %file_name%
set /a "occurance=occurance+1"
echo "Occurance is = %occurance%" >> %file_name%
echo "Occurance is = %occurance%"
echo "Completed at %fullstamp% on %1"
echo "Waiting %secs_to_wait% seconds"
IF %times_to_run% EQU %occurance% goto complete
Timeout /t %secs_to_wait% /nobreak >nul
goto cycle

:complete
exit