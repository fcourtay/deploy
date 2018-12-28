Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted
## Requesting Admin prompt
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}
## Variables
$ChocolatelyGetName = "ChocolateyGet"
$NuGetName = "NuGet"
$ChocoPackagesToInstall = `
    #"office365proplus", `
    #"microsoft-teams", `
    #"powerbi", `
    "visualstudiocode", `
    "googlechrome", `
    "mremoteng", ` #remote desktop manager
    "7zip", `
    #"rsat", ` #Remote Admin tools
    "git", `
    "python", `
    #"nmap", ` #network mapping tool
    "sysinternals", ` #pack of internal MS tools
    #"lightshot.install", ` #screenshots
    #"picpick.portable", ` #screenshots and editing
    #"screentogif", ` #screen recorder
    #"pester", ` #powershell unit testing
    #"steam", `
    #"qbittorrent", `
    #"curl", ` #bash cmd
    #"wget", ` #bash cmd
    #"sql-server-management-studio", `
    #"logitechgaming", ` #Logitech Gaming software (for my G35 Headset)
    "vlc"
$StartTime = Get-Date
Write-Host "[START] $StartTime"
## Install NuGet first
Install-PackageProvider -Name $NuGetName -MinimumVersion 2.8.5.201 -Force

## Verify installed
$NuGetInstalled = [bool](Get-PackageProvider | where-object{$_.Name -eq $NuGetName}).count
if($NuGetInstalled){
    ## Continue

    ## Install ChocolateyGet
    Find-PackageProvider -Name $ChocolatelyGetName | Install-PackageProvider -Force

    ## Validate Installed
    $ChocoModule = Get-Module -ListAvailable -Name $ChocolatelyGetName
    $ChocoGetInstalled = [bool]($ChocoModule).count
    if($ChocoGetInstalled){
        ## Continue
        Import-Module $ChocoModule -Force
        
        ## Make sure prereqs are met
        Get-Package -Force | Out-Null
        foreach($pkg in $ChocoPackagesToInstall){
            $pkgInstallStart = get-date
            ## Install Programs
            Install-Package -Name $pkg -Force
            $pkgInstallEnd = get-date
            Write-Host "[INSTALL TIME] $(New-TimeSpan -Start $pkgInstallStart -End $pkgInstallEnd)"
        }
    }
    else {
        throw "$ChocolatelyGetName installation could not be found"
    }
}
else {
    throw "$NuGetName installation could not be found"
}

##Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$EndTime = Get-Date
$Diff = New-TimeSpan -Start $StartTime -End $EndTime
Write-Host "[END] $EndTime`nTotal: $Diff"