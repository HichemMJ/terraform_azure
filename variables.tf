variable "resource_group_name" {
  type = string
  description = "Azure Resource Group Name"
  default = "hichemmj"
}

variable "location" {
  type = string
  description = "Azure Resource Location"
  default = "francecentral"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
