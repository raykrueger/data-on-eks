variable "region" {
  description = "Region"
  type        = string
  #default     = "us-west-2"
  validation {
    condition     = contains(["us-east-1", "us-west-2", "ap-northeast-1", "eu-north-1"], var.region)
    error_message = "Region must be one of the supported regions. https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-express-networking.html"
  }
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  # starts with vpc
  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'."
  }
}

variable "route_table_ids" {
  description = "Route table IDs to associate with gateway endpoint"
  type        = list(string)
  validation {
    error_message = " IDs must start with 'rtb-'"
    condition = alltrue([
      for s in var.route_table_ids :
      can(regex("^rtb-", s))
    ])
  }
}
