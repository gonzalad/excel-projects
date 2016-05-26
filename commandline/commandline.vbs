'Get current dir
Set wshell = CreateObject("WScript.Shell")
'wshell.CurrentDirectory

'Get program args
Dim oArgs
Set oArgs=WScript.Arguments 
'WScript.Echo oArgs.Count 

'Call XLS macro
Dim resultFile
resultFile = CallExcelMacro(oArgs)

'Get ExitCode
WScript.Quit GetExternalApiExitCode(resultFile)
set wshell = Nothing

Sub DeleteFile(myFileToDelete)
   Dim fso
   Set fso = CreateObject("Scripting.FileSystemObject")
   Call fso.DeleteFile(myFileToDelete, True)
End Sub

Function CallExcelMacro(oArgs)
	Dim XLS
	Dim Wb
	'Call XLS macro
	set XLS = CreateObject("Excel.application")
	XLS.visible = false

	'compute result file name
	Dim nowDate 
	nowDate = Now 
	Dim folderName
	'folderName = WScript.CreateObject("Scripting.FileSystemObject").GetSpecialFolder(2)
	folderName =  wshell.CurrentDirectory
	Dim resultFile
	resultFile = folderName & "\" & Year(nowDate) & "-" & Month(nowDate) & "-" & Day(nowDate) & "-" & Hour(nowDate) & "-" & Minute(nowDate) & "-" & Second(nowDate) & ".txt"

	'launch excel and call excel macro
	set wb = XLS.Workbooks.Open(oArgs(0))
	Dim macroName
	macroName = oArgs(1)
	If oArgs.Count = 2 Then
		Call wb.Application.Run("ExternalApi", resultFile, macroName)
	ElseIf oArgs.Count = 3 Then
		Call wb.Application.Run("ExternalApi", resultFile, macroName, oArgs(2))
	ElseIf oArgs.Count = 4 Then
		Call wb.Application.Run("ExternalApi", resultFile, macroName, oArgs(2), oArgs(3))
	End If
	wb.Close false

	' Sort sans enregistrer les docs
	XLS.Quit
	set XLS = Nothing
	set wb = Nothing
	CallExcelMacro = resultFile
End Function

Function GetExternalApiExitCode(resultFile)

	' *** result file handling ***
	'Check result file
	Dim resultContent
	Set fso = CreateObject("Scripting.FileSystemObject")
	If (fso.FileExists(resultFile) = False) Then
	    ' Result file doesn't exists
	    GetExternalApiExitCode = 666
	    Exit Function
	End If

	Dim f
	Set f = fso.OpenTextFile(resultFile, 1) ', ForReading'
	resultContent = f.ReadAll()
	f.Close
	Dim exitCodeAsString
	If (Len(Trim(resultContent)) <> 0) Then

		exitCodeAsString = ReadResultInfo("ErrorCode", resultContent)
		Call DeleteFile(resultFile)
		Dim exitCode
		On Error Resume Next
		exitCode = CInt(exitCodeAsString)
		If Err.Number <> 0 Then
			GetExternalApiExitCode = 669
			Exit Function
		End If
		On Error Goto 0
		GetExternalApiExitCode = exitCode
	Else
		' Invalid result file content
	    GetExternalApiExitCode = 667
	End If
End Function

Function ReadResultInfo(info, resultContent) 
	Dim startIdx
	Dim endIdx
	startIdx = InStr(resultContent, "<" & info & ">")
	endIdx = InStr(resultContent, "</" & info & ">")
	If (startIdx < 1 Or endIdx < 1 Or startIdx >= endIdx) Then
		' Invalid result file content
    	WScript.Quit 668
	End If
	ReadResultInfo = Mid(resultContent, startIdx + Len("<" & info & ">"), endIdx - Len("</" & info & ">"))
End Function
