variable "my_ip" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type    = string
  default = "Aa12345#"
}