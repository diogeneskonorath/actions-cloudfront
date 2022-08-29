terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = ">= 4"
  }

  cloud {
    organization = "Dexco"
    workspaces {
      name = "template-s3-cloudfront-module-${var.env}"
    }
  }
}

provider "aws" {
  region = var.region
}


module "cloudwatch" {
  source   = "app.terraform.io/Dexco/cloudwatch/aws"
  version  = "1.0.0"
  app_name = var.app_name
  env      = var.env
  team     = var.team
  project  = var.project
}

module "acm" {
  source      = "app.terraform.io/Dexco/acm/aws"
  version     = "1.0.0"
  certificate = var.certificate
}

module "iam" {
  source  = "app.terraform.io/Dexco/iam/aws"
  version = "1.0.0"
}

module "route53" {
  source         = "app.terraform.io/Dexco/route53/aws"
  version        = "1.0.0"
  domain         = var.domain
  app_name       = var.app_name 
  dns_name       = var.dns_name
  alias_name     = module.cloudfront.domain_name
  alias_zone_id  = module.cloudfront.hosted_zone_id
}

module "s3" {
  source   = "app.terraform.io/Dexco/s3/aws"
  version  = "1.0.0"
  app_name = var.app_name
  env      = var.env
  team     = var.team
  project  = var.project
}

module "cloudfront" {
  source             = "app.terraform.io/Dexco/cloudfront/aws"
  version            = "1.0.0"
  app_name           = var.app_name
  bucket_domain_name = module.s3.bucket_domain_name
  bucket_id          = module.s3.bucket_id
  bucket_arn         = module.s3.bucket_arn
  cache_control      = var.cache_control
  certificate_arn    = module.acm.certificate_arn
  domain             = var.domain
  dns_name           = var.dns_name
  env                = var.env
  team               = var.team
  project            = var.project
}