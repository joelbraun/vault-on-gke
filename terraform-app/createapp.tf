# Builds application cluster for IdentityServer
provider "google" {
  region  = "${var.region}"
  zone    = "${var.zone}"
  project = "${var.project_id}"
}

# Create the service account
resource "google_service_account" "identity-server" {
  account_id   = "identity-server"
  display_name = "Identity Server"
  project      = "${var.project_id}"
}

# Create a service account key
resource "google_service_account_key" "identity" {
  service_account_id = "${google_service_account.identity-server.name}"
}

# Add the service account to the project
resource "google_project_iam_member" "service-account" {
  count   = "${length(var.service_account_iam_roles)}"
  project = "${var.project_id}"
  role    = "${element(var.service_account_iam_roles, count.index)}"
  member  = "serviceAccount:${google_service_account.identity-server.email}"
}

# Enable required services on the project
resource "google_project_service" "service" {
  count   = "${length(var.project_services)}"
  project = "${var.project_id}"
  service = "${element(var.project_services, count.index)}"

  # Do not disable the service on destroy. On destroy, we are going to
  # destroy the project, but we need the APIs available to destroy the
  # underlying resources.
  disable_on_destroy = false
}

resource "google_container_cluster" "identity" {
  name    = "identity"
  project = "${var.project_id}"
  zone    = "${var.zone}"

  min_master_version = "${var.kubernetes_version}"
  node_version       = "${var.kubernetes_version}"

  initial_node_count = "${var.num_vault_servers}"

  node_config {
    machine_type    = "${var.instance_type}"
    service_account = "${google_service_account.identity-server.email}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/iam",
    ]

    tags = ["identity"]
  }

  depends_on = ["google_project_service.service"]
}

resource "google_compute_global_address" "identity" {
  name       = "identity-lb"
  depends_on = ["google_project_service.service"]
}

# This file contains all the interactions with Kubernetes
provider "kubernetes" {
  host     = "${google_container_cluster.identity.endpoint}"
  username = "${google_container_cluster.identity.master_auth.0.username}"
  password = "${google_container_cluster.identity.master_auth.0.password}"

  client_certificate     = "${base64decode(google_container_cluster.identity.master_auth.0.client_certificate)}"
  client_key             = "${base64decode(google_container_cluster.identity.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.identity.master_auth.0.cluster_ca_certificate)}"
}

# # Write the configmap
# resource "kubernetes_config_map" "vault" {
#   metadata {
#     name = "vault"
#   }

#   data {
#     load_balancer_address = "${google_compute_address.vault.address}"
#     gcs_bucket_name       = "${google_storage_bucket.vault.name}"
#     kms_key_id            = "${google_kms_crypto_key.vault-init.id}"
#   }
# }

# Render the YAML file
data "template_file" "app" {
  template = "${file("${path.module}/../k8s/app.yaml")}"

  vars {
    load_balancer_ip  = "${google_compute_global_address.identity.name}"
    num_vault_servers = "${var.num_vault_servers}"
  }
}

# Submit the job
resource "null_resource" "apply" {
  triggers {
    host                   = "${md5(google_container_cluster.identity.endpoint)}"
    username               = "${md5(google_container_cluster.identity.master_auth.0.username)}"
    password               = "${md5(google_container_cluster.identity.master_auth.0.password)}"
    client_certificate     = "${md5(google_container_cluster.identity.master_auth.0.client_certificate)}"
    client_key             = "${md5(google_container_cluster.identity.master_auth.0.client_key)}"
    cluster_ca_certificate = "${md5(google_container_cluster.identity.master_auth.0.cluster_ca_certificate)}"
  }

  provisioner "local-exec" {
    command = <<EOF
gcloud container clusters get-credentials "${google_container_cluster.identity.name}" --zone="${google_container_cluster.identity.zone}" --project="${google_container_cluster.identity.project}"
kubectl config set-context "gke_${google_container_cluster.identity.project}_${google_container_cluster.identity.zone}_${google_container_cluster.identity.name}"

echo '${data.template_file.app.rendered}' | kubectl apply -f -
EOF
  }
}

resource "null_resource" "add_tls_secret" {
  triggers {
    host                   = "${md5(google_container_cluster.identity.endpoint)}"
    username               = "${md5(google_container_cluster.identity.master_auth.0.username)}"
    password               = "${md5(google_container_cluster.identity.master_auth.0.password)}"
    client_certificate     = "${md5(google_container_cluster.identity.master_auth.0.client_certificate)}"
    client_key             = "${md5(google_container_cluster.identity.master_auth.0.client_key)}"
    cluster_ca_certificate = "${md5(google_container_cluster.identity.master_auth.0.cluster_ca_certificate)}"
  }

  provisioner "local-exec" {
    command = <<EOF
kubectl create secret tls tlssecret --key MyKey.key --cert MyCertificate.crt
EOF
  }

  depends_on = ["null_resource.apply"]
}

data "template_file" "ingress" {
  template = "${file("${path.module}/../k8s/ingress.yaml")}"
}

resource "null_resource" "add_ingress" {
  triggers {
    host                   = "${md5(google_container_cluster.identity.endpoint)}"
    username               = "${md5(google_container_cluster.identity.master_auth.0.username)}"
    password               = "${md5(google_container_cluster.identity.master_auth.0.password)}"
    client_certificate     = "${md5(google_container_cluster.identity.master_auth.0.client_certificate)}"
    client_key             = "${md5(google_container_cluster.identity.master_auth.0.client_key)}"
    cluster_ca_certificate = "${md5(google_container_cluster.identity.master_auth.0.cluster_ca_certificate)}"
  }

  provisioner "local-exec" {
    command = <<EOF
echo '${data.template_file.ingress.rendered}' | kubectl apply -f -
EOF
  }

  depends_on = ["null_resource.add_tls_secret"]
}
