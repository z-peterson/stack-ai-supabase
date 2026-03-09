# Production Supabase on AWS

Infrastructure-as-Code deployment of [Supabase](https://supabase.com) on AWS using **Terraform** and **Helm on EKS**.

## Architecture

```
Internet --> ALB --> NGINX Ingress --> Kong (API Gateway)
                                        |-- PostgREST ------> RDS PG15 (Multi-AZ)
                                        |-- GoTrue Auth ----> RDS
                                        |-- Realtime -------> RDS (WAL/logical replication)
                                        |-- Storage API ----> S3 (via IRSA)
                                        |-- Studio (Admin UI)
                                        |-- Postgres Meta --> RDS
                                        |-- Edge Functions (Deno)
                                        |-- Imgproxy -------> S3
                                        '-- Vector (observability)

EKS (private subnets, 2 AZs, Karpenter autoscaling)
RDS PostgreSQL 15 (Multi-AZ, private subnets, encrypted)
S3 (versioned, encrypted, block all public access)
Secrets Manager --> External Secrets Operator --> K8s Secrets
IAM: IRSA for pod-level least privilege
```

## Prerequisites

- AWS CLI v2 configured with appropriate credentials
- Terraform >= 1.7
- Helm >= 3.14
- kubectl >= 1.29
- kubeconform
- tflint
- shellcheck

### Quick Setup

```bash
bash scripts/setup-tools.sh
```

## Repository Structure

```
terraform/           Terraform IaC (VPC, EKS, RDS, S3, Secrets, IAM)
kubernetes/          Helm values, ExternalSecrets, NetworkPolicies, Karpenter
scripts/             Deploy, teardown, smoke test, secret rotation
docs/                Architecture, decisions, security, observability
```

## Deployment

### 1. Configure Variables

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Deploy Infrastructure

```bash
bash scripts/deploy.sh
```

This runs: `terraform apply` -> EKS kubeconfig -> ESO install -> manifests -> Helm install -> smoke test.

### 3. Verify

```bash
bash scripts/smoke-test.sh
```

### 4. Teardown

```bash
bash scripts/teardown.sh
```

## Validation (Local)

```bash
make init    # Initialize Terraform
make test    # Run all checks (terraform validate, tflint, helm lint/template, kubeconform, shellcheck)
```

## Key Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Database | RDS over in-cluster PG | Managed backups, Multi-AZ HA, operational simplicity |
| Object Storage | S3 over MinIO | Native AWS, IRSA integration, zero ops |
| Secrets | External Secrets Operator | Rich mapping via ExternalSecret CRD, jmesPath |
| Pod Identity | IRSA | Pod-level least privilege, auto-rotation |
| Autoscaler | Karpenter | Faster scaling, better bin-packing |
| Helm Chart | supabase-community/supabase | Active maintenance, HPA + IRSA support |

See [docs/decisions.md](docs/decisions.md) for full ADRs.

## Security

- All data encrypted at rest (RDS: AES-256, S3: SSE-KMS)
- All traffic encrypted in transit (TLS termination at ALB)
- Network isolation via VPC private subnets and NetworkPolicies
- Secrets managed in AWS Secrets Manager, synced via ESO
- IRSA for pod-level IAM (no static credentials)
- RDS accessible only from EKS security group on port 5432

See [docs/security.md](docs/security.md) for details.

## Observability

- EKS control plane logging (api, audit, authenticator)
- VPC Flow Logs to CloudWatch
- Vector sidecar for log aggregation
- Prometheus-compatible metrics via HPA

See [docs/observability.md](docs/observability.md) for details.

## Challenges & Learnings

- Supabase has ~13 microservices with complex inter-service dependencies
- RDS parameter group tuning for logical replication + pg_cron requires careful config
- IRSA trust policy construction needs exact OIDC provider ARN threading
- Network policies must balance security with service discovery needs

## Future Improvements

- Dual NAT Gateway for AZ-level HA
- Terratest integration tests with ephemeral AWS environments
- Full observability stack (Prometheus + Grafana)
- WAF rules on ALB for DDoS protection
- Automated certificate rotation via cert-manager
- Blue/green deployment strategy for Supabase upgrades
