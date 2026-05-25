# Branch Protection Rules

<!--
  =============================================================================
  Branch Protection — Enforced Governance for the main Branch
  =============================================================================

  WHY THIS DOCUMENT EXISTS:
    Branch protection rules are configured in GitHub Settings, not in code.
    This document serves as the "as-code" definition of those settings,
    ensuring they can be reviewed, versioned, and replicated when
    instantiating the template for new services.

  HOW TO APPLY:
    GitHub UI: Settings → Branches → Branch protection rules → Add rule
    GitHub CLI: gh api repos/{owner}/{repo}/branches/main/protection --method PUT
    Terraform: github_branch_protection_v3 resource

  TOOL INFO:
    - License: Free (GitHub feature, all plans)
    - Cost: $0
    - "Require signed commits" available on all plans
    - "Require status checks" available on all plans
  =============================================================================
-->

## Recommended Rules for `main` Branch

### Rule: `main`

| Setting | Value | Why |
|---|---|---|
| **Require a pull request before merging** | Enabled | All changes go through review |
| → Required approvals | 1 (minimum) | At least one human validates the change |
| → Dismiss stale reviews on new pushes | Enabled | Force re-review after changes |
| → Require review from Code Owners | Enabled | CODEOWNERS file determines reviewers |
| **Require status checks to pass** | Enabled | CI gates must pass before merge |
| → Status checks required | See list below | Specific checks that must succeed |
| **Require conversation resolution** | Enabled | All review comments must be addressed |
| **Require signed commits** | Enabled | Verify commit author identity (see commit-signing.md) |
| **Require linear history** | Enabled | Squash-merge only, clean linear history |
| **Do not allow bypassing** | Enabled | Even admins must follow the rules |
| **Restrict who can push** | Enabled | Only merge via PR, no direct push |

### Required Status Checks

These are the CI workflows that must pass before a PR can be merged:

| Check Name | Workflow | Purpose |
|---|---|---|
| `Verify PR classification label` | `require-labels.yml` | PR has classification label |
| `Scan for secrets` | `gitleaks.yml` | No secrets in the diff |
| `Static analysis (Semgrep OSS)` | `semgrep.yml` | SAST findings addressed |
| `Scan filesystem for vulnerabilities` | `trivy.yml` | No CRITICAL/HIGH CVEs |

Conditional checks (based on PR labels, set as required when applicable):

| Check Name | Workflow | When Required |
|---|---|---|
| `Gate: Tier-1 FMEA sections` | `definition-of-done.yml` | tier-1 PRs |
| `Gate: SFMEA updated` | `definition-of-done.yml` | feature/integration PRs |
| `Gate: FTA exists` | `definition-of-done.yml` | new-service/migration PRs |
| `Gate: FTA ↔ Diagrams` | `definition-of-done.yml` | integration/new-service PRs |
| `Gate: Alert ↔ Runbook` | `definition-of-done.yml` | feature/integration/new-service PRs |

Exception handling:
- `Gate: SFMEA updated` may also pass via the `sfmea-exception` label when the PR body explicitly justifies why no new application failure mode was introduced.

## Applying via GitHub CLI

```bash
# Set branch protection (adjust org/repo)
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["Verify PR classification label","Scan for secrets","Static analysis (Semgrep OSS)","Scan filesystem for vulnerabilities"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":true}' \
  --field required_linear_history=true \
  --field required_signatures=true \
  --field restrictions=null
```

## Applying via Terraform

```hcl
resource "github_branch_protection_v3" "main" {
  repository     = github_repository.service.name
  branch         = "main"
  enforce_admins = true

  required_status_checks {
    strict   = true
    contexts = [
      "Verify PR classification label",
      "Scan for secrets",
      "Static analysis (Semgrep OSS)",
      "Scan filesystem for vulnerabilities",
    ]
  }

  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
  }

  required_signatures = true
  required_linear_history = true
}
```
