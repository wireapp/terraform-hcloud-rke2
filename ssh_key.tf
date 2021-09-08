# This creates a ssh private key that can be used for root login.
# It is necessary so that hcloud does not send emails for each server creation,
# as well as needed to do initial configuration of the cluster, or creation of users.
resource "tls_private_key" "root" {
  algorithm = "RSA"
  rsa_bits  = 4096
  count     = var.ssh_key_create ? 1 : 0
}
