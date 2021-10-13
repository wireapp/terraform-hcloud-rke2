# These are worker-only nodes
resource "hcloud_server" "worker" {
  count       = var.workers_number
  name        = "worker-${var.cluster_name}-${count.index}"
  image       = "ubuntu-20.04"
  server_type = var.worker_type
  ssh_keys    = var.ssh_keys
  location    = "nbg1"
  labels      = { "role-worker" = "1" }
  user_data   = templatefile("${path.module}/worker_userdata.tmpl", {
    extra_ssh_keys = []
    rke2_cluster_secret = var.rke2_cluster_secret
    rke2_url = var.rke2_url
    rke2_channel = "stable"
    node_id = "worker-${var.cluster_name}-${count.index}"
  })
}

# Attach worker nodes to the private network.
# Even though they might be able to reach other nodes through their public IPs,
# the private network (on hetzner at least) is way faster.
resource "hcloud_server_network" "worker" {
  count     = var.workers_number
  server_id = hcloud_server.worker[count.index].id
  subnet_id = var.subnet_id
}

output "worker_ipv4s" {
  value = hcloud_server.worker[*].ipv4_address
}

output "worker_ipv6s" {
  value = hcloud_server.worker[*].ipv6_address
}
