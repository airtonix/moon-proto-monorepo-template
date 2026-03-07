# Contributing

Thank you for considering contributions to this project! This guide covers our development setup, conventions, and workflow.

## Prerequisites

Before you start, ensure you have the following installed globally:

- **`mise`** — polyglot runtime and task manager
  - Install: https://mise.jdx.dev/
- **`moon`** — task orchestration CLI (via `mise use -g --pin github:moonrepo/moon`)
- **`proto`** — toolchain version management (via `mise use -g --pin github:moonrepo/proto`)

Once installed, `moon` and `proto` will be pinned to the versions we use.

## Setup

After cloning, run the setup sequence:

```bash
proto install    # Install all pinned tools from .prototools
hk install       # Install git hooks
moon run :setup  # Run the setup task (installs project dependencies)
```

This will:
- Download and pin tool versions (hk, bun, go, etc.)
- Configure git pre-commit hooks for linting and formatting
- Install JavaScript/TypeScript dependencies via Bun
- Prepare your workspace

## Conventions

### Task orchestration: Use `moon run`

All project tasks are defined in `moon.yml` files and orchestrated via `moon`:

```bash
moon run :lint       # Lint all projects
moon run :test       # Run all tests
moon run :build      # Build all projects
moon run :typecheck  # Type-check all TypeScript
```

**Why?** Moon provides a unified task interface, caching, parallel execution, and correct dependency ordering across the monorepo.

### Package.json scripts

- **In `pkgs/*` (libraries/tools):** No `scripts` field. The `no-package-scripts` linter in `hk.pkl` enforces this.
- **In `apps/*` (applications):** Scripts are allowed and may proxy to `moon` tasks (e.g., `"dev": "moon run app:dev"`).

If you need to add a task, define it in the project's `moon.yml` file instead.

### Tool versions via proto

All tool versions are pinned in `.prototools` and installed by `proto install`:

```
hk = "1.37.0"      # git hooks
bun = "1.3.2"      # package manager / runtime
go = "1.25.1"      # go compiler
```

To update a tool, modify `.prototools` and run `proto install`.

Custom plugins (e.g., `hk`) are stored in `proto/plugins/` and referenced in `.prototools`.

### Git hooks via hk

Pre-commit hooks are configured in `hk.pkl` and managed by `hk`:

- **ESLint** — Lints TypeScript files
- **Prettier** — Formats code
- **Pkl** — Validates `.pkl` files
- **no-package-scripts** — Enforces moon task convention

**Before commit:** `hk` automatically runs fixers (`fix = true`) and stashes unstaged changes.

**Manual checks:**
```bash
hk check   # Validate all linters
hk fix     # Auto-fix all linters
```

## Commits and pull requests

### Commit format

This repo enforces [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(scope): short description
fix(scope): short description
docs(readme): update setup instructions
test(utils): add edge case tests
refactor(cli): simplify parsing logic
```

PR title validation is enforced by `.github/workflows/pr-title.yml`. Commits are squashed on merge, so focus on PR titles.

### Before pushing

1. Run `hk fix` to auto-format and fix issues
2. Run `moon run :lint` and `moon run :test` to validate your changes
3. If applicable, update `README.md` or `CONTRIBUTING.md`

## CI/CD pipeline

Our GitHub Actions workflows enforce quality and automate releases:

### `pr.yml` — PR checks
- **Triggers:** On `pull_request` events
- **Validates:**
  - PR title follows Conventional Commits
  - Code passes linting (`moon run :lint`)
  - Tests pass (`moon run :test`)
  - TypeScript compiles (`moon run :typecheck`)

### `release.yml` — Automated versioning and release notes
- **Triggers:** On `push` to `master`
- **Actions:**
  - Runs `release-please` to generate release notes and bump version based on commit history
  - Creates a release PR (or updates if open)
  - When merged, publishes the release

### `publish.yml` — Publish artifacts
- **Triggers:** On GitHub `release` events
- **Actions:**
  - Publishes packages to registries (npm, etc.)
  - Builds and tags Docker images (if applicable)

## Troubleshooting

### Hook failing but you disagree?

If a hook is too strict, you can:

1. **Bypass temporarily:** `git commit --no-verify` (use sparingly)
2. **Report an issue:** Discuss in our issue tracker
3. **Update `hk.pkl`:** If the rule is wrong, propose a fix

### Tool version mismatch

If you see "version mismatch" errors:

```bash
proto install --clean  # Re-download and install all tools
```

### Tests failing locally but passing in CI

This usually means a version mismatch. Ensure:

```bash
proto install
bun install
moon run :test
```

## Questions?

- Check the **README.md** for project layout and quick examples
- Review **`.moon/workspace.yml`** for global moon config
- Check **`hk.pkl`** for hook configuration
- Ask in an issue or discussion thread
