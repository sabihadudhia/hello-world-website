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