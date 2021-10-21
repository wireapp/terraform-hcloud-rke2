locals {
  node_taint = (var.controlplane_has_worker) ? [] : ["node-role.kubernetes.io/control-plane=true:NoSchedule"]

  rke2_config_seed = {
    "disable-cloud-controller" = var.hetzner_ccm_enabled,
    "tls-san"                  = var.tls_san,
    "token"                    = var.rke2_cluster_secret,
    "node-taint"               = local.node_taint
    "kube-apiserver-arg" = [
      "kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"
    ]
    "kubelet-arg" = (var.hetzner_ccm_enabled) ? [
      "cloud-provider=external"
    ] : []
  }

  # Same as rke2_config_seed, except server is set
  rke2_config = merge(local.rke2_config_seed, {
    server = var.rke2_url
  })

  cloud_config_seed = {
    write_files = concat([
      { path        = "/etc/rancher/rke2/config.yaml",
        permissions = "0600",
        owner       = "root:root",
        content     = jsonencode(local.rke2_config_seed)
      },
      { path        = "/opt/rke2/install_rke2.sh",
        permissions = "0755",
        owner       = "root:root",
        content     = file("${path.module}/install_rke2.sh")
      },
      { path        = "/var/lib/rancher/rke2/server/manifests/rke2-canal-config.yaml",
        permissions = "0600",
        owner       = "root:root",
        content     = file("${path.module}/rke2-canal-config.yaml"),
      }],

      # system-upgrade-controller
      [
        { path        = "/var/lib/rancher/rke2/server/manifests/system-upgrade-controller.yaml",
          permissions = "0600",
          owner       = "root:root",
          content     = file("${path.module}/system-upgrade-controller.yaml"),
        }
      ],

      # hetzner ccm
      (!var.hetzner_ccm_enabled) ? [] : [
        { path        = "/var/lib/rancher/rke2/server/manifests/hcloud-secret.yaml",
          permissions = "0600",
          owner       = "root:root",
          content = templatefile("${path.module}/hcloud-secret.yaml.tpl", {
            hcloud_token = var.hcloud_token,
            network_id   = var.network_id,
          }),
        },
        { path        = "/var/lib/rancher/rke2/server/manifests/rke2-ingress-hcloud-lb.yaml",
          permissions = "0600",
          owner       = "root:root",
          content     = file("${path.module}/rke2-ingress-hcloud-lb.yaml"),
        },
        { path        = "/var/lib/rancher/rke2/server/manifests/hcloud-ccm-networks.yaml",
          permissions = "0600",
          owner       = "root:root",
          content     = file("${path.module}/hcloud-ccm-networks.yaml"),
        }
    ])

    runcmd = [
      "apt-get update",
      "apt-get install -y jq",
      "/opt/rke2/install_rke2.sh",
    ]
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
      },
    ]
    runcmd : [
      "apt-get update",
      "apt-get install -y jq",
      "/opt/rke2/install_rke2.sh",
    ]
  }
}

# These are controlplane nodes, running etcd.
# They optionally also run worker payloads.
resource "hcloud_server" "controlplane" {
  count       = var.node_count
  name        = "${var.node_prefix}-${count.index}"
  image       = "ubuntu-20.04"
  server_type = var.node_type
  ssh_keys    = var.ssh_keys
  location    = "nbg1"
  labels = merge(
    { "role-controlplane" = "1" },
    var.controlplane_has_worker ? { "role-worker" = "1" } : {}
  )
  user_data = count.index == 0 ? "#cloud-config\n${jsonencode(local.cloud_config_seed)}" : "#cloud-config\n${jsonencode(local.cloud_config)}"
}

# Attach controlplane nodes to the private network.
resource "hcloud_server_network" "controlplane" {
  count     = var.node_count
  server_id = hcloud_server.controlplane[count.index].id
  subnet_id = var.node_subnet_id
}
