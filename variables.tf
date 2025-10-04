variable "aws_region" {
  default     = "ap-southeast-7"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default     = "10.0.2.0/24"
}

variable "public_subnet_az" {
  default     = "ap-southeast-7a"
}

variable "private_subnet_az" {
  default     = "ap-southeast-7b"
}

variable "public_ami" {
  default     = "ami-0e4f6ae724df740e7"  
}

variable "private_ami" {
  default     = "ami-0e4f6ae724df740e7"  
}

variable "instance_type" {
  default     = "t2.micro"
}