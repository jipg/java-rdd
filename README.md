# Java DevSecOps Template

A production-ready Java template embedding **75 engineering practices** across 6 layers: build foundation, Risk-Driven Development (RDD), security and supply chain, DORA metrics, and automated versioning with testing — all at **$0 licensing cost**.

Aligned with SFMEA, FTA, HAZOP, DORA, and Risk-Driven Development (RDD) principles from the DevSecOps/SRE proposal.

## What Is This?

This repository is a **structural template** for Java services in a multi-domain organization. It is not just a starter project — it embeds engineering discipline into the repository itself:

- **Build foundation**: Java 21 LTS, strict compiler settings, SpotBugs + PMD + Checkstyle, centralized dependency management via parent POM, reproducible builds
- **Risk-Driven Development**: SFMEA, FTA, HAZOP, postmortems, and runbooks as version-controlled code with CI enforcement
- **Security & supply chain**: Secret detection, SAST, SCA, SBOM, dependency updates — all open source
- **DORA metrics**: Deploy events emitted to Splunk, dashboards as code, RPN-to-CFR evidence loop

Every file includes comments explaining **what** it does and **why** it was chosen, making this an educational template as well as a functional one.

## Practices Inventory (75 total)

### Layer 1 — Repository Foundation (6 practices)

| Practice | File(s) | What it guarantees |
|---|---|---|
| Java-specific `.gitignore` | `.gitignore` | Excludes `target/`, `.idea/`, `.classpath`, OS files |
| Line ending normalization | `.gitattributes` | LF on Linux/macOS, CRLF for `.bat`/`.cmd`, binaries untouched |
| MIT License | `LICENSE` | Clear legal terms for the project |
| Code of Conduct | `CODE_OF_CONDUCT.md` | Community behavior standards |
| Contributing guide | `CONTRIBUTING.md` | Branching strategy, Conventional Commits, PR guidelines |
| Expanded README | `README.md` | What the template is, how to use it, all conventions |

### Layer 2 — Java Build Foundation (17 practices)

| Practice | File(s) | What it guarantees |
|---|---|---|
| Java/Maven version pinning | `maven-enforcer-plugin` in `pom.xml` | Java 21+, Maven 3.9.0+ required |
| Maven Wrapper | `.mvn/wrapper/`, `mvnw`, `mvnw.cmd` | Portable build without pre-installed Maven |
| Strict compiler | `pom.xml` | `-Xlint:all`, `-Werror`, `failOnWarning=true` |
| OWASP Dependency Check | `pom.xml` | Known CVEs in dependencies detected at build time |
| Reproducible builds | `pom.xml` | `project.build.outputTimestamp` for deterministic output |
| Centralized dependency management | `pom.xml` (parent POM) | `dependencyManagement` + `pluginManagement` for all versions |
| SpotBugs + Find Security Bugs | `pom.xml`, `spotbugs-exclude.xml` | SAST: OWASP/CWE bug detection at build time |
| PMD | `pom.xml`, `pmd-ruleset.xml` | 400+ code quality and best practice rules |
| Checkstyle | `pom.xml`, `checkstyle.xml` | Style enforcement at build time |
| JaCoCo | `pom.xml` | Code coverage collection and reporting |
| Build-time analysis enforcement | `pom.xml` | All analyzers run during `mvn verify`, violations fail build |
| Analyzer opt-out | `pom.xml` | `-Dspotbugs.skip=true`, `-Dpmd.skip=true` per module if needed |
| Comprehensive `.editorconfig` | `.editorconfig` | IDE-agnostic style rules for Java, XML, YAML, properties |
| Batch mode builds | `.mvn/maven.config` | `--batch-mode --strict-checksums` by default |
| JVM build tuning | `.mvn/jvm.config` | JVM flags for the build process |
| Automated versioning | `.mvn/jgitver.config.xml` | Semantic versioning from git tags |
| Standard folder structure | `example-app/src/`, `build/`, `docs/` | Maven convention layout |

### Layer 3 — Risk-Driven Development (20 practices)

| Practice | File(s) | What it guarantees |
|---|---|---|
| Versioned SFMEA | `risk/sfmea.md` | Living failure mode analysis (S/O/D/RPN/AP), CI forces updates |
| Fault Tree Analysis (FTA) | `risk/fta/template.md`, `dropped-work.md`, `deploy-failed.md` | Fault trees with Mermaid diagrams, traceable to C4 components |
| HAZOP | `risk/hazop/template.md`, `deploy-flow.md` | Operational deviation analysis with guide words |
| Blameless postmortems | `risk/postmortems/template.md` | 5 Whys, SFMEA feedback loop, `deploy_id` for DORA |
| Risk Register | `risk/risk-register.md` | Consolidated risk view sorted by RPN descending |
| Runbooks as code | `runbooks/template.md` | Symptoms, diagnosis, remediation, escalation, contacts |
| FMEA-aligned PR template | `.github/PULL_REQUEST_TEMPLATE.md` | 6 questions: what fails, severity, probability, detection, rollback, artifacts |
| Mandatory labels | `.github/labels.yml` | 11 labels: `bugfix`, `feature`, `integration-change`, `new-service`, `migration`, `tier-1/2/3`, `breaking-change` |
| Require labels workflow | `.github/workflows/require-labels.yml` | Blocks merge without classification label |
| Tiered Definition of Done | `.github/workflows/definition-of-done.yml` | Different CI gates per change type |
| Tier-1 FMEA check | `definition-of-done.yml` | tier-1 PRs with empty FMEA sections are blocked |
| SFMEA update check | `definition-of-done.yml` | `feature`/`breaking-change` PRs must update sfmea.md |
| FTA existence check | `definition-of-done.yml` | `new-service`/`migration` PRs require FTA |
| FTA-to-diagrams validator | `build/validate-fta-diagrams.sh` | Component names in FTA must exist in architecture diagrams |
| Alert-to-runbook validator | `build/validate-alert-runbook.sh` | Every alert must point to an existing runbook |
| Architecture as code | `docs/architecture/README.md` | C4/Mermaid diagrams versioned and referenced by FTA |
| ADR template with risks | `docs/adr/template.md` | "Risks Introduced" section feeds SFMEA |
| ADR-0001: Maven Dependency Management | `docs/adr/0001-...md` | Documents centralized dependency management decision |
| ADR-0002: RDD | `docs/adr/0002-...md` | Documents RDD as structural discipline |
| Alert definitions as code | `observability/dynatrace/alerts/README.md` | YAML structure for versioned alert definitions |

### Layer 4 — Security & Supply Chain (13 practices)

| Practice | File(s) | What it guarantees |
|---|---|---|
| Secret detection | `.gitleaks.toml`, `gitleaks.yml` | Scans PRs and pushes for leaked secrets (MIT, $0) |
| Custom secret rules | `.gitleaks.toml` | JDBC connection strings, Spring passwords, Dynatrace/Splunk tokens |
| Automated dependency updates | `.github/dependabot.yml` | Maven + GitHub Actions weekly, grouped PRs (GitHub Free, $0) |
| Cross-language SAST | `.github/workflows/semgrep.yml` | Semgrep OSS: OWASP Top 10, CWE Top 25, Java rules (LGPL, $0) |
| Vulnerability scanning | `.github/workflows/trivy.yml` | Trivy: CVEs in deps + IaC misconfigs + weekly scan (Apache 2.0, $0) |
| SBOM generation | `.github/workflows/sbom.yml` | CycloneDX JSON/XML attached to releases (Apache 2.0, $0) |
| Domain-based code ownership | `.github/CODEOWNERS` | Auto-assigned reviewers: build, security, risk, observability, src |
| Branch protection as code | `docs/security/branch-protection.md` | Rules documented with gh CLI + Terraform examples |
| Commit signing guide | `docs/security/commit-signing.md` | SSH (recommended) and GPG signing step-by-step |
| Attribution policy | `build/check-attribution-policy.sh`, `.githooks/` | Pre-commit hooks for authorship policy |
| SARIF integration | `semgrep.yml`, `trivy.yml` | Unified results in GitHub Security tab |
| Open source toolchain | All security workflows | Equivalent coverage to GitHub Advanced Security at $0 |
| ADR-0003: Security strategy | `docs/adr/0003-...md` | Documents open source vs CodeQL decision |

### Layer 5 — DORA Metrics (10 practices)

| Practice | File(s) | What it guarantees |
|---|---|---|
| Deploy event schema | `observability/dora/event-schema.json` | JSON Schema contract with 20+ fields for deploy events |
| Deploy tracker (reusable) | `.github/workflows/deploy-tracker.yml` | Emits events to Splunk HEC: metadata, lead time, is_failure |
| Graceful degradation | `deploy-tracker.yml` | Splunk failures don't break deploys (non-blocking) |
| Deploy-incident correlation | `build/link-deploy-incident.sh` | Links postmortems to deploy_id for CFR |
| Monthly DORA consolidation | `build/consolidate-dora.sh` | Git-based monthly report (works without Splunk) |
| Versioned DORA dashboard | `observability/dora/dashboard-queries.spl` | 9 Splunk SPL queries: DF, LT (P50/P95), CFR, MTTR, scorecard |
| RPN-to-CFR evidence loop | `consolidate-dora.sh` | Quarterly correlation table: SFMEA trends vs DORA trends |
| Splunk HEC configuration | `observability/splunk/README.md` | Setup guide, event routing, correlation fields |
| DORA reports directory | `observability/dora/reports/` | Monthly reports committed to repo as evidence |
| ADR-0004: DORA strategy | `docs/adr/0004-...md` | Documents emission architecture and evidence loop |

### Layer 6 — Versioning & Testing (9 practices)

| Practice | File(s) | What it guarantees |
|---|---|---|
| Maven Wrapper | `.mvn/wrapper/`, `mvnw` | Pinned build tool restored via `./mvnw` |
| jgitver configuration | `.mvn/jgitver.config.xml` | Semantic versioning from git tags, `v*` prefix |
| Automated changelog | `CHANGELOG.md` | Living changelog updated on every release |
| Automated release workflow | `.github/workflows/release.yml` | Version computation, tag, and GitHub Release on every merge to main |
| JUnit 5 test framework | `pom.xml`, `example-app/` | Centrally managed test framework with example tests |
| JaCoCo code coverage | `pom.xml` | Cross-platform coverage collection (XML/HTML reports) |
| AssertJ assertions | `pom.xml` | Readable test assertions with clear failure messages |
| Test execution workflow | `.github/workflows/test.yml` | Tests + coverage on every push/PR, artifacts retained 30 days |
| Test DoD gate | `.github/workflows/definition-of-done.yml` | Tests must pass for bugfix/feature/integration/new-service/migration PRs |

## The Evidence Loop

```
SFMEA (risk/sfmea.md)
  RPN score tracks risk level
  |
  +- Actions reduce RPN (tests, alerts, runbooks)
  |
  v
DORA Metrics (observability/dora/)
  CFR and MTTR track delivery health
  |
  +- Lower CFR = fewer production failures
  +- Lower MTTR = faster recovery
  |
  v
Evidence: "RPN down correlates with CFR down and MTTR down"
  Quarterly report cross-references SFMEA trends with DORA trends
  |
  v
Continuous improvement cycle
```

## Security Toolchain ($0 total)

| Tool | License | What it covers |
|---|---|---|
| SpotBugs + Find Security Bugs | LGPL | SAST: OWASP/CWE bug detection (build time) |
| PMD | BSD | Code quality: 400+ rules (build time) |
| Checkstyle | LGPL | Style enforcement (build time) |
| OWASP Dependency Check | Apache 2.0 | SCA: dependency CVEs (build time) |
| Semgrep OSS | LGPL 2.1 | SAST: cross-language, custom rules (CI) |
| Trivy | Apache 2.0 | SCA: dependency CVEs, IaC misconfigs (CI) |
| Gitleaks | MIT | Secret detection in commits (CI) |
| CycloneDX Maven plugin | Apache 2.0 | SBOM generation for compliance (CI) |
| Dependabot | GitHub Free | Automated dependency updates |
| JUnit 5 | EPL 2.0 | Test framework with parallel execution |
| JaCoCo | EPL 2.0 | Cross-platform code coverage collection |
| AssertJ | Apache 2.0 | Readable test assertions |

## PR Risk Classification

Required change-type labels in this repository are:
`bugfix`, `feature`, `integration-change`, `new-service`, `migration`, `documentation`.

`documentation` is a first-class classification label for PRs that only change explanatory, governance, or operational text and do not change runtime behavior.

## Project Structure

```
.
+-- .editorconfig                          # Java style rules (IDE-agnostic)
+-- .gitattributes                         # Line ending normalization
+-- .githooks/                             # Local commit hooks
+-- .github/
|   +-- CODEOWNERS                         # Domain-based code ownership
|   +-- PULL_REQUEST_TEMPLATE.md           # FMEA-aligned risk questions
|   +-- dependabot.yml                     # Automated dependency updates
|   +-- labels.yml                         # Risk-tiered label taxonomy
|   +-- workflows/
|       +-- definition-of-done.yml         # Tiered CI gates by change type
|       +-- deploy-tracker.yml             # DORA deploy event emission
|       +-- enforce-attribution-policy.yml # PR metadata validation
|       +-- gitleaks.yml                   # Secret detection
|       +-- release.yml                    # Automated versioning & release
|       +-- require-labels.yml             # Mandatory PR classification
|       +-- sbom.yml                       # CycloneDX SBOM generation
|       +-- semgrep.yml                    # SAST (Semgrep OSS)
|       +-- test.yml                       # Test execution & coverage
|       +-- trivy.yml                      # Vulnerability scanning
+-- .gitleaks.toml                         # Secret detection rules
+-- .gitignore                             # Java/Maven-specific ignores
+-- .mvn/
|   +-- jgitver.config.xml                 # Automated semantic versioning
|   +-- jvm.config                         # JVM flags for build
|   +-- maven.config                       # Maven default options
|   +-- wrapper/                           # Maven Wrapper
+-- CHANGELOG.md                           # Auto-generated changelog
+-- CODE_OF_CONDUCT.md
+-- CONTRIBUTING.md                        # Branching, commits, PR guidelines
+-- LICENSE                                # MIT
+-- README.md                              # This file
+-- build/
|   +-- check-attribution-policy.sh        # Authorship policy enforcement
|   +-- check-commit-coauthors.sh          # Co-author validation
|   +-- consolidate-dora.sh                # Monthly DORA report generation
|   +-- gh-pr-safe.sh                      # Safe PR creation wrapper
|   +-- link-deploy-incident.sh            # Deploy-incident correlation
|   +-- validate-alert-runbook.sh          # Alert must have runbook
|   +-- validate-fta-diagrams.sh           # FTA must match architecture
+-- checkstyle.xml                         # Java style rules (build-time)
+-- docs/
|   +-- adr/
|   |   +-- template.md                    # MADR template + "Risks Introduced"
|   |   +-- 0001-use-maven-dependency-management.md
|   |   +-- 0002-rdd-as-structural-discipline.md
|   |   +-- 0003-security-toolchain-and-supply-chain-strategy.md
|   |   +-- 0004-dora-metrics-emission-strategy.md
|   |   +-- 0005-automated-versioning-and-test-strategy.md
|   +-- architecture/README.md             # C4 diagrams as code guide
|   +-- security/
|       +-- branch-protection.md           # Rules + gh CLI + Terraform
|       +-- commit-signing.md              # SSH/GPG signing guide
+-- example-app/                           # Example JUnit 5 test project
|   +-- pom.xml
|   +-- src/main/java/com/example/
|   +-- src/test/java/com/example/
+-- observability/
|   +-- dora/
|   |   +-- README.md                      # DORA architecture and data flow
|   |   +-- dashboard-queries.spl          # 9 Splunk SPL dashboard queries
|   |   +-- event-schema.json              # Deploy event JSON Schema
|   |   +-- reports/                       # Monthly DORA reports
|   +-- dynatrace/alerts/README.md         # Alert definitions as code
|   +-- splunk/README.md                   # HEC setup and event routing
+-- pmd-ruleset.xml                        # PMD custom ruleset
+-- pom.xml                                # Parent POM (all config here)
+-- risk/
|   +-- sfmea.md                           # Living failure mode analysis
|   +-- risk-register.md                   # Consolidated risk view
|   +-- fta/                               # Fault Tree Analysis
|   |   +-- template.md
|   |   +-- dropped-work.md
|   |   +-- deploy-failed.md
|   +-- hazop/                             # Operational deviation analysis
|   |   +-- template.md
|   |   +-- deploy-flow.md
|   +-- postmortems/template.md            # Blameless incident review
+-- runbooks/template.md                   # Operational response procedures
+-- spotbugs-exclude.xml                   # SpotBugs exclusion filter
```

## Local Commit Policy

This repository enforces local commit metadata rules with versioned hooks. To enable after cloning:

```bash
git config core.hooksPath .githooks
chmod +x .githooks/commit-msg build/check-commit-coauthors.sh
```

The hooks reject `Co-authored-by:` trailers unless explicitly allowlisted in `build/allowed-coauthors.txt`, and reject staged content with automated attribution wording.

For PRs from the terminal, use `build/gh-pr-safe.sh` instead of `gh pr create` directly.

## How to Use

### Option 1: GitHub Template

1. Click **"Use this template"** on the GitHub repository page
2. Name your new repository following the domain taxonomy: `{domain}/{service}`
3. Clone it locally and start building

### Option 2: Manual Clone

```bash
git clone https://github.com/jipg/java-rdd.git my-project
cd my-project
rm -rf .git
git init
git add .
git commit -m "feat: initialize project from java-rdd template"
```

### Option 3: Fork

Fork this repository and customize it for your own needs.

## Getting Started

After creating your project from this template:

1. Verify the build works:
   ```bash
   ./mvnw verify
   ```
2. Update this `README.md` with your project-specific information
3. Replace `{{dominio}}.{{servicio}}` placeholders in risk/ and runbooks/
4. Add your production module:
   ```bash
   mkdir -p src/main/java/com/yourorg/yourservice
   # Add the module to pom.xml <modules> section
   ```
5. Configure GitHub secrets for DORA metrics (optional):
   - `SPLUNK_HEC_URL`: Splunk HEC endpoint
   - `SPLUNK_HEC_TOKEN`: HEC authentication token
6. Apply branch protection rules per `docs/security/branch-protection.md`
7. Set up commit signing per `docs/security/commit-signing.md`
8. Populate `risk/sfmea.md` with initial failure modes for your service
9. Start building features using branches from `main`

## Commit Conventions

This project follows [Conventional Commits](https://www.conventionalcommits.org/).

```
<type>(<scope>): <description>
```

| Type | When to Use |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Formatting, no code logic change |
| `refactor` | Code restructuring, no behavior change |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system or dependency changes |
| `ci` | CI/CD pipeline changes |
| `chore` | Maintenance tasks |

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full specification.

## PR Risk Classification

Every PR requires exactly one classification label that determines which CI gates apply:

| Label | CI Gates Applied |
|---|---|
| `bugfix` | Baseline (label required, secrets scan) |
| `feature` | + SFMEA updated, alert-runbook coverage |
| `integration-change` | + FTA-diagram coherence, contract tests |
| `new-service` / `migration` | + FTA exists, HAZOP, all validators strict |

Risk tier labels (`tier-1`, `tier-2`, `tier-3`) indicate business criticality. `tier-1` PRs with empty FMEA sections in the PR template are blocked.

See [.github/labels.yml](.github/labels.yml) for the full label taxonomy.

## Architecture Decision Records

| ADR | Decision |
|---|---|
| [ADR-0001](docs/adr/0001-use-maven-dependency-management.md) | Maven parent POM with centralized dependency management |
| [ADR-0002](docs/adr/0002-rdd-as-structural-discipline.md) | RDD as structural repo discipline (not external docs) |
| [ADR-0003](docs/adr/0003-security-toolchain-and-supply-chain-strategy.md) | Open source security toolchain ($0 vs $49/committer GHAS) |
| [ADR-0004](docs/adr/0004-dora-metrics-emission-strategy.md) | DORA metrics emission via Splunk HEC |
| [ADR-0005](docs/adr/0005-automated-versioning-and-test-strategy.md) | Automated versioning (jgitver) and test strategy (JUnit 5 + JaCoCo) |

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a Pull Request.
