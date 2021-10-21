locals {
  rke2_config = {
    "server"      = var.rke2_url
    "token"       = var.rke2_cluster_secret
    "kubelet-arg" = (var.hetzner_ccm_enabled) ? [
      "cloud-provider=external"
    ] : []
  }

  cloud_config = {
    write_files = [
      { path        = "/etc/rancher/rke2/config.yaml",
        permissions = "0600",
        owner       = "root:root",
        content     = jsonencode(local.rke2_config)
      },
      { path        = "/opt/rke2/install_rke2.sh",
        permissions = "0755",
        owner       = "root:root",
        content     = file("${path.module}/install_rke2.sh")
      }
    ]

    runcmd = [
      "apt-get update",
      "apt-get install -y jq",
      "/opt/rke2/install_rke2.sh",
    ]
  }
}

# These are worker-only nodes
resource "hcloud_server" "worker" {
  count       = var.node_count
  name        = "${var.node_prefix}-${count.index}"
  image       = "ubuntu-20.04"
  server_type = var.node_type
  ssh_keys    = var.ssh_keys
  location    = "nbg1"
  labels      = { "role-worker" = "1" }
  user_data   = "#cloud-config\n${jsonencode(local.cloud_config)}"
}

# Attach worker nodes to the private network.
# Even though they might be able to reach other nodes through their public IPs,
# the private network (on hetzner at least) is way faster.
resource "hcloud_server_network" "worker" {
  count     = var.node_count
  server_id = hcloud_server.worker[count.index].id
  subnet_id = var.node_subnet_id
}
