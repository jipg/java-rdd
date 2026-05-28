# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build and run all quality gates (Checkstyle, PMD, SpotBugs, JaCoCo)
./mvnw verify -Ddependency-check.skip=true

# Run tests only (skips static analysis)
./mvnw -pl example-app test

# Run a single test class
./mvnw -pl example-app test -Dtest=TaskServiceTest

# Run a single test method
./mvnw -pl example-app test -Dtest=TaskServiceTest#createSavesTaskAndReturnsResponse

# Start the application
./mvnw -pl example-app spring-boot:run

# Run the full OWASP dependency vulnerability scan (slow — skipped in normal dev)
./mvnw verify
```

## Architecture

This is a Maven multi-module project. The root `pom.xml` is a parent aggregator that centralises all dependency versions, plugin versions, and quality gate configuration. Currently there is one module: `example-app`.

### example-app

Spring Boot 4.0.6 REST API backed by PostgreSQL. Java 21 required.

**Layer structure** (`src/main/java/com/example/`):

- `controller/` — `@RestController` classes. Depend on the service *interface*, never the impl. Path variables must use explicit names: `@PathVariable("id")`.
- `service/` — `TaskService` is the interface; `TaskServiceImpl` carries `@Service`. Spring wires the impl via the interface.
- `repository/` — Spring Data `JpaRepository` interfaces. No implementation needed.
- `model/` — JPA entities and enums. Entities must **not** be `final` (Hibernate proxies them). Every entity needs a `protected` no-arg constructor and a `@PrePersist` method for audit fields.
- `dto/` — Java records used as request/response types. Keep Jackson-free; Spring Boot 4 bundles Jackson 3.x (`tools.jackson.databind`, not `com.fasterxml.jackson.databind`).
- `config/` — Spring `@Configuration` classes.

**Database:** PostgreSQL on `localhost:5432/example_db`. `spring.jpa.hibernate.ddl-auto=update` auto-creates tables in dev. Hibernate 7 is pulled in transitively by `spring-boot-starter-data-jpa` — no explicit dependency needed.

**Test pattern:** No Spring context in unit tests. Use `MockMvcBuilders.standaloneSetup(controller)` for controller tests and `@ExtendWith(MockitoExtension.class)` for service tests. `@WebMvcTest` does not exist in Spring Boot 4.0 — the `web.servlet` slice was removed.

## Quality Gates

The parent POM enforces these at `verify` phase — all fail the build:

| Tool | Config file | What it checks |
|---|---|---|
| Checkstyle | `checkstyle.xml` | Google Java Style, 4-space indent, 120-char line limit |
| PMD | `pmd-ruleset.xml` | All major categories; `UseUtilityClass` is excluded |
| SpotBugs + FindSecBugs | `spotbugs-exclude.xml` | SAST; `Low` threshold, `Max` effort |
| JaCoCo | parent pom | Coverage report (threshold not enforced yet) |
| OWASP Dependency Check | parent pom | CVE scan; skip locally with `-Ddependency-check.skip=true` |

Compiler flags: `-Xlint:all -Werror` — all warnings are errors.

To suppress a SpotBugs finding on a specific method, prefer `@SuppressFBWarnings` over adding to `spotbugs-exclude.xml`. Only add to the XML for patterns that apply across the whole codebase.

## CI / PR Requirements

PRs must be labelled. The `definition-of-done.yml` workflow applies risk-tiered gates based on the label:

| Label | Extra gates required |
|---|---|
| `bugfix` | tests pass |
| `feature` | tests + SFMEA updated (`risk/sfmea.md`) + alert/runbook coverage |
| `integration-change` | feature gates + FTA↔diagram coherence + sequence diagram updated |
| `new-service` / `migration` | integration-change gates + FTA file exists in `risk/fta/` |

Adding `sfmea-exception` to a PR bypasses the SFMEA gate; document the justification in the PR body.

Tier-1 PRs (label `tier-1`) additionally require all five FMEA sections in the PR body to be filled in.

## Attribution Policy

A `commit-msg` hook and a CI workflow block commit messages, PR titles, and PR bodies that contain phrases matching the pattern `(generated|created|...) (with|by|using|...)`. Do not include tool-attribution wording (e.g. "Generated with Claude") in any of these fields. This is enforced both locally (`.githooks/commit-msg`) and in CI (`enforce-attribution-policy.yml`).

To activate the local hook: `git config core.hooksPath .githooks`

Allowed `Co-authored-by` trailers are listed in `build/allowed-coauthors.txt`. Any co-author not in that file will fail the commit hook.

## Release

Releases are automated via `release.yml` on push to `main`. Versioning uses jgitver (computed from git tags). Commits with message prefix `chore(release):` are skipped. Use Conventional Commits for commit messages.
