//Loops: https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9

terraform {
  required_providers {
    vsphere = "~> 1.17"
  }
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}


//If you deploy the vm on a cluster with DSR active and not using Resource Pool
//data "vsphere_compute_cluster" "cluster" {
//  name          = var.vsphere_cluster
//  datacenter_id = data.vsphere_datacenter.dc.id
//}


//If you deploy the vm on a resourcepool
//data "vsphere_resource_pool" "pool" {
//  name          = var.vsphere_resource_pool
//  datacenter_id = "${data.vsphere_datacenter.dc.id}"
//}

//If you deploy the vm on a ESXi Host directly
data "vsphere_host" "host" {
  name = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "ds" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "ocp_template" {
  name          = var.ocp_template_name
  datacenter_id = data.vsphere_datacenter.dc.id

/*  
  The template must have the following properties predefined:
  
  Hard Disk 120GB
  Network Interface
  Guest Operationg System
  "edit settings" -> tab "VM Options" -> section "Advanced" -> "Latency Sensitivity" -> High
  "edit settings" -> tab "VM Options" -> section "Advanced" -> "Configuration parameters" -> click "Edit configuration"
        
        Add configuration params:
        
        guestinfo.ignition.config.data.encoding -> base64        
	disk.EnableUUID -> TRUE
*/	
}



provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
  
  
}


resource "vsphere_virtual_machine" "vm" {
  count = length(var.nodes)
  name  = var.nodes[count.index].name
  folder= var.vsphere_folder
  
  //en caso de tener un cluster con DSR activo y no usar Resource Pool:
  //resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  
  //en caso de usar resource pool
  resource_pool_id = data.vsphere_resource_pool.pool.id
  
  
  //en caso de no tener clusters e ir contra el host directamente:
  //resource_pool_id = data.vsphere_host.host.resource_pool_id
  
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = var.nodes[count.index].cpu
  memory   = var.nodes[count.index].memory
  
  guest_id = data.vsphere_virtual_machine.ocp_template.guest_id
//  scsi_type = data.vsphere_virtual_machine.ocp_template.scsi_type

  enable_disk_uuid = "true"

//network and disk although cloned they are required so you must set them

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.ocp_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.ocp_template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.ocp_template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.ocp_template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ocp_template.id
    
    
  }

  vapp {
    properties = {
      "guestinfo.ignition.config.data" = var.nodes[count.index].ignition
    }
  }
  
  wait_for_guest_net_timeout= -1
}


output "names" {
  value = ["${vsphere_virtual_machine.vm.*.name}"]
}


output "macs" {
  value = ["${vsphere_virtual_machine.vm.*.network_interface}"]
}

