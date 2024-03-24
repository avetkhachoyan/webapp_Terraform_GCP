variable "project_id" {
  description = "GCP project ID"
  type = string
}

variable "region" {
  description = "GCP region where resources will be deployed"
  type = string
}

variable "location" {
  description = "GCP zone"
  type = string
}

variable "gcp_credentials" {
  type = string
  sensitive = true
  description = "Google Cloud service account credentials"
}

variable "root_password_secret" {}
variable "user_password_secret" {}
variable "user_name_secret" {}

variable "function_name" {
  default = "ph_clfunction"
}

variable "runtime" {
  default = "python38"
}

variable "entry_point" {
  default = "app_function"
}

variable "email_address" {
  type = string
}
