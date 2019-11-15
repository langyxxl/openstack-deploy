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

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh
useradd -s /bin/bash -d /opt/stack -m stack
passwd stack <<EOF
321
321
EOF
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

su - stack -c 'mkdir .pip'
cp /root/.pip/pip.conf /opt/stack/.pip/pip.conf
chown stack:stack /opt/stack/.pip/pip.conf
su - stack -c 'git clone http://git.trystack.cn/openstack/devstack'
su - stack -c 'cd devstack; git checkout -b stein origin/stable/stein'
su - stack -c 'sed -i "/add-apt-repository -y universe/s/^/#/" devstack/tools/fixup_stuff.sh'

cat  > /opt/stack/devstack/local.conf <<EOF
[[local|localrc]]
ADMIN_PASSWORD=321
DATABASE_PASSWORD=\$ADMIN_PASSWORD
RABBIT_PASSWORD=\$ADMIN_PASSWORD
SERVICE_PASSWORD=\$ADMIN_PASSWORD
LOGFILE=\$DEST/logs/stack.sh.log
LOGDAYS=2
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
SWIFT_REPLICAS=1
SWIFT_DATA_DIR=$DEST/data
GIT_BASE=http://git.trystack.cn
#GLANCE_REPO=https://git.openstack.org/openstack/glance.git
NOVNC_REPO=http://git.trystack.cn/kanaka/noVNC.git
SPICE_REPO=http://git.trystack.cn/git/spice/spice-html5.git
DOWNLOAD_DEFAULT_IMAGES=false
disable_service tempest
disable_service cinder
disable_service etcd3
LOG_COLOR=False
OVS_PHYSICAL_BRIDGE=br-ex
PUBLIC_BRIDGE=br-ex
OVS_BRIDGE_MAPPINGS=public:br-ex
API_WORKERS=1
EOF

chown stack:stack /opt/stack/devstack/local.conf

su - stack -c "screen -dm -S devstack /opt/stack/devstack/stack.sh"
