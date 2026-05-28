# Service FMEA (SFMEA) — example.task-api

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
    - Each row references the component from doc/diagram/sequence.md.
    - FTA entries in /risk/fta/ expand the "Cause" column into full fault trees.
    - Runbooks in /runbooks/ provide remediation for each failure mode.
    - Postmortems in /risk/postmortems/ link back to rows they discovered.
  =============================================================================
-->

## Last Review

| Reviewed By | Date | Next Review |
|---|---|---|
| team | 2026-05-28 | 2026-08-28 |

## SFMEA Table

| ID | Component | Failure Mode | Effect | Cause | S | O | D | RPN | AP | Current Control | Action | Owner | Date |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| FM-001 | TaskController | No authentication or authorization on any endpoint | Any unauthenticated caller can read, create, update, or delete all tasks; data breach and destruction | No security filter chain configured | 9 | 6 | 8 | 432 | Critical | None | Add Spring Security with JWT or session-based auth; add `@PreAuthorize` per endpoint | team | 2026-05-28 |
| FM-002 | TaskServiceImpl / PostgreSQL | `GET /tasks` returns unbounded result set | Service runs out of heap, responds with OOM or extreme latency; cascading failure under load | `findAll()` with no pagination limit | 6 | 5 | 7 | 210 | Critical | None | Replace `findAll()` with `findAll(Pageable)`; add `max-http-request-header-size` guard | team | 2026-05-28 |
| FM-003 | TaskServiceImpl / PostgreSQL | Non-atomic read-modify-write in `PUT /tasks/{id}` | Concurrent updates silently overwrite each other; last writer wins with no conflict signal | `findById` + `setTitle` + `save` not wrapped in `@Transactional` with optimistic lock | 5 | 4 | 8 | 160 | High | None | Add `@Transactional` to `update()`; add `@Version` field to `Task` for optimistic locking | team | 2026-05-28 |
| FM-004 | TaskController | Permanent hard delete with no recovery path | Tasks deleted accidentally or maliciously cannot be recovered | `DELETE /tasks/{id}` issues hard `DELETE` SQL with no soft-delete or audit trail | 7 | 3 | 9 | 189 | High | None | Add `deletedAt` soft-delete column; archive instead of destroy; add delete audit log | team | 2026-05-28 |
| FM-005 | TaskController / TaskServiceImpl | No input validation on `TaskRequest` | DB constraint violation returns 500 with internal error message; null title reaches DB layer | `TaskRequest` record has no `@NotNull`/`@NotBlank` constraints; no `@Valid` on controller | 5 | 6 | 4 | 120 | High | DB `NOT NULL` on title column | Add Bean Validation (`@NotBlank` on title); add `@Valid` in controller; add `@ControllerAdvice` for `MethodArgumentNotValidException` | team | 2026-05-28 |
| FM-006 | TaskServiceImpl | Error messages expose internal DB details (table names, SQL state) | Caller receives stack trace or SQL error text; aids reconnaissance | `ResponseStatusException` default message may include Hibernate/JDBC error cause | 4 | 5 | 7 | 140 | High | None | Add `@RestControllerAdvice` that maps exceptions to sanitised RFC 7807 `ProblemDetail` responses | team | 2026-05-28 |
| FM-007 | PostgreSQL | DB connection pool exhaustion under load | All endpoints return 503; service fully unavailable | Hikari pool defaults (10 connections); slow queries hold connections; no timeout tuning | 7 | 4 | 3 | 84 | Medium | Spring Boot Hikari defaults | Set `spring.datasource.hikari.*` pool size, connection timeout, and idle timeout; add pool metrics | team | 2026-05-28 |
| FM-008 | PostgreSQL | PostgreSQL unavailable | All CRUD operations fail with 500; total service outage | DB host unreachable, crash, or planned maintenance | 9 | 3 | 2 | 54 | Medium | Spring Boot startup fail-fast | Add health endpoint (`/actuator/health`); add DB liveness probe; configure retry in datasource | team | 2026-05-28 |

## Summary

| Priority | Count | Trend |
|---|---|---|
| Critical (RPN > 200 or S >= 9) | 2 | Initial assessment |
| High (100-200) | 4 | Initial assessment |
| Medium (50-99) | 2 | Initial assessment |
| Low (< 50) | 0 | Initial assessment |

## Change Log

| Date | Change | PR |
|---|---|---|
| 2026-05-28 | Initial SFMEA from sequence diagram analysis | — |
