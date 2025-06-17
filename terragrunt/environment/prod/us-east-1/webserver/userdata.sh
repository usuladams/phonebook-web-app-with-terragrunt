#!/bin/bash
dnf update -y
dnf install python3 -y
dnf install python-pip -y
pip3 install Flask==2.3.3
pip3 install Flask-MySql
pip3 install boto3
dnf install git -y
echo "${dbendpoint}" > /home/ec2-user/dbserver.endpoint
cd /home/ec2-user
TOKEN=$(aws --region=us-east-1 ssm get-parameter --name /baby/phonebook/token --with-decryption --query 'Parameter.Value' --output text)
git clone https://$TOKEN@github.com/usuladams/phonebook-web-app.git
python3 /home/ec2-user/phonebook-web-app/solutions/phonebook-app.py