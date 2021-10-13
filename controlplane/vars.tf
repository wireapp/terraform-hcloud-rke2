variable "hcloud_token" {}

variable "cluster_name" {
  type        = string
  description = "name of the cluster"
}

variable "controlplane_number" {
  type        = number
  description = "The number of controlplane nodes to deloy"
  default     = 3
}

variable "controlplane_has_worker" {
  type        = bool
  description = "Whether to register the controlplane node as a worker node too"
  default     = false
}

variable "controlplane_hostname" {
  type        = string
  description = "The DNS hostname pointing to the load balancer created here. If set, nodes will be configured to contact it, instead of its IPv4 address. Make sure to pass this in as a string, and when creating the record, use the controlplane_ipv4 output as a value, so you can create the record while machines are booting up (and this module returned)"
  default     = null
}

variable "controlplane_type" {
  type        = string
  description = "Hetzner machine type for controlplane"
  default     = "cx21"
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

variable "lb_id" {
  type        = string
  description = "id of the load balancer to connect masters"
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
