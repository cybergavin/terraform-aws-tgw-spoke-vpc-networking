variable "org" {
  description = "A name or abbreviation for the Organization. Only alphanumeric characters and hyphens are valid, with a string length from 3 to 8 characters."
  type        = string
  default     = "acme-its"
}

variable "app_id" {
  description = "The universally unique application ID for the service. Only alphanumeric characters are valid, with a string length from 3 to 8 characters."
  type        = string
  default     = "appid"
}

variable "global_tags" {
  description = "A map of global tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "A valid Infrastructure Environment (poc, dev, tst, stg, prod)"
  type        = string
  default     = "poc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  nullable    = false
}

variable "subnet_cidrs" {
  description = "A map of subnet aliases and their associated list of CIDR blocks across multiple AZs, with an alias length from 3 to 8 lowercase alphanumeric characters and valid CIDR blocks."
  type        = map(list(string))
  default     = {}
}

variable "security_groups" {
  description = "List of security groups with associated ingress and egress rules"
}

variable "tgw_sharing_enabled" {
  description = "Enable or disable the Transit Gateway sharing and attachment resources. Set to true to create the resources."
  type        = bool
  default     = false
}

variable "shared_transit_gateway_arn" {
  description = "The ARN of the Ingress network account's shared Transit Gateway."
  type        = string
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID for the peering connection. TBD: Obtain output from another tofu module."
  type        = string
}

variable "dns_servers" {
  description = "List of custom DNS servers to use"
  type        = list(string)
  default     = []
}

variable "dns_domain" {
  description = "Domain name for DHCP option set"
  type        = string
  default     = ""
}