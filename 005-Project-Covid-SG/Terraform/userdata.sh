#!/bin/bash
yum update -y
yum install python3 -y
pip3 install flask
pip3 install covid
cd /home/ec2-user/
FOLDER="https://raw.githubusercontent.com/serdarcw/My_projects/master/005-Project-Covid-SG/"
wget "$FOLDER"covid19.py
wget "$FOLDER"app.py
mkdir templates
cd templates
wget "$FOLDER"templates/about.html
wget "$FOLDER"templates/error.html
wget "$FOLDER"templates/index.html
cd ..
python3 app.py