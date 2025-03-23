
variable "REGION" {
  default = "us-east-2"
}

variable "ZONE1" {
  default = "us-east-2a"
}

variable "ZONE2" {
  default = "us-east-2b"
}

variable "AMI_d" {
  default = {
    us-east-2 = "ami-01a017aa67573389c"
  }
}

variable "AMI_b" {
  default = {
    us-east-2 = "ami-059261ff7474f56fe"
  }
}

variable "USER" {
  default = "ubuntu"
}

variable "PUB_KEY" {
  default = "aff-cse-wiz2"
}