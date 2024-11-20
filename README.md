# "Hello, World!" website hosted on AWS
IU Cloud Programming Project

This project demonstrates how to deploy a simple "Hello, World!" website using AWS and Terraform. The setup includes a scalable, globally distributed architecture with S3, CloudFront, and EC2.

## Features
- **Static Website Hosting**: S3 bucket configured for hosting `index.html`.
- **Global Distribution**: CloudFront serves the website globally for low latency.
- **Dynamic Scaling**: Auto Scaling adjusts EC2 instances based on traffic.
- **Infrastructure as Code**: Fully replicable using Terraform.

## Prerequisites
- An AWS account with appropriate permissions.
- Terraform installed (v1.0+ recommended).
- Git installed for cloning this repository.

## Setup Instructions

1. **Clone the Repository**:
   ```bash
     git clone https://github.com/sabihadudhia/hello-world-website.git
     cd hello-world-website
   
2. **Update Configuration**:
    Open provider.tf and set the AWS region if needed.
    Replace subnet IDs or other specific resource IDs with your own.

3. **Initialize and Deploy**:
   ```bash
    terraform init
    terraform plan
    terraform apply

4. **Access the Website**:
    Note the CloudFront URL or S3 endpoint from the Terraform outputs.
    Open the URL in your browser to view the website.

5. **File Structure**:
- `provider.tf`: AWS provider configuration.
- `S3.tf`: S3 bucket setup for static website hosting.
- `CloudFront.tf`: CloudFront distribution setup.
- `EC2.tf`: EC2 instance and Auto Scaling configuration.
- `index.html`: The static HTML file for the website.

6. **Outputs**:
- S3 Website Endpoint: The URL for direct S3 hosting.
- CloudFront Distribution URL: The globally cached and secure website address.



