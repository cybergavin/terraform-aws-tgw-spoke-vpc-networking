# Data Source for AWS regions
data "aws_region" "current" {}

# Data Source for AWS availability zones
data "aws_availability_zones" "current" {}

# Local variables
locals {
  # Retrieve region details - this breaks for regions like Asia-Pacific
  region_name_parts = split("-", data.aws_region.current.name)
  region_code       = "${local.region_name_parts[0]}${join("", [for i in range(1, length(local.region_name_parts)) : substr(local.region_name_parts[i], 0, 1)])}"

  # Retrieve available AZs
  azs      = data.aws_availability_zones.current.names
  az_count = length(local.azs)

  # Group subnets by AZ
  subnets_by_az = {
    for az in distinct([for subnet in aws_subnet.this : subnet.availability_zone]) :
    az => [for subnet in aws_subnet.this : subnet.id if subnet.availability_zone == az]
  }

  # Select the first subnet from each AZ for the TGW attachment
  tgw_subnets = [for az, subnets in local.subnets_by_az : subnets[0]]

  # Create a unique subnet configuration based on provided subnets
  subnet_configs = flatten([
    for alias, cidrs in var.subnet_cidrs : [
      for i, cidr in cidrs : {
        key  = alias
        cidr = cidr
        az   = local.azs[i % local.az_count]
      }
    ]
  ])

  # Security group ingress rules configuration
  sg_ingress_configs = flatten([
    for sg in var.security_groups :
    [
      for rule in sg.ingress :
      {
        sg_alias    = sg.alias
        description = rule.description
        from_port   = rule.from_port
        to_port     = rule.to_port
        ip_protocol = rule.ip_protocol
        cidr_ipv4   = rule.cidr_ipv4
      }
    ]
  ])
  # Security group egress rules configuration
  sg_egress_configs = flatten([
    for sg in var.security_groups :
    [
      for rule in sg.egress :
      {
        sg_alias    = sg.alias
        description = rule.description
        ip_protocol = rule.ip_protocol
        cidr_ipv4   = rule.cidr_ipv4
      }
    ]
  ])
}

# VPC Creation
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    {
      Name = module.networking_vpc_label.id
    },
    var.global_tags
  )
}

# Subnet Creation
resource "aws_subnet" "this" {
  for_each = { for subnet in local.subnet_configs : module.networking_subnet_label["${var.app_id}-${subnet.key}-${subnet.az}"].id => subnet }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = merge(
    {
      Name = each.key
    },
    var.global_tags
  )
}

# Accept the Transit Gateway Share invitation
resource "aws_ram_resource_share_accepter" "this" {
  for_each = var.tgw_sharing_enabled ? { "enabled_tgw" = var.shared_transit_gateway_arn } : {}

  share_arn = each.value
}

# Create Transit Gateway attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.tgw_sharing_enabled ? { "enabled_tgw" = var.transit_gateway_id } : {}

  transit_gateway_id = each.value
  vpc_id             = aws_vpc.this.id
  subnet_ids         = local.tgw_subnets
  tags = merge(
    {
      Name = module.networking_tgw_attachment_label.id
    },
    var.global_tags
  )
}

# Route Table Creation
resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    {
      Name = module.networking_rtb_label.id
    },
    var.global_tags
  )
}

# Route to Transit Gateway
resource "aws_route" "tgw_route" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0" # Adjust if needed
  transit_gateway_id     = var.transit_gateway_id
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "this" {
  for_each = aws_subnet.this

  subnet_id      = each.value.id
  route_table_id = aws_route_table.this.id
}

resource "aws_security_group" "this" {
  for_each = { for sg in var.security_groups : module.networking_sg_label["${var.app_id}-${sg.alias}"].id => sg }

  name        = each.key
  description = each.value.description
  vpc_id      = aws_vpc.this.id

  tags = merge(
    {
      Name = each.key
    },
    var.global_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for idx, rule in local.sg_ingress_configs : "${var.app_id}-${rule.sg_alias}-${idx}" => rule }

  security_group_id = aws_security_group.this[module.networking_sg_label["${var.app_id}-${each.value.sg_alias}"].id].id

  description = each.value.description
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4   = each.value.cidr_ipv4
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for idx, rule in local.sg_egress_configs : "${var.app_id}-${rule.sg_alias}-${idx}" => rule }

  security_group_id = aws_security_group.this[module.networking_sg_label["${var.app_id}-${each.value.sg_alias}"].id].id
  description       = each.value.description
  ip_protocol       = each.value.ip_protocol
  cidr_ipv4         = each.value.cidr_ipv4
}


# DHCP Option Set for Custom DNS (Bluecat DNS in Ingress VPC)
resource "aws_vpc_dhcp_options" "this" {
  domain_name_servers = var.dns_servers
  domain_name         = var.dns_domain
  tags = merge(
    {
      Name = module.networking_dop_label.id
    },
    var.global_tags
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}