@echo off
Rem Paramenters: Node or Load Balancer  User  Password  Timeout
Rem Calculate the actual Date and Time
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "fullstamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"
REM Assigning the wait period before running again and also the number of runs to make
Rem Assign the name of the archive
set file_name="DBHealthcheckGal_%1_%fullstamp%.txt"

REM Read in which cluster you wish to run against
echo Which cluster do you wish to run tests against
echo 1. EMEA PRO
echo 2. EMEA STG
echo 3. Sandbox
set /P cluster="Enter cluster: "
echo How many times do you want to run the healthcheck?
set /p times_to_run="Enter value: "
echo What wait period do you want in between runs?
set /p secs_to_wait="Enter value: "

IF %cluster% EQU 1 goto prod
	
IF %cluster% EQU 2 goto stg

IF %cluster% EQU 3 goto sandbox

:prod
REM Running healthcheck against production cluster
echo Running Production
set machine_to_run=ida-verp01-v.gre.omc.hp.com
echo %machine_to_run%
set uname=dbadmin
set pword=pass4admin
goto cycle
exit

:stg
REM Running healthcheck against staging cluster
echo Running Staging
set machine_to_run=ida-ver-stg-v.gre.omc.hp.com
echo %machine_to_run%
set uname=dbadmin
set pword=pass4admin
goto cycle
exit

:sandbox
REM Running healthcheck against sandbox cluster
echo Running Sandbox
set machine_to_run=shr3-vrt-dev-vglb1.houston.hp.com
echo %machine_to_run%
set uname=vertica
set pword=v3rtic@2015
goto cycle
exit


:cycle
Rem Calculate the actual Date and Time
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "fullstamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"

echo "Database Health Check on %1 at %fullstamp%" >> %file_name%
echo "Database Health Check on %1 at %fullstamp%"

vsql -h %machine_to_run% -U %uname% -w %pword% -f healthcheck.sql >> %file_name%
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