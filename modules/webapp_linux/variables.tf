variable "tags" {
  type = map(string)
}

variable "app_settings" {
  type = map(string)
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "asp_name" {
  type = string
}

variable "webapp_name" {
  type = string
}

variable "sku_name" {
  type = string
} 

variable "keyvault_id" {
  type = string
}