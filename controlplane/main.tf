# These are controlplane nodes, running etcd.
# They optionally also run worker payloads.
resource "hcloud_server" "controlplane" {
  count       = var.node_count
  name        = "controlplane-${var.cluster_name}-${count.index}"
  image       = "ubuntu-20.04"
  server_type = var.server_type
  ssh_keys    = var.ssh_keys
  location    = "nbg1"
  labels = merge(
    { "role-controlplane" = "1" },
    var.controlplane_has_worker ? { "role-worker" = "1" } : {}
  )
  user_data = templatefile("${path.module}/controlplane_userdata.tmpl", {
    rke2_cluster_secret = var.rke2_cluster_secret
    tls_san             = [ var.lb_ip, var.lb_external_v4, var.lb_external_v6 ]
    master_index        = count.index
    rke2_channel        = "stable"
    rke2_url            = "https://${var.lb_ip}:9345"
    clustername         = var.cluster_name
    hcloud_token        = var.hcloud_token
    network_id          = var.network_id
    node_id             = "worker-${var.cluster_name}-${count.index}"
    node_taint          = yamlencode((! var.controlplane_has_worker) ? ["node-role.kubernetes.io/etcd=true:NoExecute", "node-role.kubernetes.io/controlplane=true:NoSchedule"] : [])
  })
}

# Attach controlplane nodes to the private network.
resource "hcloud_server_network" "controlplane" {
  count     = var.node_count
  server_id = hcloud_server.controlplane[count.index].id
  subnet_id = var.subnet_id
}

output "controlplane_ipv4s" {
  value = hcloud_server.controlplane[*].ipv4_address
}

output "controlplane_ipv6s" {
  value = hcloud_server.controlplane[*].ipv6_address
}
