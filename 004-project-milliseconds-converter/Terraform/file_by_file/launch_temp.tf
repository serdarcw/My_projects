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
  user_data = filebase64("userdata.sh")
}