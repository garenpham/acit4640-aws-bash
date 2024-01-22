#!/bin/bash

# Source the state file
source state_file_ec2.txt

# Find EC2 Public IPv4 DNS
# REMOTE_HOST_IP=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
REMOTE_HOST=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicDnsName' --output text)
REMOTE_USER=ubuntu
SSH_KEY_FILE=~/.ssh/acit_4640

# Copy the setup file into the EC2
scp -r setup $REMOTE_USER@$REMOTE_HOST:~/setup

ssh $REMOTE_HOST << EOF
  # Set up user, permisison, and install required apt packages
  sudo su

  # Create a user called a01 with the home folder /a01
  useradd -m -d /a01 a01 || echo "User already exists."

  # Give permission to the home folder. 755 means read and execute access for everyone and also write access for the owner of the file. 
  chmod 755 /a01

  # Create a user called backend with the home folder /backend
  useradd -m -d /backend backend || echo "User already exists."

  # Give permission to the home folder.
  chmod 755 /backend

  # Install required packages
  apt update && apt install -y nginx python3-pip python3-venv libmysqlclient-dev mysql-server ;

  # Copy the frontend file index.html to /a01/web_root
  mkdir -p /a01/web_root ; cp /home/ubuntu/setup/frontend/index.html /a01/web_root

  # Set up the back-end

  # Copy the backend to /a01/app
  mkdir -p /a01/app ; cp /home/ubuntu/setup/backend/* /a01/app
  mkdir -p src
  mkdir -p /backend/src ; cp /home/ubuntu/setup/backend/* /backend/src

  exit
EOF

ssh $REMOTE_HOST "
  # MySQL configuration
  sudo mysql << DELIM
    ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Password';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    CREATE DATABASE IF NOT EXISTS backend;
    CREATE USER IF NOT EXISTS 'example'@'localhost' IDENTIFIED BY 'secure';
    GRANT ALL PRIVILEGES ON backend.* TO 'example'@'localhost';
    FLUSH PRIVILEGES;
    USE backend;
    CREATE TABLE IF NOT EXISTS item (
    name varchar(30) NOT NULL,
    bcit_id varchar(10) NOT NULL,
    PRIMARY KEY (bcit_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    INSERT INTO backend.item (name, bcit_id) VALUES ('Tan','A01215507');
    DELIM;
"

ssh $REMOTE_HOST << EOF
  # Install python dependencies

  sudo su
  
  su -c "pip3 install --user --break-system-packages -r /backend/src/requirements.txt" -s /bin/sh backend

  # Python service

  cp /backend/src/backend.service /etc/systemd/system/backend.service

  systemctl daemon-reload
  systemctl enable backend
  systemctl start backend

  # Copy nginx default file 
  cp /home/ubuntu/setup/default /etc/nginx/sites-available/default && systemctl restart nginx
EOF