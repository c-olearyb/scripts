@echo off
Rem Paramenters: Node or Load Balancer  User  Password  Timeout
Rem Calculate the actual Date and Time
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "fullstamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"
Rem Assign the name of the archive
set file_name="Daily_EBI_run_%fullstamp%.txt"


REM Read in which cluster you wish to run against
echo Which cluster do you wish to run tests against
echo 1. EMEA PRO
echo 2. EMEA A2D2
echo 3. EMEA STG
echo 4. EMEA All
set /P cluster="Enter cluster: "

IF %cluster% EQU 1 goto ebiprod
	
IF %cluster% EQU 2 goto ebia2d2

IF %cluster% EQU 3 goto ebistg

IF %cluster% EQU 4 goto ebiall

:ebiprod
REM Running healthcheck against production cluster
set machine_to_run=ida-verp01-v.gre.omc.hp.com
echo Running on %machine_to_run%
echo Running on Production >> %file_name%
set uname=dbadmin
set pword=pass4admin
call :cycle
goto :eof

:ebia2d2
REM Running healthcheck against A2D2 cluster
set machine_to_run=138.35.13.241
echo Running on %machine_to_run%
echo Running on A2D2 >> %file_name%
set uname=dbadmin
set pword=N0tmyf@ult
call :cycle
goto :eof

:ebistg
REM Running healthcheck against staging cluster
set machine_to_run=ida-ver-stg-v.gre.omc.hp.com
echo Running on %machine_to_run%
echo Running on Staging >> %file_name%
set uname=dbadmin
set pword=pass4admin
call :cycle
goto :eof

:ebiall
REM Running healthcheck against ALL clusters
REM Running healthcheck against production cluster
set machine_to_run=ida-verp01-v.gre.omc.hp.com
echo Running on %machine_to_run%
echo Running on Production >> %file_name%
set uname=dbadmin
set pword=pass4admin
call :cycle
REM Running healthcheck against A2D2 cluster
set machine_to_run=138.35.13.241
echo Running on %machine_to_run%
echo Running on A2D2 >> %file_name%
set uname=dbadmin
set pword=N0tmyf@ult
call :cycle
REM Running healthcheck against staging cluster
echo Running Staging
set machine_to_run=ida-ver-stg-v.gre.omc.hp.com
echo "Running on %machine_to_run%"
echo Running on Staging >> %file_name%
set uname=dbadmin
set pword=pass4admin
call :cycle
goto :eof


:cycle
REM Running sql commands
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "fullstamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"
echo "Database Health Check on %machine_to_run% at %fullstamp%" >> %file_name%
echo "Database Health Check on %machine_to_run% at %fullstamp%"
echo. >> %file_name%
vsql -h %machine_to_run% -U %uname% -w %pword% -f Daily_EBI_sql.sql >> %file_name%
echo "***** Completed at %fullstamp% on %machine_to_run% *****" >> %file_name%
echo. >> %file_name%
echo. >> %file_name%
echo. >> %file_name%
echo. >> %file_name%
echo. >> %file_name%
echo. >> %file_name%