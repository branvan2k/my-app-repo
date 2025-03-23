resource "aws_security_group" "ec2_sg" {
  name        = "allow_ssh_ping"
  description = "sg for to allow ssh and ping"
  vpc_id      = aws_vpc.aff2_vpc.id

  tags = {
    Name = "Terraform_project_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_ingress_rule" "allow_icmp" {
  security_group_id = aws_security_group.ec2_sg.id
  from_port         = -1
  to_port           = -1
  ip_protocol       = "icmp"
  cidr_ipv4         = "10.0.0.0/16"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}



