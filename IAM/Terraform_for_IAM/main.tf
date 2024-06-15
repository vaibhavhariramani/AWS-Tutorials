provider "aws" {
  region     = "us-east-1"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_iam_role" "example_role" {
  name = "examplerole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "example_attachment" {
  role       = aws_iam_role.example_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_instance" "example_instance" {
  ami           = "ami-06ca3ca175f37dd66"
  instance_type = "t2.micro"
  
  iam_instance_profile = aws_iam_instance_profile.example_profile.name
  tags = {
    Name = "exampleinstance"
  }
}
resource "aws_iam_instance_profile" "example_profile" {
  name = "example_profile"
  role = aws_iam_role.example_role.name
}
resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-bucket-name-terraform"
  
}
resource "aws_s3_bucket_policy" "example_bucket_policy" {
  bucket = aws_s3_bucket.example_bucket.id
  policy = data.aws_iam_policy_document.example_bucket_policy.json
}

data "aws_iam_policy_document" "example_bucket_policy" {
  statement {
    principals {
      type        = "AWS"
       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.example_role.name}"]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.example_bucket.arn,
      "${aws_s3_bucket.example_bucket.arn}/*",
    ]
  }
}

# resource "aws_s3_bucket_policy" "example_bucket_policy" {
#   depends_on = [ aws_s3_bucket.example_bucket ]
#   bucket = aws_s3_bucket.example_bucket.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "s3:GetObject",
#         Effect = "Allow",
#         Resource = "${aws_s3_bucket.example_bucket.arn}/*",
#         Principal = "*"
#       }
#     ]
#   })
# }
data "aws_caller_identity" "current" {}