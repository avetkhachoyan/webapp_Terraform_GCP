output "app_py" {
  description = "Created cloudfunction"
  value       = google_cloudfunctions_function.ph_clfunction.name
}