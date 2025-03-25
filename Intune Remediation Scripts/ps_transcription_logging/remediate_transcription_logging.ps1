<#
.DESCRIPTION
    Checks if the Transcription registry key is set to 1.
    Creates or updates the key and returns exit code 0 on success, 1 on failure.

    PowerShell Transcription captures the full command line input and output of PowerShell sessions, which can help detect abuse and support forensic investigations.
    
    This script alone is not enough. You need to also created a transcription log output file, and should consider setting file system auditing (Local Security Policy > Advanced Audit Policy Configuration > Object Access > Audit File System).

	Author: emdeh
    Version: 1.0.0
#>

