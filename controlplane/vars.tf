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

variable "lb_ip" {
  type        = string
  description = "ip of the lb to use to connect masters"
}

variable "lb_external_v4" {
  type        = string
  description = "external v4 ip of the lb"
}

variable "lb_external_v6" {
  type        = string
  description = "external v4 ip of the lb"
}

variable "network_id" {
  type        = string
  description = "network id to put servers into"
}

variable "subnet_id" {
  type        = string
  description = "subnet id to put servers into"
}

variable "hetzner_ccm_enabled" {
  type        = bool
  description = "Whether to set up hcloud-cloud-controller-manager and configure the nginx ingress controller to make use of it"
  default     = true
}

variable "hetzner_ccm_version" {
  type        = string
  description = "Version of the hcloud-controller-manager"
  default     = "v1.12.0"
}

variable "ssh_keys" {
  type        = list
  default     = []
  description = "ssh keys to add to hetzner server instances"
}
