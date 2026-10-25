Set objArgs = WScript.Arguments
If objArgs.Count = 0 Then
    WScript.Quit
End If

appKey = objArgs(0)
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
psScript = scriptDir & "\Launch-App.ps1"

cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File """ & psScript & """ -AppKey """ & appKey & """"
CreateObject("WScript.Shell").Run cmd, 0, False
