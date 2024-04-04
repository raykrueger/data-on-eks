
# Static list of zone ids that support s3 one zone
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-express-networking.html
locals {

  region = var.region

  s3_express_zone_ids = [
    "use1-az4",
    "use1-az5",
    "use1-az6",
    "usw2-az1",
    "usw2-az3",
    "usw2-az4",
    "apne1-az1",
    "apne1-az4",
    "eun1-az1",
    "eun1-az2",
    "eun1-az3"
  ]

  # Intersection of available AZs and the ones that support exrpess zone
  s3_azs_in_region = tolist(setintersection(data.aws_availability_zones.available.zone_ids, local.s3_express_zone_ids))
}

data "aws_availability_zones" "available" {}

resource "aws_s3_directory_bucket" "xpbucket" {
  count = length(local.s3_azs_in_region) > 0 ? 1 : 0
  # Bucket Naming Rules https://docs.aws.amazon.com/AmazonS3/latest/userguide/directory-bucket-naming-rules.html
  # bucket name must follow... base-name--azid--x-s3
  bucket = "spark-data-${random_bytes.rando.hex}--${local.s3_azs_in_region[0]}--x-s3"
  location {
    name = local.s3_azs_in_region[0]
  }
}

resource "random_bytes" "rando" {
  length = 8
}

# VPC Gateway endpoint for S3
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${local.region}.s3"
  route_table_ids = var.route_table_ids
  tags = {
    Name = "spark-s3-endpoint"
  }
}
