@echo off
for /f "delims=" %%p in ('ReadLine -h -p "Enter password: "') do set PWD=%%p
echo You entered: %PWD%
