variable "region" {
  default = "ap-southeast-1"
  description = "aws region"
}

variable "availability_zone" {
  default = "ap-southeast-1a"
  description = "aws availability zone"
}

variable "registered_domain_dns_addr" {
  default = "54.179.59.254"
  description = "google dns playlisten.app record addr"
}

variable "key_name" {
  default = "playlisten"
  description = "aws ssh key"
}
