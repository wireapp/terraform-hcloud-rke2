variable "node_prefix" {
  type        = string
  description = "Common prefix to use for all workers (hostname and k8s node name)"
}

variable "node_count" {
  type        = number
  description = "How many pure worker nodes to deploy, in addition to controlplane nodes (where workload runs too if controlplane_has_worker)"
  default     = 3
}

variable "node_subnet_id" {
  type        = string
  description = "network id to put servers into"
}

variable "node_type" {
  type        = string
  description = "Hetzner machine type for worker nodes"
  default     = "cx51"
}

variable "hetzner_ccm_enabled" {
  type        = bool
  description = "Whether nodes should be configured to use the CCM"
  default     = true
}

variable "rke2_cluster_secret" {
  type = string

  description = "Cluster secret for rke2 cluster registration"
}

variable "rke2_url" {
  type        = string
  description = "URL to connect to ($RKE2_URL)"
}

variable "ssh_keys" {
  type        = list(string)
  default     = []
  description = "SSH key IDs or names which should be injected into the servers at creation time."
}
