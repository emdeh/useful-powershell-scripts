<#
.SYNOPSIS
This script updates missing GivenName and Surname fields in Azure AD user records to "unknown".

Originally developed to address an issues where MFA authentication was failing for users with missing
GivenName and Surname fields in Azure B2C AD - presumably because the token claims wouldn't work if the
fields returned null value.

Can be adapted to other scenarios where other object properties need to be updated based on certain conditions.

.DESCRIPTION
The script connects to an Azure AD tenant, reads a CSV file containing user UPNs, and checks each user's 
GivenName and Surname fields. If either field is blank, it updates the field to "unknown". The script logs 
the actions taken and any errors encountered.

The script requires the AzureAD module. The user will be prompted to sign in to Azure AD.

.PARAMETER TenantId
The Azure AD Tenant ID.

.PARAMETER CSVPath
The path to the CSV file containing user UPNs. The CSV file should have a header row with a column named 
"UserPrincipalName".

.PARAMETER AuditLog
The path to the audit log file where the script will log its actions and results.

.NOTES
- The script requires the AzureAD module.
- The script sets the execution policy to RemoteSigned for the current user.
- The user will be prompted to sign in to Azure AD.

.EXAMPLE
.\update_missing_name.ps1
This example runs the script using the default parameters defined within the script.
Be sure to set the variables at the beginning of the script before running.

#>

# Set Execution Policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Parameters/Variables
$TenantId = "YOUR_TENANT_ID"    # Azure AD Tenant ID
$CSVPath = ".\users.csv"        # Path to the CSV file file containing user object UPNs of targets (e.g., with a UserPrincipalName column - first row as header)
$AuditLog = ".\AuditLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Connect to Azure AD
Connect-AzureAD -TenantId $TenantId
# You will be prompted to sign in

# Import the CSV
$users = Import-Csv -Path $CSVPath

# Prepare the audit log header
"Timestamp,UserPrincipalName,Action,Result" | Out-File $AuditLog

# Show that processing has begun
Write-Host "Processing..."

foreach ($user in $users) {
    # Extract UPN from the user object
    $upn = $user.userPrincipalName
    try {
        # Get the current user's Azure AD record
        $aadUser = Get-AzureADUser -Filter "UserPrincipalName eq '$upn'"
        if ($null -eq $aadUser) {
            # User not found
            $result = "FOR REVIEW - UserNotFound"
            "$([DateTime]::UtcNow),$upn,NoUpdate,$result" | Out-File $AuditLog -Append
            continue
        }
        # Check GivenName and Surname
        $givenNameBlank = [string]::IsNullOrWhiteSpace($aadUser.GivenName)
        $surnameBlank = [string]::IsNullOrWhiteSpace($aadUser.Surname)
        if ($givenNameBlank -or $surnameBlank) {
            # Update blank field(s) that were found to "unknown"
            $newGiven = if ($givenNameBlank) { "unknown" } else { $aadUser.GivenName }
            $newSurname = if ($surnameBlank) { "unknown" } else { $aadUser.Surname }
            Set-AzureADUser -ObjectId $aadUser.ObjectId -GivenName $newGiven -Surname $newSurname
            $result = "UPDATED - User fields updated"
            "$([DateTime]::UtcNow),$upn,UpdateApplied,$result" | Out-File $AuditLog -Append
        } else {
            # Both fields are not blank
            $result = "FOR REVIEW - No update needed"
            "$([DateTime]::UtcNow),$upn,NoUpdate,$result" | Out-File $AuditLog -Append
        }
    } catch {
        # Catch errors during processing
        $errorMessage = $_.Exception.Message -replace "`n"," " -replace "`r"," "
        "$([DateTime]::UtcNow),$upn,Error,$errorMessage" | Out-File $AuditLog -Append
    }
}

# Show that processing is complete
Write-Host "Completed."