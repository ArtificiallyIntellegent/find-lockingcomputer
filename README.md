# Functionality
A multithreaded script that will
1. Query for all domain controllers listed in Active Directory
2. Connect to each controller and query Security logs for the given user and retrieve the Computer that is locking out the AD Account.

# Example
c:\>find-lockingcomputer.ps1 -username mjake
   
# Dependencies
1. Active Directory Module for Powershell
2. Run the script with the account that has access to retrieve Security Logs from Domain Controllers
3. Domain Controllers WinRM connectivity enabled   
