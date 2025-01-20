# s3_bucket.tf

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "flarie-microservice-1"
#   acl    = "public-read"

  website {
    index_document = "index.html"
    # Optional: Error page
    # error_document = "error.html"
  }
}

output "frontend_url" {
  value = aws_s3_bucket.frontend_bucket.website_endpoint
}
