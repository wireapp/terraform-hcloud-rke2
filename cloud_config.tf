# This token is used to bootstrap the cluster and join new nodes
resource "random_string" "rke2_token" {
  length = 64
}

locals {
  # configure rke2_server_url to controlplane_hostname if set, else to the ipv4 of the controlplane load balancer
  rke2_server_url = "https://${var.controlplane_hostname != null ? var.controlplane_hostname : hcloud_load_balancer.controlplane.ipv4}:9345"


  # Configure both the controlplane loadbalancers' IPv4 and IPv6 addresses as
  # SANs, and optionally the controlplane_hostname if set.
  rke2_tls_san = concat(
    [hcloud_load_balancer.controlplane.ipv4, hcloud_load_balancer.controlplane.ipv6],
    var.controlplane_hostname != null ? [var.controlplane_hostname] : []
  )

  # TODO: internal networking!

  userdata_server_bootstrap = module.rke2_cloudconfig_server_bootstrap.userdata
  userdata_server           = module.rke2_cloudconfig_server.userdata
  userdata_agent            = module.rke2_cloudconfig_agent.userdata

  k8s_extra_config = merge(
    var.hetzner_ccm_enabled ? { "kubelet-arg" = "cloud-provider=external" } : {},
    var.hetzner_ccm_enabled ? { "cloud-controller-name": "hcloud" } : {},
    {
      # This configures kube-apiserver to prefer InternalIP over everything
      kube-apiserver-arg = "kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"
    }
  )

  # Before running the installation script, but after cloud-init already provided the
  # /etc/rancher/rke2/config.yaml file, annotate it with the internal ip
  # adresses retrieved from the hcloud metadata server.
  # This is somewhat terrifying, but given there's no yq available on fedora,
  # use some bash :-)
  # We also need to configure the private interface to have a static name, and drop a .link file for that
  install_script_pre = <<-EOC
    internal_ip=$(curl -sfL http://169.254.169.254/hetzner/v1/metadata/private-networks | grep "ip:" | head -n 1| cut -d ":" -f2 | xargs)
    internal_mac=$(curl -sfL http://169.254.169.254/hetzner/v1/metadata/private-networks | grep "mac_address:" | head -n 1 | awk '{print $2}')
    echo "node-ip: $internal_ip" >> /etc/rancher/rke2/config.yaml
    echo -e "[Match]\nMACAddress=$internal_mac\n[Link]\nName=priv" > /etc/systemd/network/80-internal.link
  EOC

  # We can't provide additional files in /var/lib/rancher/rke2/server/manifests during startup,
  # as these get overwritten on startup apparently
  # Until addons are supported in RKE2
  # (https://github.com/rancher/rke2/issues/568), we drop it in
  # /var/lib/rancher/custom_rke2_addons, which is a poormans alternative to it.
  install_script_post = join("\n", [
    <<-EOQ
    cat <<EOF > /var/lib/rancher/custom_rke2_addons/rke2-canal-interface-name.yaml
    apiVersion: helm.cattle.io/v1
    kind: HelmChartConfig
    metadata:
      name: rke2-canal
      namespace: kube-system
    spec:
      valuesContent: |-
        flannel:
          iface: "priv"
    EOF
    EOQ
    ,
    # This installs the Hetzner Cloud Controller Manager if enabled (the default)
    var.hetzner_ccm_enabled ? <<-EOQ
      curl -sfL https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/download/${var.hetzner_ccm_version}/ccm-networks.yaml > /var/lib/rancher/custom_rke2_addons/hetzner_ccm.yaml
      cat << EOG > /var/lib/rancher/custom_rke2_addons/nginx-use-loadbalancer.yaml
      apiVersion: helm.cattle.io/v1
      kind: HelmChartConfig
      metadata:
        name: rke2-ingress-nginx
        namespace: kube-system
      spec:
        valuesContent: |-
          controller:
            kind: Deployment
            autoscaling:
              enabled: true
              minReplicas: 2
              maxReplicas: 3
            hostNetwork: false
            service:
              enabled: true
              type: LoadBalancer
              externalTrafficPolicy: Local
              annotations:
                load-balancer.hetzner.cloud/location: nbg1
      EOG
    EOQ
    : ""
  ])
}

module "rke2_cloudconfig_server_bootstrap" {
  source              = "./cloudconfig-rke2"
  rke2_token          = random_string.rke2_token.result
  server_tls_san      = local.rke2_tls_san
  node_taint          = (! var.controlplane_has_worker) ? ["CriticalAddonsOnly=true:NoExecute"] : []
  install_rke2_type   = "server"
  install_script_pre  = local.install_script_pre
  install_script_post = local.install_script_post
  extra_config        = local.k8s_extra_config
}

module "rke2_cloudconfig_server" {
  source              = "./cloudconfig-rke2"
  rke2_token          = random_string.rke2_token.result
  server_tls_san      = local.rke2_tls_san
  node_taint          = (! var.controlplane_has_worker) ? ["CriticalAddonsOnly=true:NoExecute"] : []
  install_rke2_type   = "server"
  server_url          = local.rke2_server_url
  install_script_pre  = join("\n", [local.install_script_pre, "sleep 200"])
  install_script_post = local.install_script_post
  extra_config        = local.k8s_extra_config
}

module "rke2_cloudconfig_agent" {
  source              = "./cloudconfig-rke2"
  rke2_token          = random_string.rke2_token.result
  install_rke2_type   = "agent"
  server_url          = local.rke2_server_url
  install_script_pre  = join("\n", [local.install_script_pre, "sleep 200"])
  install_script_post = local.install_script_post
  extra_config        = local.k8s_extra_config
}

