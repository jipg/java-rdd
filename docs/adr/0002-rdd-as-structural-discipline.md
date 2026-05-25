# Adopt Risk-Driven Development (RDD) as a Structural Repo Discipline

- Status: accepted
- Deciders: Engineering team, SRE team
- Date: 2026-05-25

## Context and Problem Statement

The organization is adopting DevSecOps practices aligned with SFMEA, FTA, HAZOP, and DORA metrics. Risk analysis traditionally lives in documents (Confluence pages, Excel sheets) that quickly become outdated because they are disconnected from the code they describe. When the code changes, nobody remembers to update the risk analysis. When an incident happens, the postmortem findings don't feed back into the risk model.

How should we embed risk analysis into the development workflow so that it stays current, is version-controlled, and is enforced by CI — not by process compliance checklists?

## Decision Drivers

- **Currency**: Risk artifacts must be updated when code changes, or they become misleading. Stale risk analysis is worse than no risk analysis.
- **Traceability**: Every failure mode must trace to architecture components, every alert to a runbook, every FTA node to a C4 diagram.
- **Automation**: CI must enforce risk artifact updates, not humans remembering to check a wiki page.
- **Proportionality**: The level of risk analysis must match the risk of the change (a bugfix doesn't need FTA, a new service does).
- **DORA alignment**: The system must improve, not hinder, deployment frequency and change lead time.
- **Blameless culture**: Postmortems feed the risk model, not blame reports.

## Considered Options

- **Option 1**: Embed risk artifacts in the repo with CI enforcement
- **Option 2**: External risk management tool (Jira, ServiceNow)
- **Option 3**: Wiki-based risk documentation with manual review

## Decision Outcome

Chosen option: **Option 1 — Embed risk artifacts in the repo with CI enforcement**, because it is the only option that guarantees risk artifacts are updated atomically with code changes and validated automatically.

### Positive Consequences

- Risk analysis is reviewed in the same PR as the code it describes
- CI gates prevent merging code without appropriate risk assessment
- Postmortems create feedback loops that update SFMEA automatically
- New services inherit the full risk framework from the template
- Risk artifacts are diffable, searchable, and have full git history
- Labels enable proportional analysis (bugfix vs new-service)

### Negative Consequences

- Higher initial learning curve for developers unfamiliar with SFMEA/FTA
- PR template is more demanding than "describe your changes"
- Risk of "checkbox compliance" if the team doesn't internalize the value
- CI gates add time to the PR process (mitigated by parallel job execution)

## Implementation

The following artifacts materialize RDD in the repository:

| Artifact | Path | Purpose |
|---|---|---|
| SFMEA | `/risk/sfmea.md` | Living failure mode analysis |
| FTA | `/risk/fta/*.md` | Fault trees for top events |
| HAZOP | `/risk/hazop/*.md` | Operational deviation analysis |
| Postmortems | `/risk/postmortems/*.md` | Incident learnings -> SFMEA feedback |
| Risk Register | `/risk/risk-register.md` | Consolidated risk view |
| Runbooks | `/runbooks/*.md` | Operational response procedures |
| PR Template | `.github/PULL_REQUEST_TEMPLATE.md` | FMEA-aligned questions |
| Labels | `.github/labels.yml` | Risk-tiered classification |
| FTA Validator | `build/validate-fta-diagrams.sh` | FTA <-> architecture coherence |
| Alert Validator | `build/validate-alert-runbook.sh` | Alert <-> runbook coverage |
| Label Gate | `.github/workflows/require-labels.yml` | Mandatory classification |
| DoD Gate | `.github/workflows/definition-of-done.yml` | Tiered validation |

## Risks Introduced

| Risk | Failure Mode | Severity | Mitigation | SFMEA Ref |
|---|---|---|---|---|
| Checkbox compliance | Team fills templates mechanically without thinking | M | Quarterly risk reviews, postmortem culture, training | FM-XXX |
| CI gate too strict | Legitimate PRs blocked by false positives | M | Non-strict mode for local dev, escape hatch via label | FM-XXX |
| Template staleness | Template becomes outdated as practices evolve | L | Annual template review, ADR for changes | FM-XXX |
| Over-engineering risk analysis | Simple changes get disproportionate scrutiny | L | Label-based proportionality (bugfix vs new-service) | FM-XXX |

## Links

- [Conventional Commits](https://www.conventionalcommits.org/)
- [MADR — Markdown Any Decision Records](https://adr.github.io/madr/)
- [SFMEA reference](https://en.wikipedia.org/wiki/Failure_mode_and_effects_analysis)
- [Fault Tree Analysis](https://en.wikipedia.org/wiki/Fault_tree_analysis)
- [HAZOP](https://en.wikipedia.org/wiki/Hazard_and_operability_study)
- [DORA Metrics](https://dora.dev/)
- ADR-0001: [Maven Dependency Management](0001-use-maven-dependency-management.md)
