This change relates to a User Application Hardening strategy control about PowerShell Transcription Logging.

For more information, please see ASD's article on [Securing PowerShell in the enterprise](https://www.cyber.gov.au/resources-business-and-government/maintaining-devices-and-systems/system-hardening-and-administration/system-administration/securing-powershell-enterprise). This change only deals with the transcription component.

## Deployment approach
Transcription Logging can be turned on via an [Intune device configuration policy](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-admx-powershellexecutionpolicy?WT.mc_id=Portal-fx#enabletranscripting)


This policy lets you apply the following equivalent registry settings:
```bash
Key = `HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription`
EnableTranscripting = 1 # (REG_DWORD)
EnableInvocationHeader  = 1 # (REG_DWORD)
OutputDirectory = C:\Path\To\Desired\Directory # (REG_SZ)
```
## OutputDirectory
The policy will create the `OutputDirectory`. [Microsoft's documentation](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-admx-powershellexecutionpolicy?WT.mc_id=Portal-fx#admx-powershellexecutionpolicy-enabletranscripting:~:text=will%20record%20transcript%20output%20to%20each%20users%27%20My%20Documents%20directory%2C%20with%20a%20file%20name%20that%20includes%20%27PowerShell_transcript%27) sets the default log path to the user's `My Documents` folder. 

This might not be suitable for every context. Especially if the location syncs to a OneDrive and you intend to apply future controls to protect the directory and preserve forensic integrity.

## Controlling log bloat
PowerShell transcription log settings do not natively support log size limits or rollover. While it's unlikely the log directory will grow rapidly, the detection and remediation scripts in this folder can be used to manage this aspect.

The detection script will check if the directory exceeds a specified size (e.g. 10000 KB). If so, the remediation script triggers to delete the transcript subfolders older than 90 days.

The size threshold and retention period can be adjusted based on volume and ideally to align with other log retention requirements. During testing, intentionally low limits can be used to validate the logic of the scripts.

## Future improvements
While this change implements transcription logging, additional improvements will maximise the forensic value of transcription logs. Consider:
- Restricting permissions on the transcript directory to prevent tampering.
- Enabling auditing on the directory to monitor access and changes.
- Shipping logs off-host (subject to SIEM or log-store infrastructure).