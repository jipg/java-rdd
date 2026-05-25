# Open Source Security Toolchain and Supply Chain Strategy

- Status: accepted
- Deciders: Engineering team, Security team
- Date: 2026-05-25

## Context and Problem Statement

The organization needs a comprehensive security and supply chain strategy for its Java services. The industry-standard approach (GitHub Advanced Security with CodeQL) costs $49 per committer per month for private repositories. For an organization with a mixed stack (.NET, Java, AWS serverless) and multiple teams, this cost scales quickly.

How should we build a security toolchain that provides defense-in-depth (SAST, SCA, secret detection, SBOM) without vendor lock-in or significant licensing costs, while maintaining equivalent or better security coverage?

## Decision Drivers

- **Cost**: Minimize licensing costs without sacrificing security coverage
- **Open source preference**: Favor tools that can be self-hosted, audited, and customized by the team
- **Defense in depth**: Multiple overlapping tools catch what individual tools miss (aligned with SFMEA layered controls)
- **CI integration**: All tools must run in GitHub Actions without paid dependencies
- **Multi-language support**: The org has .NET, Java, and serverless — tools should cover the full stack where possible
- **SARIF support**: Results must integrate with GitHub Security tab for unified visibility
- **Supply chain compliance**: SBOM generation for regulatory requirements (EO 14028, EU CRA)

## Decision Outcome

Chosen option: **Open source toolchain**, because it provides equivalent or better coverage at zero licensing cost, with full transparency and no vendor lock-in.

### Security Coverage Matrix

| Security Concern | Tool(s) | When | License | Cost |
|---|---|---|---|---|
| **SAST (code vulnerabilities)** | SpotBugs + Find Security Bugs | Build time | LGPL | $0 |
| | PMD | Build time | BSD | $0 |
| | Semgrep OSS | CI (PR) | LGPL 2.1 | $0 |
| **SCA (dependency vulnerabilities)** | OWASP Dependency Check | Build time (`mvn verify`) | Apache 2.0 | $0 |
| | Trivy (filesystem scan) | CI (PR) | Apache 2.0 | $0 |
| | Dependabot | Automated PRs | GitHub Free | $0 |
| **Secret detection** | Gitleaks | CI (PR) + push | MIT | $0 |
| **IaC misconfigurations** | Trivy (config scan) | CI (PR) | Apache 2.0 | $0 |
| **SBOM generation** | CycloneDX Maven plugin | CI (push/release) | Apache 2.0 | $0 |
| **Style enforcement** | Checkstyle | Build time | LGPL | $0 |
| **Code ownership** | CODEOWNERS | PR review | GitHub Free | $0 |
| **Commit integrity** | GPG/SSH signing | Every commit | Git/GPG/SSH | $0 |
| **Branch governance** | Branch protection | PR merge | GitHub Free | $0 |
| **Dependency updates** | Dependabot | Scheduled PRs | GitHub Free | $0 |

**Total licensing cost: $0**

### Defense in Depth Visualization

```
+-------------------------------------------------------------+
|                    DEVELOPMENT TIME                           |
|  +-------------------------------------------------------+  |
|  | IDE (IntelliJ / Eclipse / VS Code)                     |  |
|  |  * SpotBugs plugin (bugs, OWASP/CWE)                  |  |
|  |  * Checkstyle plugin (style enforcement)               |  |
|  |  * PMD plugin (code quality)                           |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
|                    BUILD TIME (mvn verify)                    |
|  +-------------------------------------------------------+  |
|  | maven-compiler-plugin  -> -Xlint:all -Werror           |  |
|  | spotbugs-maven-plugin  -> SAST (Find Security Bugs)    |  |
|  | maven-pmd-plugin       -> Code quality rules           |  |
|  | maven-checkstyle-plugin-> Style enforcement            |  |
|  | dependency-check-maven -> Known CVEs in dependencies   |  |
|  | jacoco-maven-plugin    -> Code coverage collection     |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
|                    CI TIME (PR)                               |
|  +-------------------------------------------------------+  |
|  | Gitleaks     -> Secret detection in diff               |  |
|  | Semgrep OSS  -> Cross-language SAST (OWASP Top 10)     |  |
|  | Trivy FS     -> Dependency CVEs (NVD + GitHub)         |  |
|  | Trivy Config -> IaC misconfigurations                  |  |
|  | DoD workflow -> Risk artifact validation               |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
|                    MERGE TIME                                 |
|  +-------------------------------------------------------+  |
|  | Branch protection -> All checks green                  |  |
|  | CODEOWNERS        -> Right reviewers approved          |  |
|  | Signed commits    -> Author identity verified          |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
|                    POST-MERGE                                 |
|  +-------------------------------------------------------+  |
|  | CycloneDX SBOM -> Inventory for compliance             |  |
|  | Dependabot     -> Automated dependency updates         |  |
|  | Trivy weekly   -> Catch newly disclosed CVEs           |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

### Positive Consequences

- Zero licensing cost for the entire security toolchain
- No vendor lock-in — all tools are portable to any CI system
- Defense in depth with 6+ overlapping security layers
- SARIF integration provides unified security dashboard in GitHub
- SBOM compliance ready for regulatory requirements
- All tools are auditable (open source)

### Negative Consequences

- More tools to maintain and update than a single GHAS subscription
- No single vendor support — community support only
- Semgrep OSS has fewer rules than Semgrep Cloud (paid tier)
- Trivy may produce false positives requiring triage
- Team must understand multiple tools instead of one

## Risks Introduced

| Risk | Failure Mode | Severity | Mitigation | SFMEA Ref |
|---|---|---|---|---|
| Tool version drift | Different SpotBugs/Trivy versions across services | M | Pin versions in parent POM, Dependabot updates | FM-XXX |
| False positive fatigue | Teams ignore findings due to noise | H | Tune rules, exclusion filters, quarterly rule review | FM-XXX |
| Coverage gap | A vulnerability class not caught by any tool | M | Annual security assessment, penetration testing | FM-XXX |
| SBOM accuracy | CycloneDX misses transitive dependencies | L | Cross-validate with Trivy SBOM output | FM-XXX |

## Links

- [SpotBugs](https://spotbugs.github.io/) — LGPL
- [Find Security Bugs](https://find-sec-bugs.github.io/) — LGPL
- [PMD](https://pmd.github.io/) — BSD
- [Checkstyle](https://checkstyle.org/) — LGPL
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/) — Apache 2.0
- [Semgrep OSS](https://github.com/semgrep/semgrep) — LGPL 2.1
- [Trivy](https://github.com/aquasecurity/trivy) — Apache 2.0
- [Gitleaks](https://github.com/gitleaks/gitleaks) — MIT
- [CycloneDX Maven plugin](https://github.com/CycloneDX/cyclonedx-maven-plugin) — Apache 2.0
- ADR-0001: [Maven Dependency Management](0001-use-maven-dependency-management.md)
- ADR-0002: [RDD as Structural Discipline](0002-rdd-as-structural-discipline.md)
