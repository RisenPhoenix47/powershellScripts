<# 
.SYNOPSIS
    A script that crawls a filesystem to determine access permissions.
.EXAMPLE
    .\GetFilePermissions.ps1 -filePath C:\Users
.PARAMETER filePath
    Path to the starting directory for the script.
.PARAMETER csvPath
    Filepath for the CSV export 
    Example: C:\MyCSV.csv
#>

Param(
    [Parameter(Mandatory=$true)][String]$filePath,
    [Parameter(Mandatory=$true)][String]$csvPath
)

$report = [System.Collections.Generic.List[Object]]::new() # Create output file 

$files = Get-ChildItem -recurse $filePath | Select FullName, Name
$progressDelta = 100/($files.count); $percentComplete = 0; $fileNumber = 0
foreach ($file in $files) {
    $fileNumber++
    $fileStatus = $file.Name + " ["+ $fileNumber +"/" + $files.Count + "]"
    Write-Progress -Activity "Checking permissions for file" -Status $fileStatus -PercentComplete $PercentComplete
    $PercentComplete += $ProgressDelta
    $permissions = (get-acl $file.FullName).access | Select-Object IdentityReference, FileSystemRights, AccessControlType, IsInherited | Where-Object {$_.IdentityReference -ne "NT AUTHORITY\SYSTEM" -and $_.IdentityReference -ne "BUILTIN\Administrators" -and $_.IsInherited -ne "True"}
    foreach ($permission in $permissions){
        $reportline = [PSCustomObject]@{
            Name = $file.FullName
            Identity = $permission.IdentityReference
            Rights = $permission.FileSystemRights
            Inherited = $permission.IsInherited
        }
        $report.Add($reportline)
    }
}

$report | Export-Csv $csvPath