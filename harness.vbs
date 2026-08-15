' DeepSeek Harness launcher (toggle) - no console window.
' Location-independent: harness.ps1 is resolved next to this script,
' so the whole folder can be moved or cloned anywhere on disk.
Option Explicit

Dim fso, base, sh
Set fso = CreateObject("Scripting.FileSystemObject")
base = fso.GetParentFolderName(WScript.ScriptFullName)
Set sh = CreateObject("WScript.Shell")
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & base & "\harness.ps1""", 0, False
