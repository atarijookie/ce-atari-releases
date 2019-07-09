#!/bin/sh
# Franz FW update

echo "----------------------------------"
echo " "
echo ">>> Updating Franz - START"

if [ ! -f /tmp/franz.hex ]; then            # if this file doesn't exist, try to extract it from ZIP package
    if [ -f /tmp/ce_update.zip ]; then      # got the ZIP package, unzip
        unzip -o /tmp/ce_update.zip -d /tmp
    else                                    # no ZIP package? damn!
        echo "/tmp/franz.hex and /tmp/ce_update.zip don't exist, can't update!"
        exit
    fi
fi

#----------------------------------------
# if symlink serial0 exists, use it, otherwise try to use ttyAMA0
if [ -f /dev/serial0 ]; then
    serialport="/dev/serial0"
else
    serialport="/dev/ttyAMA0"
fi

echo "Will use serial port: " $serialport
#----------------------------------------

/ce/update/flash_stm32 -y -w /tmp/franz.hex $serialport
rm -f /tmp/franz.hex

echo " "
echo ">>> Updating Franz - END"
echo "----------------------------------"

