# Create a CloudFront distribution to cache and serve the S3 website globally
resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name  # Use the S3 bucket as the origin for CloudFront
    origin_id   = "S3-Website"  				# Unique identifier for the origin

    custom_origin_config {
      http_port              = 80  				# Allow HTTP traffic (port 80)
      https_port             = 443  			# Allow HTTPS traffic (port 443)
      origin_protocol_policy = "http-only"  	# Use HTTP for traffic between CloudFront and the origin (S3)
      origin_ssl_protocols   = ["TLSv1.2"]  	# Allow only secure TLS connections
    }
  }

  enabled             = true  					# Enable the CloudFront distribution
  default_root_object = "index.html"  			# The default object to serve when accessing the CloudFront distribution

  # Configure cache behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]  		# Allow GET and HEAD requests for caching
    cached_methods   = ["GET", "HEAD"]  		# Cache GET and HEAD requests
    target_origin_id = "S3-Website"  			# Use the S3 website as the source for the content

    forwarded_values {
      query_string = false  					# Do not forward query strings to the origin
      cookies {
        forward = "none"  						# Do not forward cookies
      }
    }

    viewer_protocol_policy = "redirect-to-https"  # Force HTTPS redirection for viewers
  }

  # Set geographical restrictions (none in this case)
  restrictions {
    geo_restriction {
      restriction_type = "none"  				# No geographic restrictions
    }
  }

  # Enable CloudFront's default SSL certificate for secure connections
  viewer_certificate {
    cloudfront_default_certificate = true  		# Use CloudFront's default SSL certificate
  }

  tags = {
    Name        = "CloudFrontDistribution"  	# Tag for identifying the distribution
    Environment = "Development"  				# Tag to specify the environment as development
  }
}

# Output the CloudFront distribution URL where the static site is served
output "cloudfront_url" {
  value       = aws_cloudfront_distribution.website_distribution.domain_name  # URL to access the CloudFront distribution
  description = "CloudFront Distribution URL"  	# Description of the output value
}