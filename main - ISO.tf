//Loops: https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9

terraform {
  required_providers {
    vsphere = "~> 1.17"
  }
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}


//en caso de deplegar las imágenes sobre un cluster con DSR activo y no usar Resource Pool
//data "vsphere_compute_cluster" "cluster" {
//  name          = var.vsphere_cluster
//  datacenter_id = data.vsphere_datacenter.dc.id
//}


//en caso de deplegar las imágenes sobre un resource pool
data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

//en caso de deplegar las imágenes sobre un host directamente
//data "vsphere_host" "host" {
//  name = var.vsphere_host
//  datacenter_id = data.vsphere_datacenter.dc.id
//}

data "vsphere_datastore" "ds" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
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
  
  guest_id = "coreos64Guest"


  enable_disk_uuid = "true"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 120
    thin_provisioned = true
  }
  
  
  cdrom {
    datastore_id = data.vsphere_datastore.ds.id
    path         = "${var.iso_folder}/${var.nodes[count.index].name}.iso"
  }
  
  wait_for_guest_net_timeout= -1
}


output "names" {
  value = ["${vsphere_virtual_machine.vm.*.name}"]
}


output "macs" {
  value = ["${vsphere_virtual_machine.vm.*.network_interface}"]
}

