# Contributing

Thank you for your interest in contributing to this project! This guide explains our workflow, branching strategy, and commit conventions.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a new branch from `develop` following the branching conventions below
4. Make your changes
5. Commit using Conventional Commits format
6. Push your branch and open a Pull Request against `develop`

## Branching Strategy

We use a simplified Git Flow model with the following branches:

| Branch | Purpose |
|---|---|
| `main` | Production-ready code. Only receives merges from `release/*` or `hotfix/*` |
| `develop` | Integration branch. All feature branches merge here |
| `feature/<name>` | New features or enhancements |
| `bugfix/<name>` | Bug fixes targeting `develop` |
| `hotfix/<name>` | Urgent fixes applied directly to `main` |
| `release/<version>` | Release preparation and final adjustments |

### Branch Naming

Use lowercase, kebab-case names that describe the change:

```
feature/add-user-authentication
bugfix/fix-null-reference-on-login
hotfix/patch-security-vulnerability
release/1.2.0
```

### Workflow

```
main ------------------------------------------ (stable releases)
 |                          ^
 |                          | merge
 v                          |
develop --+------+-------- release/x.y.z
          |      |
          |      v
          |   feature/foo
          v
       bugfix/bar
```

1. Create your branch from `develop`
2. Work on your changes with atomic commits
3. Open a PR to `develop`
4. After review and approval, squash-merge or merge into `develop`
5. When ready for release, create a `release/*` branch from `develop`
6. Merge the release branch into `main` and tag it

## Conventional Commits

All commits **must** follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

This repository also blocks unauthorized `Co-authored-by:` trailers and automated authorship wording through local Git hooks. Commit messages or staged files must not contain tool-provenance text.

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|---|---|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only changes |
| `style` | Code style changes (formatting, semicolons, etc.) |
| `refactor` | Code changes that neither fix a bug nor add a feature |
| `perf` | Performance improvements |
| `test` | Adding or updating tests |
| `build` | Changes to the build system or dependencies |
| `ci` | Changes to CI/CD configuration |
| `chore` | Other changes that don't modify src or test files |
| `revert` | Reverts a previous commit |

### Scope

The scope is optional and refers to the module or area affected:

```
feat(auth): add JWT token refresh
fix(api): handle null response from payment gateway
docs(readme): update installation instructions
```

### Breaking Changes

Indicate breaking changes with a `!` after the type/scope or with a `BREAKING CHANGE:` footer:

```
feat(api)!: change authentication endpoint response format

BREAKING CHANGE: The /auth/login endpoint now returns a different JSON structure.
```

### Examples

```
feat(users): add email verification on registration
fix(orders): prevent duplicate order submission
docs: update contributing guidelines
refactor(database): extract repository pattern from services
test(auth): add integration tests for login flow
build: upgrade to Java 22
ci: add GitHub Actions workflow for PR validation
```

## Git Hooks

Enable the repository-managed hooks after cloning:

```bash
git config core.hooksPath .githooks
chmod +x .githooks/commit-msg build/check-commit-coauthors.sh
```

The `commit-msg` hook rejects any `Co-authored-by:` trailer that is not explicitly allowlisted in `build/allowed-coauthors.txt`.
The `pre-commit` and `commit-msg` hooks also reject automated authorship or tool-attribution wording.

For PR metadata created from the terminal, use `build/gh-pr-safe.sh create ...` and `build/gh-pr-safe.sh edit ...` so titles and bodies are validated before they are sent to GitHub.
PR titles and bodies are also validated in GitHub Actions, which prevents manual edits in the GitHub UI from bypassing the repository policy.

## Pull Request Guidelines

- Keep PRs focused on a single concern
- Write a clear title following Conventional Commits format
- Include a description of **what** changed and **why**
- Link related issues using `Closes #123` or `Fixes #123`
- Ensure all CI checks pass before requesting review
- Request at least one reviewer

## PR Classification

Change classification labels are necessary, but they are not sufficient on their own to represent risk.

This repository treats PR classification as a two-dimensional decision:

| Dimension | Purpose | Examples |
|---|---|---|
| Change type | Describes the nature of the modification | `bugfix`, `feature`, `integration-change`, `new-service`, `migration`, `documentation` |
| Risk level | Describes operational and business impact | `tier-1`, `tier-2`, `tier-3`, `breaking-change` |

### Why One Label Is Not Enough

- A `bugfix` can still be high risk if it touches authentication, payments, migrations, or rollback-sensitive code.
- A `feature` can be low risk if it is isolated and easily reversible.
- A `migration` may be routine or may carry significant blast radius.
- A documentation-only PR should not be forced to masquerade as a product change.
- The type of change and the level of risk answer different questions and should not be collapsed into a single label.

### Practical Rule

- Every PR must have exactly one change-type label.
- PRs affecting critical paths or sensitive systems should also carry a risk label.
- Use `breaking-change` when compatibility, contracts, or rollout safety are affected.
- When in doubt, classify the PR conservatively and document the rationale in the PR body.
- Use `sfmea-exception` only when the SFMEA gate would normally apply but the PR does not introduce a new application failure mode.

### Examples

| Scenario | Change Type | Risk Label |
|---|---|---|
| Small UI defect in a non-critical admin page | `bugfix` | `tier-3` |
| New API endpoint behind a feature flag | `feature` | `tier-2` |
| Database backfill with rollback constraints | `migration` | `tier-1` |
| Change to auth token validation logic | `bugfix` | `tier-1` + `breaking-change` if contracts change |
| README, ADR, or runbook wording only | `documentation` | optional, based on affected audience |

### Label Cases

| Label | Use It When | Typical Cases |
|---|---|---|
| `bugfix` | You are restoring intended behavior | null fix, retry fix, validation correction |
| `feature` | You are adding net-new capability | endpoint, screen, operator automation |
| `integration-change` | You are changing system-to-system contracts or flow | webhook schema, queue consumer, external API contract |
| `new-service` | You are introducing a separately deployable runtime unit | new API, worker, daemon |
| `migration` | You are changing state that needs rollback planning | schema migration, backfill, storage move |
| `documentation` | You are only changing explanatory, governance, or operational text | README, ADR wording, guide, note |
| `tier-1` | Failure would have severe customer or business impact | auth, payments, routing, issuance |
| `tier-2` | Failure is important but not primary critical path | reporting, support APIs, internal ops |
| `tier-3` | Blast radius is limited and rollback is straightforward | non-critical admin UI, isolated tooling |
| `breaking-change` | Compatibility or rollout safety changes | removed field, incompatible config, response shape change |
| `sfmea-exception` | SFMEA gate applies, but no new application failure mode is introduced | governance-only change, scanner-only change, process control addition |
| `fta-required` | A new top-level failure path needs fault-tree analysis | new infrastructure dependency, new service boundary |
| `runbook-required` | Operator response or alert handling changes | new alert, escalation path, recovery step |
| `adr-included` | The PR includes an architectural decision record | ADR added or materially updated |

## Code Standards

- Follow the existing code style and conventions in the project
- Write unit tests for new functionality
- Keep methods small and focused
- Use meaningful names for variables, methods, and classes
