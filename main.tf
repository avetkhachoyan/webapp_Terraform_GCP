### Secrets ###

resource "google_secret_manager_secret" "user_name_secret" {
  secret_id = var.user_name_secret
  replication { 
    auto {}  
  }
}

resource "google_secret_manager_secret_version" "user_name_secret_value" {
  secret = google_secret_manager_secret.user_name_secret.id
  secret_data = var.user_name_secret
}

resource "google_secret_manager_secret" "root_password_secret" {
  secret_id = var.root_password_secret
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "root_password_secret_value" {
  secret = google_secret_manager_secret.root_password_secret.id
  secret_data = var.root_password_secret
}

resource "google_secret_manager_secret" "user_password_secret" {
  secret_id = var.user_password_secret
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "user_password_secret_value" {
  secret = google_secret_manager_secret.user_password_secret.id
  secret_data = var.user_password_secret
}

resource "google_secret_manager_secret" "connection_string" {
  secret_id = "mysql-connection-string"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "connection_string_value" {
  secret = google_secret_manager_secret.connection_string.id
  secret_data = "mysql://${var.user_name_secret}:${var.user_password_secret}@localhost:3306/mysql-database"
}


### Encryption Key ###

resource "google_kms_key_ring" "key_ring" {
  name     = "db-key-ring"
  location = var.location
}

resource "google_kms_crypto_key" "key" {
  key_ring     = google_kms_key_ring.key_ring.name
  purpose      = "ENCRYPT_DECRYPT"
  name         = "db-key"
}


### Database Configuration ###

resource "google_cloud_run_service" "mysql_database" {
  name     = "mysql-database"
  location = var.location
  template {
    spec {
      containers {
        image = "mysql:latest"
        ports {
          container_port = 3306
        }
        env {
          name  = "MYSQL_ROOT_PASSWORD"
          value = google_secret_manager_secret_version.root_password_secret_value.secret_data
        }
        env {
          name  = "MYSQL_USER_NAME"
          value = google_secret_manager_secret_version.user_name_secret_value.secret_data
        }
        env {
          name  = "MYSQL_USER_PASSWORD"
          value = google_secret_manager_secret_version.user_password_secret_value.secret_data
        }
      }
    }
  }
}

resource "google_sql_database_instance" "mysql_instance" {
  name     = "db-mysql-instance"
  database_version   = "MYSQL_5_7"
  deletion_protection = true
  encryption_key_name = google_kms_crypto_key.key
  settings {
    tier              = "db-f1-micro"
    activation_policy = "ALWAYS"
      backup_configuration {
      enabled = true
      start_time = "00:00"
    }
  }
}


### Storage ###

resource "google_storage_bucket" "zip_bucket" {
  name     = "zip-bucket"
  location = var.location
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "function.zip"
  bucket = google_storage_bucket.zip_bucket.name
  source = "webapp_upload/function.zip"
}

resource "google_storage_bucket" "function_bucket" {
  name     = "function-bucket-${random_string.bucket_suffix.result}"
  location = var.location
}

resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}


### CloudFunction ###

resource "google_cloudfunctions_function" "ph_clfunction" {
  name              = var.function_name
  runtime           = "python38"
  entry_point       = "main"
  trigger_http      = true
  available_memory_mb = 256

  source_archive_bucket = google_storage_bucket.zip_bucket.name
  source_archive_object = "webapp_upload/function.zip"

  environment_variables = {
    "MYSQL_CONNECTION_STRING" = google_secret_manager_secret_version.connection_string_value.secret_data
  }
}

### Monitoring ###

resource "google_project_service" "monitoring" {
  service = "monitoring.googleapis.com"
}

resource "google_project_service" "logging" {
  service = "logging.googleapis.com"
}

resource "google_monitoring_uptime_check_config" "cloud_function_uptime_check" {
  display_name = "Cloud Function Uptime Check"
    monitored_resource {
    type = "uptime_url"
    labels = {
    }
  }
  timeout = "5s"
  period = "60s"
  http_check {
    path = "/healthcheck"
    port = 443
    use_ssl = true
  }
}

locals{
  json_file = fileset(path.module, "dashboards/*.json")
}

resource "google_monitoring_dashboard" "cloud_function_dashboard" {
  for_each = local.json_file
  dashboard_json  = file(each.key)
}

resource "google_monitoring_dashboard" "cloud_sql_dashboard" {
  for_each = local.json_file
  dashboard_json  = file(each.key)
}

resource "google_monitoring_notification_channel" "email_channel" {
  display_name = "Email Channel"
  type         = "email"
  labels = {
    email_address = var.email_address
  }
}

resource "google_monitoring_alert_policy" "cloud_function_alert_policy" {
  display_name  = "Cloud Function Alert Policy"
  combiner      = "OR"
  conditions {
    display_name = "Function Latency"
    condition_threshold {
      filter = "metric.type=\"cloudfunctions.googleapis.com/function/execution_duration\" AND resource.type=\"cloud_function\""
      comparison = "COMPARISON_GT"
      threshold_value = "100"
      duration = "60s"
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  notification_channels = ["projects/${var.project_id}/notificationChannels/${google_monitoring_notification_channel.email_channel.id}"] ## Put the vaules of target environment ##
}

resource "google_monitoring_alert_policy" "cloud_sql_alert_policy" {
  display_name  = "Cloud SQL Alert Policy"
  combiner      = "OR"
  conditions {
    display_name = "Database CPU Utilization"
    condition_threshold {
      filter = "metric.type=\"sql.googleapis.com/database/cpu/utilization\" AND resource.type=\"cloudsql_database\""
      comparison = "COMPARISON_GT"
      threshold_value = "80"
      duration = "60s"
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  notification_channels = ["projects/${var.project_id}/notificationChannels/${google_monitoring_notification_channel.email_channel.id}"]
}
