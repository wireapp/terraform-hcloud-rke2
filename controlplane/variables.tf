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

variable "seed_node" {
  type        = bool
  description = "Whether the first node will be a seed node. Needs to be set to true initially, and set to false once the cluster was deployed initially, to prevent it from recreating a (second) cluster on redeploy"
  default     = false
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
  type        = list(string)
  description = "List of SAN to add to the kube-apiserver endpoint"
}

variable "network_id" {
  type        = string
  description = "Network ID used. Will be passed to the CCM."
}

variable "hetzner_ccm_enabled" {
  type        = bool
  description = "When enabled, this will deploy hcloud-cloud-controller-manager (with network and load balancer support), and configure control plane nodes to use it as a CCM"
  default     = true
}

variable "ssh_keys" {
  type        = list(string)
  default     = []
  description = "SSH key IDs or names which should be injected into the servers at creation time."
}
