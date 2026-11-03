# Drive age report

Read-only tables for each Windows drive: percentages of files in each top-level folder (including subfolders) last modified more than 1 month, 6 months, and 1 year ago. Percentages overlap.

Requires Python 3.9+; no extra packages. Download and run in **PowerShell**:

```powershell
Invoke-WebRequest -UseBasicParsing `
  "https://raw.githubusercontent.com/konnorve/computer-setup/main/drive_age.py" `
  -OutFile drive_age.py

py .\drive_age.py
```
