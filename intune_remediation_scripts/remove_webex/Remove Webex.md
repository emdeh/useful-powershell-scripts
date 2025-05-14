# Remove Webex

## Overview

This remediation script targets instances where Webex has been installed within the user context.

- **Detection Script:** Runs as the user, checks known per-user Webex install locations (e.g. %LOCALAPPDATA%\Programs\Cisco Spark and %LOCALAPPDATA%\WebEx folders, or corresponding registry keys in HKCU). If any Webex is found in the user profile, the script returns a non-zero exit code (marking the device “non-compliant” and triggering remediation)
- **Remediation Script:** Runs as the logged-in user’s context (Intune setting `Run this script using the logged-in credentials = Yes`). It will:
    1. Kill Webex Processes running from the user profile (to avoid file locks).
    2. Use Official Uninstaller if possible: If a Webex was installed via MSI (Windows Installer) in user context, we attempt a silent `msiexec /x` removal. (If the uninstall string indicates an MSI, append `/qn` for quiet uninstall.)
    3. Fallback to Manual Clean-up: If no silent uninstall is available (e.g. Webex’s own uninstall executables require user confirmation and have *no silent parameters*), the script will manually remove Webex files and registry entries in the user profile. Specifically, it will delete Webex folders under `%LOCALAPPDATA%` and `%APPDATA% `for that user, and remove any corresponding `HKCU` uninstall registry keys so that stale entries are cleared from the user’s Add/Remove Programs.
    4. Preserve Machine-Wide Installations: The script explicitly avoids touching anything in `C:\Program Files\` or `C:\Program Files (x86)\`. Those are left intact (e.g. if IT deployed Webex to all machines, that installation remains).

    