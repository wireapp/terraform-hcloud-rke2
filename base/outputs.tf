output "nodes_network_id" {
  value = hcloud_network.nodes.id
}
output "nodes_subnet_id" {
  value = hcloud_network_subnet.nodes.id
}
