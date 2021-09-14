# This creates a ssh private key that can be used for root login.
# It is necessary so that hcloud does not send emails for each server creation,
# as well as needed to do initial configuration of the cluster, or creation of users.
resource "tls_private_key" "root" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# This persists the ssh key at the location specified by ssh_key_path.
resource "local_file" "id_root" {
  filename          = var.ssh_key_path
  sensitive_content = tls_private_key.root.private_key_pem
  file_permission   = "0600"
}
