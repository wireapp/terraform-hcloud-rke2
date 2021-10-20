# This token is used to bootstrap the cluster and join new nodes
resource "random_string" "rke2_token" {
  length = 64
}

locals {
  # In case ssh_key_create is set to true, append the created ssh key name to
  # the list of ssh keys, else just pass around var.ssh_keys.
  ssh_keys = var.ssh_key_create ? concat([hcloud_ssh_key.root[0].name], var.ssh_keys) : var.ssh_keys
}

module "base" {
  source = "./base"

  cluster_name        = var.cluster_name
  hetzner_ccm_enabled = var.hetzner_ccm_enabled
}

module "controlplane" {
  source = "./controlplane"

  ssh_keys = local.ssh_keys

  hcloud_token        = var.hcloud_token
  hetzner_ccm_enabled = var.hetzner_ccm_enabled

  node_count  = var.controlplane_count
  node_prefix = "controlplane-${var.cluster_name}"
  node_type = var.controlplane_type

  rke2_cluster_secret = random_string.rke2_token.result
  rke2_url            = "https://${module.base.controlplane_lb_ip}:9345"

  network_id = module.base.nodes_network_id
  subnet_id  = module.base.nodes_subnet_id

  tls_san = [
    module.base.controlplane_lb_ip,
    module.base.controlplane_lb_ipv4,
    module.base.controlplane_lb_ipv6
  ]
}

module "workers" {
  source = "./workers"

  ssh_keys = local.ssh_keys

  node_count  = var.worker_count
  node_prefix = "worker-${var.cluster_name}-"
  node_type = var.worker_type

  subnet_id = module.base.nodes_subnet_id

  rke2_cluster_secret = random_string.rke2_token.result
  rke2_url            = "https://${module.base.controlplane_lb_ip}:9345"
}
