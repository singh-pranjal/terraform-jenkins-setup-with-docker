provider "aws" {
region=var.region  
}
resource "aws_vpc" "my-jenkins" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name="Jenkins-vpc"
  }
} 

resource "aws_security_group" "jenkins-sg" {
  name = "jenkins-sg"
  vpc_id = aws_vpc.my-jenkins.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-jenkins.id
  tags = {
    name="jenkins-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my-jenkins.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    name="jenkins-public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my-jenkins.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags ={
    name="jenkins-public-rt"
  }
}
resource "aws_route_table_association" "public_assoc" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_instance" "jenkins" {
    ami = "ami-07ff62358b87c7116"
    instance_type = var.instance-type
    key_name = "test"
    vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
    subnet_id = aws_subnet.public_subnet.id
  
  user_data = file("user-data.sh")
  tags = {
    name="terraform jenkins"
  }
}