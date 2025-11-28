# Monitoring & Logging Plan for Voting App

## Monitoring Strategy

### Tools:
- **Prometheus** for metrics collection
- **Grafana** for dashboards
- **Azure Monitor** for infrastructure

#### Key Metrics:
- **Vote Service**: Request rate, response time, error rate
- **Result Service**: Data freshness, chart rendering performance  
- **Worker Service**: votes processed, queue length
- **Redis**: Memory usage, cache hit ratio, connections
- **PostgreSQL**: active connections, query performance

#### Alerts:
- service down for > 2 minutes
- Error rate >5%
- High response time (>1s)
Redis memory >80%

## Example Prometheus setup
```yaml
scrape_configs:
  - job_name: 'voting-app'
    static_configs:
      - targets: ['vote:8080', 'result:8081']
    
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
```

## Example Grafana dashboard
```json
{
  "panels": [
    {
      "title": "Request Rate",
      "targets": [{
        "expr": "rate(http_requests_total[5m])"
      }]
    },
    {
      "title": "Error Rate", 
      "targets": [{
        "expr": "rate(http_requests_total{status=~'5..'}[5m])"
      }]
    }
  ]
}
```