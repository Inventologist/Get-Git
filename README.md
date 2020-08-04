# Get-Git
Small script to download a Git repository, so that when others use your script, it downloads the required  scripts/modules
 
## Backstory
I try to really use the repositories that I post here.  So, you can imagine that my scripts are completely intertwined.
Previously, I would simply include the accessory function INSIDE of the script.  I desparately wantd some "Built-In" way to get and load a repository... just like the Powershell Gallery.  So, I embarked on this journey.

I'm sure that there are scenarios that I am not catching... please be kind!
#### Get in touch when you find something wrong.

## Usage
First Line Downloads and executes the script GETS the Repo and stores it in your Modules Directory
Second Line Dot Sources the script necessary to access the function (If it were a PSM1 file you would use: Import-Module $PathtoModule\NameOfPSMFile.psm1)
    
#### First Line
```powershell
Invoke-Expression ('$GHDLUri="https://github.com/Inventologist/SuperLine/archive/master.zip";$GHUser="Inventologist";$GHRepo="SuperLine"' + (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Inventologist/Get-Git/master/Get-Git.ps1'))
```

#### Second Line
```powershell
. $PathtoModule\Public\SuperLine.ps1
```
    
The second line may NOT be necessary if you have a 'Get-Git.Autoload.txt' file in the repository.  This is not a GitHub standardized file... its something that I created.
Simply have the content of the file be the command that is used to load it, and the script will find it.

#### So, I only have to use the first line in my script, because SuperLine has the Get-Git.AutoLoad.txt file.
```powershell
Invoke-Expression ('$GHDLUri="https://github.com/Inventologist/SuperLine/archive/master.zip";$GHUser="Inventologist";$GHRepo="SuperLine"' + (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Inventologist/Get-Git/master/Get-Git.ps1'))
```

## References / Credits
I've tried a few other scripts... some work, some dont.  The Genesis for the idea came from this article:
https://habr.com/en/post/476914/

I looked into his ps1 script, but I couldn't wrap my head around some of the logic (probably because the code was fairly evolved), So I started from scratch.  At some point I would love to collab with the author of that script.
 
 
