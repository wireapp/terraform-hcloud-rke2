# These are controlplane nodes, running etcd.
# They optionally also run worker payloads.
resource "hcloud_server" "controlplane" {
  count       = var.controlplane_number
  name        = "controlplane-${var.cluster_name}-${count.index}"
  image       = "ubuntu-20.04"
  server_type = var.controlplane_type
  ssh_keys    = var.ssh_keys
  location    = "nbg1"
  labels = merge(
    { "role-controlplane" = "1" },
    var.controlplane_has_worker ? { "role-worker" = "1" } : {}
  )
  user_data   = templatefile("${path.module}/controlplane_userdata.tmpl", {
    extra_ssh_keys = []
    rke2_cluster_secret = var.rke2_cluster_secret
    lb_address = var.lb_ip
    lb_external_v4 = var.lb_external_v4
    lb_external_v6 = var.lb_external_v6
    master_index = count.index
    rke2_channel = "stable"
    clustername = var.cluster_name
    lb_id = var.lb_id
    hcloud_token = var.hcloud_token
    network_id_encoded = base64encode(var.network_id)
    node_id = "worker-${var.cluster_name}-${count.index}"
    node_taint = yamlencode((! var.controlplane_has_worker) ? ["node-role.kubernetes.io/etcd=true:NoExecute","node-role.kubernetes.io/controlplane=true:NoSchedule"] : [])
  })
}

# Attach controlplane nodes to the private network.
resource "hcloud_server_network" "controlplane" {
  count     = var.controlplane_number
  server_id = hcloud_server.controlplane[count.index].id
  subnet_id = var.subnet_id
}

output "controlplane_ipv4s" {
  value = hcloud_server.controlplane[*].ipv4_address
}

output "controlplane_ipv6s" {
  value = hcloud_server.controlplane[*].ipv6_address
}
