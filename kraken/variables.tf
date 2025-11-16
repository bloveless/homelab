variable "cf_api_key" {
  type = string
  sensitive = true
}

variable "postgres_password" {
  type = string
  sensitive = true
}

variable "mariadb_root_password" {
  type = string
  sensitive = true
}

variable "fritzandandre_app_key" {
  type = string
  sensitive = true
}

variable "fritzandandre_db_password" {
  type = string
  sensitive = true
}
