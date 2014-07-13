@echo off

rem IMPORTANT NOTE
rem Invoke with WINSCHED parameter in the Windows Task Scheduler.

rem ***** Short Explanation (none :-)) *****

rem Put "C:\robocopy-sample.bat WINSCHED" as the command in the Windows 
rem Task Scheduler textbox. Then change anything you like between 
rem :DO and :END. 
rem This is what actually gets executed after the snapshot creation.
rem If you want to create snapshot of a volume other than C:, change
rem the drive letter in the vscsc call between :WINSCHED and :DO.

rem At prompt, to add a job that executes this script with the 
rem SYSTEM account every 30 minutes, you can issue the command:

rem schtasks /CREATE /RU SYSTEM /TN "Backup Docs" /SC MINUTE /MO 30 /TR "C:\robocopy-sample.bat WINSCHED" 


rem ***** Long Explanation *****************

rem The Windows Task Scheduler is not very good at handling prompt
rem commands: so you have to deal with file names with spaces,
rem the problem of redirecting the output (if you want to know
rem what's going on in your script), ecc.

rem To avoid using another script just to invoke a line like
rem "vscsc -exec=C:\robocopy-sample.bat C: > C:\robocopy.log", which you cannot put in the
rem Windows Task Scheduler, we induce this script to do all the job.

rem In other words, the script executes what's between :WINSCHED
rem and :DO if it is invoked with the WINSCHED parameter,
rem otherwise it behaves as if it was called with the name of the
rem intended snapshot volume as a parameter.

rem So, here's what's going on in the latter case: the
rem Windows Task Scheduler calls the script that calls vscsc
rem that calls the script again.

rem ****** End Explanations *****************
rem *****************************************


rem Put all the stuff into some directory: the script, the logs and the backups.
rem In this case we work in C:\
set RUNDIR="C:"

if not "%1%"=="WINSCHED" goto DO

:WINSCHED

vscsc -exec=%RUNDIR%\robocopy-sample.bat C:

goto END

:DO

rem Name of the log file, to get some info about what's going on with robocopy
set LOGFILE=%RUNDIR%\robocopy.log

rem DOS Volume Name to be assigned to the snapshot
set SNAPDOS=B:

rem Backup Documents and Settings folder
set DOCS_SRC=%SNAPDOS%\Documents and Settings
set DOCS_DST=C:\Documents and Settings.backup

dosdev %SNAPDOS% %1%

robocopy "%DOCS_SRC%" "%DOCS_DST%" /MIR /B /R:0 >> "%LOGFILE%"

dosdev /D %SNAPDOS%

:END
