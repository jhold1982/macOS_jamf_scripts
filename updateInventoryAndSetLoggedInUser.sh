#!/bin/bash 

loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")


/usr/local/bin/jamf recon -endUsername "$loggedInUser"@yourCompanyEmail.com


exit 0