#!/usr/bin/env bash
# This script is used to perform 
# a cluster poweroff using ipmitool

# baremetal nodes ips from node registration file
# Used as reference only 
#controller-0 => 10.69.25.10
#controller-1 => 10.69.25.11
#computeHCI-0 => 10.69.25.14
#computeHCI-1 => 10.69.25.15
#computeHCI-2 => 10.69.25.16
#computeHCI-3 => 10.69.25.17
#computeHCI-4 => 10.69.25.18
#computeHCI-5 => 10.69.25.19

function readInput() {
  read -s -p "Enter the ipmi password: " ipmi_pass
}

function nodeStatus() {
  for node in 10 11 {13..19} ; do
     echo -n "Host:10.69.25.${node} => "
    /usr/bin/ipmitool -I lanplus -U root -P $ipmi_pass -H 10.69.25.${node} chassis power status
  done
}

function nodePowerOff() {
  for node in 10 11 {13..19} ; do
     echo -n "Host:10.69.25.${node} => "
    /usr/bin/ipmitool -I lanplus -U root -P $ipmi_pass -H 10.69.25.${node} chassis power off
  done
}

function nodePowerOn() {
  for node in 10 11 {13..19} ; do
    /usr/bin/ipmitool -I lanplus -U root -P $ipmi_pass -H 10.69.25.${node} chassis power on
  done
}


function printHelp() {
cat <<EOF 
Script: $(basename ${0}) is used to power-off pre-defined ipmi hosts. 

Example usage:
  $(basename ${0}) status   - Displays power status of host using ipmi.
  $(basename ${0}) poweroff - Power off the host using ipmi.
  $(basename ${0}) poweron  - Power on the host using ipmi.

Note: The script will prompt for the ipmi password which assumes
you are using the same ipmi password for all hosts. Modify to fit your
needs.
EOF
}

case "$1" in 
  status)
      readInput ; nodeStatus
      ;;
  poweroff)
      readInput ; nodePowerOff
      ;;
  poweron)
      readInput ; nodePowerOn
      ;;
  *)
      printHelp
      ;;
esac
