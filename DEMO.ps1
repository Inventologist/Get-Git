<#
    Demonstration of the Get-Git SCript
#>

Function Get-Git {
    Param (
    [parameter()]$PSModulePath = ($profile | Split-Path) + "\Modules",
    [parameter(Mandatory)]$GHDLUri,
    [parameter(Mandatory)][string]$GHUser,
    [parameter(Mandatory)][string]$GHRepo,
    [parameter()][ValidateSet("Yes","No")]$ForceRefresh = "No"
    )
    
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
        First Line GETS the Repo and stores it in your Modules Directory
        Second Line Dot Sources the script necessary to access the function (If it were a PSM1 file you would use: Import-Module $PathtoModule\NameOfPSMFile.psm1)
        
        Get-Git -GHDLUri https://github.com/Inventologist/SuperLine/archive/master.zip -GHUser Inventologist -GHRepo SuperLine -ForceRefresh Yes
        . $PathtoModule\Public\SuperLine.ps1


        .LINK
        Online version: http://www.fabrikam.com/extension.html
    #>

    $GHDLFile = Split-Path $GHDLUri -Leaf
    $Script:PathtoModule = "$PSModulePath\$GHRepo"

    IF (Test-Path -Path $PSModulePath\$GHRepo) {
        IF ($ForceRefresh -eq "No") {
            Write-Warning "Module already Exists @ $PSModulePath\$GHRepo`nSkipping download";Start-Sleep 1;break
        } ELSE {
            DO {
                Write-Host "ForceRefresh is ON... Removing local repository for $GHRepo"
                Remove-Item -Path $PSModulePath\$GHRepo -Force -Recurse
            } UNTIL (!(Test-Path -Path $PSModulePath\$GHRepo))
        }
    }
    
    Write-Host "Downloading Repository Zip File for: $GHRepo"
    Start-BitsTransfer -Source $GHDLUri -Destination $PSModulePath
        
    Write-Host "Expanding Repository Zip File"
    Expand-Archive -Path $PSModulePath\$GHDLFile -DestinationPath $PSModulePath -Force
    $ExpandedDirName = (Get-Item -Path "$PSModulePath\$GHRepo-*").name
    
    Write-Host "Cleanup"
    Rename-Item -Path $PSModulePath\$ExpandedDirName -NewName $PSModulePath\$GHRepo
    Remove-Item -Path $PSModulePath\$GHDLFile
}

Get-Git -GHDLUri https://github.com/Inventologist/SuperLine/archive/master.zip -GHUser Inventologist -GHRepo SuperLine -ForceRefresh Yes
. $PathtoModule\Public\SuperLine.ps1

#Clear the screen of any formatting
DO {Clear-Host;$repeat++} UNTIL ($repeat -ge 3)

#necessary to let the screen stabilize, or the colors will come out mixed up
start-sleep -m 500

SuperLine "This is a Test"," of ","Superline","!" -F Green,White,Green,Red
SuperLine "It ","allows ","you to have multiple ","colors ","on ","one line","!" -F White,Red,White,DarkGreen,Red,Blue