# Terraform module : `workload-spoke-vpc`
This Terraform module sets up basic networking in a workload spoke VPC on AWS, where all ingress/egress traffic enters/exits the VPC via a transit gateway in another AWS account.

![](VIEWME.png "AWS Hub-Spoke")


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_networking_base_label"></a> [networking\_base\_label](#module\_networking\_base\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_networking_dop_label"></a> [networking\_dop\_label](#module\_networking\_dop\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_networking_rtb_label"></a> [networking\_rtb\_label](#module\_networking\_rtb\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_networking_sg_label"></a> [networking\_sg\_label](#module\_networking\_sg\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_networking_subnet_label"></a> [networking\_subnet\_label](#module\_networking\_subnet\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_networking_tgw_attachment_label"></a> [networking\_tgw\_attachment\_label](#module\_networking\_tgw\_attachment\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_networking_vpc_label"></a> [networking\_vpc\_label](#module\_networking\_vpc\_label) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_vpc_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_ram_resource_share_accepter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share_accepter) | resource |
| [aws_route.tgw_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_dhcp_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_availability_zones.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | The universally unique application ID for the service. | `string` | `""` | no |
| <a name="input_dns_domain"></a> [dns\_domain](#input\_dns\_domain) | Domain name for DHCP option set | `string` | n/a | yes |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of custom DNS servers to use (e.g., Bluecat) | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (poc, dev, tst, stg, prod) | `string` | n/a | yes |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | A map of global tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_org"></a> [org](#input\_org) | A name or abbreviation for the Organization. Must not contain blankspaces and special characters. | `string` | `"usc-its"` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security groups with associated ingress and egress rules | <pre>list(object({<br/>    alias       = string<br/>    description = string<br/>    ingress = list(object({<br/>      description = string<br/>      cidr_ipv4   = string<br/>      ip_protocol = string<br/>      from_port   = optional(number) # optional for cases like `-1` protocol<br/>      to_port     = optional(number) # optional for cases like `-1` protocol<br/>    }))<br/>    egress = list(object({<br/>      description = string<br/>      cidr_ipv4   = string<br/>      ip_protocol = string<br/>      from_port   = optional(number) # optional for cases like `-1` protocol<br/>      to_port     = optional(number) # optional for cases like `-1` protocol<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_shared_transit_gateway_arn"></a> [shared\_transit\_gateway\_arn](#input\_shared\_transit\_gateway\_arn) | The ARN of the Ingress network account's shared Transit Gateway. TBD: Obtain output from another tofu module. | `string` | n/a | yes |
| <a name="input_subnet_cidrs"></a> [subnet\_cidrs](#input\_subnet\_cidrs) | Map of subnet aliases to a list of CIDR blocks for each component across multiple AZs | `map(list(string))` | n/a | yes |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | Transit Gateway ID for the peering connection. TBD: Obtain output from another tofu module. | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the MFT VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
