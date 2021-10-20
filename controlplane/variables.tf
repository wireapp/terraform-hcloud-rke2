variable "hcloud_token" {
  type        = string
  description = "hetzner cloud api token. Used by the CCM, if the CCM is used"
}

variable "node_prefix" {
  type        = string
  description = "Common prefix to use for all workers (hostname and k8s node name)"
}

variable "node_count" {
  type        = number
  description = "The number of controlplane nodes to deloy"
  default     = 3
}

variable "node_subnet_id" {
  type        = string
  description = "network id to put servers into"
}

variable "node_type" {
  type        = string
  description = "Hetzner machine type for controlplane nodes"
  default     = "cx21"
}

variable "controlplane_has_worker" {
  type        = bool
  description = "Whether to register the controlplane node as a worker node too"
  default     = false
}

variable "rke2_cluster_secret" {
  type        = string
  description = "Cluster secret for rke2 cluster registration"
}

variable "rke2_url" {
  type        = string
  description = "URL to connect to ($RKE2_URL)"
}

variable "tls_san" {
  type = list(string)
  description = "List of SAN to add to the kube-apiserver endpoint"
}

variable "network_id" {
  type        = string
  description = "Network ID used. Will be passed to the CCM."
}

variable "hetzner_ccm_enabled" {
  type        = bool
  description = "Whether to set up hcloud-cloud-controller-manager and configure the nginx ingress controller to make use of it"
  default     = true
}

variable "ssh_keys" {
  type        = list(string)
  default     = []
  description = "SSH key IDs or names which should be injected into the servers at creation time."
}
