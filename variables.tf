variable "org" {
  description = "A name or abbreviation for the Organization. Must not contain blankspaces and special characters."
  type        = string
  default     = "usc-its"
}

variable "app_id" {
  description = "The universally unique application ID for the service."
  type        = string
  default     = ""
}

variable "global_tags" {
  description = "A map of global tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment (poc, dev, tst, stg, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the MFT VPC"
  type        = string
}

variable "subnet_cidrs" {
  description = "Map of subnet aliases to a list of CIDR blocks for each component across multiple AZs"
  type        = map(list(string))
  # Validation to ensure no blankspaces in alias and length does not exceed 5 characters
  validation {
    condition = alltrue([
      for alias, cidrs in var.subnet_cidrs :
      alias != "" && length(alias) <= 5 && alltrue([for cidr in cidrs : cidr != ""])
    ])
    error_message = "Subnet alias should not contain blankspaces and must not exceed 5 characters."
  }
}

variable "security_groups" {
  description = "List of security groups with associated ingress and egress rules"
  type = list(object({
    alias       = string
    description = string
    ingress = list(object({
      description = string
      cidr_ipv4   = string
      ip_protocol = string
      from_port   = optional(number) # optional for cases like `-1` protocol
      to_port     = optional(number) # optional for cases like `-1` protocol
    }))
    egress = list(object({
      description = string
      cidr_ipv4   = string
      ip_protocol = string
      from_port   = optional(number) # optional for cases like `-1` protocol
      to_port     = optional(number) # optional for cases like `-1` protocol
    }))
  }))
}
variable "shared_transit_gateway_arn" {
  description = "The ARN of the Ingress network account's shared Transit Gateway. TBD: Obtain output from another tofu module."
  type        = string
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID for the peering connection. TBD: Obtain output from another tofu module."
  type        = string
}

variable "dns_servers" {
  description = "List of custom DNS servers to use (e.g., Bluecat)"
  type        = list(string)
}

variable "dns_domain" {
  description = "Domain name for DHCP option set"
  type        = string
}