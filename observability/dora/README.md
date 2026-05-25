# DORA Metrics — Emission and Computation

<!--
  =============================================================================
  DORA Metrics Architecture
  =============================================================================

  WHY THIS DIRECTORY EXISTS:
    The four DORA metrics (Deployment Frequency, Lead Time for Changes,
    Change Failure Rate, Mean Time to Recovery) are the industry standard
    for measuring software delivery performance. This directory contains
    the schema, dashboard definitions, and documentation for how this
    repo emits and computes DORA data.

  THE KEY INSIGHT:
    DORA metrics are not something you measure passively — the repo must
    EMIT the data that feeds them. Without explicit instrumentation,
    metrics are either unavailable or computed from unreliable proxies.

  DATA FLOW:
    1. GitHub Actions workflow deploys the service
    2. deploy-tracker.yml emits a JSON event to Splunk HEC
    3. Splunk indexes the event in the 'dora_events' index
    4. Dashboard queries compute the four DORA metrics
    5. Postmortems link to deploy_id for CFR/MTTR correlation

  CLOSING THE LOOP (from DevSecOps proposal §8):
    RPN (from SFMEA) decreasing → CFR/MTTR improving → evidence-based
    risk reduction. This is the "RPN bajando → CFR/TRS mejorando con
    evidencia" cycle the proposal describes.
  =============================================================================
-->

## The Four DORA Metrics

| Metric | What it measures | How we compute it | Elite threshold |
|---|---|---|---|
| **Deployment Frequency (DF)** | How often we deploy to production | `count(event_type=deploy AND deploy_environment=production)` per day/week | On-demand (multiple/day) |
| **Lead Time for Changes (LT)** | Time from first commit to production | `avg(dora_lead_time_ms)` where deploy_status=success | Less than 1 hour |
| **Change Failure Rate (CFR)** | Percentage of deploys causing failures | `count(dora_is_failure=true) / count(*)` for production deploys | 0-15% |
| **Mean Time to Recovery (MTTR)** | Time from failure detection to resolution | Derived from postmortem timeline (detection → resolution) | Less than 1 hour |

## Data Sources

```
┌──────────────┐    ┌─────────────────┐    ┌───────────────┐
│ GitHub Actions│───▶│  Splunk HEC     │───▶│ dora_events   │
│ (deploy)     │    │  (HTTPS POST)   │    │ (Splunk index)│
└──────────────┘    └─────────────────┘    └───────┬───────┘
                                                    │
┌──────────────┐                                    ▼
│ Postmortems  │───▶ consolidate-dora.sh ───▶ DORA Dashboard
│ (risk/)      │    (monthly correlation)   (SPL queries)
└──────────────┘
```

## Files in This Directory

| File | Purpose |
|---|---|
| `event-schema.json` | JSON Schema for deploy events (contract) |
| `dashboard-queries.spl` | Splunk SPL queries for the DORA dashboard |
| `README.md` | This documentation |

## Required GitHub Secrets

| Secret | Purpose |
|---|---|
| `SPLUNK_HEC_URL` | Splunk HEC endpoint (e.g., `https://splunk.example.com:8088/services/collector`) |
| `SPLUNK_HEC_TOKEN` | HEC authentication token |
| `DORA_DOMAIN` | Business domain name (e.g., `polizas`) |
| `DORA_SERVICE` | Service name (e.g., `payment-processor`) |

## Splunk Index Setup

Create a dedicated index for DORA events:

```
# In Splunk (indexes.conf or via UI)
[dora_events]
homePath   = $SPLUNK_DB/dora_events/db
coldPath   = $SPLUNK_DB/dora_events/colddb
thawedPath = $SPLUNK_DB/dora_events/thaweddb
maxTotalDataSizeMB = 1024
frozenTimePeriodInSecs = 63072000  # 2 years retention
```

## How Metrics Flow to Evidence

```
SFMEA (risk/sfmea.md)
  │ RPN score tracks risk level
  │
  ├──▶ Actions reduce RPN
  │     (new tests, alerts, runbooks)
  │
  ▼
DORA Metrics (this directory)
  │ CFR and MTTR track delivery health
  │
  ├──▶ Lower CFR = fewer production failures
  ├──▶ Lower MTTR = faster recovery
  │
  ▼
Evidence: "RPN ↓ correlates with CFR ↓ and MTTR ↓"
  │ Quarterly report cross-references SFMEA trends with DORA trends
  │
  ▼
Continuous improvement cycle
```
