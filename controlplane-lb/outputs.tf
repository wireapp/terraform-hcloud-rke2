output "private_ipv4" {
  value = hcloud_load_balancer_network.controlplane.ip
  description = "The IPv4 address of the load balancer in the private network."
}

output "public_ipv4" {
  value       = hcloud_load_balancer.controlplane.ipv4
  description = "The public IPv4 address of the load balancer."
}

output "public_ipv6" {
  value       = hcloud_load_balancer.controlplane.ipv6
  description = "The public IPv6 address of the load balancer."
}
