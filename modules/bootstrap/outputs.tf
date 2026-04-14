output "terraform_state_bucket_name" {
  value = var.create_state_bucket ? google_storage_bucket.terraform_state[0].name : var.state_bucket_name
}

output "core_service_account_email" {
  value = google_service_account.core_deployer.email
}

output "compute_service_account_email" {
  value = google_service_account.compute_deployer.email
}

output "workload_identity_provider_name" {
  value = google_iam_workload_identity_pool_provider.github.name
}
