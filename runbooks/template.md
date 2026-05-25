# Runbook: [Alert/Scenario Name]

<!--
  =============================================================================
  Runbook Template — Operational Response Procedures
  =============================================================================

  WHY THIS FILE EXISTS:
    Every alert from Dynatrace or Splunk MUST point to a runbook by URL.
    Runbooks are version-controlled code, not wiki pages, because:
    1. They are reviewed in PRs alongside the code that creates the alerts
    2. They are versioned — you can see what the runbook said at incident time
    3. CI validates that every alert has a corresponding runbook

  NAMING CONVENTION:
    [alert-name-or-scenario].md  (lowercase, kebab-case)
    Example: api-gateway-5xx-spike.md

  ALERT-RUNBOOK MAPPING:
    The CI validator (build/validate-alert-runbook.sh) cross-references
    alert definitions in /observability/dynatrace/alerts/ against files
    in /runbooks/. If an alert has no runbook, the PR is blocked.

  QUALITY CRITERIA:
    - A runbook must be actionable by someone who has never seen this service
    - Diagnosis steps must be copy-pasteable commands or clickable links
    - Remediation must include the SAFEST action first, escalation second
    - Every runbook must be tested during quarterly incident drills
  =============================================================================
-->

- **Alert Name**: [exact name as configured in Dynatrace/Splunk]
- **Alert Source**: [Dynatrace | Splunk | CloudWatch | Custom]
- **Severity**: [P1-Critical | P2-High | P3-Medium | P4-Low]
- **Service**: {{dominio}}.{{servicio}}
- **Last Tested**: YYYY-MM-DD
- **Owner**: [team/person]

## Symptoms

<!--
  What the on-call person will observe. Include specific signals:
  - Alert message text
  - Dashboard panels that will show anomalies
  - User-facing symptoms
-->

- [ ] [Symptom 1: e.g., "Dynatrace alert: API response time > 2s for 5 min"]
- [ ] [Symptom 2: e.g., "Splunk shows increased 5xx count in service logs"]
- [ ] [Symptom 3: e.g., "Users report timeout errors on checkout page"]

## Quick Assessment (< 2 minutes)

<!--
  Fast triage to determine impact scope before diving into diagnosis.
-->

| Check | Command / Link | Expected | If Abnormal |
|---|---|---|---|
| Service health | [Dynatrace dashboard URL] | All green | Go to Diagnosis |
| Error rate | [Splunk query link] | < 0.1% | Go to Diagnosis |
| Recent deploys | `gh run list --repo {{org}}/{{repo}} --limit 5` | No recent deploy | Check rollback section |
| Dependencies | [dependency health dashboard] | All healthy | Check dependency runbook |

## Diagnosis

<!--
  Step-by-step investigation. Each step should be:
  1. A specific action (query, command, dashboard check)
  2. What to look for in the result
  3. What to do based on what you find
-->

### Step 1: [Check specific component]

```bash
# Command to run or query to execute
[paste exact command here]
```

**Look for**: [what indicates the problem]
**If found**: Proceed to Remediation -> [specific section]
**If not found**: Continue to Step 2

### Step 2: [Check next component]

```bash
# Next diagnostic command
[paste exact command here]
```

**Look for**: [what indicates the problem]
**If found**: Proceed to Remediation -> [specific section]
**If not found**: Escalate

## Remediation

<!--
  Actions to resolve the issue. Order from SAFEST to RISKIEST.
  Each action should be reversible or have a rollback.
-->

### Option A: [Safest remediation — e.g., restart/scale]

```bash
# Exact commands to execute
[paste commands here]
```

**Expected result**: [what should happen after executing]
**Verification**: [how to confirm the fix worked]
**Rollback**: [how to undo this action if it makes things worse]

### Option B: [Next remediation — e.g., config change]

```bash
# Exact commands to execute
[paste commands here]
```

**Expected result**: [what should happen]
**Verification**: [how to confirm]
**Rollback**: [how to undo]

### Option C: [Rollback to previous version]

```bash
# Exact rollback commands
[paste commands here]
```

**Expected result**: Previous known-good version is serving traffic
**Verification**: [health check commands]

## Escalation

<!--
  When to escalate, and to whom. Include specific thresholds.
-->

| Condition | Escalate To | Contact | SLA |
|---|---|---|---|
| Not resolved in 15 min | [senior engineer] | [Slack/phone] | 5 min response |
| Data integrity concern | [DBA team] | [Slack channel] | 10 min response |
| Customer-facing P1 | [incident commander] | [PagerDuty] | Immediate |
| Security incident | [security team] | [security Slack] | Immediate |

## Related

- **SFMEA**: [risk/sfmea.md — row FM-XXX]
- **FTA**: [risk/fta/xxx.md]
- **Dashboard**: [Dynatrace dashboard URL]
- **Splunk Search**: [saved search URL]
- **Architecture**: [docs/architecture/xxx.md — component affected]
- **Previous Incidents**: [risk/postmortems/YYYY-MM-DD-xxx.md]
