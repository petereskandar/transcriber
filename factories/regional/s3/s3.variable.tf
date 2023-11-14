variable "tags" {
  type        = map(string)
  default     = {}
  description = ""
}

variable "domain_name" {
  type        = string
  description = "Public domain name needed for ACM Certificate Creation and DNS records creation"
}

variable "domain_name_prefix" {
  type        = string
  description = "domain prefix for public app exposure : webapp.petereskandar.eu"
}
