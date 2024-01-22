#!/bin/bash

bash a01_vpc_setup.sh &&
bash a01_ec2_setup.sh &&

# Source the state file
source state_file_ec2.txt &&

aws ec2 wait instance-status-ok --instance-ids "${instance_id}" &&

bash a01_app_setup.sh