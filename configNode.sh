#!/bin/sh

IPS=("192.168.1.3" "192.168.1.4" "192.168.1.5" "192.168.1.6" "192.168.1.7" "192.168.1.8" "192.168.1.8")
names=("bootstrap-0" "control-plane-0" "control-plane-1" "control-plane-2" "infra-0" "infra-1" "worker-0")
ignitions=("bootstrap" "master" "master" "master" "worker" "worker" "worker")
mask="255.255.255.0"
gateway="192.168.1.1"
dns1="192.168.1.1"
dns2="8.8.8.8"
domain="cluster2.poc.com"

i=0
for ip in "${IPS[@]}"; do

mkdir -p ../install/node-$i/etc/sysconfig/network-scripts/

cat <<EOF > ../install/node-$i/etc/sysconfig/network-scripts/ifcfg-ens192
DEVICE=ens192
BOOTPROTO=none
ONBOOT=yes
IPADDR=$ip
NETMASK=$mask
GATEWAY=$gateway
DNS1=$dns1
DNS2=$dns2
DOMAIN=$domain
DEFROUTE=yes
IPV6INIT=no
EOF
	
i=$(($i+1))
done	

i=0
for name in "${names[@]}"; do

hostname=$name.$domain
cat <<EOF > .../install/node-$i/etc/hostname
$hostname
EOF

i=$(($i+1))
done

i=0
for ignition in "${ignitions[@]}"; do

filetranspile -i ../install/$ignition.ign -f ../install/node-$i -o ../install/$ignition-$i.ign

if [ $i != 0 ]; then
base64 -w0 ../install/$ignition-$i.ign > ../install/$ignition-$i.64
fi


i=$(($i+1))
done	
