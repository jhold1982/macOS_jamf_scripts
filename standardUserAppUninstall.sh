#!/bin/bash
#################################################################################
#
# Remove Application Script for Jamf Pro
#
# Purpose: Thoroughly removes macOS applications by terminating processes and 
# deleting application files. Supports both sandboxed and non-sandboxed apps
# located in the /Applications directory. Also cleans up package receipts.
#
# Parameters:
#   $4 - Application name to be removed (required)
#   $5+ - Optional package identifiers to forget from package database
#
# Usage Examples:
#   Basic: jamf policy -event remove-app -p "Firefox"
#   With package cleanup: jamf policy -event remove-app -p "Microsoft Word" "com.microsoft.word"
#
#################################################################################

# Store the application name from the 4th parameter passed to the script
appName="$4"

# Function to gracefully terminate an application before removal
function silent_app_quit() {
    # Parameter $1 contains the application name to be terminated
    appName="$1"
    
    # Check if the application is currently running using case-insensitive, exact match
    if [[ $(pgrep -ix "$appName") ]]; then
    	echo "Closing $appName"
    	
    	# Attempt graceful termination using AppleScript
    	/usr/bin/osascript -e "quit app \"$appName\""
    	sleep 1
    	
    	# Verify application termination with timeout mechanism
    	# Will attempt for up to 10 seconds before forcing termination
    	countUp=0
    	while [[ $countUp -le 10 ]]; do
    		# Check if the process has terminated
    		if [[ -z $(pgrep -ix "$appName") ]]; then
    			echo "$appName closed."
    			break
    		else
    			# Increment counter and wait before next check
    			let countUp=$countUp+1
    			sleep 1
    		fi
    	done
    	
    	# If application still running after timeout, use pkill for forced termination
        if [[ $(pgrep -x "$appName") ]]; then
    	    echo "$appName failed to quit - killing."
    	    /usr/bin/pkill "$appName"
        fi
    fi
}

# Validate required parameter - exit if no application name provided
if [[ -z "${appName}" ]]; then
    echo "No application specified!"
    exit 1
fi

# Terminate the application if it's currently running
silent_app_quit "$appName"

# Prepare for application removal
echo "Removing application: ${appName}"

# Ensure application name has .app extension for proper path handling
# This accommodates shorthand inputs like "Firefox" instead of "Firefox.app"
if [[ ! $appName == *".app"* ]]; then
	appName=$appName".app"
fi

# Construct the full path to the application
# If a path is already provided (contains slash), use it as-is
# Otherwise, assume application is in the standard /Applications directory
if [[ ! $appName == *"/"* ]]; then
	appToDelete="/Applications/$appName"
else
	appToDelete="$appName"
fi

# Execute the actual removal of the application bundle
# Using rm -rf to recursively and forcefully remove all application files
/bin/rm -rf "${appToDelete}"

# Clean up package receipts from the system database
# This prevents package system conflicts and enables clean reinstallation if needed
# Loop through all remaining parameters (from $5 onward) as potential package identifiers
for package in "${@:5}"; do
    if [[ ${package} ]]; then
        # Search for package receipts matching the provided identifier (case-insensitive)
        # Then forget each matching package using pkgutil
        /usr/sbin/pkgutil --pkgs | /usr/bin/grep -i "${package}" | /usr/bin/xargs /usr/bin/sudo /usr/sbin/pkgutil --forget
    fi
done
