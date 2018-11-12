terraform {
  backend "gcs" {
    bucket = "backend-prod-infra-221411"
    prefix = "terraform/state"
  }
}
