<# 
.SYNOPSIS
    A simple script that crawls sharepint sites, determines file path length and outputs it in CSV format.
.EXAMPLE
    .\GetSharePointFilePathLength.ps1 -tenantURL https://contoso-admin.sharepoint.com -csvPath .\MyCSV.csv
.PARAMETER tenantURL
    URL for the admin URL for your tenant 
    Example: https://contoso-admin.sharepoint.com
.PARAMETER csvPath
    Filepath for the CSV export 
    Example: C:\MyCSV.csv
.NOTES
    Adapted from a script written by Jos Lieban available via this link on GitLab: 
    https://gitlab.com/Lieben/assortedFunctions/blob/master/get-filesWithLongPathsInOffice365.ps1. 
#>

Param(
    [Parameter(Mandatory=$true)][String]$tenantURL,
    [Parameter(Mandatory=$true)][String]$csvPath
)


Connect-PnPOnline -Url $tenantURL -Interactive

$report = [System.Collections.Generic.List[Object]]::new()
$sites = Get-PnPListItem -List DO_NOT_DELETE_SPLIST_TENANTADMIN_AGGREGATED_SITECOLLECTIONS -Fields ID,Title,TemplateTitle,SiteUrl,IsGroupConnected
foreach($site in $sites){
    Write-Host "Processing $($site.FieldValues.Title) with url $($site.FieldValues.SiteUrl)"
    Connect-PnPOnline $site.FieldValues.SiteUrl -Interactive
    $lists = Get-PnPList -Includes BaseType,BaseTemplate,ItemCount
        $lists | where {$_.BaseTemplate -eq 101 -and $_.ItemCount -gt 0} | % {
            Write-Host "Detected document library $($_.Title) with Id $($_.Id.Guid) and Url $baseUrl$($_.RootFolder.ServerRelativeUrl), processing..."
            $items = Get-PnPListItem -List $_ -PageSize 2000
            foreach($item in $items){
                $itemName = Split-Path $item.FieldValues.FileRef -Leaf
                $itemFullUrl = "$($item.FieldValues.FileRef)"
                $filePath = $itemFullUrl.Substring(7)
                Write-Host $filePath
                $pathLength = $filePath.Length
                Write-Host $pathLength
                $reportLine = [PSCustomObject] @{
                    FilePath    = $filePath
                    PathLength  = $pathLength
                }
                $report.Add($reportLine)
            }
        }
}

$report | Export-CSV $csvPath -NoTypeInformation
