resource "aws_autoscaling_group" "web-asg" {
  name                      = "web-asg"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 90
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = ["subnet-4de77701", "subnet-f693ba8c", "subnet-160dfe7d"]
  launch_template {
    id      = aws_launch_template.my_launch-teamplate.id
    version = "$Latest"
  }
  target_group_arns     = [aws_lb_target_group.WebServerTargetGroup.arn]
  tag {
    key                 = "name"
    value               = local.name
    propagate_at_launch = true
  }
  timeouts {
    delete = "15m"
  }
}