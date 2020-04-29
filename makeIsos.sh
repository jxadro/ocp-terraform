#!/bin/sh

DNS=60.85.201.4
MASK=255.255.0.0
ROUTER=60.85.0.1
WEB='http:\/\/60.85.201.4:81'
DOMAIN=ocp42cluster1.jordax.com
ISO='/opt/ocp42/rhcos-4.3.8-x86_64-installer.x86_64.iso'
RAW=rhcos-4.3.8-x86_64-metal.x86_64.raw.gz


HOSTS=("bootstrap-0_bootstrap_60.85.201.5" "control-plane-0_master_60.85.201.6" "control-plane-1_master_60.85.201.7" "control-plane-2_master_60.85.201.8" "infra-0_worker_60.85.201.9" "infra-1_worker_60.85.201.10" "worker-0_worker_60.85.201.11")

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
