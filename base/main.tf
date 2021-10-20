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
