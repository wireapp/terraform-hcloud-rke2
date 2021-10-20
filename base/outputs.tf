

output "controlplane_lb_id" {
  value       = hcloud_load_balancer_network.controlplane.id
  description = "Internal load balancer ip."
}

output "controlplane_lb_ip" {
  value = hcloud_load_balancer_network.controlplane.ip
}

output "nodes_network_id" {
  value = hcloud_network.nodes.id
}
output "nodes_subnet_id" {
  value = hcloud_network_subnet.nodes.id
}

output "controlplane_lb_ipv4" {
  value       = hcloud_load_balancer.controlplane.ipv4
  description = "The IPv4 address of the load balancer exposing the controlplane."
}

output "controlplane_lb_ipv6" {
  value       = hcloud_load_balancer.controlplane.ipv6
  description = "The IPv4 address of the load balancer exposing the controlplane."
}
