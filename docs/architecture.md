# Architecture

## Overview

This deployment runs Supabase on AWS using EKS for compute, RDS for the database, and S3 for object storage. All infrastructure is managed via Terraform, and the application layer is deployed via the supabase-community Helm chart.

## Component Diagram

```
                          Internet
                             |
                         [AWS ALB]
                             |
                      [NGINX Ingress]
                             |
                        [Kong Gateway]
                       /    |    |    \
                      /     |    |     \
              [PostgREST] [Auth] [Realtime] [Storage API]
              [Studio]    [Meta] [Functions] [Imgproxy]
              [Vector/Logflare]
                      \     |    |     /
                       \    |    |    /
                    [RDS PostgreSQL 15]    [S3 Bucket]
                     (Multi-AZ, encrypted)  (versioned, encrypted)
```

## Network Architecture

### VPC Layout (10.0.0.0/16)

| Subnet | CIDR | AZ | Purpose |
|--------|------|----|---------|
| Public A | 10.0.0.0/20 | us-east-1a | ALB, NAT Gateway |
| Public B | 10.0.16.0/20 | us-east-1b | ALB (HA) |
| Private A | 10.0.160.0/20 | us-east-1a | EKS nodes, RDS primary |
| Private B | 10.0.176.0/20 | us-east-1b | EKS nodes, RDS standby |

### Traffic Flow

1. External traffic enters via ALB in public subnets
2. ALB forwards to NGINX Ingress Controller on EKS nodes (private subnets)
3. NGINX routes to Kong API Gateway pods
4. Kong routes to individual Supabase microservices
5. Services connect to RDS (port 5432) and S3 (HTTPS) from private subnets
6. Outbound internet traffic from private subnets goes through NAT Gateway

## Compute (EKS)

- **Cluster**: EKS 1.29 with private endpoint
- **Node Group**: Managed, t3.large instances (2-6 nodes)
- **Autoscaling**: Karpenter for fast, efficient pod-driven scaling
- **Pod Identity**: IRSA (IAM Roles for Service Accounts) for least-privilege access

## Database (RDS)

- **Engine**: PostgreSQL 15 with Multi-AZ deployment
- **Instance**: db.t3.medium (configurable)
- **Extensions**: pg_cron enabled via shared_preload_libraries
- **Replication**: Logical replication enabled for Supabase Realtime
- **Encryption**: AES-256 at rest
- **Backups**: 7-day automated retention

## Object Storage (S3)

- **Versioning**: Enabled for data durability
- **Encryption**: SSE-S3 (AES-256)
- **Access**: All public access blocked, SSL-only policy enforced
- **Lifecycle**: Incomplete multipart uploads cleaned after 7 days
- **Pod Access**: Via IRSA (Storage service account has scoped S3 permissions)

## Secrets Management

```
Terraform (random_password) --> AWS Secrets Manager
                                       |
                              External Secrets Operator
                                       |
                              Kubernetes Secrets
                                       |
                              Supabase Pods (env vars)
```

Secrets flow: Terraform generates random passwords and stores them as a single JSON blob in AWS Secrets Manager. External Secrets Operator runs in-cluster with IRSA credentials, syncs secrets to Kubernetes Secrets every hour. The Helm chart references these K8s Secrets via `secretRef`.
