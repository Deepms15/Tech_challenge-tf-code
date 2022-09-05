provider "aws" {
  region      = var.aws["region"]
  profile     = var.aws["profile"]    
}

terraform {
    backend "s3" {}
}

resource "aws_s3_bucket" "b" {
  bucket = var.s3-bucket
  tags = var.common_tags
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
/*
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.b.id
  versioning_configuration {
    status = "Enabled"
  }
}
*/
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.b.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}
/*
resource "aws_s3_object" "object" {
  bucket = var.s3-log-bucket
  key    = var.s3-log-folder
}

resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.b.id

  target_bucket = var.s3-log-bucket
  target_prefix = var.s3-log-folder
}
*/
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.b.id
  policy = file("./template/policy.json")
}

resource "aws_s3_bucket_ownership_controls" "bucket_owner" {
  bucket = aws_s3_bucket.b.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
