## Overview

This repository contains a set of Bash scripts and Ansible playbooks to assist with the process of bringing up an Openstack compute nodes after a power outage in a Red Hat OpenStack 13 Hyper-converged Environment.


![Power On Computes flowchart](https://github.com/hybridpollo/HCI_PowerOn_Computes/blob/master/HCI_Compute_PowerOn.png)


## Background

The Red Hat OpenStack Platform implementation of hyper-converged infrastructures (HCI) uses Red Hat Ceph Storage as a storage provider. This infrastructure features hyper-converged nodes, where Compute and Ceph Storage services are co-located and configured for optimized resource usage.

A power outage without any redudant infrastructure is a catastrophic event that may
lead into loss of data on traditional computing systems. This is also true on complex, distributed private cloud platforms such as the Red Hat OpenStack Platform. It gets slightly more complex when you have a Hyper-converged system where the already complex cloud operating system is also serving as a software defined storage cluster such as the case in Ceph as the storage product in the OSP13 HCI product.



## Scripts and Ansible Playbooks
`build_ansible_inventory.sh` - Used to build the initial inventory file to support
the rest of the Ansible playbooks. The script will add to the inventory file
every active baremetal node in the environment.


`poweroff_computes_hci.yml` - Used to power off all compute nodes. This
was created for convenience when testing the power on procedure. This is not a
graceful shutdown as it executes a 'power-off' action via Ironic.

`poweroff_controllers.yml` - Used to power off all controller nodes. This
was created for convenience when testing the power on procedure. This is not a
graceful shutdown as it executes a 'power-off' action via Ironic.

`poweron_controllers.yml`- Used to power on controllers.

`poweron_computes_hci.yml`- Used to power on controllers.


## Usage
The main feature of this repository is the `poweron_computes_hci.yml` playbooks
which will power on hosts in a Red Hat OpenStack Platform 13 Hyper-converged
environment in the event of the power outage. This playbook attempts the following:

- Verifies that all compute nodes are powered off. It will fail if partial power-failure
which at that point. Manual recovery of the affected computes is required.
- Verifies OpenStack control plane nodes are up and reachable.
- Verifies the Pacemaker cluster is online on controllers.
- Verifies the Ceph monitors on the controllers are in quorum.
- Powers on all compute nodes if all previous conditions are met.


## Limitations

*__Issue__*

Nova compute instances or virtual machines may not have access to the
Ceph storage immediately if using the auto-start feature in Nova.

*__Background__*

Red Hat OpenStack Platform 13 Hyper-converged environments by design collocates
the Compute service with Ceph OSDs on the same physical host. Both the OpenStack
services and Ceph OSDs are  containerized which depend on the docker service to be
started as you can see in the systemd-analyze output below:


```
[root@overcloud-computehci-er801hci-3 containers]# systemd-analyze critical-chain ceph-osd@15.service
The time after the unit is active or started is printed after the "@" character.
The time the unit takes to start is printed after the "+" character.

ceph-osd@15.service +77ms
└─docker.service @3min 55.060s +9.782s
  └─network.target @3min 53.316s
    └─openvswitch.service @3min 22.288s +40ms
      └─ovs-vswitchd.service @6.852s +3min 15.421s
        └─ovs-delete-transient-ports.service @6.689s +111ms
          └─ovsdb-server.service @5.882s +736ms
            └─basic.target @5.731s
              └─driverctl@pci-0000:af:00.1.service @2.287s +3.443s
                └─system-driverctl.slice @2.081s
                  └─system.slice
                    └─-.slice
```

As a result the last service to start in Hyper-converged nodes are the ceph-osd
services.

## References


How to properly shutdown a Red Hat OpenStack Platform Deployment: https://access.redhat.com/solutions/1977013
