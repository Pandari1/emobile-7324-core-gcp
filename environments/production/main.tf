terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.30"
    }
  }

  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "bootstrap" {
  source = "../../modules/bootstrap"

  project_id                    = var.project_id
  region                        = var.region
  prefix                        = var.prefix
  github_organization           = var.github_organization
  core_repository_name          = var.core_repository_name
  compute_repository_name       = var.compute_repository_name
  core_allowed_branches         = var.core_allowed_branches
  compute_allowed_branches      = var.compute_allowed_branches
  workload_identity_pool_id     = var.workload_identity_pool_id
  workload_identity_provider_id = var.workload_identity_provider_id
  create_state_bucket           = var.create_state_bucket
  state_bucket_name             = var.state_bucket_name
  bucket_location               = var.bucket_location
}

module "networking" {
  source = "../../modules/networking"

  prefix        = var.prefix
  region        = var.region
  subnet_cidr   = var.subnet_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr
}
