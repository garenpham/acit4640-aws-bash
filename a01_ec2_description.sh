#!/bin/bash

# Source the state file
source state_file_ec2.txt

# Loop to wait for EC2 Instance to come up
aws ec2 wait instance-running --instance-ids "${instance_id}"

# Describe EC2 instance
aws ec2 describe-instances --instance-ids "$instance_id"