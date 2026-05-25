# Automated Versioning (jgitver) and Test Strategy (JUnit 5 + JaCoCo)

- Status: accepted
- Deciders: Engineering team
- Date: 2026-05-25

## Context and Problem Statement

The template had 66 practices across 5 layers but lacked automated changelog generation, semantic versioning from conventional commits, and a configured test framework. How should we add automated release versioning and a test foundation while maintaining the $0 / open source constraint?

## Decision Drivers

- Must derive version bumps automatically from conventional commits already enforced by the repo
- Must be Java-native (no Node.js runtime dependency)
- Test framework must support parallel execution, data-driven tests, and code coverage collection
- All tools must be $0 and open source
- Tag format must match existing `consolidate-dora.sh` expectations (`v*` prefix)

## Considered Options

### Versioning

- jgitver (Maven extension, Apache 2.0)
- semantic-release (Node.js, MIT)
- maven-release-plugin (complex, convention-heavy)
- Manual versioning

### Testing

- JUnit 5 (Eclipse Public License 2.0)
- JUnit 4 (Eclipse Public License 1.0)
- TestNG (Apache 2.0)

## Decision Outcome

**Versioning**: jgitver, because it is a Maven-native extension (no Node.js), derives versions from git tags and commit history, integrates seamlessly with the Maven build lifecycle, and costs $0.

**Testing**: JUnit 5 + JaCoCo + AssertJ, because JUnit 5 is the modern standard for Java testing, JaCoCo provides cross-platform coverage without OS-specific agents, and AssertJ produces readable fluent assertion failure messages.

### Positive Consequences

- Every merge to main automatically derives the version from git tags and history
- Tag format (`v*`) feeds directly into DORA deploy frequency metrics
- Test infrastructure is ready for the first production project
- Coverage artifacts (JaCoCo XML/HTML) enable future threshold enforcement
- Evidence loop strengthened: tests reduce CFR, automated releases increase DF

### Negative Consequences

- jgitver is a smaller project than semantic-release (less ecosystem)
- jgitver derives versions from git state rather than generating changelogs (changelog generation requires a separate step or plugin)
- Test project exists but has no production code to test yet (template mode)

## Pros and Cons of the Options

### jgitver

- Good, because Java-native (Maven extension via `.mvn/extensions.xml`), no Node.js
- Good, because derives semantic versions from git tags and commit distance
- Good, because Apache 2.0 license, $0
- Good, because tag prefix is configurable (`v*` matches DORA scripts)
- Good, because no POM version management needed — version is computed at build time
- Bad, because smaller community than semantic-release
- Bad, because does not generate changelogs natively (requires complementary tooling)

### semantic-release

- Good, because mature ecosystem with many plugins
- Good, because highly configurable release pipeline
- Good, because generates changelogs automatically
- Bad, because requires Node.js runtime (adds dependency)
- Bad, because complex configuration for simple Java projects

### maven-release-plugin

- Good, because official Maven project tooling
- Good, because handles POM version updates and tagging
- Bad, because modifies POM files in the repo (noisy commits)
- Bad, because complex multi-step release process
- Bad, because designed for a different era of release management

### Manual versioning

- Good, because simple and explicit
- Bad, because error-prone and inconsistent
- Bad, because does not scale with multiple contributors

### JUnit 5

- Good, because modern standard for Java testing
- Good, because parallel execution support via `junit.jupiter.execution.parallel`
- Good, because extensible with `@ParameterizedTest`, `@ValueSource`, `@CsvSource`
- Good, because Eclipse Public License 2.0
- Good, because modular architecture (jupiter, vintage, platform)

### JUnit 4

- Good, because long history in Java ecosystem
- Good, because broad IDE and tool support
- Bad, because legacy architecture, no longer actively developed
- Bad, because less expressive parameterized test support

### TestNG

- Good, because powerful data-driven testing with `@DataProvider`
- Good, because flexible test configuration via XML
- Bad, because less community adoption than JUnit 5 in modern projects
- Bad, because IDE integration is less consistent

## Risks Introduced

| Risk | Failure Mode | Severity | Mitigation | SFMEA Ref |
|---|---|---|---|---|
| jgitver project abandoned | Version derivation breaks on new Git/Maven versions | L | Pin version, fork if needed; extension is simple enough to replace | FM-010 |
| Release workflow infinite loop | chore(release) commit triggers itself | H | `if: "!contains(..., 'chore(release):')"` guard in workflow | FM-011 |
| AssertJ license change | Future version changes to commercial | L | Pin version in parent POM; current Apache 2.0 license is permanent for released versions | FM-012 |
| No production code to test | Example tests pass but provide no safety net | L | Template mode; tests will cover real code as projects are added | FM-013 |

## Links

- [jgitver GitHub](https://github.com/jgitver/jgitver)
- [jgitver Maven plugin](https://github.com/jgitver/jgitver-maven-plugin)
- [JUnit 5 documentation](https://junit.org/junit5/)
- [JaCoCo documentation](https://www.jacoco.org/jacoco/)
- [AssertJ documentation](https://assertj.github.io/doc/)
- [ADR-0004: DORA metrics](0004-dora-metrics-emission-strategy.md) — tag format alignment
