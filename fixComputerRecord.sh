#!/bin/sh
# original here: http://managingosx.wordpress.com/2008/02/07/mcx-dslocal-and-leopard/
# All credit to Greg Neagle for allowing Lion updates to be integrated as well
# This script detects changes in the MAC address of the computer it runs on and modifies the computer record in MCX accordingly
# Additionally, if MCX management varies between laptops and desktops, it only updates the applicable record and removes the other 

# First, declare computer record GUIDs, since management keys off of it
local_desktop_GUID="DD24623B-37E9-48EE-A726-D2F284921882"
local_laptop_GUID="63A0C4D0-C3B6-486F-997F-4F9D68DEFAA8"

changedMCX=false

# Verify GUID declared above is present in computer records on disk
current_local_desktop_GUID=`/usr/bin/dscl /Local/MCX -read /Computers/local_desktop GeneratedUID | cut -f2 -d " "`
current_local_laptop_GUID=`/usr/bin/dscl /Local/MCX -read /Computers/local_laptop GeneratedUID | cut -f2 -d " "`
# If they aren't, fix and refresh
if [ "$current_local_desktop_GUID" != "$local_desktop_GUID" ] ; then
    echo "Updating GUID for /Computers/local_desktop..."
    echo "was: $current_local_desktop_GUID"
    echo "now: $local_desktop_GUID"
    /usr/bin/dscl /Local/MCX -create /Computers/local_desktop GeneratedUID $local_desktop_GUID
    changedMCX=true
fi
if [ "$current_local_laptop_GUID" != "$local_laptop_GUID" ] ; then  
    echo "Updating GUID for /Computers/local_laptop..."
        echo "was: $current_local_laptop_GUID"
        echo "now: $local_laptop_GUID"
    /usr/bin/dscl /Local/MCX -create /Computers/local_laptop GeneratedUID $local_laptop_GUID
    changedMCX=true
fi

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
    /usr/bin/dscl /Local/MCX -create /Computers/$computerRecordName ENetAddress $macAddress
    /usr/bin/dscl /Local/MCX -create /Computers/$computerRecordName comment "Auto-Created"
# prune the unused one
    /usr/bin/dscl /Local/MCX -delete /Computers/$otherRecordName ENetAddress
    changedMCX=true
fi

storedHardwareUUID=`/usr/bin/dscl /Local/MCX -read /Computers/$computerRecordName hardwareuuid | cut -f2 -d " "`
thisHardwareUUID=`/usr/sbin/system_profiler SPHardwareDataType | grep "Hardware UUID:" | cut -d":" -f2 | cut -d " " -f2`
if [ "$storedHardwareUUID" != "$thisHardwareUUID" ] ; then
        echo "Updating Hardware UUID for /Computers/$computerRecordName..."
        echo "was: $storedHardwareUUID"
        echo "now: $thisHardwareUUID"
    if [ "$thisHardwareUUID" ] ; then
            /usr/bin/dscl /Local/MCX -create /Computers/$computerRecordName hardwareuuid "$thisHardwareUUID"
        else
        /usr/bin/dscl /Local/MCX -delete /Computers/$computerRecordName hardwareuuid
    fi
        /usr/bin/dscl /Local/MCX -delete /Computers/$otherRecordName hardwareuuid
    changedMCX=true
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