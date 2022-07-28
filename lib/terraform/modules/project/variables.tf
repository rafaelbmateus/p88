variable "name" {
  description = "project name"
}

variable "env" {
  description = "environment"
}

variable "purpose" {
  description = "project purpose"
}

variable "resources" {
  type = list(string)
  description = "project resources"
}