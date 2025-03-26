<#
.DESCRIPTION
    Pre-check script for PowerShell Transcription folder.
    Ensures the folder exists with the correct NTFS permissions and audit rules.
    This script is intended for use as an Intune remediation script:
    it exits with 0 only if all checks pass, else it exits with 1.

    You should also consider setting file system auditing (Local Security Policy > 
    Advanced Audit Policy Configuration > Object Access > Audit File System).

    Author: emdeh
    Version: 1.0.0
#>

$folder = 'C:\Logs\PowerShellTranscripts'

# 1. Check if the folder exists
try {
    if (-not (Test-Path $folder)) {
        Write-Output "Folder path does not exist. Has the registry values or Intune configuration been set?"
        exit 1
    }
}
catch {
    Write-Output "Error checking folder path: $_"
    exit 1
}

# 2. Retrieve current NTFS ACL for the folder
try {
    $acl = Get-Acl -Path $folder
}
catch {
    Write-Output "Error retrieving ACL: $_"
    exit 1
}

# Define the expected NTFS ACL rules
$expectedAccessRules = @(
    @{ Identity = "CREATOR OWNER";         Rights = "FullControl";   AccessType = "Deny" },
    @{ Identity = "Authenticated Users";     Rights = "Read, Write";   AccessType = "Allow" },
    @{ Identity = "SYSTEM";                  Rights = "FullControl";   AccessType = "Allow" },
    @{ Identity = "BUILTIN\Administrators";   Rights = "FullControl";   AccessType = "Allow" }
)

$allAccessRulesOk = $true

# Validate each expected ACL rule
foreach ($rule in $expectedAccessRules) {
    $found = $acl.Access | Where-Object {
        $_.IdentityReference -eq $rule.Identity -and
        $_.AccessControlType.ToString() -eq $rule.AccessType -and
        $_.FileSystemRights.ToString().Contains($rule.Rights)
    }
    if (-not $found) {
        Write-Output "Missing or incorrect ACL rule for $($rule.Identity)"
        $allAccessRulesOk = $false
    }
}

if (-not $allAccessRulesOk) {
    Write-Output "Folder exists but NTFS permissions are incorrect."
    exit 1
}
else {
    Write-Output "Folder exists and ACL permissions are correct."
}

# 3. Retrieve current SACL (audit rules)
try {
    $aclAudit = Get-Acl -Audit $folder
}
catch {
    Write-Output "Error retrieving SACL: $_"
    exit 1
}

# Define the expected audit rule for "Everyone" with FullControl for both Success and Failure events
$expectedAudit = @{
    Identity   = "Everyone"
    Rights     = "FullControl"
    AuditFlags = "Success, Failure"
}

$auditRule = $aclAudit.Audit | Where-Object {
    $_.IdentityReference -eq $expectedAudit.Identity -and
    $_.FileSystemRights.ToString().Contains($expectedAudit.Rights) -and
    $_.AuditFlags.ToString() -eq $expectedAudit.AuditFlags
}

if (-not $auditRule) {
    Write-Output "Folder exists and NTFS permissions correct, but auditing rules are incorrect."
    exit 1
}
else {
    Write-Output "Folder exists and all permissions (ACL & auditing) are correct."
    exit 0
}
