#!/bin/sh

# first stop any cosmosex process (script or app)
/ce/ce_stop.sh

echo " "
echo "Updating CosmosEx from internet, this will take a while."
echo "DO NOT POWER OFF THE DEVICE!!!"
echo " "

# download changes from repo
git pull

# update xilinx
/ce/update/update_xilinx.sh

# update hans
/ce/update/update_hans.sh

# update franz
/ce/update/update_franz.sh

#--------------
# check if it's now HW vs FW mismatch, which might need another Xilinx flashing
out=$( /ce/app/cosmosex hwinfo )
mm=$( echo "$out" | grep 'HWFWMM' )

# if MISMATCH detected, flash xilinx again -- without programmed Hans the HW reporting from app could be wrong, and thus this one is needed to fix the situation
if [ "$mm" = "HWFWMM: MISMATCH" ]; then
    /ce/update/update_xilinx.sh
fi 
#--------------

sync

echo " "
echo "Update done, you may start the /ce/ce_start.sh now!";
echo " "
