  
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
    Specifies the location to store the modules.  AS of yet, this is a fixed position in the $profile directory.
    Feel free to change it if you like... be warned, the path you specify has to be in your $env:PSModulePath.

    .PARAMETER GHDLUri
    The GitHub Download URI
    Example: https://github.com/Inventologist/SuperLine/archive/master.zip
           
    .PARAMETER GHUser
    User name for the Repo owner.  This is used to give a unique name to the directory.  
    For example: Superline directory would end up being named: SuperLine-Inventologist
    
    .PARAMETER GHRepo
    Repo name.  Required to name directory properly.

    .PARAMETER ForceRefresh
    Valid values are Yes / No
    Will activate the refresh functions.  The repo will be downloaded first, and if it is successful, the script will delete the existing Repo and replace it with the downloaded copy.

    .INPUTS
    None. You cannot pipe objects to this
    
    .OUTPUTS
    None
    
    .EXAMPLE
    You do not need THIS script locally, or THIS code.  See the explaination below.  I have worked this out so it can be called with a one-liner.
    
    Example of what I use in my scripts to call this script and download other Repos
    First Line Downloads and executes the script GETS the Repo and stores it in your Modules Directory
    Second Line Dot Sources the script necessary to access the function (If it were a PSM1 file you would use: Import-Module $PathtoModule\NameOfPSMFile.psm1)
    
    Invoke-Expression ('$GHDLUri="https://github.com/Inventologist/SuperLine/archive/master.zip";$GHUser="Inventologist";$GHRepo="SuperLine";$ForceRefresh = "Yes"' + (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Inventologist/Get-Git/master/Get-Git.ps1'))
    . $PathtoModule\Public\SuperLine.ps1

    See further explaination below in regards to the second line (where you load the ps1/psm1)
    
    .EXAMPLE
    The second line may NOT be necessary if you have a 'Get-Git.Autoload.txt' file in the repository.  This is not a GitHub standardized file... its something that I created.
    Simply have the content of the file be the command that is used to load it, and the script will find it.
#>

#Prevent all Progress Bars
$Global:ProgressPreference = 'SilentlyContinue'

#Set the Path to the Modules
$PSModulePath = ($profile | Split-Path) + "\Modules"

#Create the directory if it does not exist
IF (!(Test-Path $PSModulePath)) {New-Item -Path $PSModulePath -ItemType Directory -Force | Out-Null}

#Extract the File Name from the $GHDLUri
$GHDLFile = Split-Path $GHDLUri -Leaf

#Create a unique name for the directory that the module is stored in.  This helps with duplicate Modules/Repo names
#WARNING: This will prevent you from loading the module(s) by "Import-Module ABC".  Reason: the module directory name has to be the same as the module.  
#Workaround: You will have to provide the full path to any module that you want to load (that are in these kinds of directories)  You can use $PathToModule (see below)
$UniqueNameforRepoDir = $GHRepo + "-" + $GHUser

#Create a variable that can be used to give the full path to the module directory
$Script:PathToModule = "$PSModulePath\$UniqueNameforRepoDir"

#AutoLoad file designation
$AutoLoadFile = "$PathToModule\Get-Git.AutoLoad.txt"

Function GHDLRepo {
    Write-Host "Downloading required file for: $GHRepo" -f Cyan

    Invoke-WebRequest -Uri $GHDLUri -OutFile $PSModulePath\$GHDLFile

    If (Test-Path -Path $PSModulePath\$GHDLFile) {$Script:GHRepoDL = "Yes"} ELSE {Write-Error "Download Failure";$Script:GHRepoDL = "No"}
}

Function GHDLRefresh {
    DO {
        Write-Host "ForceRefresh is ON... Removing local repository for $GHRepo"
        Remove-Item -Path $PathToModule -Force -Recurse
    } UNTIL (!(Test-Path -Path $PathToModule))
}

Function GHDLFinalize {
    # Get extenstion to figure out what neesd to be done with the downloaded file
    $Extension = $GHDLUri.Split('.')[-1]

    Switch ($Extension) {
        
        zip {
            Write-Host "Expanding Repository Zip File"
            Expand-Archive -Path $PSModulePath\$GHDLFile -DestinationPath $PSModulePath -Force
            
            $Script:ExpandedDirName = (Get-Item -Path "$PSModulePath\$GHRepo-*").name
            Rename-Item -Path $PSModulePath\$ExpandedDirName -NewName $PathToModule
        }
        
        default {
            IF (!(Test-Path -path $PathToModule)) {New-Item $PathToModule -Type Directory | Out-Null}
            Copy-Item ($PSModulePath + "\" + $GHDLFile) -Destination $PathToModule
        }
    }
        
    Remove-Item -Path $PSModulePath\$GHDLFile
}

###############
# Main Script #
###############


IF (!(Test-Path -Path $PathToModule)) {
    GHDLRepo
    IF ($GHRepoDL -eq "Yes") {GHDLFinalize}
} ELSE {
    #Repo Exists and ForceRefresh = NO
    IF ($ForceRefresh -eq "No") {
        Write-Warning "Module already Exists @ $PathToModule`nSkipping download"
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

IF (Test-Path $AutoLoadFile) {
    Write-Host "AutoLoad Command Found" -f DarkGray
    

    $Script:AutoLoadCommands = @()
    foreach ($line in Get-Content $AutoLoadFile) {
        if ($line | Select-String -Pattern '^Command: ' -CaseSensitive) {
            $line = $line -replace 'Command: ',''
            $Script:AutoLoadCommands += $line
        }
    }
    
    foreach ($command in $Script:AutoLoadCommands) {
        Invoke-Expression -Command $command    
    }
}

Write-Host ""