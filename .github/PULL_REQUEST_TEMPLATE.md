## Classification

<!--
  REQUIRED: Select exactly ONE label before submitting this PR.
  The label determines which CI validation gates apply.
  Without a label, merge is blocked by the require-labels workflow.
-->

- **Label**: <!-- bugfix | feature | integration-change | new-service | migration -->
- **Tier**: <!-- tier-1 (critical path) | tier-2 (important) | tier-3 (standard) -->

## What does this PR do?

<!-- One paragraph summarizing the change and its motivation. -->

---

## Risk Assessment (FMEA-aligned)

<!--
  These questions are derived from Failure Mode and Effects Analysis (FMEA).
  For PRs labeled `tier-1`, ALL sections below MUST be completed.
  The definition-of-done workflow validates that these sections are not empty.

  For `tier-2` and `tier-3`, complete what applies. Empty sections for tier-1
  will block the merge.
-->

### 1. What can fail with this change?

<!--
  Identify NEW or MODIFIED failure modes introduced by this PR.
  Think about: null references, race conditions, timeouts, data corruption,
  authentication bypass, resource exhaustion, breaking API contracts.

  Example:
  - The new retry logic could cause duplicate processing if the message
    broker delivers the same message twice during the retry window.
  - The database migration adds a NOT NULL column, which will fail if
    existing rows have NULL values.
-->

- [ ] No new failure modes identified
- [ ] New failure modes listed below:

### 2. How severe if it fails?

<!--
  Estimate the impact using the SFMEA severity scale (1-10):
  1 = cosmetic | 5 = degraded service | 10 = data loss/security breach

  Justify your score. Reference the affected component and user impact.

  Example:
  - Severity: 7 — Duplicate payment processing would result in double charges.
    Affects: PaymentService → PaymentGateway integration.
-->

- **Severity estimate**: [ ] 1-3 (Low) | [ ] 4-6 (Medium) | [ ] 7-10 (High)
- **Justification**:

### 3. How likely to fail?

<!--
  Assess the probability considering:
  - Test coverage for the changed code paths
  - Complexity of the change (lines changed, components touched)
  - Historical failure rate of the affected area
  - Edge cases and boundary conditions

  Example:
  - Occurrence: 3 — The retry logic has 95% branch coverage, and the
    idempotency key prevents duplicates. Similar pattern works in 3 other services.
-->

- **Test coverage**: [percentage or description]
- **Complexity**: [ ] Low (< 50 lines, 1 file) | [ ] Medium (50-200 lines, 2-5 files) | [ ] High (> 200 lines or > 5 files)
- **Occurrence estimate**: [ ] 1-3 (Unlikely) | [ ] 4-6 (Possible) | [ ] 7-10 (Likely)

### 4. Would we detect it in time?

<!--
  What observability was added or already exists to detect this failure
  BEFORE users are significantly impacted?

  Consider: metrics, alerts, structured logs, health checks, dashboards.

  Example:
  - Added: Duplicate payment counter metric (payment.duplicate.count)
  - Added: Dynatrace alert when duplicate count > 0 in 5 min window
  - Existing: Payment service error rate alert (< 1% threshold)
-->

- **New metrics/alerts added**:
- **New structured logs added**:
- **Existing detection coverage**:
- **Detection estimate**: [ ] 1-3 (Automated, fast) | [ ] 4-6 (Manual, delayed) | [ ] 7-10 (Undetectable until user reports)

### 5. Rollback plan

<!--
  How do we undo this change if it causes problems in production?
  Be specific — "revert the PR" is not enough for database migrations
  or API contract changes.

  Example:
  - Code: Revert this PR (no breaking API changes, backward compatible)
  - Database: Migration is backward-compatible (adds nullable column).
    Rollback migration drops the column. Tested in staging.
  - Feature flag: Disabled via FEATURE_PAYMENT_RETRY=false env var.
-->

- **Rollback strategy**:
- **Estimated rollback time**:
- **Data migration rollback** (if applicable):

### 6. Risk artifacts updated?

<!--
  Check all that apply. For `feature` and `breaking-change` labels,
  SFMEA update is mandatory if new failure modes were identified above.
-->

- [ ] SFMEA updated (`risk/sfmea.md`) — new/modified failure modes added
- [ ] Risk register updated (`risk/risk-register.md`)
- [ ] FTA created/updated (`risk/fta/`)
- [ ] Runbook created/updated (`runbooks/`)
- [ ] ADR created (`docs/adr/`) — for architectural decisions
- [ ] N/A — no risk artifact changes needed (justify below)

**Justification if N/A**:

---

## Checklist

- [ ] Tests added/updated with adequate coverage
- [ ] No new warnings introduced (SpotBugs/PMD/Checkstyle violations)
- [ ] Follows Conventional Commits in all commits
- [ ] PR title follows Conventional Commits format
- [ ] Reviewed my own diff before requesting review
