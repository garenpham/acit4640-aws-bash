#!/bin/bash


# Create VPC
vpc_cidr=172.16.0.0/16
vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --query Vpc.VpcId --output text)

# Enable public hostnames
aws ec2 modify-vpc-attribute \
 --vpc-id "${vpc_id}" \
 --enable-dns-hostnames "{\"Value\":true}"

# Create Subnet
subnet_cidr=172.16.1.0/24
subnet_id=$(aws ec2 create-subnet  --vpc-id $vpc_id --cidr-block $subnet_cidr --query Subnet.SubnetId  --output text)

# Modify Subnet attribute to assign public ip
aws ec2 modify-subnet-attribute --subnet-id "$subnet_id" --map-public-ip-on-launch

# Create Internet Gateway and attach to VPC
gateway_id=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
aws ec2 attach-internet-gateway --internet-gateway-id $gateway_id --vpc-id $vpc_id

# Create Route Table
route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --query RouteTable.RouteTableId --output text)

# Create route to Internet Gateway
aws ec2 create-route --route-table-id "$route_table_id" --destination-cidr-block 0.0.0.0/0 --gateway-id "$gateway_id"

# Associate Routing Table with Subnet and store association ID
rt_association_id=$(aws ec2 associate-route-table --route-table-id $route_table_id --subnet-id $subnet_id --query AssociationId --output text)

# Create Security Group
security_group_name=a1_web_sg_1
security_group_desc=a1_web_sg_1
security_group_id=$(aws ec2 create-security-group --group-name "$security_group_name" --description "$security_group_desc" --vpc-id $vpc_id --query GroupId --output text)


# Add rules to Security Group
bcit_cidr=142.232.0.0/16
home_cidr=24.84.236.0/24
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr $bcit_cidr # SSH from BCIT
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 80 --cidr $bcit_cidr # HTTP from BCIT
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr $home_cidr # SSH from Home
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 80 --cidr $home_cidr # HTTP from Home
aws ec2 authorize-security-group-egress --group-id $security_group_id --protocol tcp --port 80 --cidr 0.0.0.0/0 # HTTP from anywhere


# Tag resources
aws ec2 create-tags --resources "$vpc_id" "$subnet_id" "$gateway_id" "$route_table_id" --tags Key=Project,Value=a1_project
aws ec2 create-tags --resources "$vpc_id" --tags Key=Name,Value=a1_vpc
aws ec2 create-tags --resources "$subnet_id" --tags Key=Name,Value=a1_sn_web_1
aws ec2 create-tags --resources "$route_table_id" --tags Key=Name,Value=a1_web_rt_1
aws ec2 create-tags --resources "$gateway_id" --tags Key=Name,Value=a1_gw_1

# Save state
{
  echo "vpc_id=$vpc_id"
  echo "subnet_id=$subnet_id" 
  echo "gateway_id=$gateway_id" 
  echo "route_table_id=$route_table_id"
  echo "security_group_id=$security_group_id"
} > state_file_vpc.txt