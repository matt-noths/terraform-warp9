terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "5.82.2"
        }
    }
}

provider "aws" {
    region = "eu-west-2"
}

variable "ingressrules" {
    type = list(number)
    default = [80, 443]
}

variable "egressrules" {
    type = list(number)
    default = [80, 443]
}


resource "aws_security_group" "webtraffic" {
    name = "matt.noodletown.securitygroup"

    dynamic "ingress" {
        iterator = port
        for_each = var.ingressrules
        content {
            from_port = port.value
            to_port   = port.value
            protocol  = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    dynamic "egress" {
        iterator = port
        for_each = var.egressrules
        content {
            from_port = port.value
            to_port   = port.value
            protocol  = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

resource "aws_instance" "ec2" {
    ami = "ami-032598fcc7e9d1c7a"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.webtraffic.name]
    tags = {
        Name = "matt.noodletown02"
    }
    # Specify the startup script here
    user_data = <<-EOF
    #!/bin/bash
    sudo yum update
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1>Hello from Terraform</h1>" | sudo tee /var/www/html/index.html
  EOF
}

resource "aws_eip" "elasticeip" {
    instance = aws_instance.ec2.id
}

output "EIP" {
    value = aws_eip.elasticeip.public_ip
}
