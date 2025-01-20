# backend.tf

terraform {
  backend "s3" {
    bucket = "flarie-state-file"
    key    = "terraform/statefile"
    region = "us-east-1"
  }
}
