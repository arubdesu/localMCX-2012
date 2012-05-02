#!/bin/sh
# original here: http://managingosx.wordpress.com/2010/03/12/yet-again-with-the-local-mcx/
# 
# first make sure /Local/MCX node exists
if [ ! -d "/private/var/db/dslocal/nodes/MCX" ] ; then
	echo "Missing /Local/MCX node!"
	exit 0
fi

# does DirectoryService/opendirectoryd know about the
# /Local/MCX node?
output=`/usr/bin/dscl /Local/MCX list /`
if [ "$?" -ne "0" ]; then
    # non-zero return code from dscl
    # hopefully because we just created the node and 
    # DirectoryService/opendirectoryd doesn't know about it yet
    # so kill DirectoryService/opendirectoryd
    # they restart automatically and check for new nodes
    osvers=`/usr/bin/uname -r | /usr/bin/cut -d'.' -f1`
    if [ "$osvers" -gt "9" ] ; then
        /usr/bin/killall opendirectoryd
    else
        /usr/bin/killall DirectoryService
    fi
    # check with dscl again and fail if we can't access the /Local/MCX node
    output=`/usr/bin/dscl /Local/MCX list /`
    if [ "$?" -ne "0" ] ; then
        echo "/Local/MCX node not accessible!"
        exit 0
    fi
fi

# now test if /Local/MCX is already in the search path, after /Local/Default and /BSD/local
localMCXinSearchPath=`/usr/bin/dscl /Search read / CSPSearchPath | /usr/bin/grep "/Local/MCX"`
if [ "$localMCXinSearchPath" == "" ] ; then
# NOTE: the following may fail if Active Directory is last in the search path, since there's a space in the name.  I'm currently working on a permanent solution.
  currentSearchPathContainsBSDlocal=`/usr/bin/dscl /Search read / CSPSearchPath | /usr/bin/grep "/BSD/local"`
  if [ "$currentSearchPathContainsBSDlocal" != "" ] ; then
      currentSearchPathBegin="/Local/Default /BSD/local"
      currentSearchPathEnd=`/usr/bin/dscl /Search read / CSPSearchPath | /usr/bin/cut -d" " -f4-`
  else
      currentSearchPathBegin="/Local/Default"
      currentSearchPathEnd=`/usr/bin/dscl /Search read / CSPSearchPath | /usr/bin/cut -d" " -f3-`
  fi
      /usr/bin/dscl /Search create / SearchPolicy CSPSearchPath
      /usr/bin/dscl /Search create / CSPSearchPath $currentSearchPathBegin /Local/MCX $currentSearchPathEnd

# unload so we only run once
/bin/launchctl unload /Library/LaunchDaemons/com.afp548.LocalMCX-fixSearchPath.plist

fi

exit 0