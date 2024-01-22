#!/bin/bash

# Source the state file
source state_file_vpc.txt

# Detach Internet Gateway from VPC
aws ec2 detach-internet-gateway --internet-gateway-id "$gateway_id" --vpc-id "$vpc_id"

# Delete Internet Gateway
aws ec2 delete-internet-gateway --internet-gateway-id "$gateway_id"

# Delete Subnet
aws ec2 delete-subnet --subnet-id "$subnet_id"

# Delete Route Table
aws ec2 delete-route-table --route-table-id "$route_table_id"

# Delete Security Group
aws ec2 delete-security-group --group-id "$security_group_id"

# Delete VPC
aws ec2 delete-vpc --vpc-id "$vpc_id"
