#!/bin/sh 

#
# You can use it as follows:
#   - ce start  -- start all services
#   - ce stop   -- stop all services
#   - ce status -- get the status of all services
#

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

get_setting_from_file()
{
    # Get one setting from .cfg file
    # $1 - config variable name, e.g. PID_FILE
    # $2 - path to config file of the service

    cat $2 | grep "$1=" | cut -d "=" -f 2
}

handle_service()
{
    # Function handles start/stop/status of service.
    # $1 - command - start | stop | status
    # $2 - path to config file of the service

    pid_file=$( get_setting_from_file PID_FILE $2 )
    exec_file=$( get_setting_from_file EXEC_FILE $2 )
    
    # now always check first if the app is running
    app_running=$( check_if_pid_running $pid_file )

    service_dir=$( dirname $2 )
    service_name=$( basename $service_dir )

    # should just report status?
    if [ "$1" = "status" ]; then
        if [ "$app_running" = "1" ]; then
            printf "    %-20s [RUNNING]\n" "$service_name"
        else
            printf "    %-20s [STOPPED]\n" "$service_name"
        fi
    fi

    # should start?
    if [ "$1" = "start" ]; then
        if [ "$app_running" != "1" ]; then          # not running? start
            echo "Starting service $service_name"
            dir_before=$( pwd )                     # remember current dir
            cd $service_dir                         # change to service dir
            eval "$exec_file > /dev/null 2>&1 &"    # start the executable file / script file
            cd $dir_before                          # go back to previous dir
        fi
    fi

    # should stop?
    if [ "$1" = "stop" ]; then
        if [ "$app_running" = "1" ]; then       # is running? stop
            echo "Stopping service $service_name"
            app_pid_number=$( cat $pid_file 2> /dev/null )
            kill -9 "$app_pid_number" > /dev/null 2>&1
        fi
    fi
}

# go through all the service config files and start / stop / status those services
echo ""
echo "CosmosEx services:"

for found in /ce/services/*
do
    if [ -d "$found" ]; then            # if found thing is a dir
        path_cfg="$found/service.cfg"   # construct path to service config file

        if [ -f "$path_cfg" ]; then     # if service config file exists
            handle_service $1 $path_cfg
        fi
    fi
done

echo ""
