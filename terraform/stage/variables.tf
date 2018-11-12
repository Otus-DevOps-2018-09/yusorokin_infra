variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable "zone" {
  description = "Instance zone"
  default     = "europe-west1-b"
}

variable "count" {
  description = "Instances count"
  default     = "1"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-base-app"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-base-db"
}

variable db_url {
  description = "MongoDB server URL"
  default     = "reddit-db:27017"
}

variable source_ranges {
  description = "Source ip ranges for ssh connection"
  type        = "list"
  default     = ["0.0.0.0/0"]
}

variable "do_provision" {
  description = "If true then provisioning will go on"
  default     = true
}
