provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"
  name    = ["backend-prod-infra-221411", "backend-stage-infra-221411"]
}

output storage-bucket_url {
  value = "${module.storage-bucket.url}"
}
