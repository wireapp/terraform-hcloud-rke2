variable "cluster_name" {
  type        = string
  description = "name of the cluster"
}

variable "workers_number" {
  type        = number
  description = "How many pure worker nodes to deploy, in addition to controlplane nodes (where workload runs too if controlplane_has_worker)"
  default     = 3
}

variable "worker_type" {
  type        = string
  description = "Hetzner machine type for workers"
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
