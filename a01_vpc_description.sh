#!/bin/bash

# Source the state file
source state_file_vpc.txt

# Describe VPC
aws ec2 describe-vpcs --vpc-ids "$vpc_id"

# Describe Subnet
aws ec2 describe-subnets --subnet-ids "$subnet_id"

# Describe Internet Gateway
aws ec2 describe-internet-gateways --internet-gateway-ids "$gateway_id"

# Describe Route Table
aws ec2 describe-route-tables --route-table-ids "$route_table_id"

# Describe Security Group
aws ec2 describe-security-groups --group-ids "$security_group_id"