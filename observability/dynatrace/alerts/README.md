# Alert Definitions — {{dominio}}.{{servicio}}

<!--
  =============================================================================
  Alert Definitions as Code
  =============================================================================

  WHY THIS DIRECTORY EXISTS:
    Alert definitions are version-controlled source code, not manual
    Dynatrace/Splunk configurations. Each alert is defined in a YAML or
    JSON file that:
    1. Documents the alert threshold, condition, and severity
    2. Links to its corresponding runbook in /runbooks/
    3. Is validated by CI to ensure runbook coverage

  CI VALIDATION:
    The build/validate-alert-runbook.sh script reads each alert definition
    file and checks that the `runbook` field points to an existing file
    in /runbooks/. If any alert lacks a runbook, the PR is blocked.

  FILE FORMAT:
    Each alert is a YAML file with this structure:

    ```yaml
    name: "api-response-time-high"
    description: "API P95 response time exceeds 2 seconds for 5 minutes"
    source: dynatrace
    severity: P2-High
    condition:
      metric: "builtin:service.response.time:percentile(95)"
      threshold: 2000  # milliseconds
      duration: 5m
      operator: ">"
    runbook: "/runbooks/api-response-time-high.md"
    service: "{{dominio}}.{{servicio}}"
    tags:
      - performance
      - sla
    ```

  NAMING CONVENTION:
    [alert-name].yml (lowercase, kebab-case, matching the alert name)
    Example: api-response-time-high.yml, queue-depth-critical.yml

  WHEN TO ADD:
    - Every new endpoint must have RED metrics alerts (Request rate, Error
      rate, Duration) — enforced by definition-of-done.yml workflow.
    - Every new async consumer must have depth/lag alerts.
    - Every new dependency must have health/latency alerts.
  =============================================================================
-->

## Alert Categories

| Category | Metrics | Source |
|---|---|---|
| RED (Request/Error/Duration) | Response time, error rate, throughput | Dynatrace APM |
| Infrastructure | CPU, memory, disk, network | Dynatrace Infrastructure |
| Queue/Messaging | Depth, lag, DLQ count | Dynatrace / CloudWatch |
| Business | Transaction volume, conversion rate | Splunk (structured logs) |
| Security | Auth failures, anomalous access patterns | Splunk |
