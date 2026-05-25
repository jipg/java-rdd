# Use Maven Parent POM for Centralized Dependency Management

- Status: accepted
- Deciders: Engineering team
- Date: 2026-05-25

## Context and Problem Statement

The organization is building a multi-service Java architecture across several domains. Each domain will contain multiple services, all instantiated from this template repository. Without centralized dependency management, each service will independently declare Maven dependency versions, leading to version drift, diamond dependency conflicts, and inconsistent static analysis coverage across the portfolio.

How should we manage Maven dependency versions and static analysis tooling across all modules in a repository to ensure consistency, security, and maintainability?

## Decision Drivers

- **Consistency**: All modules in a repo must use identical dependency versions to prevent "works on my machine" and diamond dependency issues.
- **Security (DevSecOps)**: Static analysis (SpotBugs, PMD, Checkstyle) and SCA (OWASP Dependency Check) must be applied uniformly. No module should be able to accidentally skip analyzers.
- **Maintainability**: Updating a dependency version should require changing exactly one file (the parent POM), not N files across N modules.
- **Auditability**: Security auditors need a single manifest to review for known CVEs, aligned with SFMEA supply chain risk analysis.
- **Developer experience**: New modules inherit all analyzers automatically without manual setup.
- **DORA alignment**: Reducing change lead time for dependency updates directly improves deployment frequency.

## Considered Options

- **Option 1**: Parent POM with `<dependencyManagement>` and `<pluginManagement>`
- **Option 2**: Individual dependency declarations in each module POM
- **Option 3**: Maven BOM (Bill of Materials) as a separate published artifact

## Decision Outcome

Chosen option: **Option 1 — Parent POM with centralized management**, because it is the Maven-native solution that provides the strongest guarantees of version consistency without requiring separate artifact publication.

### Positive Consequences

- Single file (parent `pom.xml`) to update for version bumps
- `<dependencyManagement>` ensures all modules inherit the same versions
- Plugins configured in `<pluginManagement>` are inherited automatically
- `maven-enforcer-plugin` pins Java and Maven versions (equivalent to `global.json`)
- PR diff for dependency updates is minimal (one line change)
- Security audit can be performed by scanning a single POM
- New modules inherit everything by declaring the parent

### Negative Consequences

- Developers unfamiliar with Maven parent POMs need onboarding (mitigated by documentation in the POM itself and this ADR)
- Overriding a version for a specific module requires explicit `<version>` in that module's POM, which adds friction — intentionally
- All modules share the same version of a dependency; if one module needs a different version, it must be explicitly justified

## Analyzers Selected

The following static analysis tools were chosen based on complementary coverage:

| Analyzer | Purpose | Risk Area Covered |
|---|---|---|
| SpotBugs + Find Security Bugs | Bug detection, SAST (OWASP/CWE) | Security, Reliability |
| PMD | 400+ code quality and best practice rules | Maintainability |
| Checkstyle | Style enforcement at build time | Consistency |
| OWASP Dependency Check | Known CVE detection in dependencies | Supply Chain |
| JaCoCo | Code coverage measurement | Testing |

This combination provides defense-in-depth: multiple analyzers with overlapping but distinct rule sets ensure that a vulnerability missed by one tool is caught by another.

## Risks Introduced

| Risk | Failure Mode | Severity | Mitigation | SFMEA Ref |
|---|---|---|---|---|
| Parent POM coupling | All modules locked to same versions | L | Version overrides when justified; tested in CI | FM-XXX |
| Plugin configuration drift | Module overrides parent plugin config | M | Code review, enforcer plugin, CODEOWNERS on pom.xml | FM-XXX |
| Build time increase | All analyzers run on every build | L | Skip flags for local dev (-Dspotbugs.skip -Dpmd.skip) | FM-XXX |

## Links

- [Maven Parent POM documentation](https://maven.apache.org/guides/introduction/introduction-to-the-pom.html)
- [MADR template](https://adr.github.io/madr/)
