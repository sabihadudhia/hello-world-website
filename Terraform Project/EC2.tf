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

