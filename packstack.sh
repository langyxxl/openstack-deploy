yum install -y centos-release-openstack-stein
yum update -y
yum install -y openstack-packstack

packstack --allinone --os-cinder-install=n --os-swift-install=n --os-ceilometer-install=n \
	--os-aodh-install=n --os-neutron-metering-agent-install=n \
	--os-neutron-ml2-mechanism-drivers=openvswitch  --os-neutron-l2-agent=openvswitch \
	--service-workers=1 --os-heat-cfn-install=n

