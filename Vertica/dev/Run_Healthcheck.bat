@echo off

REM Read in which cluster you wish to run against
echo Which cluster do you wish to run tests against
echo 1. EMEA PRO
echo 2. EMEA STG
echo 3. sandbox
set /P cluster="Enter cluster: "
echo How many times do you want to run the healthcheck?
set /p times="Enter value: "

IF %cluster% EQU 1 goto prod
	
IF %cluster% EQU 2 goto stg

IF %cluster% EQU 3 goto sandbox

:prod
REM Running healthcheck against production cluster
echo Running Production
DBHealthcheck ida-verp01-v.gre.omc.hp.com dbadmin pass4admin 10 %times%
exit

:stg
REM Running healthcheck against staging cluster
echo Running Staging
DBHealthcheck ida-ver-stg-v.gre.omc.hp.com dbadmin pass4admin 10 %times%
exit

:sandbox
REM Running healthcheck against sandbox cluster
echo Running Sandbox
set /P username="Enter username: "
set /P password="Enter password: "
echo %username% is running the Sandbox Healthcheck
DBHealthcheck ida-ver-stg-v.gre.omc.hp.com %username% %password% 10 %times%
exit