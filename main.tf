# This token is used to bootstrap the cluster and join new nodes
resource "random_string" "rke2_token" {
  length = 64
}

module "base" {
  source = "./base"

  cluster_name = var.cluster_name
  hetzner_ccm_enabled = var.hetzner_ccm_enabled
}

module "controlplane" {
  source = "./controlplane"

  hcloud_token = var.hcloud_token
  ssh_keys = var.ssh_key_create ? concat([hcloud_ssh_key.root[0].name],data.hcloud_ssh_keys.all_keys.ssh_keys.*.name) : data.hcloud_ssh_keys.all_keys.ssh_keys.*.name

  controlplane_number = var.controlplane_number
  controlplane_type = var.controlplane_type

  rke2_cluster_secret = random_string.rke2_token.result
  cluster_name = var.cluster_name

  lb_ip = module.base.controlplane_lb_ip
  lb_id = module.base.controlplane_lb_id
  network_id = module.base.nodes_network_id
  subnet_id = module.base.nodes_subnet_id

  lb_external_v4 = module.base.controlplane_lb_ipv4
  lb_external_v6 = module.base.controlplane_lb_ipv6

  hetzner_ccm_enabled = var.hetzner_ccm_enabled
  hetzner_ccm_version = var.hetzner_ccm_version
}

module "workers" {
  source = "./workers"

  ssh_keys = var.ssh_key_create ? concat([hcloud_ssh_key.root[0].name],data.hcloud_ssh_keys.all_keys.ssh_keys.*.name) : data.hcloud_ssh_keys.all_keys.ssh_keys.*.name

  workers_number = var.workers_number
  worker_type = var.worker_type

  rke2_cluster_secret = random_string.rke2_token.result
  cluster_name = var.cluster_name

  lb_ip = module.base.controlplane_lb_ip
  lb_id = module.base.controlplane_lb_id
  subnet_id = module.base.nodes_subnet_id
}
