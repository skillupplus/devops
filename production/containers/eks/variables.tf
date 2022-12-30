################################################################################
# Cluster
################################################################################

variable "name" {
  description = "Name of the project"
  type        = string
  default     = "skillup"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "skillup-apne2-alpha"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = 1.23
}
