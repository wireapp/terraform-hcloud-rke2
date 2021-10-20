output "controlplane_ipv4s" {
  value = hcloud_server.controlplane[*].ipv4_address
}

output "controlplane_ipv6s" {
  value = hcloud_server.controlplane[*].ipv6_address
}
