variable "db_password" {
  description = "Password for PostgreSQL"
  type        = string
  sensitive   = true
  default     = "securepassword"
}
