## Overview

This repository contains a set of Bash scripts and Ansible playbooks to assist with the process of bringing up an Openstack compute nodes after a power outage in a Red Hat OpenStack 13 Hyper-converged Environment.



## Background

The Red Hat OpenStack Platform implementation of hyper-converged infrastructures (HCI) uses Red Hat Ceph Storage as a storage provider. This infrastructure features hyper-converged nodes, where Compute and Ceph Storage services are co-located and configured for optimized resource usage.

A power outage without any redudant infrastructure is a catastrophic event that may
lead into loss of data on traditional computing systems. This is also true on complex, distributed private cloud platforms such as the Red Hat OpenStack Platform. It gets slightly more complex when you have a Hyper-converged system where the already complex cloud operating system is also serving as a software defined storage cluster such as the case in Ceph as the storage product in the OSP13 HCI product.



## Key Scripts

build_ansible_inventory.sh - Used to build the inventory for the entire environment.
ipmi_actions.sh - Used to perform ipmi actions such as poweron or poweroff of the
devices referenced in the script.





## How to use


![Power On Computes flowchart](https://github.com/hybridpollo/HCI_PowerOn_Computes/blob/master/HCI_Compute_PowerOn.png)


## Limitations


## References
