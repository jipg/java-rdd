# Risk Register — example.task-api

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
| R-001 | No authentication or authorization — any caller can read, modify, or delete all tasks | Security | SFMEA FM-001 / FTA task-api-unauthenticated-access / HAZOP H-001 | 9 | 6 | 8 | 432 | Critical | Open | team | 2026-05-28 |
| R-002 | `GET /tasks` returns unbounded result set — causes OOM or extreme latency as table grows | Performance | SFMEA FM-002 / FTA task-list-unbounded / HAZOP H-003 | 6 | 5 | 7 | 210 | Critical | Open | team | 2026-05-28 |
| R-003 | Permanent hard delete with no soft-delete or audit trail — deleted tasks are unrecoverable | Reliability | SFMEA FM-004 / HAZOP H-005 | 7 | 3 | 9 | 189 | High | Open | team | 2026-05-28 |
| R-004 | Non-atomic read-modify-write in `PUT /tasks/{id}` — concurrent updates silently overwrite each other | Reliability | SFMEA FM-003 / HAZOP H-004 | 5 | 4 | 8 | 160 | High | Open | team | 2026-05-28 |
| R-005 | Error responses expose internal DB details (SQL state, table names, Hibernate messages) | Security | SFMEA FM-006 / HAZOP H-006 | 4 | 5 | 7 | 140 | High | Open | team | 2026-05-28 |
| R-006 | No input validation on `TaskRequest` — null or blank `title` reaches DB layer and returns 500 | Reliability | SFMEA FM-005 / HAZOP H-002 | 5 | 6 | 4 | 120 | High | Open | team | 2026-05-28 |
| R-007 | DB connection pool exhaustion under sustained load — all endpoints return 503 | Performance | SFMEA FM-007 / HAZOP H-007 | 7 | 4 | 3 | 84 | Medium | Open | team | 2026-05-28 |
| R-008 | PostgreSQL unavailable — total service outage with no health probe or retry | Reliability | SFMEA FM-008 / HAZOP H-009 | 9 | 3 | 2 | 54 | Medium | Open | team | 2026-05-28 |

## Closed Risks

| ID | Risk Description | Category | Resolution | Closed Date |
|---|---|---|---|---|
| — | — | — | — | — |

## Risk Trend

| Quarter | Critical | High | Medium | Low | Total |
|---|---|---|---|---|---|
| 2026-Q2 | 2 | 4 | 2 | 0 | 8 |
