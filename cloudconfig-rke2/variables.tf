variable "rke2_token" {
  type        = string
  description = "The RKE2 token, used to bootstrap servers and agents."
  default     = null
}

variable "server_tls_san" {
  type        = list(string)
  description = "Additional hostname or IP to set as a Subject Alternative Name in the TLS cert. It only makes sense to set this on servers"
  default     = []
}

variable "node_taint" {
  type        = list(string)
  description = "List of node taints to set. Add CriticalAddonsOnly=true:NoExecute if this is a master node you don't want other payload to be scheduled."
  default     = []
}

variable "install_rke2_channel" {
  type        = string
  description = "INSTALL_RKE2_CHANNEL to pass during installation"
  default     = "stable"
}

variable "install_rke2_type" {
  type        = string
  description = "INSTALL_RKE2_TYPE to specify, defaults to server"
  default     = "server"
}

variable "install_script_pre" {
  type        = string
  description = "Commands to run before running the RKE2 installer"
  default     = ""
}

variable "install_script_post" {
  type        = string
  description = "Commands to execute after running the RKE2 installer"
  default     = ""
}

variable "server_url" {
  type        = string
  description = "Server to set. Needs to be set on all nodes (agent or server), except the first server node, and may not be set there."
  default     = null
}

variable "extra_config" {
  type        = map
  description = "Additional config to be merged to /etc/rancher/rke2/config.yaml."
  default     = {}
}
