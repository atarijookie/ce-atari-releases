#!/bin/sh

#
# This is a shell script for a service. The name 'service.sh' is intentional,
# so the main runner script can find it according to the name. 
#
# You can use it as follows:
#   - service start  -- to start this service (runs quickly, because it will run the exec detached)
#   - service stop   -- to stop this service (runs quickly, because it just calls kill)
#   - service status -- to get the status of the service - running on stopped (runs quickly, because just looks for PID)
#

####################################################################
# dirs and files definitions - if done correctly, you need to 
# change only these few lines to adapt this file to another service.

VAR_DIR="/var/run/ce"
PID_FILE_APP="$VAR_DIR/mount.pid"               # PID file of the app this service manages
EXEC_FILE="./ce_mounter.sh"

####################################################################

mkdir -p "$VAR_DIR"                             # create var dir if not exists

# check if running as root
if [ $(id -u) != 0 ]; then
  echo "Please run this as root"
  exit 1
fi

# check if one of the supported commands was supplied
if [ "$1" != "status" ] && [ "$1" != "start" ] && [ "$1" != "stop" ]; then
  echo "Please specify only valid commands: start | stop | status"
  exit 1
fi

####################################################################
# Starting or stopping of the service might take longer time, 
# so we want to make sure only one copy of this script is running.

check_if_pid_running()
{
    # Function checks if the supplied PID from file in $1 is running.

    pid_number=$( cat $1 2> /dev/null )    # get previous PID from file if possible
    found=$( ps -A | grep "$pid_number" | wc -l )       # this will return 1 on PID exists and 0 or total_number_of_processes when PID doesn't exist

    if [ "$found" = "1" ]; then     # found? report 1
        echo "1"
    else                            # not found? report 0
        echo "0"
    fi
}

####################################################################

# now always check first if the app is running
app_running=$( check_if_pid_running $PID_FILE_APP )

# should just report status?
if [ "$1" = "status" ]; then
    echo "$app_running"
    exit $app_running
fi

# should start?
if [ "$1" = "start" ]; then
    if [ "$app_running" != "1" ]; then      # not running? start
        echo "Starting service"
        eval "$EXEC_FILE > /dev/null 2>&1 &"
    else                                    # is running? just warn
        echo "Service is running, so not starting."
    fi
fi

# should stop?
if [ "$1" = "stop" ]; then
    if [ "$app_running" = "1" ]; then       # is running? stop
        echo "Stopping service"
        app_pid_number=$( cat $PID_FILE_APP 2> /dev/null )
        kill -9 "$app_pid_number" > /dev/null 2>&1
    else                                    # not running? just warn
        echo "Service not running, nothing to stop."
    fi
fi
