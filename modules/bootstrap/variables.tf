variable "project_id" {
  description = "Target GCP project ID."
  type        = string
}

variable "region" {
  description = "Primary GCP region."
  type        = string
}

variable "prefix" {
  description = "Common resource naming prefix."
  type        = string
}

variable "github_organization" {
  description = "GitHub organization or user that owns both repositories."
  type        = string
}

variable "core_repository_name" {
  description = "Repository name for the core infrastructure repo."
  type        = string
}

variable "compute_repository_name" {
  description = "Repository name for the compute infrastructure repo."
  type        = string
}

variable "core_allowed_branches" {
  description = "Branches in the core repo allowed to federate into GCP."
  type        = list(string)
}

variable "compute_allowed_branches" {
  description = "Branches in the compute repo allowed to federate into GCP."
  type        = list(string)
}

variable "workload_identity_pool_id" {
  description = "Workload Identity Pool ID."
  type        = string
}

variable "workload_identity_provider_id" {
  description = "Workload Identity Provider ID."
  type        = string
}

variable "create_state_bucket" {
  description = "Whether Terraform should create the remote state bucket."
  type        = bool
}

variable "state_bucket_name" {
  description = "Globally unique GCS bucket name for Terraform state."
  type        = string
}

variable "bucket_location" {
  description = "Location for the Terraform state bucket."
  type        = string
}
