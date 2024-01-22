#!/bin/bash

# Source the state file
source state_file_vpc.txt

# Create EC2 instance
ami_id=ami-04203cad30ceb4a0c # Ubuntu
instance_type=t2.micro
ssh_key_name=acit_4640
instance_id=$(aws ec2 run-instances \
         --image-id $ami_id \
         --instance-type $instance_type \
         --key-name $ssh_key_name \
         --subnet-id $subnet_id \
         --security-group-ids $security_group_id \
         --query 'Instances[*].InstanceId' \
         --output text)

# Tag EC2 instance
aws ec2 create-tags --resources "$instance_id" --tags Key=Project,Value=a1_project Key=Name,Value=a1_ec2

# Save instance ID
{
  echo "instance_id=$instance_id"
} > state_file_ec2.txt
