#!/usr/bin/bash
# *********************************************************
# * script to detect long-running UoWs                    *
# * Check for those older than 2 minutes (120 seconds)    *
# * If you want to look for the long UoWs, then you need  *
# * to compare the two fields UOWLOGDA and UOWLOGTI with  *
# * the current time to see how long they are.            *
# *********************************************************
#
# See if we were passed a Queue Manager name
if [ "$1" != "" ]; then
    echo "Positional parameter 1:QMGR Name 1 contains $1"
    qmgr="$1"
else
    echo "Positional parameter 1:QMGR Name is empty"
    exit 0
fi

# See if we were passed a time limit in seconds
if [ "$2" != "" ]; then
    echo "Positional parameter 2:LUW Length Seconds 2 contains $2"
    seconds=$2
else
    echo "Positional parameter 1:LUW Length Seconds is empty. Will default to 120 seconds"
    seconds=120
fi

# Switches

countUoW=0
countlimit=1
DA=0
TI=0
PID=0
APPL=0

# Search Literals

lit_uowlogda="UOWLOGDA"
lit_uowlogti="UOWLOGTI"
lit_pid="PID"
lit_appltag="APPLTAG"

# Set the runmqsc display command
discmd="DISPLAY CONN(*) UOWLOGDA UOWLOGTI PID APPLTAG WHERE(UOWLOGTI NE ' ')"

# Run the command and pipe the utput to a file
echo $discmd | runmqsc $qmgr > /tmp/runmqsc.out

# Make the output file useable
chmod ugo+rwx /tmp/runmqsc.out

# lets loop through the output file 
while read p; do

# Bypass first line of report
if [ `echo $p | grep -c "DISPLAY" ` -gt 0 ]
   then
     p=" "
fi

# Lets look for UOWLOGDA parameter
if [ `echo $p | grep -c "UOWLOGDA" ` -gt 0 ]
   then
# Have we saw the UOWLOGDA parameter before reporting, yes, we have an issue   	   
       if [ "$DA" = 1 ]
          then
            echo "WE have an order issue on input"
            echo "Input line = "
            echo "$p"
            echo "ending execution"
            exit 1
       fi
# indicate we have the LOGDA parameter       
       DA=1
# Find the position of UOWLOGDA and go after the date
       position=`awk -v a="$p" -v b="$lit_uowlogda" 'BEGIN{print index(a,b)}'` 
       position="$((position+8))"
       uowlogda="${p:$position:10}"

fi

# Lets look for the UOWLOGTI parameter
if [ `echo $p | grep -c "UOWLOGTI" ` -gt 0 ]
   then
# Indicate we have found it
     TI=1
# Lets extract the time and format it
     position=`awk -v a="$p" -v b="$lit_uowlogti" 'BEGIN{print index(a,b)}'` 
     position="$((position+8))"
     uowlogti="${p:$position:8}"
     uowlogti=`echo $uowlogti | sed 's/\./\:/g'`
fi

# Lets look for the PID parameter
if [ `echo $p | grep -c "PID" ` -gt 0 ]
   then
# indicate we have found it   	
     PID=1
# Let extract the value for PID
# is it at the beginning of the line or a second parameter on the same line     
     position=`awk -v a="$p" -v b="$lit_pid" 'BEGIN{print index(a,b)}'` 
     if [ "$position" -lt 8 ] 
        then
# First parameter
          uowlogpid=`echo "$p"| awk -F'(' '{print $2}' | awk -F')' '{print $1}' `
        else
# Second parameter        
          uowlogpid=`echo "$p"| awk -F'(' '{print $3}' | awk -F')' '{print $1}' `
     fi
fi

# Lets extract APPLTAG
if [ `echo $p | grep -c "APPLTAG" ` -gt 0 ]
   then
# we found it, lets indicate that   	
     APPL=1
# Let extract the value for PID
# is it at the beginning of the line or a second parameter on the same line
     position=`awk -v a="$p" -v b="$lit_appltag" 'BEGIN{print index(a,b)}'` 
     if [ "$position" -lt 8 ] 
        then
# First parameter
          uowlogappltag=`echo "$p"| awk -F'(' '{print $2}' | awk -F')' '{print $1}' `
        else
# Second parameter
          uowlogappltag=`echo "$p"| awk -F'(' '{print $3}' | awk -F')' '{print $1}' `
     fi
#     echo "uowlogappltag = $uowlogappltag"
fi

# Have all 4 fields been found
if [ "$DA" = 1 ] && [ "$TI" = 1 ] && [ "$PID" = 1 ] && [ "$APPL" = 1 ]
   then
# They have been found, turn them off so we can get the next one after this
     DA=0
     TI=0
     PID=0
     APPL=0
# Calculate the current date and time in EPOC time
     E1=$(date +%'s')
     sp=" "
Concat Date and Time
     E2date=$uowlogda$sp$uowlogti
# Calculate the UOW date and time in EPOC seconds
     E2=$(date -d "$E2date" +%s)
# Calculate the UOW age in seconds
     uowage=$(($E1 - E2))
# Is the UOW time longer than our set threshold (defaults to 120 seconds)
     if [ $uowage -gt $seconds ]
        then
          countUoW=$((countUoW+1))
          echo "Long-running UoW ("$uowage seconds, PID=$uowlogpid , APPLTAG=$uowlogappltag")"
     fi
fi

done < /tmp/runmqsc.out

if [ $countUoW -lt $countlimit ]
   then
   echo "No long-running UoW older than", $seconds, "seconds"
fi 