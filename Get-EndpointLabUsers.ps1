
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
    Exports Active Directory lab users to CSV.

.DESCRIPTION
    Retrieves users from a specified OU, exports a CSV report,
    validates the exported records, and writes a log.

.EXAMPLE
    .\Get-EndpointLabUsers.ps1

.EXAMPLE
    .\Get-EndpointLabUsers.ps1 -ReportFolder "C:\EndpointLab\CustomReports"
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$SearchBase = "OU=Lab-Users,DC=endpointlab,DC=test",

    [Parameter()]
    [string]$ReportFolder = "C:\EndpointLab\Reports",

    [Parameter()]
    [string]$LogFolder = "C:\EndpointLab\Logs"
)

$ErrorActionPreference = "Stop"

$ReportPath = Join-Path $ReportFolder "AD-Users-Report.csv"
$LogPath = $null

function Write-LabLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "ERROR")]
        [string]$Level = "INFO"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Entry = "[$Timestamp] [$Level] $Message"

    Write-Host $Entry

    if ($LogPath) {
        Add-Content -LiteralPath $LogPath -Value $Entry -ErrorAction Stop
    }
}

try {
    # Prepare folders
    New-Item -Path $ReportFolder -ItemType Directory -Force |
        Out-Null

    New-Item -Path $LogFolder -ItemType Directory -Force |
        Out-Null

    # Generate a unique log file for this run
    $RunId = Get-Date -Format "yyyyMMdd-HHmmss-fffffff"
    $LogPath = Join-Path $LogFolder "AD-Report-$RunId.log"

    Write-LabLog "Starting Active Directory user report."
    Write-LabLog "Search base: $SearchBase"

    # Retrieve users
    $Users = @(
        Get-ADUser -Filter * `
            -SearchBase $SearchBase `
            -Properties Department,Title,Enabled `
            -ErrorAction Stop |
        Select-Object Name,SamAccountName,Enabled,Department,Title |
        Sort-Object Name
    )

    if ($Users.Count -eq 0) {
        throw "No users found in the specified OU."
    }

    Write-LabLog "Found $($Users.Count) users."

    # Export to CSV
    $Users | Export-Csv `
        -LiteralPath $ReportPath `
        -NoTypeInformation `
        -Encoding UTF8 `
        -ErrorAction Stop

    # Import and validate CSV
    $Imported = @(
        Import-Csv -LiteralPath $ReportPath -ErrorAction Stop
    )

    if ($Imported.Count -ne $Users.Count) {
        throw "CSV row count does not match the AD query."
    }

    $Properties = @(
        "Name", "SamAccountName", "Enabled", "Department", "Title"
    )

    foreach ($Index in 0..($Users.Count - 1)) {
        foreach ($Property in $Properties) {
            $Expected = [string]$Users[$Index].$Property
            $Actual = [string]$Imported[$Index].$Property

            if ($Expected -cne $Actual) {
                throw "CSV validation failed for row $Index, property $Property."
            }
        }
    }

    Write-LabLog "CSV validation passed." "SUCCESS"
    Write-LabLog "Report saved: $ReportPath" "SUCCESS"
    Write-LabLog "Log saved: $LogPath" "SUCCESS"

    exit 0

}
catch {
    $Message = $_.Exception.Message

    try {
        Write-LabLog "Report failed: $Message" "ERROR"
    }
    catch {
        Write-Host "ERROR: $Message" -ForegroundColor Red
        Write-Host "Logging also failed: $($_.Exception.Message)" -ForegroundColor Red
    }

    exit 1
}
