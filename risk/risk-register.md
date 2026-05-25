# Risk Register — {{dominio}}.{{servicio}}

<!--
  =============================================================================
  Risk Register — Consolidated risk tracking for the service
  =============================================================================

  WHY THIS FILE EXISTS:
    The risk register is the executive view of all identified risks. It
    aggregates risks from SFMEA, FTA, HAZOP, and postmortems into a single
    prioritized table ordered by RPN descending.

  RELATIONSHIP TO OTHER RISK ARTIFACTS:
    - sfmea.md:        Detailed failure mode analysis -> feeds rows here
    - fta/*.md:        Fault tree breakdowns of top events -> referenced in "Source"
    - hazop/*.md:      Operational deviation analysis -> referenced in "Source"
    - postmortems/*.md: Incident learnings -> creates new rows here

  WHEN TO UPDATE:
    - When sfmea.md is updated, reflect changes here.
    - After postmortems, add newly discovered risks.
    - During quarterly reviews, re-score and re-sort.
    - When a risk is fully mitigated, move to "Closed Risks" section.

  CATEGORIES:
    - Security:     Authentication, authorization, data exposure, injection
    - Reliability:  Availability, fault tolerance, recovery
    - Performance:  Latency, throughput, resource exhaustion
    - Operations:   Deployment, configuration, monitoring gaps
    - Compliance:   Regulatory, audit, data retention
    - Integration:  Third-party dependencies, API contracts, data consistency
  =============================================================================
-->

## Active Risks (sorted by RPN descending)

| ID | Risk Description | Category | Source | S | O | D | RPN | AP | Status | Owner | Last Review |
|---|---|---|---|---|---|---|---|---|---|---|---|
| R-001 | [risk description] | [category] | [SFMEA FM-xxx / FTA / HAZOP / Postmortem] | - | - | - | - | - | Open | [owner] | YYYY-MM-DD |

## Closed Risks

| ID | Risk Description | Category | Resolution | Closed Date |
|---|---|---|---|---|
| - | - | - | - | - |

## Risk Trend

| Quarter | Critical | High | Medium | Low | Total |
|---|---|---|---|---|---|
| YYYY-QN | 0 | 0 | 0 | 0 | 0 |
