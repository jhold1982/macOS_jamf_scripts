#!/bin/bash 

# macOS script for JAMF to check for software updates and restart mac

# Check for updates using JAMF Binary
updates=$(/usr/local/bin/jamf checkJSSUpdates -restart)

# If updates are available, install then restart mac
if [ "$updates" = "available" ]; then
/usr/local/bin/jamf policy -event checkJSSUpdates
/usr/local/bin/jamf restart -now
fi


# To use this script, 
# you will need to save it to a file on the Mac 
# and make it executable by running the following command:

# chmod +x /path/to/script.sh



# You can then run the script by calling it from the command line:

# /path/to/script.sh



# You can also schedule the script to run at regular intervals using a tool like cron, 
# which allows you to specify when the script should be run. For example, 
# you could add the following line to your crontab to run the script every day at 6:00am:

# 0 6 * * * /path/to/script.sh


