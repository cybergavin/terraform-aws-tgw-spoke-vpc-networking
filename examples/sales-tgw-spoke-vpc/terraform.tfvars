org         = "cg-it"
app_id      = "slg"
environment = "tst"
vpc_cidr    = "10.10.0.0/16"
subnet_cidrs = {
  web  = ["10.10.0.0/26", "10.10.0.64/26"]
  sqldb = ["10.10.1.0/27", "10.10.1.32/27"]
}
tgw_sharing_enabled        = false
shared_transit_gateway_arn = "arn:aws:ram:us-west-2:123456789012:resource-share/xxxxxxxx-1111-yyyy-2222-1a2b3c4d5e6f"
transit_gateway_id         = "tgw-0123wert1234qwe12"
dns_servers                = ["10.100.153.53", "10.100.253.53", "AmazonProvidedDNS"]
dns_domain                 = "cybergav.in"
security_groups = [
  {
    alias       = "web"
    description = "Security group for Sales web application"
    ingress = [
      {
        description = "Allow HTTPS"
        cidr_ipv4   = "0.0.0.0/0"
        source_sg_alias = null
        from_port   = 443
        to_port     = 443
        ip_protocol = "tcp"
      }
    ]
    egress = [
      {
        description = "Allow DB traffic"
        cidr_ipv4   = null
        destination_sg_alias = "sqldb"
        from_port            = 1433         
        to_port              = 1433         
        ip_protocol = "tcp"
      },
      {
        description = "Allow traffic to monitoring server"
        cidr_ipv4   = "150.240.22.32/27"
        destination_sg_alias = null
        from_port            = 9099         
        to_port              = 9099         
        ip_protocol = "tcp"
      }      
    ]
  },
  {
    alias       = "sqldb"
    description = "Security group for Sales DB servers"
    ingress = [
      {
        description = "Allow Web traffic"
        cidr_ipv4   = null
        source_sg_alias = "web"
        from_port   = 1433
        to_port     = 1433
        ip_protocol = "tcp"
      }
    ]
  }
]
global_tags = {
  "cg:application:name"       = "Sales Lead Generation"
  "cg:application:id"         = "slg"
  "cg:application:owner"      = "Sales IT"
  "cg:operations:environment" = "tst"
  "cg:operations:managed_by"  = "Terraform"
  "cg:cost:cost_center"       = "CC12345"
  "cg:cost:business_unit"     = "Technology"
}