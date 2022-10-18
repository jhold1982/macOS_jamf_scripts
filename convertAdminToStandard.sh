#!/bin/bash


# JAMF parameter "Target Account"
targetAccount="$4"


function check_jamf_pro_arguments {
  if [ -z "$targetAcccount" ]; then
    echo "X ERROR: Undefined JAMF Pro argument."
    exit 74
  fi
}


check_jamf_pro_arguments


if /usr/bin/dscl . -read "/groups/admin" GroupMembership | /usr/bin/grep -q "$targetAccount"; then
  /usr/sbin/dseditgroup -o edit -d "$targetAccount" admin
  echo "Changed $targetAccount to standard user."
else
  echo "$targetAcount is already a standard user."
fi



exit 0
