# Get-Git
Small script to download a Git repository, so that when others use your script, it downloads the required  scripts/modules
 
## Backstory
I try to really use the repositories that I post here.  So, you can imagine that my scripts are completely intertwined.

Well, they ARE when I use them, but not here.  Here they were separated.  The problem has been... finding as easy way to retrieve a GitHub script/Repo that is a dependency.</br>
Previously, I would simply include the accessory function INSIDE of the script.  I desparately wanted some "Built-In" way to get and load a repository... just like the Powershell Gallery.  So, I embarked on this journey.

I'm sure that there are scenarios that I am not catching... please be kind!
#### Get in touch when you find something wrong.

## Usage
**First Line:** Downloads and executes the script GETS the Repo and stores it in your Modules Directory.</br>
**Second Line:** Dot Sources the script necessary to access the function (If it were a PSM1 file you would use: Import-Module $PathtoModule\NameOfPSMFile.psm1)
    
#### First Line (One-Liner)
```powershell
Invoke-Expression ('$GHDLUri="https://github.com/Inventologist/SuperLine/archive/master.zip";$GHUser="Inventologist";$GHRepo="SuperLine"' + (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Inventologist/Get-Git/master/Get-Git.ps1'))
```
#### First Line (If you like your code a little more compact/organized)
```powershell
Invoke-Expression ('
$GHDLUri="https://github.com/Inventologist/SuperLine/archive/master.zip";
$GHUser="Inventologist";
$GHRepo="SuperLine";
$ForceRefresh="Yes"' + 
(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Inventologist/Get-Git/master/Get-Git.ps1'))
```

#### Second Line
```powershell
. $PathtoModule\Public\SuperLine.ps1
```
    
The second line may NOT be necessary if you have a 'Get-Git.Autoload.txt' file in the repository.  This is not a GitHub standardized file... its something that I created.
Simply have the content of the file be the command that is used to load it, and the script will find it.

The Get-Git.AutoLoad.txt file for our example: SuperLine
```
#>
    This file is for Get-Git (and any other program that chooses to use it)
    The purpose is to serve as a reference point for the command to use to load the 
    Module/Script so that the main purpose of the function can be utilized.

    Any command that your Repo requires should be listed below starting with "Command: "

    ##Please use $PathToModules when trying to reference the root of where the modules are stored.
    Example:  If you want SuperLine to be loaded you would put the following : Command: . $PathToModules\pulic\SuperLine.ps1

<#

Command: . $PathtoModule\Public\SuperLine.ps1
```

Get-Git will parse throught the file and grab any line starting with "Command: "  <-- yes you need that extra space after "Command:".

#### So, I only have to use the first line in my script, because SuperLine has the Get-Git.AutoLoad.txt file.
```powershell
Invoke-Expression ('$GHDLUri="https://github.com/Inventologist/SuperLine/archive/master.zip";$GHUser="Inventologist";$GHRepo="SuperLine"' + (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Inventologist/Get-Git/master/Get-Git.ps1'))
```

## References / Credits
I've tried a few other scripts... some work, some dont.  The Genesis for the idea came from this article:
https://habr.com/en/post/476914/

I looked into his ps1 script, but I couldn't wrap my head around some of the logic (probably because the code was fairly evolved), So I started from scratch.  At some point I would love to collab with the author of that script.
 
 
