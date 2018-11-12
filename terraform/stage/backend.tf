terraform {
  backend "gcs" {
    bucket = "backend-stage-infra-221411"
    prefix = "terraform/state"
  }
}
