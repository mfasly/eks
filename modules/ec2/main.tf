resource "aws_launch_template" "ec2" {
  name_prefix            = var.launch_template
  image_id               = var.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name               = var.key_name
}

resource "aws_autoscaling_group" "ec2_asg" {
  vpc_zone_identifier = concat(var.public_subnet_ids)
  max_size            = var.ec2_max_size
  min_size            = var.ec2_min_size
  desired_capacity    = var.ec2_desire_size

  launch_template {
    id      = aws_launch_template.ec2.id
    version = "$Latest"
  }
}