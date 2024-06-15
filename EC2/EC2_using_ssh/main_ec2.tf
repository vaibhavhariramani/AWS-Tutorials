terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"

}

resource "aws_instance" "example_server" {
  ami           = "ami-04e914639d0cca79a"
  instance_type = "t2.micro"
  key_name = "terraform_ec2_key"

  user_data = <<EOF
#!/bin/bash
echo "Copying the SSH Key to the server"
echo -e "${var.ssh_key}" >> /home/ubuntu/.ssh/authorized_keys
EOF

  tags = {
    Name = "DemoBlogExample"
  }
}

resource "aws_key_pair" "terraform_ec2_key" {
	key_name = "terraform_ec2_key"
	public_key = "${file("terraform_ec2_key.pub")}"
}
