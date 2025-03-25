<#
.DESCRIPTION
    Ensures the outputDirectory for PowerShell Transcription has the appropriate
    permissions set.

    You should also set file system auditing (Local Security Policy > 
    Advanced Audit Policy Configuration > Object Access > Audit File System).

    Author: emdeh
    Version: 1.0.0
#>

$folder = "C:\Logs\PowerShellTranscripts"

# 1. Check if the folder exists
try {
    if (-not (Test-Path $folder)) {
        Write-Output "Folder path does not exist. Has the registry values been set?"
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

# Rule 1: CREATOR OWNER: FullControl, Deny
$rule1 = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule (
    'CREATOR OWNER',
    'FullControl',
    'ContainerInherit, ObjectInherit',
    'None',
    'Deny'
)
$acl.SetAccessRule($rule1)
Write-Host "Set NTFS permission for CREATOR OWNER (FullControl, Deny)"

# Rule 2: Authenticated Users: Read and Write, Allow
$rule2 = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule (
    'Authenticated Users',
    'Read, Write',
    'ContainerInherit, ObjectInherit',
    'None',
    'Allow'
)
$acl.SetAccessRule($rule2)
Write-Host "Set NTFS permission for Authenticated Users (Read, Write, Allow)"

# Rule 3: SYSTEM: FullControl, Allow
$rule3 = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule (
    'SYSTEM',
    'FullControl',
    'ContainerInherit, ObjectInherit',
    'None',
    'Allow'
)
$acl.SetAccessRule($rule3)
Write-Host "Set NTFS permission for SYSTEM (FullControl, Allow)"

# Rule 4: BUILTIN\Administrators: FullControl, Allow
$rule4 = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule (
    'BUILTIN\Administrators',
    'FullControl',
    'ContainerInherit, ObjectInherit',
    'None',
    'Allow'
)
$acl.SetAccessRule($rule4)
Write-Host "Set NTFS permission for BUILTIN\Administrators (FullControl, Allow)"

# Apply the updated ACL to the folder
try {
    Set-Acl -Path $folder -AclObject $acl
    Write-Host "NTFS permissions applied to $folder."
}
catch {
    Write-Output "Error applying ACL: $_"
    exit 1
}

# 3. Apply auditing. Retrieve the current SACL (audit rules)
try {
    $aclAudit = Get-Acl -Audit $folder
}
catch {
    Write-Output "Error retrieving SACL: $_"
    exit 1
}

# Create an audit rule for Everyone: FullControl, auditing both Success and Failure events.
$auditRule = New-Object -TypeName System.Security.AccessControl.FileSystemAuditRule (
    'Everyone',
    'FullControl',
    'ContainerInherit, ObjectInherit',
    'None',
    'Success, Failure'
)
$aclAudit.AddAuditRule($auditRule)

# Apply the updated SACL to the folder
try {
    Set-Acl -Path $folder -AclObject $aclAudit
    Write-Host "Auditing rule applied to $folder."
}
catch {
    Write-Output "Error applying auditing rule: $_"
    exit 1
}

Write-Host "Folder setup complete."