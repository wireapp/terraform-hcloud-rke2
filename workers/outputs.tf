output "worker_ipv4s" {
  value = hcloud_server.worker[*].ipv4_address
}

output "worker_ipv6s" {
  value = hcloud_server.worker[*].ipv6_address
}
