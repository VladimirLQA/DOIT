variable "project_name" {
  description = "Used as a prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "app_port" {
  description = "Port the Node.js app listens on"
  type        = number
  default     = 8086
}

variable "bastion_allowed_cidrs" {
  description = "List of CIDRs allowed to SSH into the bastion"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

