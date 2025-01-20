# s3_objects.tf

resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.frontend_bucket.bucket
  key    = "index.html"
  source = "../Frontend/index.html"  # Path to your local file
  content_type = "text/html" 
#   acl    = "public-read"
}

resource "aws_s3_bucket_object" "style_css" {
  bucket = aws_s3_bucket.frontend_bucket.bucket
  key    = "style.css"
  source = "../Frontend/style.css"  # Path to your local file
  content_type = "text/css"
#   acl    = "public-read"
}

resource "aws_s3_bucket_object" "app_js" {
  bucket = aws_s3_bucket.frontend_bucket.bucket
  key    = "app.js"
  source = "../Frontend/app.js"  # Path to your local file
  content_type = "application/javascript"
#   acl    = "public-read"
}



