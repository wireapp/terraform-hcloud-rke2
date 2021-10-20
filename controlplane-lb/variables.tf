variable "lb_subnet_id" {
  type        = string
  description = "ID of the subnet the load balancer should be attached to"
}

variable "lb_type" {
  type        = string
  description = "Load balancer type"
}
