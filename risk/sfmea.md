# Service FMEA (SFMEA) — {{dominio}}.{{servicio}}

<!--
  =============================================================================
  SFMEA — Service Failure Mode and Effects Analysis
  =============================================================================

  WHY THIS FILE EXISTS:
    This is the living risk analysis for this service. It is NOT documentation
    sitting in Confluence — it is version-controlled source code subject to
    the same review and CI gates as any .java file.

  WHEN TO UPDATE:
    - Every PR labeled `feature` or `breaking-change` MUST update this file
      if the change introduces or modifies a failure mode.
    - After every postmortem, add the discovered failure mode here.
    - During quarterly risk reviews, re-score all rows.

  HOW TO SCORE (1-10 scale):
    S (Severity):   Impact if the failure occurs.
                    1 = cosmetic | 5 = degraded service | 10 = data loss/security breach
    O (Occurrence):  Likelihood of the failure happening.
                    1 = nearly impossible | 5 = occasional | 10 = near certain
    D (Detection):   Ability to detect BEFORE the failure reaches users.
                    1 = always detected (automated) | 5 = manual detection |
                    10 = undetectable until user reports

    RPN = S x O x D  (Risk Priority Number, max 1000)

  ACTION PRIORITY (AP):
    - Critical (RPN > 200 or S >= 9): Immediate action required, blocks release.
    - High (RPN 100-200): Action required within current sprint.
    - Medium (RPN 50-99): Action required within current quarter.
    - Low (RPN < 50): Monitor, no immediate action.

  TRACEABILITY:
    - Each row should reference the component from /docs/architecture/ diagrams.
    - FTA entries in /risk/fta/ expand the "Cause" column into full fault trees.
    - Runbooks in /runbooks/ provide remediation for each failure mode.
    - Postmortems in /risk/postmortems/ link back to rows they discovered.

  CI VALIDATION:
    - The `definition-of-done.yml` workflow checks that this file's last
      modified date is recent for PRs labeled `feature` or `breaking-change`.
  =============================================================================
-->

## Last Review

| Reviewed By | Date | Next Review |
|---|---|---|
| [team/owner] | YYYY-MM-DD | YYYY-MM-DD |

## SFMEA Table

| ID | Component | Failure Mode | Effect | Cause | S | O | D | RPN | AP | Current Control | Action | Owner | Date |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| FM-001 | [component from C4] | [how it fails] | [impact on users/business] | [root cause] | - | - | - | - | - | [existing mitigation] | [planned action] | [owner] | YYYY-MM-DD |

<!--
  EXAMPLE ROW (remove when populating):

  | FM-001 | API Gateway | Request timeout under load | Users see 504 errors, SLA breach | Connection pool exhaustion | 7 | 4 | 3 | 84 | Medium | Circuit breaker pattern | Add connection pool metrics to Dynatrace dashboard | @sre-team | 2026-05-20 |
-->

## Summary

| Priority | Count | Trend |
|---|---|---|
| Critical (RPN > 200) | 0 | - |
| High (100-200) | 0 | - |
| Medium (50-99) | 0 | - |
| Low (< 50) | 0 | - |

## Change Log

| Date | Change | PR |
|---|---|---|
| YYYY-MM-DD | Initial SFMEA creation | #N |
