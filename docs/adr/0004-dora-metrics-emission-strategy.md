# DORA Metrics Emission Strategy via Splunk HEC

- Status: accepted
- Deciders: Engineering team, SRE team
- Date: 2026-05-25

## Context and Problem Statement

The DevSecOps proposal (section 8) establishes DORA metrics as the primary
measure of software delivery performance. The four metrics — Deployment
Frequency, Lead Time for Changes, Change Failure Rate, and Mean Time to
Recovery — require structured data from the CI/CD pipeline and incident
management process.

Most organizations attempt to derive DORA metrics passively (e.g., counting
merged PRs as "deploys"). This produces inaccurate data because:
- Not every merge is a deploy
- Deploy failures are invisible without explicit tracking
- Lead Time computation requires knowing the first commit timestamp
- CFR requires linking deploys to incidents

How should we instrument the repo to emit accurate DORA data, close the
RPN<->CFR feedback loop, and produce evidence-based improvement metrics?

## Decision Drivers

- **Accuracy**: Metrics must reflect actual production deploys, not proxies
- **Splunk alignment**: The org uses Splunk as its log/event platform
- **Low coupling**: DORA emission must not block deploys if Splunk is down
- **Traceability**: Every deploy event must link to commit, PR, and CI run
- **Feedback loop**: SFMEA risk reduction (RPN down) must correlate with
  delivery improvement (CFR down, MTTR down) with evidence
- **Git-based fallback**: Basic metrics must be computable without Splunk

## Considered Options

- **Option 1**: Splunk HEC emission from GitHub Actions with git-based consolidation
- **Option 2**: GitHub API-based metrics (deployment environments + DORA APIs)
- **Option 3**: Third-party DORA platform (LinearB, Sleuth, Jellyfish)

## Decision Outcome

Chosen option: **Option 1 — Splunk HEC emission with git-based
consolidation**, because it leverages the org's existing Splunk
infrastructure, provides real-time metrics, and includes a git-based
fallback for offline analysis.

### Architecture

```
GitHub Actions                    Splunk
+-------------------+              +-------------------------------+
| deploy workflow   |              | dora_events index             |
|   |               |    HEC      |   |                           |
|   +-- deploy      |------------>|   +-- Dashboard (9 panels)    |
|   |               |   (HTTPS)   |   |   DF, LT, CFR, MTTR       |
|   +-- track-deploy|              |   |                           |
|   |  (reusable)   |              |   +-- Alerts                  |
|   |   * metadata  |              |   |   CFR > 30% -> PagerDuty  |
|   |   * lead time |              |   |   DF < 1/week -> Slack    |
|   |   * is_failure|              |   |                           |
|   |   * JSON event|              |   +-- Reports                 |
|   +---------------+              +-------------------------------+
                                           ^
Git (fallback)                             | correlation
+-------------------+              +-------+-----------+
| consolidate-dora  |              | Postmortems        |
|   * git log       |---------->  | risk/postmortems/  |
|   * git tags      |  monthly    |   deploy_id linkage |
|   * postmortems   |  report     |                     |
+-------------------+              +---------------------+
```

### The RPN <-> CFR Evidence Loop

This is the key insight from the DevSecOps proposal: risk reduction must
produce measurable delivery improvement, not just lower numbers on a
spreadsheet.

```
Quarter N:
  SFMEA avg RPN = 120  ->  CFR = 25%  ->  MTTR = 2 hours

  Actions taken:
  - Added retry policies (RPN for "dropped work" FM-003: 120 -> 60)
  - Added circuit breakers (RPN for "cascade failure" FM-007: 160 -> 80)
  - Improved runbooks (Detection score D: 7 -> 3 for 4 failure modes)

Quarter N+1:
  SFMEA avg RPN = 75   ->  CFR = 12%  ->  MTTR = 45 min
  Evidence: RPN down 37% correlates with CFR down 52% and MTTR down 62%
```

The monthly DORA report (from `consolidate-dora.sh`) includes an RPN<->CFR
correlation table that tracks this relationship over time.

### Positive Consequences

- Real-time DORA metrics in Splunk from the first deploy
- Deploy events are structured (JSON Schema contract) and queryable
- Git-based consolidation works without Splunk for offline analysis
- Deploy-incident correlation via postmortem deploy_id field
- Monthly reports committed to repo as auditable evidence
- Non-blocking: Splunk failures don't break deploys

### Negative Consequences

- Requires Splunk HEC setup (index, token, network access)
- Monthly consolidation script needs manual or scheduled execution
- Lead Time accuracy depends on git history (squash-merge loses detail)
- MTTR is not directly emitted — derived from postmortem durations

## Pros and Cons of the Options

### Option 1: Splunk HEC + git consolidation

- Good, because uses existing Splunk infrastructure
- Good, because real-time and historical metrics
- Good, because git-based fallback for offline analysis
- Good, because non-blocking (deploy continues if Splunk is down)
- Good, because custom fields (domain, service, correlation_id)
- Bad, because requires Splunk HEC configuration
- Bad, because MTTR is not auto-computed (needs postmortem data)

### Option 2: GitHub API-based metrics

- Good, because no external infrastructure needed
- Good, because GitHub provides deployment environments API
- Bad, because limited to GitHub-provided fields
- Bad, because no custom domain/service taxonomy
- Bad, because no Splunk integration (separate dashboard)
- Bad, because GitHub DORA metrics are basic/limited

### Option 3: Third-party DORA platform

- Good, because turnkey DORA dashboards and insights
- Good, because automated data collection
- Bad, because additional licensing cost ($15-50/dev/month)
- Bad, because vendor lock-in for metrics data
- Bad, because limited customization for domain taxonomy
- Bad, because data lives outside the org's infrastructure

## Risks Introduced

| Risk | Failure Mode | Severity | Mitigation | SFMEA Ref |
|---|---|---|---|---|
| Splunk HEC downtime | Deploy events lost, metrics gap | M | Git-based consolidation as fallback, HEC retry | FM-XXX |
| Incorrect Lead Time | Squash-merge loses intermediate commits | L | Use PR first-commit timestamp, document limitation | FM-XXX |
| Stale monthly reports | Team forgets to run consolidation | L | Schedule via GitHub Actions cron, reminder in standup | FM-XXX |
| Metric gaming | Teams optimize metrics over outcomes | M | Cross-reference with SFMEA trends, qualitative review | FM-XXX |
| Missing correlation | Postmortems without deploy_id | M | CI check via link-deploy-incident.sh --strict | FM-XXX |

## Links

- [DORA Research](https://dora.dev/)
- [Splunk HEC Documentation](https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector)
- [Accelerate (book)](https://itrevolution.com/product/accelerate/) — Forsgren, Humble, Kim
- ADR-0002: [RDD as Structural Discipline](0002-rdd-as-structural-discipline.md)
- ADR-0003: [Security Toolchain Strategy](0003-security-toolchain-and-supply-chain-strategy.md)
