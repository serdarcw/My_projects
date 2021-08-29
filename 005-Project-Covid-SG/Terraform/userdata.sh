#!/bin/bash
yum update -y
yum install python3 -y
pip3 install flask
pip3 install covid
cd /home/ec2-user/
wget https://raw.githubusercontent.com/serdarcw/My_projects/master/006-Project-Covid-SG/covid19.py
wget https://raw.githubusercontent.com/serdarcw/My_projects/master/006-Project-Covid-SG/app.py
mkdir templates
cd templates
wget https://raw.githubusercontent.com/serdarcw/My_projects/master/006-Project-Covid-SG/templates/about.html
wget https://raw.githubusercontent.com/serdarcw/My_projects/master/006-Project-Covid-SG/templates/error.html
wget https://raw.githubusercontent.com/serdarcw/My_projects/master/006-Project-Covid-SG/templates/index.html
cd ..
python3 app.py