# FTA: Unauthenticated Access to Task API

- **SFMEA Reference**: FM-001
- **Severity**: 9 (data breach or full data destruction by anonymous caller)
- **Last Updated**: 2026-05-28
- **Owner**: team

## Top Event

> Any unauthenticated caller can invoke any Task API endpoint (create, read, update, delete) without presenting credentials, exposing all task data and enabling data destruction.

## Fault Tree Diagram

```mermaid
flowchart TD
    TOP["TOP EVENT:<br/>Unauthenticated access to Task API<br/>Component: TaskController"]
    TOP --> OR1{"OR"}

    OR1 --> INT1["No authentication filter present<br/>Component: TaskController"]
    OR1 --> INT2["Authentication present but bypassable<br/>Component: TaskController"]

    INT1 --> AND1{"AND"}
    AND1 --> BE1["BE-1: Spring Security not on classpath<br/>Component: TaskController<br/>SFMEA: FM-001"]
    AND1 --> BE2["BE-2: No SecurityFilterChain bean defined<br/>Component: TaskController<br/>SFMEA: FM-001"]

    INT2 --> OR2{"OR"}
    OR2 --> BE3["BE-3: All routes permitted in security config<br/>Component: TaskController<br/>SFMEA: FM-001"]
    OR2 --> BE4["BE-4: JWT signature not verified<br/>Component: TaskController<br/>SFMEA: FM-001"]
    OR2 --> BE5["BE-5: Token expiry not enforced<br/>Component: TaskController<br/>SFMEA: FM-001"]
```

## Basic Events

| ID | Event | Component | Probability | Mitigation | Runbook |
|---|---|---|---|---|---|
| BE-1 | Spring Security not on classpath | TaskController | H | Add `spring-boot-starter-security` dependency | — |
| BE-2 | No SecurityFilterChain bean defined | TaskController | H | Define `SecurityFilterChain` in `config/SecurityConfig.java` | — |
| BE-3 | All routes permitted via `permitAll()` | TaskController | M | Restrict to authenticated routes; use `@PreAuthorize` | — |
| BE-4 | JWT signature not verified | TaskController | L | Use `spring-security-oauth2-resource-server`; enforce `jwk-set-uri` | — |
| BE-5 | Token expiry not enforced | TaskController | L | Validate `exp` claim; short-lived tokens (15 min) | — |

## Minimal Cut Sets

1. {BE-1, BE-2} — Spring Security absent: no filter chain exists, every request is admitted
2. {BE-3} — Single point of failure: security configured but all paths `permitAll()`
3. {BE-4} — Single point of failure: tokens accepted without signature check
4. {BE-5} — Single point of failure: expired tokens remain valid indefinitely

## Recommended Actions

| Action | Priority | Owner | Target Date | Status |
|---|---|---|---|---|
| Add `spring-boot-starter-security` dependency | Critical | team | 2026-06-04 | Open |
| Implement `SecurityFilterChain` in `config/SecurityConfig.java` requiring authentication on all `/tasks/**` routes | Critical | team | 2026-06-04 | Open |
| Add `@PreAuthorize` annotations per endpoint with role-based rules | High | team | 2026-06-11 | Open |
| Add security integration test asserting 401 on unauthenticated requests | High | team | 2026-06-11 | Open |
