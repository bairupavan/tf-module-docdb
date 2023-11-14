variable "name" {
  default = "docdb"
}
variable "env" {}
variable "tags" {}
variable "subnet_ids" {}
variable "engine_version" {}
variable "port" {
  default = 27017
}
variable "vpc_id" {}
variable "allow_db_cidr" {}
variable "instance_count" {}
variable "instance_class" {}