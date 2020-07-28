    
<#
    .SYNOPSIS
    Downloads and Expands a GitHub Repository so you can use components in your scripts and have them automatically load

    .DESCRIPTION
    Downloads a GitHub Repository ZIP file
    Exapnds the Zip file
    Renames it without the -master on the end

    .PARAMETER PSModulePath
    Specifies the location to store the modules.

    .PARAMETER GHDLUri
    The GitHub Download URI
    Example: https://github.com/Inventologist/SuperLine/archive/master.zip

    .INPUTS
    None. You cannot pipe objects to this

    .OUTPUTS
    None.

    .EXAMPLE
    Example of what I use in my scripts to call this script and download other Repos
    First Line Downloads and executes the scriptGETS the Repo and stores it in your Modules Directory
    Second Line Dot Sources the script necessary to access the function (If it were a PSM1 file you would use: Import-Module $PathtoModule\NameOfPSMFile.psm1)
        
    Get-Git.ps1 -GHDLUri https://github.com/Inventologist/SuperLine/archive/master.zip -GHUser Inventologist -GHRepo SuperLine -ForceRefresh Yes
    . $PathtoModule\Public\SuperLine.ps1
#>

$Global:ProgressPreference = 'SilentlyContinue'

$PSModulePath = ($profile | Split-Path) + "\Modules"
$GHDLFile = Split-Path $GHDLUri -Leaf
$Script:PathtoModule = "$PSModulePath\$GHRepo"

Function GHDLRepo {
    $GHDLRepo = ""
    Write-Host "Downloading Repository Zip File for: $GHRepo"
    Start-BitsTransfer -Source $GHDLUri -Destination $PSModulePath
    If (Test-Path -Path $PSModulePath\$GHDLFile) {$Script:GHRepoDL = "Yes"} ELSE {Write-Error "Download Failure";$Script:GHRepoDL = "No"}
}

Function GHDLRefresh {
    DO {
        Write-Host "ForceRefresh is ON... Removing local repository for $GHRepo"
        Remove-Item -Path $PSModulePath\$GHRepo -Force -Recurse
    } UNTIL (!(Test-Path -Path $PSModulePath\$GHRepo))
}
    
Function GHDLFinalize {
    Write-Host "Expanding Repository Zip File"
    Expand-Archive -Path $PSModulePath\$GHDLFile -DestinationPath $PSModulePath -Force
    $Script:ExpandedDirName = (Get-Item -Path "$PSModulePath\$GHRepo-*").name
    
    Write-Host "Cleanup"
    Rename-Item -Path $PSModulePath\$ExpandedDirName -NewName $PSModulePath\$GHRepo
    Remove-Item -Path $PSModulePath\$GHDLFile
}

IF (!(Test-Path -Path $PSModulePath\$GHRepo)) {
    GHDLRepo
    IF ($GHRepoDL -eq "Yes") {GHDLFinalize}
} ELSE {
    #Repo Exists and ForceRefresh = NO
    IF ($ForceRefresh -eq "No") {
        Write-Warning "Module already Exists @ $PSModulePath\$GHRepo`nSkipping download"
        Start-Sleep 1
        return
    }
    #Repo does NOT exist and ForceRefresh = Yes
    IF ($ForceRefresh -eq "Yes") {
        GHDLRepo
        IF ($GHRepoDL -eq "Yes") {GHDLRefresh}
        IF ($GHRepoDL -eq "Yes") {GHDLFinalize}        
    }
}