# Active Directory User Reporting Automation

## Project Overview

A reusable PowerShell script that generates Active Directory user inventory reports, exports results to CSV, validates exported records, and maintains timestamped execution logs.

Developed as part of a hands-on Windows Server 2025 and Endpoint Engineering home lab.

## Technologies

- Windows Server 2025
- Active Directory Domain Services (AD DS)
- Windows PowerShell
- Microsoft Hyper-V
- CSV reporting and validation

## Features

- Queries Active Directory users from a configurable Organizational Unit
- Exports account names, usernames, enabled status, departments, and job titles
- Supports configurable report and log directories
- Generates timestamped execution logs
- Validates CSV row counts and exported attribute values
- Uses error handling and process exit codes

## Lab Environment

| Component | Configuration |
|---|---|
| Virtualization | Microsoft Hyper-V |
| Operating System | Windows Server 2025 |
| Domain | endpointlab.test |
| Domain Controller | LAB-DC01 |
| Target OU | Lab-Users |
| Test Accounts | Three fictional employee accounts |

## Usage

Run from a Windows PowerShell session with the Active Directory module installed and permission to query the target directory.

Default execution:

```powershell
.\Get-EndpointLabUsers.ps1
```

Custom report directory:

```powershell
.\Get-EndpointLabUsers.ps1 -ReportFolder "C:\EndpointLab\CustomReports"
```

Custom search base:

```powershell
.\Get-EndpointLabUsers.ps1 -SearchBase "OU=Lab-Users,DC=endpointlab,DC=test"
```

The script writes `AD-Users-Report.csv` to the selected report directory and creates timestamped log files.

A successful execution returns exit code `0`; failures return `1`.

## Testing and Validation

Validated in an isolated Active Directory environment using three fictional user accounts.

Tests completed:

- Successful AD user retrieval
- CSV export and reimport
- Row-count validation
- Attribute comparison between query results and exported CSV
- Timestamped log creation
- Custom report directory parameter
- Successful process exit code

## Security Considerations

The script performs read-only Active Directory queries. It does not modify user accounts or group memberships.

Use appropriately scoped directory read permissions. Reports and logs should be stored in secured locations because account inventories can contain organizational information.

The repository includes only fictional sample records and excludes operational logs, credentials, and actual directory exports.

## Future Enhancements

- Automated scheduled reporting
- Disabled-account reporting
- Department-based report filtering
- Pester unit tests
- Improved structured logging

## Project Context

Personal hands-on technical training project demonstrating PowerShell automation, Active Directory administration, reporting, and validation skills.