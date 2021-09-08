resource "hcloud_ssh_key" "root" {
  name       = "root-${var.cluster_name}"
  public_key = tls_private_key.root[0].public_key_openssh
  count      = var.ssh_key_create ? 1 : 0
}

# These are controlplane nodes, running etcd.
# They optionally also run worker payloads.
resource "hcloud_server" "controlplane" {
  count       = var.controlplane_number
  name        = "controlplane-${var.cluster_name}-${count.index}"
  image       = "ubuntu-20.04"
  server_type = var.controlplane_type
  ssh_keys    = var.ssh_key_create ? [hcloud_ssh_key.root[0].name] : []
  location    = "nbg1"
  labels = merge(
    { "role-controlplane" = "1" },
    var.controlplane_has_worker ? { "role-worker" = "1" } : {}
  )
  user_data = count.index == 0 ? local.userdata_server_bootstrap : local.userdata_server
}

# Attach controlplane nodes to the private network.
resource "hcloud_server_network" "controlplane" {
  count     = var.controlplane_number
  server_id = hcloud_server.controlplane[count.index].id
  subnet_id = hcloud_network_subnet.nodes.id
}

output "controlplane_ipv4s" {
  value = hcloud_server.controlplane[*].ipv4_address
}

output "controlplane_ipv6s" {
  value = hcloud_server.controlplane[*].ipv6_address
}

# These are worker-only nodes
resource "hcloud_server" "worker" {
  count       = var.workers_number
  name        = "worker-${var.cluster_name}-${count.index}"
  image       = "ubuntu-20.04"
  server_type = var.worker_type
  ssh_keys    = var.ssh_key_create ? [hcloud_ssh_key.root[0].name] : []
  location    = "nbg1"
  labels      = { "role-worker" = "1" }
  user_data   = local.userdata_agent
}

# Attach worker nodes to the private network.
# Even though they might be able to reach other nodes through their public IPs,
# the private network (on hetzner at least) is way faster.
resource "hcloud_server_network" "worker" {
  count     = var.workers_number
  server_id = hcloud_server.worker[count.index].id
  subnet_id = hcloud_network_subnet.nodes.id
}

output "worker_ipv4s" {
  value = hcloud_server.worker[*].ipv4_address
}

output "worker_ipv6s" {
  value = hcloud_server.worker[*].ipv6_address
}
