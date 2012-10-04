#!/bin/sh
# original here: http://managingosx.wordpress.com/2008/02/07/mcx-dslocal-and-leopard/
# All credit to Greg Neagle for allowing Lion updates to be integrated as well
# This script detects changes in the MAC address of the computer it runs on and modifies the computer record in MCX accordingly
# Additionally, if MCX management varies between laptops and desktops, it only updates the applicable record and removes the other 
# set -x
changedMCX=false

# get the major OS version, we need it a few places later
# 9 = Leopard
# 10 = Snow Leopard
# 11 = Lion
# 12 = Mountain Lion
OSVERS=`/usr/bin/uname -r | /usr/bin/cut -d'.' -f1`

# check what the currently-running computers MAC address is
macAddress=`/sbin/ifconfig en0 | /usr/bin/grep 'ether' | /usr/bin/sed "s/^[[:space:]]ether //"  | cut -f1 -d " "`
# identify if we're on a laptop, since it would therefore have "Book" in its model name
IS_LAPTOP=`/usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier" | grep "Book"`

if [ "$IS_LAPTOP" != "" ]; then
	computerRecordName=local_laptop
	otherRecordName=local_desktop
else
	computerRecordName=local_desktop
  otherRecordName=local_laptop
fi

# check what MAC address is currently stored in the computer record name
storedMacAddress=`/usr/bin/dscl /Local/MCX -read /Computers/$computerRecordName ENetAddress | cut -f2 -d " "`
if [ "$storedMacAddress" != "$macAddress" ] ; then
    echo "Updating MAC address for /Computers/$computerRecordName..."
    echo "was: $storedMacAddress"
    echo "now: $macAddress"
# shove in the right value for the right computer record
# Mountain Lion doesn't let us use dscl to write to the /Local/MCX node, 
# so we will update the raw plist with PlistBuddy
if [ "$OSVERS" -lt "11" ] ; then
    /usr/bin/dscl /Local/MCX -create /Computers/$computerRecordName ENetAddress $macAddress
    /usr/bin/dscl /Local/MCX -create /Computers/$computerRecordName comment "Auto-Created"
# prune the unused one
    /usr/bin/dscl /Local/MCX -delete /Computers/$otherRecordName ENetAddress
    changedMCX=true
else
    /usr/libexec/PlistBuddy -c "Delete :en_address: string" /private/var/db/dslocal/nodes/MCX/computers/$computerRecordName.plist
    /usr/libexec/PlistBuddy -c "Add :en_address: string $macAddress" /private/var/db/dslocal/nodes/MCX/computers/$computerRecordName.plist
fi

fi

storedHardwareUUID=`/usr/bin/dscl /Local/MCX -read /Computers/$computerRecordName hardwareuuid | cut -f2 -d " "`
thisHardwareUUID=`/usr/sbin/system_profiler SPHardwareDataType | grep "Hardware UUID:" | cut -d":" -f2 | cut -d " " -f2`
if [ "$storedHardwareUUID" != "$thisHardwareUUID" ] ; then
        echo "Updating Hardware UUID for /Computers/$computerRecordName..."
        echo "was: $storedHardwareUUID"
        echo "now: $thisHardwareUUID"
    if [ "$OSVERS" -lt "11" ] ; then
        if [ "$thisHardwareUUID" ] ; then
                /usr/bin/dscl /Local/MCX -create /Computers/$computerRecordName hardwareuuid "$thisHardwareUUID"
            else
            /usr/bin/dscl /Local/MCX -delete /Computers/$computerRecordName hardwareuuid
        fi
            /usr/bin/dscl /Local/MCX -delete /Computers/$otherRecordName hardwareuuid
        changedMCX=true
    else
        /usr/libexec/PlistBuddy -c "Delete :hardwareuuid: string" /private/var/db/dslocal/nodes/MCX/computers/$computerRecordName.plist
        /usr/libexec/PlistBuddy -c "Add :hardwareuuid: string $thisHardwareUUID" /private/var/db/dslocal/nodes/MCX/computers/$computerRecordName.plist
    fi
fi

if [ "$changedMCX" == "true" ] ; then
    echo "MCX settings were changed."
    if [ -x "/usr/bin/mcxrefresh" ]; then
        /usr/bin/mcxrefresh -n nobody
    fi
fi

# unload so we only run once, but pieces are still present if en0 changes
/bin/launchctl unload /Library/LaunchDaemons/com.afp548.localMCX-fixMACaddy.plist

exit 0