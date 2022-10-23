<# 
.SYNOPSIS
    A script that removes all disabled user accounts from an AD group.
.EXAMPLE
    .\RemoveDisabledUsers.ps1 -groupname "All Staff"
.PARAMETER groupName
    Name of the group to remove disabled accounts from
#>


Param(
    [Parameter(Mandatory=$true)][String]$groupName
)

$members= (Get-ADGroup $groupName -Properties members).members
foreach($member in $members) {
    $user = Get-aduser $member | Where {$_.Enabled -eq $false }
    if ($user -ne $null) {
        Write-Host "Removing $($user.Name) from $groupName..."
        Remove-ADGroupMember $groupName -Members $user
    }}