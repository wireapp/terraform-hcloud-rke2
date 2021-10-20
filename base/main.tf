resource "hcloud_network" "nodes" {
  name     = "nodes"
  ip_range = "10.0.0.0/8"
}

resource "hcloud_network_subnet" "nodes" {
  network_id   = hcloud_network.nodes.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.subnetwork
}

# This creates a load balancer for our controlplane.
resource "hcloud_load_balancer" "controlplane" {
  name               = "controlplane-${var.cluster_name}"
  load_balancer_type = var.lb_type
  network_zone       = "eu-central"
  location           = "nbg1"
}

# This attaches the load balancer to the controlplane network.
resource "hcloud_load_balancer_network" "controlplane" {
  load_balancer_id = hcloud_load_balancer.controlplane.id
  network_id       = hcloud_network.nodes.id
}

# This adds a new controlplane target to the loadbalancer, which balances among
# all servers with the "role-controlplane" label set.
resource "hcloud_load_balancer_target" "controlplane" {
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.controlplane.id
  label_selector   = "role-controlplane=1"
  use_private_ip   = true
  depends_on = [
    # We need to depend on the "attach the load balancer to the network" part being done,
    # otherwise creating the target fails
    # (as the load balancer isn't yet part of the network)
    hcloud_load_balancer_network.controlplane
  ]
}

# This registers a service at port 6443 (kube-api-server port)
resource "hcloud_load_balancer_service" "controlplane_service" {
  load_balancer_id = hcloud_load_balancer.controlplane.id
  protocol         = "tcp"
  listen_port      = "6443"
  destination_port = "6443"
}

# This registers a service at port 9345 (rke2 management port)
resource "hcloud_load_balancer_service" "controlplane_rke_management" {
  load_balancer_id = hcloud_load_balancer.controlplane.id
  protocol         = "tcp"
  listen_port      = "9345"
  destination_port = "9345"
}
