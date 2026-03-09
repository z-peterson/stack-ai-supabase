# Root module - wires all child modules together

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = var.vpc_cidr
  cluster_name = var.cluster_name
  environment  = var.environment
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  subnet_ids         = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  node_instance_types = var.node_instance_types
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
  node_desired_size  = var.node_desired_size
  environment        = var.environment
}

module "secrets" {
  source = "./modules/secrets"

  project_name = var.project_name
  db_username  = var.db_username
}

module "rds" {
  source = "./modules/rds"

  identifier            = var.rds_identifier
  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = module.secrets.db_password
  subnet_ids            = module.vpc.private_subnet_ids
  vpc_id                = module.vpc.vpc_id
  eks_security_group_id = module.eks.node_security_group_id
  environment           = var.environment
  skip_final_snapshot   = var.rds_skip_final_snapshot
  deletion_protection   = var.rds_deletion_protection
}

module "s3" {
  source = "./modules/s3"

  bucket_name = var.storage_bucket_name
  environment = var.environment
}

module "iam" {
  source = "./modules/iam"

  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider_url  = module.eks.oidc_provider_url
  cluster_name       = var.cluster_name
  storage_bucket_arn = module.s3.bucket_arn
  environment        = var.environment
}
