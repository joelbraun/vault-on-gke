# This file contains all the interactions with Google Cloud
provider "google" {
  region  = "${var.region}"
  zone    = "${var.zone}"
  project = "${var.project_id}"
}

variable "region" {
  type    = "string"
  default = "us-east4"
}

variable "zone" {
  type    = "string"
  default = "us-east4-b"
}

variable "project_id" {
  type    = "string"
  default = "id-test-deploy-2"
}

variable "instance_type" {
  type    = "string"
  default = "n1-standard-1"
}

variable "storage_bucket" {
  type    = "string"
  default = "id-test-deploy-2-vault"
}

variable "kms_keyring_name" {
  type    = "string"
  default = "vault"
}

module "vault" {
  source           = "github.com/GoogleCloudPlatform/terraform-google-vault"
  project_id       = "${var.project_id}"
  region           = "${var.region}"
  zone             = "${var.zone}"
  storage_bucket   = "${var.storage_bucket}"
  kms_keyring_name = "${var.kms_keyring_name}"
}
