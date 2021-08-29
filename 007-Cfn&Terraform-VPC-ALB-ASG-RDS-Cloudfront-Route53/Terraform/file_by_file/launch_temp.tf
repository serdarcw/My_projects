data "aws_ami" "amazon-linux-2" {
 most_recent = true
 owners           = ["amazon"]

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}


data "template_file" "userdata" {
  template = <<EOF
    #! /bin/bash
    yum update -y
    yum install python3 -y
    pip3 install flask
    pip3 install flask_mysql
    echo "${aws_db_instance.my_db_instance.address}" > home/ec2-user/dbserver.endpoint
    FOLDER="https://raw.githubusercontent.com/serdarcw/My_projects/master/003-phonebook-web-application/"
    curl -s --create-dirs -o "/home/ec2-user/templates/index.html" -L "$FOLDER"templates/index.html
    curl -s --create-dirs -o "/home/ec2-user/templates/add-update.html" -L "$FOLDER"templates/add-update.html
    curl -s --create-dirs -o "/home/ec2-user/templates/delete.html" -L "$FOLDER"templates/delete.html
    curl -s --create-dirs -o "/home/ec2-user/app.py" -L "$FOLDER"phonebook-app.py
    python3 /home/ec2-user/app.py
  EOF
}

resource "aws_launch_template" "my_launch-teamplate" {
  name = "my_launch-teamplate"
  image_id = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  key_name = var.key_pair
  vpc_security_group_ids = [aws_security_group.ec2_sec_group.id]
  tag_specifications {
    resource_type = "instance"
    tags = local.tags
  }
  user_data = base64encode(data.template_file.userdata.rendered)
}