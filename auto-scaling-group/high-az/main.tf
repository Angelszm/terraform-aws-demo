##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


##################################################################################
# RESOURCES
##################################################################################

#Create Launch config
resource "aws_launch_configuration" "nginx" {
  name_prefix     = var.naming_prefix
  image_id      =  nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type = var.instance_type
  security_groups = ["${aws_security_group.nginx_sg.id}"]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]

  lifecycle {
        create_before_destroy = true
     }
   user_data = templatefile("${path.module}/startup_script.tpl", {
    s3_bucket_name = aws_s3_bucket.web_bucket.id
  })
}

#Create Auto Scaling Group

resource "aws_autoscaling_group" "nginx" {
  name_prefix     = var.naming_prefix
  name                 = var.project
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.nginx.name
  vpc_zone_identifier = [element(aws_subnet.private_subnet.*id, count.index),]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-autoscaling"
    value= "Autocaling Group for Nginx Instance"
    propagate_at_launch = true

  })
}

