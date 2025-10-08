variable "create_private_dns_zone" {
  type    = bool
  default = true
}

variable "environment" {
  type = string
}

variable "name" {
  type = string
}

variable "subscription_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "site" {
  type    = string
  default = "mal"
}

variable "hcicluster" {
  type = any
}