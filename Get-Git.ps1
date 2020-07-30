  
<#
    This script is meant to be referenced inside of all your scripts that use other Git Repositories.
    
    #############################################################################################################
    The idea is that WHEREVER your script goes, it is Self-Contained and Self-Updating as far as its Dependencies
    #############################################################################################################
    
    It will download and keep current (ForceRefresh = ON) any GitHub Repo you specify.
    
    ### After the process is done, you will need to MANUALLY Dot-Source a script or Import-Module on the proper item(s) in the Repo to activate it!!
    I am working on an automatic way to do it... more on that soon.
    
    This script DOES NOT make the Functions inside the Repo available for immediate use... it makes them Available to Load into your environment.
    See Examples in the function comment block
#>

<#
    .SYNOPSIS
    Downloads and Expands a GitHub Repository so you can use components in your scripts and have them automatically load them
    
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
    None
    
    .EXAMPLE
    You do not need THIS script locally, or THIS code.  See the explaination below.  I have worked this out so it can be called with a one-liner.
    
    Example of what I use in my scripts to call this script and download other Repos
    First Line Downloads and executes the script GETS the Repo and stores it in your Modules Directory
    Second Line Dot Sources the script necessary to access the function (If it were a PSM1 file you would use: Import-Module $PathtoModule\NameOfPSMFile.psm1)
    
    Invoke-Expression ('$GHDLUri="https://github.com/Inventologist/SuperLine/archive/master.zip";$GHUser="Inventologist";$GHRepo="SuperLine"' + (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Inventologist/Get-Git/master/Get-Git.ps1'))
    . $PathtoModule\Public\SuperLine.ps1

    See further explaination below in regards to the second line (where you load the ps1/psm1)


    .EXAMPLE
    The second line may NOT be necessary if you have a 'Get-Git.Autoload.txt' file in the repository.  This is not a GitHub standardized file... its something that I created.
    Simply have the content of the file be the command that is used to load it, and the script will find it.
#>

$Global:ProgressPreference = 'SilentlyContinue'

$PSModulePath = ($profile | Split-Path) + "\Modules"
IF (!(Test-Path $PSModulePath)) {New-Item -Path $PSModulePath -ItemType Directory -Force | Out-Null}
$GHDLFile = Split-Path $GHDLUri -Leaf
$UniqueNameforRepoDir = $GHRepo + $GHUser
$Script:PathToModule = "$PSModulePath\$UniqueNameforRepoDir"



Function GHDLRepo {
    $GHDLRepo = ""
    Write-Host "Downloading Repository Zip File for: $GHRepo" -f Cyan
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

IF (Test-Path $PathToModule\Get-Git.AutoLoad.txt) {
    Write-Host "AutoLoad Command Found" -f DarkGray
    $CommandToLoad = Get-Content $PathToModule\Get-Git.AutoLoad.txt
    Invoke-Expression -Command $CommandToLoad
}

Write-Host ""