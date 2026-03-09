# Observability

## Current Implementation

### Logging

**EKS Control Plane Logs**
All five log types are enabled and sent to CloudWatch Logs:
- `api` - Kubernetes API server requests
- `audit` - Kubernetes audit events
- `authenticator` - IAM authenticator logs
- `controllerManager` - Controller manager operations
- `scheduler` - Pod scheduling decisions

Log group: `/aws/eks/{cluster_name}/cluster`

**VPC Flow Logs**
Network traffic logs for the VPC, sent to CloudWatch Logs:
- Captures accepted and rejected traffic
- Useful for security auditing and network debugging

**Application Logs (Vector)**
Vector runs as a sidecar/agent collecting logs from Supabase services:
- Configured via the Helm chart's `vector` deployment
- Routes logs to Logflare for Supabase Analytics

### Metrics

**Horizontal Pod Autoscaler (HPA)**
CPU-based autoscaling is enabled on stateless services:

| Service | Min | Max | CPU Target |
|---------|-----|-----|------------|
| Kong | 2 | 10 | 70% |
| PostgREST | 2 | 10 | 75% |
| Auth | 2 | 10 | 75% |
| Realtime | 2 | 10 | 75% |
| Storage | 2 | 8 | 75% |
| Functions | 2 | 8 | 75% |
| Imgproxy | 2 | 6 | 80% |

**RDS Performance Insights**
Enabled on the RDS instance for database performance monitoring:
- Top SQL queries by wait time
- CPU/IO/lock wait analysis
- 7-day retention (free tier)

### Health Checks

The smoke test script (`scripts/smoke-test.sh`) validates:
- Kong API Gateway reachability
- GoTrue Auth health endpoint
- PostgREST availability
- Studio UI accessibility

## Future Improvements

### Prometheus + Grafana Stack

Deploy kube-prometheus-stack for comprehensive monitoring:

```yaml
# Future: helm install prometheus prometheus-community/kube-prometheus-stack
```

Benefits:
- Node and pod resource metrics
- Custom Supabase service metrics
- Pre-built Kubernetes dashboards
- Alerting rules for SLOs

### Distributed Tracing

Add OpenTelemetry collector for request tracing across Supabase services:
- Trace requests from Kong through PostgREST to RDS
- Identify latency bottlenecks
- Correlate with logs and metrics

### CloudWatch Container Insights

Enable Container Insights on EKS for:
- Node-level CPU/memory/disk/network metrics
- Pod-level resource utilization
- Cluster-level aggregated views

### Alerting

Configure CloudWatch Alarms for:
- RDS CPU > 80% for 5 minutes
- RDS free storage < 10GB
- EKS node count at max capacity
- 5xx error rate > 1% on ALB
- Pod restart count > 3 in 10 minutes
