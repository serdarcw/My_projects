#!/bin/bash
yum update -y
yum install python3 -y
pip3 install flask
cd /home/ec2-user/
wget https://raw.githubusercontent.com/serdarcw/My_projects/master/002-Project-Tc-ID-SG/app.py
mkdir templates
cd templates
wget https://raw.githubusercontent.com/serdarcw/My_projects/master/002-Project-Tc-ID-SG/templates/index.html
wget https://raw.githubusercontent.com/serdarcw/My_projects/master/002-Project-Tc-ID-SG/templates/result.html
cd ..
python3 app.py