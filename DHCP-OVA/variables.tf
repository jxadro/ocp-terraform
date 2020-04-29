variable "vsphere_server" {
  type        = string
  description = "This is the vSphere server for the environment."
}

variable "vsphere_user" {
  type        = string
  description = "vSphere server user for the environment."
}

variable "vsphere_password" {
  type        = string
  description = "vSphere server password"
}

variable "vsphere_datacenter" {
  type        = string
  description = "datacenter to use"
}

variable "vsphere_cluster" {
  type        = string
  description = "vSphere cluster to use from the datacenter configured, where to allocate the images"
}

variable "vsphere_host" {
  type        = string
  description = "ESXi name or IP, depends on how it is added to vcenter, where to allocate the images"
}

variable "vsphere_resource_pool" {
  type        = string
  description = "name of the resource pool used to allocate the images"
}


variable "vsphere_datastore" {
  type        = string
  description = "data store name"
}

variable "vsphere_folder" {
  type        = string
  description = "folder in the ESX to create the vm"
}

variable "ocp_template_name" {
  type        = string
  description = "OCP template generated from the OVA"
}

variable "vsphere_network" {
  type        = string
  description = "PortGroup to use"
}

variable "iso_folder" {
  type        = string
  description = "In case of using isos the folder inside the datastore where the isos are"
}

variable "nodes" {
  type = list(object({
    name = string
    cpu = number
    memory = string
    ignition = string
    mac = string
  }))
  description = "ignition in base64, in case of using isos the ignition content is not needed"
}