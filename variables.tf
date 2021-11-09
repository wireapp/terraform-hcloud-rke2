variable "ssh_keys" {
  type        = list(string)
  default     = []
  description = "SSH key IDs or names which should be injected into the servers at creation time."
}

variable "ssh_key_create" {
  type        = bool
  description = "Create an (additional) random SSH key which will be stored in terraform state"
  default     = true
}

variable "ssh_key_path" {
  type        = string
  description = "The path to persist the ssh key path to."
  default     = "id_root"
}

variable "controlplane_count" {
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
  description = "Hetzner machine type for controlplane nodes"
  default     = "cx21"
}

variable "worker_count" {
  type        = number
  description = "How many pure worker nodes to deploy, in addition to controlplane nodes (where workload runs too if controlplane_has_worker)"
  default     = 3
}

variable "worker_type" {
  type        = string
  description = "Hetzner machine type for worker nodes"
  default     = "cx51"
}

variable "hcloud_token" {
  type        = string
  default     = ""
  description = "Hetzner API token to configure the CCM with. Only need to be set if hetzner_ccm_enabled is set to true"
}

variable "hetzner_ccm_enabled" {
  type        = bool
  description = "Whether to set up hcloud-cloud-controller-manager and configure the nginx ingress controller to make use of it"
  default     = true
}
