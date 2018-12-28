# Functions
Function WriteLog {
    [CmdletBinding()]
    param (
       [Parameter(Mandatory=$TRUE)][ValidateNotNullOrEmpty()][string]$LogFile,
       [parameter(Mandatory=$TRUE)][ValidateNotNullOrEmpty()][string]$LineOfText
     )
    try {
        Add-Content -Value "$(Get-Date) - $LineOfText" -LiteralPath $LogFile -ErrorAction Stop
    }Catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to $LogFile file"
    }
}

$LogFile = $env:windir+"\Logs\DeploymentLogs\Script-RemovedUniversalApps.log"

# Get a list of all apps
WriteLog -LogFile $LogFile -LineOfText "Starting built-in AppxPackage and AppxProvisioningPackage removal process"
$AppArrayList = Get-AppxPackage -PackageTypeFilter Bundle -AllUsers | Select-Object -Property Name, PackageFullName | Sort-Object -Property Name

# White list of appx packages to keep installed
$WhiteListedApps = @(
    "Microsoft.StorePurchaseApp",
    "Microsoft.WindowsCalculator",
    "Microsoft.WindowsStore",
    "Microsoft.Windows.Photos"
    "Microsoft.PPIProjection"
    "Microsoft.MSPaint"
    "Microsoft.DesktopAppInstaller"
    "Microsoft.WindowsCamera"
    "Microsoft.WindowsMaps"
)

# Loop through the list of appx packages
foreach ($App in $AppArrayList) {
    # If application name not in appx package white list, remove AppxPackage and AppxProvisioningPackage
    if (($App.Name -in $WhiteListedApps)) {
        WriteLog -LogFile $LogFile -LineOfText "Skipping excluded application package: $($App.Name)"
    }
    else {
        # Gather package names
        $AppPackageFullName = Get-AppxPackage -Name $App.Name | Select-Object -ExpandProperty PackageFullName
        $AppProvisioningPackageName = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $App.Name } | Select-Object -ExpandProperty PackageName

        # Attempt to remove AppxPackage
        if ($null -ne $AppPackageFullName) {
            try {
                WriteLog -LogFile $LogFile -LineOfText  "Removing application package: $($App.Name)"
                Remove-AppxPackage -Package $AppPackageFullName -ErrorAction Stop | Out-Null
            }
            catch [System.Exception] {
                WriteLog -LogFile $LogFile -LineOfText  "Removing AppxPackage failed: $($_.Exception.Message)"
            }
        }
        else {
            WriteLog -LogFile $LogFile -LineOfText  "Unable to locate AppxPackage for app: $($App.Name)"
        }

        # Attempt to remove AppxProvisioningPackage
        if ($null -ne $AppProvisioningPackageName ) {
            try {
                WriteLog -LogFile $LogFile -LineOfText  "Removing application provisioning package: $($AppProvisioningPackageName)"
                Remove-AppxProvisionedPackage -PackageName $AppProvisioningPackageName -Online -ErrorAction Stop | Out-Null
            }
            catch [System.Exception] {
                WriteLog -LogFile $LogFile -LineOfText  "Removing AppxProvisioningPackage failed: $($_.Exception.Message)"
            }
        }
        else {
            WriteLog -LogFile $LogFile -LineOfText "Unable to locate AppxProvisioningPackage for app: $($App.Name)"
        }
    }
}

Get-appxpackage -allusers *king.com.CandyCrush* | Remove-AppxPackage
Get-appxprovisionedpackage –online | where-object {$_.packagename –like "*king.com.CandyCrush*"} | remove-appxprovisionedpackage –online



WriteLog -LogFile $LogFile -LineOfText "Removal process completed"