variable "region" {
  default = "ap-southeast-1"
  description = "aws region"
}

variable "availability_zone" {
  default = "ap-southeast-1a"
  description = "aws availability zone"
}

variable "key_name" {
  default = "playlisten"
  description = "aws ssh key"
}

variable "db_pass" {
  default = "playlisten"
  description = "aws mysql password"
}

variable "rds_identifier" {
  default = "playlisten-sql"
  description = "rds endpoint"
}
