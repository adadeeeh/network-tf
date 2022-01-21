variable "public_subnet_count" {
  description = "Number of public subnet"
  type        = number
  default     = 3
}

variable "private_subnet_count" {
  description = "Number of private subnet"
  type        = number
  default     = 3
}

variable "subnet_cidr_blocks" {
  description = "Available CIDR blocks"
  type        = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24"
  ]
}