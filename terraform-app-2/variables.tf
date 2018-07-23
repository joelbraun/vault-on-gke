variable "region" {
  type    = "string"
  default = "us-east4"
}

variable "zone" {
  type    = "string"
  default = "us-west1-a"
}

variable "project_id" {
  type    = "string"
  default = "id-test-deploy-2"
}

variable "instance_type" {
  type    = "string"
  default = "n1-standard-1"
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
    "roles/errorreporting.writer",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/cloudtrace.agent",
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

variable "kubernetes_version" {
  type    = "string"
  default = "1.9.7-gke.4"
}

variable "num_vault_servers" {
  type    = "string"
  default = "2"
}
