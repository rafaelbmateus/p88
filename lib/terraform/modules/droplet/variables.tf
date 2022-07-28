variable "name" {
  description = "droplet name"
}

variable "env" {
  description = "environment"
}

variable "image" {
  description = "droplet image version"
}

variable "region" {
  description = "droplet location"
}

variable "size" {
  description = "droplet size"
}

variable "tags" {
  description = "droplet tags"
}

variable "user" {
  description = "username to user root"
}

variable "user_pvt_key" {
  description = "user root private key"
}

variable "ssh_fingerprint" {
  description = "ssh keys fingerprint"
}


