#!/bin/bash

# Source the state file
source state_file_ec2.txt

bash a01_ec2_cleanup.sh &&

aws ec2 wait instance-terminated --instance-ids "${instance_id}" &&

bash a01_vpc_cleanup.sh

