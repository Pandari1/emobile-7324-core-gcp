variable "prefix" {
  description = "Common resource naming prefix."
  type        = string
}

variable "region" {
  description = "Primary GCP region."
  type        = string
}

variable "subnet_cidr" {
  description = "Primary subnet CIDR."
  type        = string
}

variable "pods_cidr" {
  description = "Secondary CIDR used for GKE pods."
  type        = string
}

variable "services_cidr" {
  description = "Secondary CIDR used for GKE services."
  type        = string
}
