provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.gcp_credentials
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.21.0"
    }
    github = {
      source = "integrations/github"
    }
  }
}
