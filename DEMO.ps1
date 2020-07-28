<#
    Demonstration of the Get-Git SCript
#>

Invoke-Expression ('$GHDLUri="https://github.com/Inventologist/SuperLine/archive/master.zip";$GHUser="Inventologist";$GHRepo="SuperLine"' + (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Inventologist/Get-Git/master/Get-Git.ps1'))
. $PathtoModule\Public\SuperLine.ps1

#necessary to let the screen stabilize, or the colors will come out mixed up
start-sleep -m 500

Write-Host ""
Write-Host ""
SuperLine "This is a Test"," of ","Superline","!" -F Green,White,Green,Red
SuperLine "It ","allows ","you to have multiple ","colors ","on ","one line","!" -F White,Red,White,DarkGreen,Red,Blue