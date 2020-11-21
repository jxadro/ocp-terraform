#!/bin/sh

HOSTS=("bootstrap-0_bootstrap_192.168.1.3" "control-plane-0_master_192.168.1.4" "control-plane-1_master_192.168.1.5" "control-plane-2_master_192.168.1.6" "infra-0_worker_192.168.1.7" "infra-1_worker_192.168.1.8" "worker-0_worker_192.168.1.9")
mask="255.255.255.0"
gateway="192.168.1.1"
dns1="192.168.1.2"
domain="cluster2.poc.com"


for host in "${HOSTS[@]}"; do

hname=$(echo $host | awk -F_ '{ print $1}')
htype=$(echo $host | awk -F_ '{ print $2}')
hip=$(echo $host | awk -F_ '{ print $3}')

mkdir -p ../install/$hname/etc/sysconfig/network-scripts/

cat <<EOF > ../install/$hname/etc/sysconfig/network-scripts/ifcfg-ens192
DEVICE=ens192
BOOTPROTO=none
ONBOOT=yes
IPADDR=$hip
NETMASK=$mask
GATEWAY=$gateway
DNS1=$dns1
DOMAIN=$domain
DEFROUTE=yes
IPV6INIT=no
EOF

hostname=$hname.$domain	
cat <<EOF > ../install/$hname/etc/hostname
$hostname
EOF

filetranspile -i ../install/$htype.ign -f ../install/$hname -o ../install/$hname.ign

if [ $htype != "bootstrap" ]; then
base64 -w0 ../install/$hname.ign > ../install/$hname.64
fi

done	

