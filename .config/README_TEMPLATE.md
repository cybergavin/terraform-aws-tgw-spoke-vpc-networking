# Terraform module : `tgw-spoke-vpc-networking`
This Terraform module provisions foundational networking infrastructure in **spoke VPCs** that host business applications or workloads. It helps to quickly set up basic networking required by workloads in a multi-account hub-spoke network topology on AWS, where all ingress and egress traffic to/from the spoke VPC passes through a *hub* VPC (in another AWS account) via a Transit Gateway (TGW).  
This module uses the [`cloudposse/null/label`](https://registry.terraform.io/modules/cloudposse/label/null/latest) terraform module to use a consistent naming convention for provisioned resources.

![](VIEWME.png "AWS Hub-Spoke")

## Features
- Provisions the following network infrastructure in a spoke AWS account:
  - A VPC with subnets
  - TGW share acceptance and TGW attachments
  - Route tables with local and TGW-bound routes
  - DHCP options set with custom DNS settings
  - Security Groups for workloads
- Leverages the cloudposse terraform-null-label module to assign standardized names to provisioned resources.
- Applies tags consistently to provisioned resources.

## Requirements

- The TGW set up in the `network services` AWS account must be shared with the `workload` AWS account via Resource Access Manager (RAM) and the `TGW share ARN` must be made available. Ideally, if the TGW share is automated via Terraform, then the ARN may be accessed from Terraform state.
- The `TGW ID` must be made available. Ideally, if the TGW provisioning is automated via Terraform, then the TGW ID may be accessed from Terraform state.


## Usage

```hcl
module "example" {
  source                     = "cybergavin/tgw-spoke-vpc-networking/aws"
  version                    = "x.y.z" # Use latest
  org                        = var.org
  app_id                     = var.app_id
  environment                = var.environment
  vpc_cidr                   = var.vpc_cidr
  shared_transit_gateway_arn = var.shared_transit_gateway_arn
  transit_gateway_id         = var.transit_gateway_id
  subnet_cidrs               = var.subnet_cidrs
  dns_servers                = var.dns_servers
  dns_domain                 = var.dns_domain
  security_groups            = var.security_groups
  global_tags                = var.global_tags
}
```
