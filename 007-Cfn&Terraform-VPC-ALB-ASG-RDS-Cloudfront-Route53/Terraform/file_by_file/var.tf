variable "key_pair" {
  default = "serdar_client"
}

variable "vpc_cidr" {
  default = "90.90.0.0/16"
}

variable "public_subnet_A_cidr" {
  default = "90.90.10.0/24"
}

variable "public_subnet_B_cidr" {
  default = "90.90.20.0/24"
}

variable "private_subnet_A_cidr" {
  default = "90.90.11.0/24"
}

variable "private_subnet_B_cidr" {
  default = "90.90.21.0/24"
}

variable "dbtype" {
  default = "db.t2.micro"
}

variable "dbusername" {
  default = "admin"
}

variable "dbpassword" {
  default = "Serdar_1"
}

variable "dbname" {
  default = "clarusway_phonebook"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "serdar-dynamic-ports" {
  default = [80,443]
}

variable "mydomainname" {
  default = "clarusway.us"
}

variable "sub_domain_name" {
  default = "www.clarusway.us"
}
