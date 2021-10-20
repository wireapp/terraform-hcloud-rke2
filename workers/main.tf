# These are worker-only nodes
resource "hcloud_server" "worker" {
  count       = var.node_count
  name        = "${var.node_prefix}-${count.index}"
  image       = "ubuntu-20.04"
  server_type = var.node_type
  ssh_keys    = var.ssh_keys
  location    = "nbg1"
  labels      = { "role-worker" = "1" }
  user_data   = templatefile("${path.module}/userdata.tmpl", {
    rke2_channel = "stable"
    rke2_cluster_secret = var.rke2_cluster_secret
    rke2_url = var.rke2_url
  })
}

# Attach worker nodes to the private network.
# Even though they might be able to reach other nodes through their public IPs,
# the private network (on hetzner at least) is way faster.
resource "hcloud_server_network" "worker" {
  count     = var.node_count
  server_id = hcloud_server.worker[count.index].id
  subnet_id = var.subnet_id
}
