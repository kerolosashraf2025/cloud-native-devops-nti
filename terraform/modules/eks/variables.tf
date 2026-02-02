variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "endpoint_public_access" {
  type = bool
}

variable "endpoint_private_access" {
  type = bool
}

variable "enabled_cluster_log_types" {
  type = list(string)
}

variable "log_retention_in_days" {
  type = number
}

variable "node_desired" {
  type = number
}

variable "node_min" {
  type = number
}

variable "node_max" {
  type = number
}

variable "instance_types" {
  type = list(string)
}

variable "capacity_type" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "eks_cluster_role_arn" {
  type = string
}

variable "node_group_role_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
