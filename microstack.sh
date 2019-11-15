#!/bin/bash

snap install microstack --edge --classic
PATH=$PATH:/snap/bin
sed -i 's/workers = 4/workers = 1/' /var/snap/microstack/common/etc/nova/nova.conf.d/workers.conf
sed -i 's/workers = 4/workers = 1/' /var/snap/microstack/common/etc/neutron/neutron.conf.d/workers.conf
sed -i 's/virt_type = kvm/virt_type = qemu/' /var/snap/microstack/common/etc/nova/nova.conf.d/hypervisor.conf
sed -i 's/cpu_mode = host-passthrough/cpu_mode = host-model/' /var/snap/microstack/common/etc/nova/nova.conf.d/hypervisor.conf
microstack.init --auto

