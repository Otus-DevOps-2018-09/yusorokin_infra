variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-base-db"
}

variable "zone" {
  description = "Instance zone"
  default     = "europe-west1-b"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable "do_provision" {
  description = "If true then provisioning will go on"
  default     = true
}
