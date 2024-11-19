# Create a new EC2 key pair for SSH access to EC2 instances
resource "aws_key_pair" "ec2_key" {
  key_name   = "my-webpage-keypair"  # The name of the SSH key pair
  public_key = file("C:/Users/sabih/.ssh/my-webpage-keypair.pub")  # Path to the public key file on your local machine
}

# Create a security group to allow HTTP (port 80) and SSH (port 22) traffic
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"  # Name of the security group
  description = "Allow HTTP and SSH traffic"  # Description of the security group

  # Ingress rule to allow SSH traffic (port 22) from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from any IP address
  }

  # Ingress rule to allow HTTP traffic (port 80) from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP access from any IP address
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to any destination
  }
}

# Define a launch template for EC2 instances that will serve the website
resource "aws_launch_template" "web_server_launch_template" {
  name          = "web-server-launch-template"  # Name of the launch template
  image_id      = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI ID for EC2 instances in us-east-1
  instance_type = "t2.micro"  # Instance type (t2.micro is a low-cost option for testing)

  key_name = aws_key_pair.ec2_key.key_name  # Reference the SSH key pair for EC2 access

  network_interfaces {
    associate_public_ip_address = true  # Associate a public IP address with the EC2 instance
    security_groups            = [aws_security_group.ec2_sg.id]  # Apply the security group
  }

  # EC2 user data to install and run Apache HTTP server
  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>EC2 Instance Serving Content</h1>" > /var/www/html/index.html
              EOF
  )

  lifecycle {
    create_before_destroy = true  # Ensure new resources are created before the old ones are destroyed
  }
}

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