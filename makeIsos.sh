#!/bin/sh

DNS=192.168.1.2
MASK=255.255.255.0
ROUTER=192.168.1.1
WEB='http:\/\/192.168.1.2:81'
DOMAIN=cluster2.poc.com
ISO='/opt/ocp4/rhcos-4.3.8-x86_64-installer.x86_64.iso'
RAW=rhcos-4.3.8-x86_64-metal.x86_64.raw.gz

HOSTS=("bootstrap-0_bootstrap_192.168.1.3" "control-plane-0_master_192.168.1.4" "control-plane-1_master_192.168.1.5" "control-plane-2_master_192.168.1.6" "infra-0_worker_192.168.1.7" "infra-1_worker_192.168.1.8" "worker-0_worker_192.168.1.9")

mkdir /isos

for host in "${HOSTS[@]}"; do

   sudo mount $ISO  /mnt/
   mkdir /tmp/rhcos
   rsync -a /mnt/* /tmp/rhcos/
   hname=$(echo $host | awk -F_ '{ print $1}')
   htype=$(echo $host | awk -F_ '{ print $2}')
   hip=$(echo $host | awk -F_ '{ print $3}')
   cd /tmp/rhcos

   ignition_file=""
   if [ $htype == "bootstrap" ]; then
     ignition_file="bootstrap.ign"
   elif [ $htype == "master" ]; then
     ignition_file="master.ign"
   else
     ignition_file="worker.ign"
   fi

   sed -i "s/coreos.inst=yes/coreos.inst=yes ip=$hip::${ROUTER}:${MASK}:${hname}.${DOMAIN}:ens192:none nameserver=$DNS coreos.inst.install_dev=sda coreos.inst.image_url=$WEB\/$RAW coreos.inst.ignition_url=$WEB\/$ignition_file/g" isolinux/isolinux.cfg

   cat isolinux/isolinux.cfg | grep append



   isolinux/isolinux.cfg | grep coreos.inst

   sudo mkisofs -U -A "RHCOS-x86_64" -V "RHCOS-x86_64" -volset "RHCOS-x86_64" -J -joliet-long -r -v -T -x ./lost+found -o /isos/$hname.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot .

   cd ..

   rm -rf rhcos
   sudo umount /mnt

done
