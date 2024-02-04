terraform {
  backend "s3" {
    bucket = "terraform-project-1-2023"
    key    = "IAC"
    region = "us-east-1"
  }
}