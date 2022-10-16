#!/bin/bash

# To run: mac_wipri "SSID"
# Wrap the SSID in double quotes.
# Requires sudo/administrative rights

if [ -z "$1" ]; then
    echo "No SSID name supplied. Exiting.";
    exit;
fi

SSIDNAME=$1

NETFILE="/Library/Preferences/\
SystemConfiguration/com.apple.airport.preferences.plist"

#Get SSID for desired network
SSIDID=`xpath $NETFILE "\
(//dict/dict/dict/string[text()='$SSIDNAME'])\
[1]/parent::dict/preceding-sibling::key[1]" \
2>/dev/null | sed -e 's/key/string/g'`

# Make sure the desired SSID exists in the list.
if [ -z "$SSIDID" ]; then
 echo "No matching SSID value can be found in $NETFILE. Exiting.";
 exit;
fi;

# Get the current preferred network list
ORDERLIST=`xpath $NETFILE "(//dict/key[text()='PreferredOrder'])\
[1]/following-sibling::array[1]" 2>/dev/null | sed '1d;$d'`

# Count number of current entries in the network list
NUMENTRIES=`echo "$ORDERLIST" | wc -l | sed -e 's/ //g'`
echo "There are $NUMENTRIES entries in preferred network list."

# Don't make changes if it's the only network
if [ "$NUMENTRIES" -le "1" ]; then
 echo "Only one network, so no need to make priority changes. Exiting.";
 exit;
fi;

# Get the row number for the first preferred network entry
PREFTOP=`/usr/bin/grep -n -x "$ORDERLIST" $NETFILE | \
cut -f1 -d: | head -n 1`
echo "Preferred network list starts at row $PREFTOP in $NETFILE."

# Get the row number of network we want to set as highest priority
SSIDTOMOVE=`echo "$ORDERLIST" | /usr/bin/grep -n $SSIDID | cut -f1 -d:`
if [ "$SSIDTOMOVE" -eq "1" ]; then
   echo "$SSIDNAME is already top of the priority list. Exiting.";
   exit;
fi

# Print the SSID and current row number for the entry
echo "$SSIDNAME is position number $SSIDTOMOVE in preferred ordering list."

# Now actually make the changes to the file
echo "Moving $SSIDNAME to top of preferred network list..."
printf %s\\n $(( PREFTOP - 1 + SSIDTOMOVE ))m$(( PREFTOP - 1)) w q \
| ed -s $NETFILE

# With knowledge of the starting row you could add additional networks
# and handle relative priorities for additional networks if desired.

# Verify that the change worked by checking current position in list
ORDERLIST=`xpath $NETFILE "(//dict/key[text()='PreferredOrder'])\
[1]/following-sibling::array[1]" 2>/dev/null | sed '1d;$d'`
NEWLOCATION=`echo "$ORDERLIST" | /usr/bin/grep -n $SSIDID | cut -f1 -d:`
echo "$SSIDNAME is now at position number $NEWLOCATION in preferred network list"
done