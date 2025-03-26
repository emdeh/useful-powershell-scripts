# PowerShell Transcription Logging Implementation Approach

## Background and Objective
> [Please see Securing PowerShell in the enterprise for latest advice](https://www.cyber.gov.au/resources-business-and-government/maintaining-devices-and-systems/system-hardening-and-administration/system-administration/securing-powershell-enterprise]).

Implementing PowerShell transcription logging aligns with Essential Eight recommendations by capturing detailed records of PowerShell activity across endpoints. The goal is to improve detection and forensic capabilities for cybersecurity incidents involving PowerShell.

Transcription logging records the complete input/output of PowerShell sessions. Log file access permissions must be secured, [and ideally audited](https://www.cyber.gov.au/resources-business-and-government/maintaining-devices-and-systems/system-hardening-and-administration/system-administration/securing-powershell-enterprise#:~:text=Attempts%20to%20modify%20the%20registry,host%20execution%2C%20should%20be%20investigated) to enable comprehensive forensic investigations. 

PowerShell transcripts are plain text files that will accumulate over time on each endpoint. Without a SIEM or log management system to ingest them centrally, a plan for managing those files on disk is required – both to avoid running out of space and to ensure older logs are archived or disposed appropriately.

## Implementation Overview
This implementation will use:
- Intune Settings Catalog (Administrative Templates) for enabling transcription logging.
- Intune Remediation scripts for ensuring folder permissions.
- Two optional methods for log cleanup: a remediation script or a scheduled task.
- Optional file-system auditing via Local Security Policy.

## Implementation Steps

### Step 1: Enable PowerShell Transcription (Settings Catalog)
1. In Intune, navigate to Endpoint Security > Configuration Profiles.
- Create a new profile:
- Platform: Windows 10 and later
- Profile type: Settings catalog

2. Add settings:
- Navigate to Administrative Templates > Windows Components > Windows PowerShell
- Set Turn on PowerShell Transcription: Enabled
- Set Transcript output directory: C:\Logs\PowerShellTranscripts
- Set Include invocation headers: Enabled

3. Assign this policy to relevant device groups.

### Step 2: Remediation Script – Folder Permissions
Create a remediation script in Intune (Proactive Remediation):

1. Detection Script (check permissions exist).

Implement [a script](/intune_remediation_scripts/ps_transcription_logging/check_log_folder_exists.ps1) to check for the existence of the `Logs/PowerShellTranscripts` directory.

2. Remediation Script (set permissions):

Implement [a script](/intune_remediation_scripts/ps_transcription_logging/set_log_folder_acl.ps1) to validate correct NTFS and audit permissions on the `Logs/PowerShellTranscripts` directory.

3. Assign these scripts to device groups, running at least daily.

### Step 3: Log Cleanup Strategy 

TBC

### Optional: File System Auditing
File auditing adds tamper detection:

For GPO-managed environments, use Advanced Audit Policy Configuration in GPO to set `(Local Security Policy > Advanced Audit Policy Configuration > Object Access > Audit File System)`

## Justification & Best Practices
- Transcription ensures all PowerShell activity is logged, aligning with ACSC and Essential Eight recommendations.
- Folder permissions secure logs from tampering, especially denying creators from modifying/deleting their own transcripts.
- Log cleanup mitigates disk storage issues, especially critical without centralized log management (SIEM).
- File Auditing provides visibility into unauthorized access or deletion, enhancing detection capabilities.


## Future Improvements
### Centralised Logging
- Evaluate options to centralise PowerShell transcription logs to enhance visibility and response capabilities.
- Consider connectivity constraints, noting endpoints only have direct access to Azure-based "on-prem" resources when physically in the office.

> In the interim, leverage Defender XDR's Live Response feature to manually retrieve logs from endpoints, provided there is connectivity.

### Long-Term Strategy
Plan for implementing a Security Information and Event Management (SIEM) solution to automate centralised log collection and analysis.
