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

variable "project" {
  type    = "string"
  default = "id-test-deploy-2"
}

variable "kms_keyring_id" {
  type    = "string"
  default = "vault"
}

variable "kms_key_id" {
  type    = "string"
  default = "vault-init"
}

variable "instance_type" {
  type    = "string"
  default = "n1-standard-2"
}

variable "service_account_iam_roles" {
  type = "list"

  default = [
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/viewer",
  ]
}

variable "project_services" {
  type = "list"

  default = [
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "iam.googleapis.com",
  ]
}

variable "storage_bucket_roles" {
  type = "list"

  default = [
    "roles/storage.legacyBucketReader",
    "roles/storage.objectAdmin",
  ]
}

variable "kms_crypto_key_roles" {
  type = "list"

  default = [
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
  ]
}

variable "kubernetes_version" {
  type    = "string"
  default = "1.10.5-gke.0"
}

variable "num_vault_servers" {
  type    = "string"
  default = "3"
}
