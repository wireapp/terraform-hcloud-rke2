variable "subnet_id" {
  type        = string
  description = "ID of the sub-network which should be added to the load balancer"
}

variable "lb_type" {
  type        = string
  description = "Load balancer type"
}
