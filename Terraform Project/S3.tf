# Create an S3 bucket for hosting the static "Hello, World!" website
resource "aws_s3_bucket" "website_bucket" {
  bucket = "iu-terraform-hello-world-bucket"  	# The name of the S3 bucket to store the website files

  tags = {
    Name        = "StaticWebsiteBucket"  		# Label the bucket as "StaticWebsiteBucket"
    Environment = "Development"  				# Tag to specify the environment is for development
  }
}

# Block configuration to allow public access to the S3 bucket, making the website public
resource "aws_s3_bucket_public_access_block" "website_bucket_access_block" {
  bucket = aws_s3_bucket.website_bucket.id  	# Reference the bucket created above

  block_public_acls       = false  				# Allow public access control lists (ACLs)
  block_public_policy     = false  				# Allow public bucket policies
  ignore_public_acls      = false  				# Do not ignore public ACLs
  restrict_public_buckets = false  				# Do not restrict public access to the bucket
}

# Set the S3 bucket to be used for a static website, specifying the homepage (index.html)
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id  	# Reference the bucket created above

  index_document {
    suffix = "index.html"  						# Set "index.html" as the default homepage of the website
  }
}

# Define a policy that allows public access to objects in the S3 bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id  	# Reference the S3 bucket created above

  # Define the policy that allows any user (Principal = "*") to access the objects in the bucket
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicAccess",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",  			# Allow reading (GET) objects
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"  # Allow access to all objects in the bucket
      }
    ]
  })
}

# Upload the "index.html" file to the S3 bucket
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website_bucket.bucket  # Reference the bucket created above
  key          = "index.html"  					# The name of the file in the S3 bucket
  source       = "index.html"  					# Path to the local "index.html" file
  content_type = "text/html"  					# Set the MIME type to HTML
}

# Output the S3 website endpoint (URL) where the static site is hosted
output "s3_website_endpoint" {
  value       = aws_s3_bucket_website_configuration.website_config.website_endpoint  # URL to access the website
  description = "S3 Bucket Static Website Endpoint"  # Description of the output value
}