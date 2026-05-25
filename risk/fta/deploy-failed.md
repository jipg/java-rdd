# FTA: Deployment Failure

<!--
  EXAMPLE FTA — Demonstrates the template with a deployment failure scenario.
  Replace this content with the actual analysis for your service.
-->

- **SFMEA Reference**: FM-XXX
- **Severity**: 7 (service unavailable or degraded during deploy)
- **Last Updated**: YYYY-MM-DD
- **Owner**: [team/person]

## Top Event

> A deployment to production fails, leaving the service in an unavailable or degraded state.

## Fault Tree Diagram

```mermaid
flowchart TD
    TOP["TOP: Production deployment fails<br/>Service unavailable or degraded"]
    TOP --> OR1{"OR"}

    OR1 --> INT1["Build artifact invalid<br/>Component: CI Pipeline"]
    OR1 --> INT2["Infrastructure provisioning fails<br/>Component: IaC"]
    OR1 --> INT3["Application fails to start<br/>Component: Application Host"]
    OR1 --> INT4["Health checks fail post-deploy<br/>Component: Load Balancer"]

    INT1 --> OR2{"OR"}
    OR2 --> BE1["BE-1: Tests pass but artifact corrupted<br/>Component: CI Pipeline<br/>SFMEA: FM-XXX"]
    OR2 --> BE2["BE-2: Wrong artifact version deployed<br/>Component: CD Pipeline<br/>SFMEA: FM-XXX"]

    INT2 --> OR3{"OR"}
    OR3 --> BE3["BE-3: Resource quota exceeded<br/>Component: Cloud Infrastructure<br/>SFMEA: FM-XXX"]
    OR3 --> BE4["BE-4: IaC drift from manual changes<br/>Component: IaC<br/>SFMEA: FM-XXX"]

    INT3 --> OR4{"OR"}
    OR4 --> BE5["BE-5: Missing configuration/secrets<br/>Component: Config Service<br/>SFMEA: FM-XXX"]
    OR4 --> BE6["BE-6: Database migration fails<br/>Component: Database<br/>SFMEA: FM-XXX"]
    OR4 --> BE7["BE-7: Incompatible dependency version<br/>Component: Application Host<br/>SFMEA: FM-XXX"]

    INT4 --> AND1{"AND"}
    AND1 --> BE8["BE-8: New version returns errors<br/>Component: Application Host<br/>SFMEA: FM-XXX"]
    AND1 --> BE9["BE-9: Rollback mechanism fails<br/>Component: CD Pipeline<br/>SFMEA: FM-XXX"]
```

## Basic Events

| ID | Event | Component | Probability | Mitigation | Runbook |
|---|---|---|---|---|---|
| BE-1 | Artifact corrupted | CI Pipeline | L | Checksum verification | /runbooks/artifact-integrity.md |
| BE-2 | Wrong artifact version | CD Pipeline | M | GitOps, immutable tags | /runbooks/wrong-version.md |
| BE-3 | Resource quota exceeded | Cloud Infrastructure | L | Quota alerts, capacity planning | /runbooks/quota-exceeded.md |
| BE-4 | IaC drift | IaC | M | Drift detection, no manual changes | /runbooks/iac-drift.md |
| BE-5 | Missing config/secrets | Config Service | M | Pre-deploy validation | /runbooks/missing-config.md |
| BE-6 | DB migration failure | Database | M | Backward-compatible migrations | /runbooks/migration-failed.md |
| BE-7 | Incompatible dependency | Application Host | L | Lock files, CPM | /runbooks/dependency-conflict.md |
| BE-8 | New version returns errors | Application Host | M | Canary deployment, smoke tests | /runbooks/post-deploy-errors.md |
| BE-9 | Rollback fails | CD Pipeline | L | Rollback drills, blue-green | /runbooks/rollback-failed.md |

## Minimal Cut Sets

1. {BE-5} — Single point of failure: missing secrets prevents startup
2. {BE-6} — Single point of failure: failed migration blocks app boot
3. {BE-8, BE-9} — Combined: errors in new version + rollback fails = prolonged outage
4. {BE-4} — Single point of failure: IaC drift causes unexpected infra state

## Recommended Actions

| Action | Priority | Owner | Target Date | Status |
|---|---|---|---|---|
| Add pre-deploy config validation step | Critical | [owner] | YYYY-MM-DD | Open |
| Enforce backward-compatible DB migrations | High | [owner] | YYYY-MM-DD | Open |
| Monthly rollback drill in staging | High | [owner] | YYYY-MM-DD | Open |
| Add IaC drift detection to CI | Medium | [owner] | YYYY-MM-DD | Open |
