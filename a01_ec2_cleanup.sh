#!/bin/bash

# Source the state file
source state_file_ec2.txt

# Terminate EC2 instance
aws ec2 terminate-instances --instance-ids "$instance_id"
