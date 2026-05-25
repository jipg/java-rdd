# Splunk Configuration — {{dominio}}.{{servicio}}

<!--
  =============================================================================
  Splunk HTTP Event Collector (HEC) Configuration
  =============================================================================

  WHY SPLUNK HEC:
    Splunk is the organization's log aggregation platform. HEC (HTTP Event
    Collector) provides a simple HTTPS endpoint for sending structured JSON
    events. It is used for:
    1. Application logs (structured JSON via Serilog, future layer)
    2. DORA deploy events (from GitHub Actions)
    3. Business events (domain-specific telemetry)

  HEC SETUP:
    1. In Splunk: Settings → Data Inputs → HTTP Event Collector
    2. Create a new token for this service
    3. Assign the token to the appropriate index(es)
    4. Store the token as a GitHub secret (SPLUNK_HEC_TOKEN)

  SECURITY:
    - HEC tokens should be scoped per service (not shared across services)
    - Use HTTPS only (never HTTP)
    - Restrict source IP ranges if possible
    - Rotate tokens quarterly
    - Store tokens in GitHub Secrets, never in code
  =============================================================================
-->

## HEC Endpoint Format

```
POST https://{splunk-host}:8088/services/collector/event
Authorization: Splunk {hec-token}
Content-Type: application/json

{
  "index": "dora_events",
  "sourcetype": "_json",
  "source": "github-actions",
  "host": "github.com/{org}/{repo}",
  "event": {
    "event_type": "deploy",
    "deploy_id": "...",
    ...
  }
}
```

## Event Routing

| Event Type | Splunk Index | Sourcetype | Source |
|---|---|---|---|
| Deploy events | `dora_events` | `_json` | `github-actions` |
| Application logs | `app_logs` | `_json` | `{{dominio}}.{{servicio}}` |
| Business events | `business_events` | `_json` | `{{dominio}}.{{servicio}}` |

## Required Fields for All Events

Every event sent to Splunk MUST include these fields for correlation:

```json
{
  "domain": "{{dominio}}",
  "service": "{{servicio}}",
  "environment": "production|staging",
  "correlation_id": "uuid",
  "timestamp": "ISO 8601"
}
```
