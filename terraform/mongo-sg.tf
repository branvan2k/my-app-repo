resource "aws_security_group" "mongo_sg" {
  name        = "allow-mongoCom-sg"
  description = "Allow inbound traffic on port 27017 for MongoDB"
  vpc_id      = aws_vpc.aff2_vpc.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "mongo-sg"
  }
}