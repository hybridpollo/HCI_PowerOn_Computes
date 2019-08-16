#!/usr/bin/env bash
# This script is used to bootstrap an ansible inventory
# for the undercloud baremetal nodes that are active in Ironic 
# used to set the base for the PowerOn/PowerOff Playbooks

# variables
UNDERCLOUD_RC="/home/stack/stackrc"
INVENTORY_OUTFILE="${PWD}/inventory"

# source the rc file before any interaction with the script
# require for the oscli client used in functions to work
source ${UNDERCLOUD_RC} 2>/dev/null  || echo -e "FAIL: Unable to source the undercloud rc file...stopping" 

# functions
function GetControllers() {
echo -e "Adding active controllers to inventory." 
cat <<EOF > ${INVENTORY_OUTFILE}
# controller group
[controllers]
$(openstack baremetal node list -c Name -c 'Instance UUID'  -c 'Power State' -c 'Provisioning State' -f value | awk '{ if( $1 ~ "controller" && $5 == "active") { print $2 }}' | while read bm_node_id ; do openstack server list -c ID -c Name -c Networks -f value | sed 's/ctlplane=/ansible_host=/g' | awk -v id=$bm_node_id '$0 ~ id { print $2, $3, "ansible_user=heat-admin" }' ; done) 
EOF
echo -e "Done adding controllers."
}

function GetComputes() {
echo -e "Adding active computes to inventory." 
cat <<EOF >> ${INVENTORY_OUTFILE}

# compute group
[computes]
$(openstack baremetal node list -c Name -c 'Instance UUID'  -c 'Power State' -c 'Provisioning State' -f value | awk '{ if( $1 ~ "compute" && $5 == "active") { print $2 }}' | while read bm_node_id ; do openstack server list -c ID -c Name -c Networks -f value | sed 's/ctlplane=/ansible_host=/g' | awk -v id=$bm_node_id '$0 ~ id { print $2, $3, "ansible_user=heat-admin" }' ; done) 
EOF
echo -e "Done adding computes."
}

if [ -e ${INVENTORY_OUTFILE} ]; then
  read -p "Inventory file: ${INVENTORY_OUTFILE} exists. File will be overwritten. Proceed: y/n? " ANS
  if [ ${ANS} == "y" ] || [ ${ANS} == "yes"]; then 
    rm ${INVENTORY_OUTFILE}
    echo -e "Generating inventory file.."
    GetControllers
    GetComputes
    echo -e "Inventory file: ${INVENTORY_OUTFILE} created."
  else
    echo -e "Existing the script at users request."
  fi 
else
  echo -e "Generating inventory file.."
  GetControllers
  GetComputes
  echo -e "Inventory file: ${INVENTORY_OUTFILE} created."
fi 
