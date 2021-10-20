# This token is used to bootstrap the cluster and join new nodes
resource "random_string" "rke2_token" {
  length = 64
}

locals {
  # In case ssh_key_create is set to true, append the created ssh key name to
  # the list of ssh keys, else just pass around var.ssh_keys.
  ssh_keys = var.ssh_key_create ? concat([hcloud_ssh_key.root[0].name], var.ssh_keys) : var.ssh_keys
}

# Create a hcloud network
resource "hcloud_network" "nodes" {
  name     = "nodes"
  ip_range = "10.0.0.0/8"
}

# Create separate subnets for the loadbalancer, controlplanes and workers
resource "hcloud_network_subnet" "lb" {
  network_id   = hcloud_network.nodes.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}

resource "hcloud_network_subnet" "controlplane" {
  network_id   = hcloud_network.nodes.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_network_subnet" "worker" {
  network_id   = hcloud_network.nodes.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.2.0/24"
}

# Create a load balancer in its subnet
module "controlplane_lb" {
  source = "./controlplane-lb"

  lb_type      = "lb11"
  lb_subnet_id = hcloud_network_subnet.lb.id
}

module "controlplane" {
  source = "./controlplane"

  ssh_keys = local.ssh_keys

  hcloud_token        = var.hcloud_token
  hetzner_ccm_enabled = var.hetzner_ccm_enabled

  node_count  = var.controlplane_count
  node_prefix = "controlplane"
  node_type   = var.controlplane_type

  rke2_cluster_secret = random_string.rke2_token.result
  rke2_url            = "https://${module.controlplane_lb.private_ipv4}:9345"

  network_id     = hcloud_network.nodes.id
  node_subnet_id = hcloud_network_subnet.controlplane.id

  tls_san = [
    module.controlplane_lb.private_ipv4,
    module.controlplane_lb.public_ipv4,
    module.controlplane_lb.public_ipv6
  ]
}

module "workers" {
  source = "./workers"

  ssh_keys = local.ssh_keys

  node_count  = var.worker_count
  node_prefix = "worker"
  node_type   = var.worker_type

  node_subnet_id = hcloud_network_subnet.worker.id

  rke2_cluster_secret = random_string.rke2_token.result
  rke2_url            = "https://${module.controlplane_lb.private_ipv4}:9345"
}
