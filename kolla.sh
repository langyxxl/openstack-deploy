#!/bin/bash
cat >/etc/apt/sources.list <<EOF
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse
# deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
EOF

mkdir /root/.pip
cat >/root/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.douban.com/simple/
[install]
trusted-host = pypi.douban.com
EOF

ip=`hostname -I | awk '{print $1}'`
nic=`ip r |grep default |awk '{print $5}'`
ip link add link $nic name eth1 type macvlan

apt update
apt install -y python-dev libffi-dev gcc libssl-dev python-selinux python-setuptools python-pip ansible
pip install -U pip
hash -d pip
pip install kolla-ansible
mkdir -p /etc/kolla
cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp /usr/local/share/kolla-ansible/ansible/inventory/* .
kolla-genpwd
cat >>/etc/kolla/globals.yml <<EOF
openstack_release: "stein"
network_interface: "$nic"
enable_haproxy: "no"
enable_heat: "no"
enable_fluentd: "no"
openstack_service_workers: 1
openstack_service_rpc_workers: 1
EOF

sed -i s/kolla_internal_vip_address\.\*/kolla_internal_vip_address:\ \"$ip\"/ /etc/kolla/globals.yml
mkdir /etc/kolla/config/nova
cat << EOF > /etc/kolla/config/nova/nova-compute.conf
[libvirt]
virt_type=qemu
EOF

kolla-ansible -i ./all-in-one bootstrap-servers
sed -i /127.0.1/d /etc/hosts
kolla-ansible -i ./all-in-one prechecks
kolla-ansible -i ./all-in-one deploy
