# Architecture Decision Records

## ADR-001: AWS over GCP/Azure

**Status**: Accepted

**Context**: The task requires deploying Supabase to a cloud provider using IaC.

**Decision**: AWS

**Rationale**:
- Broadest Terraform provider ecosystem
- Mature EKS with strong IRSA support
- More Supabase-on-AWS reference material available
- Native S3 integration eliminates MinIO complexity

---

## ADR-002: Terraform HCL over CDKTF/Pulumi

**Status**: Accepted

**Context**: Multiple IaC tools could provision the infrastructure.

**Decision**: Terraform HCL

**Rationale**:
- Industry standard, widest community support
- Portable across teams regardless of programming language preferences
- First-class AWS provider with frequent updates
- Well-understood plan/apply workflow

---

## ADR-003: RDS over In-Cluster PostgreSQL

**Status**: Accepted

**Context**: Supabase requires PostgreSQL. The Helm chart includes an in-cluster PG option.

**Decision**: Amazon RDS PostgreSQL 15

**Rationale**:
- Managed automated backups with point-in-time recovery
- Multi-AZ deployment for high availability
- Performance Insights for monitoring
- Eliminates operational burden of managing stateful workloads in K8s
- Encryption at rest by default

**Trade-off**: Higher cost than in-cluster PG, but significantly reduced operational risk.

---

## ADR-004: S3 over MinIO

**Status**: Accepted

**Context**: Supabase Storage needs S3-compatible object storage.

**Decision**: Amazon S3

**Rationale**:
- Native AWS service, zero operational overhead
- IRSA integration for pod-level access control
- Built-in versioning, encryption, lifecycle policies
- 11 nines durability

**Trade-off**: Cloud vendor lock-in, but the S3 API is effectively an industry standard.

---

## ADR-005: External Secrets Operator over CSI Driver

**Status**: Accepted

**Context**: Secrets need to flow from AWS Secrets Manager to Kubernetes.

**Decision**: External Secrets Operator (ESO)

**Rationale**:
- ExternalSecret CRD provides declarative secret mapping
- jmesPath extraction for individual fields from JSON secrets
- Automatic refresh on configurable interval
- Better GitOps compatibility (ExternalSecret manifests are safe to commit)

**Trade-off**: Additional controller running in-cluster, but minimal resource footprint.

---

## ADR-006: IRSA over Static Credentials

**Status**: Accepted

**Context**: Pods need AWS API access (S3, Secrets Manager).

**Decision**: IAM Roles for Service Accounts (IRSA)

**Rationale**:
- Pod-level least privilege (not node-level)
- Automatic credential rotation via STS
- No static credentials to manage or leak
- Native EKS integration via OIDC provider

---

## ADR-007: Karpenter over Cluster Autoscaler

**Status**: Accepted

**Context**: EKS needs node autoscaling.

**Decision**: Karpenter

**Rationale**:
- Faster scaling decisions (seconds vs minutes)
- Better bin-packing reduces wasted compute
- Supports diverse instance type selection per workload
- Active development by AWS

**Trade-off**: Newer project with less community history than Cluster Autoscaler.

---

## ADR-008: supabase-community Helm Chart

**Status**: Accepted

**Context**: Multiple Helm charts exist for Supabase (community, bitnami).

**Decision**: supabase-community/supabase v0.5.1

**Rationale**:
- Actively maintained by the community
- Built-in HPA support per component
- Per-component serviceAccount (enables IRSA)
- secretRef support for external secret management
- Bitnami chart is deprecated

---

## ADR-009: Single NAT Gateway

**Status**: Accepted (with noted trade-off)

**Context**: NAT Gateways are needed for private subnet internet access.

**Decision**: Single NAT Gateway in one AZ

**Rationale**:
- Significant cost savings (~$32/month per NAT Gateway)
- Acceptable for initial deployment

**Trade-off**: Single point of failure. If the NAT Gateway's AZ goes down, private subnets in the other AZ lose internet access. Future improvement: deploy one NAT Gateway per AZ for full HA.

---

## ADR-010: NetworkPolicy Default-Deny

**Status**: Accepted

**Context**: Kubernetes pods can communicate freely by default.

**Decision**: Default-deny NetworkPolicy with explicit allow rules

**Rationale**:
- Zero-trust networking within the cluster
- Explicit allow rules document expected traffic patterns
- Limits blast radius of compromised pods
- Required for compliance frameworks
