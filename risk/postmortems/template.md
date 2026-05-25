# Postmortem: [Incident Name]

<!--
  =============================================================================
  Postmortem Template — Blameless Incident Review
  =============================================================================

  WHY THIS FILE EXISTS:
    Postmortems are version-controlled alongside the service code because
    they are part of the service's operational knowledge. Storing them here
    ensures they are reviewed in PRs, linked to SFMEA updates, and searchable
    alongside the code that caused the incident.

  NAMING CONVENTION:
    YYYY-MM-DD-short-incident-name.md
    Example: 2026-05-20-payment-timeout-cascade.md

  BLAMELESS CULTURE:
    Focus on SYSTEMS and PROCESSES, not individuals. The goal is to prevent
    recurrence, not assign blame. Every postmortem MUST result in at least
    one update to sfmea.md and/or a new runbook.

  PROCESS:
    1. Copy this template immediately after the incident is resolved
    2. Fill in the timeline within 24 hours while memory is fresh
    3. Complete root cause and contributing factors within 48 hours
    4. Action items must have owners and deadlines
    5. Submit as a PR that also updates sfmea.md and risk-register.md
  =============================================================================
-->

- **Date**: YYYY-MM-DD
- **Duration**: [total duration from detection to resolution]
- **Severity**: [P1-Critical | P2-High | P3-Medium | P4-Low]
- **Status**: [Draft | Reviewed | Action Items Complete]
- **Author**: [name]
- **Reviewers**: [names]

## Summary

[2-3 sentences describing what happened, the impact, and how it was resolved.]

## Impact

| Metric | Value |
|---|---|
| Users affected | [number or percentage] |
| Duration of impact | [HH:MM] |
| Revenue impact | [estimated or N/A] |
| SLA breach | [Yes/No — which SLO was violated] |
| Data loss | [Yes/No — describe if yes] |
| DORA impact | [which metrics were affected: MTTR, change failure rate] |

## Timeline (UTC)

| Time | Event |
|---|---|
| HH:MM | [First indication of problem — alert, user report, etc.] |
| HH:MM | [Incident declared, responders engaged] |
| HH:MM | [Key diagnostic step or hypothesis] |
| HH:MM | [Mitigation action taken] |
| HH:MM | [Service restored / incident resolved] |
| HH:MM | [Post-incident verification complete] |

## Detection

| Question | Answer |
|---|---|
| How was it detected? | [Alert / User report / Internal monitoring / Accident] |
| Time to detect (TTD) | [minutes from first failure to detection] |
| Could we have detected faster? | [Yes/No — how?] |
| Was there a runbook? | [Yes — /runbooks/xxx.md | No — created as action item] |

## Root Cause

[Describe the root cause. Be specific and technical. Reference the component
from C4 architecture diagrams.]

### 5 Whys

1. **Why** did [the failure happen]? — Because [reason]
2. **Why** did [reason]? — Because [deeper reason]
3. **Why** did [deeper reason]? — Because [even deeper]
4. **Why** did [even deeper]? — Because [systemic cause]
5. **Why** did [systemic cause]? — Because [root cause]

## Contributing Factors

- [Factor 1: e.g., recent code change, configuration drift, missing test]
- [Factor 2: e.g., inadequate monitoring, unclear runbook, knowledge gap]
- [Factor 3: e.g., time pressure, insufficient review, legacy system]

## SFMEA Update

| Field | Before | After |
|---|---|---|
| Failure Mode (FM-XXX) | [was it known?] | [updated description] |
| Severity (S) | [previous or N/A] | [new score with justification] |
| Occurrence (O) | [previous or N/A] | [new score — it happened, so adjust] |
| Detection (D) | [previous or N/A] | [new score based on TTD] |
| RPN | [previous] | [new RPN] |

> If this failure mode was NOT in the SFMEA, add it now as a new row.

## Action Items

| ID | Action | Type | Owner | Deadline | Status | Tracking |
|---|---|---|---|---|---|---|
| AI-001 | [preventive action] | Prevent | [owner] | YYYY-MM-DD | Open | [issue #] |
| AI-002 | [detective action] | Detect | [owner] | YYYY-MM-DD | Open | [issue #] |
| AI-003 | [process improvement] | Process | [owner] | YYYY-MM-DD | Open | [issue #] |

## Lessons Learned

### What went well

- [e.g., alert fired within 2 minutes, runbook was accurate]

### What went poorly

- [e.g., took 30 minutes to identify the right team, no rollback tested]

### Where we got lucky

- [e.g., happened during low traffic, a team member happened to be online]

## Related Artifacts

- SFMEA: [risk/sfmea.md — row FM-XXX]
- FTA: [risk/fta/xxx.md — if a new fault tree was created]
- Runbook: [/runbooks/xxx.md — created or updated]
- Risk Register: [risk/risk-register.md — row R-XXX]
- PR that caused incident: [#NNN]
- PR with fixes: [#NNN]
