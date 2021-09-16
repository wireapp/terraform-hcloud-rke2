variable "ssh_key_create" {
  type        = bool
  description = "Create a random SSH key which will be stored in terraform state"
  default     = false
}

variable "ssh_key_path" {
  type        = string
  description = "The path to persist the ssh key path to."
  default     = "id_root"
}

variable "hetzner_project_api_token" {
  type        = string
  description = "hetzner api token with read permission to read lb state"
}

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
variable "controlplane_type" {
  type        = string
  description = "Hetzner machine type for controlplane"
  default     = "cx21"
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

variable "rancher2_import" {
  type        = string
  description = "Rancher 2 import token"
  default     = null
}

