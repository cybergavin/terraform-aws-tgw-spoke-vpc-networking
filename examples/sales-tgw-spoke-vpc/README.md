# Provisioning a `sales-network`spoke VPC with networking

This example provisions a spoke VPC for `sales` applications, using the `tgw-spoke-vpc-networking` module. Refer `main.tf`.

## Module Inputs

Inputs to the module are provided via variables, whose values are specified in `terraform.tfvars`

## Module Outputs

The module outputs are:  
- VPC ID
- Subnet IDs
- Security Groupd IDs

The module outputs may be filtered for obtaining IDs of specific resources as required, for use with other resources.  

For example, after provisioning the `sales-network` if you need to use the `sqldb` security group for the database EC2 instances, you may refer to the relevant security group id by filtering the module's `security_groups` output as shown in `outputs.tf` and below.

```hcl
output "sales-sqldb-sg" {
  value = [for sg in module.sales-network.security_groups :
     sg.id
     if can(regex("sqldb", lookup(sg.tags, "Name", "")))
  ]
}
```

## Transit Gateway Connection
In this example, the transit gateway connection is disabled with `tgw_sharing_enabled = false`. It's recommended to test with this default value first, to ensure your code doesn't time out or throw errors due to an inaccessible TGW. Once tested, set the `shared_transit_gateway_arn` and `transit_gateway_id` variables to appropriate values, enable the TGW connection (`tgw_sharing_enabled = true`) and rerun the code.