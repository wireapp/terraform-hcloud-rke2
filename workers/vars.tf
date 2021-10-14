variable "worker_prefix" {
  type = string
  description = "Common prefix to use for all workers (hostname and k8s node name)"
}

variable "worker_count" {
  type        = number
  description = "How many pure worker nodes to deploy, in addition to controlplane nodes (where workload runs too if controlplane_has_worker)"
  default     = 3
}

variable "server_type" {
  type        = string
  description = "Hetzner machine type for worker nodes"
  default     = "cx51"
}

variable "rke2_cluster_secret" {
  type        = string

  description = "Cluster secret for rke2 cluster registration"
}

variable "rke2_url" {
  type        = string
  description = "URL to connect to ($RKE2_URL)"
}

variable "subnet_id" {
  type        = string
  description = "network id to put servers into"
}

variable "ssh_keys" {
  type        = list
  default     = []
  description = "ssh keys to add to hetzner server instances"
}
