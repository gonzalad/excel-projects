start /wait commandline.vbs D:\dev\excel\commandline\commandline.xlsm SayHello coucou
echo %ERRORLEVEL%
start /wait commandline.vbs D:\dev\excel\commandline\commandline.xlsm SayHello ERROR
echo %ERRORLEVEL%
pause