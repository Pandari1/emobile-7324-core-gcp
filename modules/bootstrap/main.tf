locals {
  repositories = {
    core = {
      name     = var.core_repository_name
      branches = var.core_allowed_branches
    }
    compute = {
      name     = var.compute_repository_name
      branches = var.compute_allowed_branches
    }
  }

  repo_branch_pairs = flatten([
    for repo_key, repo in local.repositories : [
      for branch in repo.branches : {
        key        = "${repo_key}:${branch}"
        repo_key   = repo_key
        repository = repo.name
        branch     = branch
      }
    ]
  ])

  attribute_condition = join(" || ", [
    for pair in local.repo_branch_pairs :
    "(assertion.repository == '${var.github_organization}/${pair.repository}' && assertion.ref == 'refs/heads/${pair.branch}')"
  ])
}

resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "sts.googleapis.com"
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_storage_bucket" "terraform_state" {
  count = var.create_state_bucket ? 1 : 0

  name                        = var.state_bucket_name
  location                    = var.bucket_location
  project                     = var.project_id
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 10
    }

    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.services]
}

resource "google_service_account" "core_deployer" {
  account_id   = "${var.prefix}-core-deployer"
  display_name = "Core repository deployer"
  description  = "Used by GitHub Actions in the core repository."
}

resource "google_service_account" "compute_deployer" {
  account_id   = "${var.prefix}-compute-deployer"
  display_name = "Compute repository deployer"
  description  = "Used by GitHub Actions in the compute repository."
}

resource "google_project_iam_member" "core_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.core_deployer.email}"
}

resource "google_project_iam_member" "compute_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.compute_deployer.email}"
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "GitHub Actions Pool"
  description               = "OIDC federation for GitHub Actions deployments."
  disabled                  = false

  depends_on = [google_project_service.services]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider_id
  display_name                       = "GitHub Actions Provider"
  description                        = "Trusts tokens issued by GitHub Actions."

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.ref"        = "assertion.ref"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = local.attribute_condition

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "core_wif" {
  service_account_id = google_service_account.core_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_organization}/${var.core_repository_name}"
}

resource "google_service_account_iam_member" "compute_wif" {
  service_account_id = google_service_account.compute_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_organization}/${var.compute_repository_name}"
}
