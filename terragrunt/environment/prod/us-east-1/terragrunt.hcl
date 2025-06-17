locals {
  region_location = basename(get_terragrunt_dir())
  profile = "baby"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "${local.region_location}"
  profile = "${local.profile}"
}
EOF
}

