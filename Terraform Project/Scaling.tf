# Auto Scaling Group for EC2 instances to handle traffic scaling
resource "aws_autoscaling_group" "web_server_asg" {
  desired_capacity     = 2  # Start with 2 EC2 instances
  max_size             = 5  # Allow up to 5 EC2 instances during high traffic
  min_size             = 1  # Allow at least 1 EC2 instance
  vpc_zone_identifier  = ["subnet-0e3f2007bb31de68e"]  # Specify subnet for EC2 instances (replace with your subnet ID)

  launch_template {
    name    = aws_launch_template.web_server_launch_template.name  # Reference the launch template created earlier
    version = "$Latest"  # Use the latest version of the launch template
  }

  health_check_type          = "EC2"  # Use EC2 health checks to manage instance status
  health_check_grace_period = 300  # Wait 5 minutes before considering the instance unhealthy
  force_delete              = true  # Force deletion of instances during scaling

  # Tag for instances launched by the Auto Scaling Group
  tag {
    key                 = "Name"
    value               = "AutoScaledEC2WebServer"
    propagate_at_launch = true
  }
}

# Auto Scaling Policy to scale up the number of instances
resource "aws_autoscaling_policy" "scale_up" {
  name               = "scale-up-policy"  		# Name of the scaling policy
  scaling_adjustment = 1  						# Add 1 instance when scaling up
  adjustment_type    = "ChangeInCapacity"  		# Use capacity adjustment for scaling
  cooldown           = 300  					# Wait 5 minutes before scaling again
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name  # Reference the Auto Scaling Group
}

# Auto Scaling Policy to scale down the number of instances
resource "aws_autoscaling_policy" "scale_down" {
  name               = "scale-down-policy"  	# Name of the scaling policy
  scaling_adjustment = -1  						# Remove 1 instance when scaling down
  adjustment_type    = "ChangeInCapacity"  		# Use capacity adjustment for scaling
  cooldown           = 300  					# Wait 5 minutes before scaling again
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name  # Reference the Auto Scaling Group
}

# Output the name of the Auto Scaling Group
output "asg_name" {
  value       = aws_autoscaling_group.web_server_asg.name  # Name of the Auto Scaling Group
  description = "Auto Scaling Group Name"  		# Description of the output value
}