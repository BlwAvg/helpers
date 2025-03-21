# Layoff Detector
Ways to gather intelligence pertaining to layoffs.  

1. Run an AD Query using PowerShell to determine when an account has been deactivated. Requires the [Active Directory Module for Windows PowerShell](https://learn.microsoft.com/en-us/powershell/module/activedirectory/).
2. Run an AD query using Active Directory Users and Computers. This requires the [Remote Server Administration Tools](https://learn.microsoft.com/en-us/windows-server/remote/remote-server-administration-tools).
3. Worker Adjustment & Retraining Notification Act (WARN) - US states must provide a listing of layoffs based on certain criteria.

## 1. PS Query
```
get-ADUser -LDAPFilter "(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=2)(whenChanged>=20241215000000.0Z))" -Properties whenChanged, title, description | Select-Object Name, SamAccountName, whenChanged, title, description | Sort-Object -Property whenChanged -Descending
```
**Output Example:**
```
Name           : First M. Last
SamAccountName : ADusername_here
whenChanged    : MM/DD/YYYY HH:MM:SS AM/PM
title          : SuperCool Query
description    : Please submit PRs to make this better
```

### PS Query breakdown
| Command Component | Description |
|-------------------|-------------|
| get-ADUser | Retrieves user accounts from AD |
| -LDAPFilter | Specifies and LDAP query filter |
| (& ... ) | Specifies an AND condition for specified terms |
| objectCategory=person | Ensure object categorized as "persons" in AD |
| objectClass=user | Ensure object categorized as "user" in AD |
| userAccountControl:1.2.840.113556.1.4.803:=2 | Searches for disabled accounts. The 1.2.840.113556.1.4.803 means [LDAP_MATCHING_RULE_BIT_AND](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/4e638665-f466-4597-93c4-12f2ebfabab5). We are looking to see (:=2) if the userAccountControl flag for "2" [bit](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/1e38247d-8234-4273-9de3-bbf313548631?redirectedfrom=MSDN) is set. If so that means the account is disabled. |
| (whenChanged>=20241215000000.0Z) | Start date and Time.  Format is YYYY MM DD - I assume HH MM SS for the rest. I only change the date and leave the HHMMSS to 0. |
| -Properties | Request additional attributes - [look here for additional properties](https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-aduser) |
| whenChanged | Date and time when the account was last modified | 
| title | Job title of user |
| description | Description field for the account |
| Select-Object | Specifies which properties to display in the output - [Look here for more on Select-Object](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object)| 
| Name | Full name of the user |
| SamAccountName | AD Username | 
| whenChanged | Date and time when the account was last modified | 
| title | Job title of user |
| description | Description field for the account |
| Sort-Object -Property whenChanged -Descending | Sorts by the whenChanges date descending |

## 2. Remote Server Administration Tools
1. Open Active Directory Users and Computers
2. Select Action > New > Query. This will prompt for a new saved query.
3. Enter whatever you want for the name, description and make sure to select the query root.
4. Enter this query and run it.
   ```
   I NEED TO PUT THE QUERY HERE
   ```

### 3. WARN Listings
For the US only. WARN requires that employers with 1OO or more full-time workers give employees 60 days notice in advance of plant closings and mass layoffs if they:
- Close a facility of 50 or more workers
- Discontinue an operating unit of 50 or more workers
- Lay off 50 to 499 workers, and these layoffs constitute 33% of the total work force at a single employment site
- Lay off 500 or more workers at a single employment site

**NOTE:** There are ways to hide this information. For example, large companies can go by multiple names, or post the notice in a different state or not post a notice at all. 

| State Lookup | How To use |
|--------------|------------|
| [WarnTracker](https://warntracker.com) | This is a site that makes it easier to search for WARN notices | 
| [Arizona](https://www.azjobconnection.gov/search/warn_lookups/new) | Queries need to be exact. It is easier to just enter a start date and filter the data |
| [California](https://edd.ca.gov/en/jobs_and_training/layoff_services_warn) | Select "Listing of WARN Notices". Downloadable excel documents that list notices |
| [Colorado](https://cdle.colorado.gov/employers/layoff-separations/layoff-warn-list) | Select the "View Real Time Warns" button. It is a google doc. |


# Links
- [WarnTracker](https://warntracker.com) - WARN Aggregator
- [Layoffs.fyi](https://layoffs.fyi) - List of tech company layoffs
- [Trueup.io](https://trueup.io/layoffs) - Another tech layoff tracker
