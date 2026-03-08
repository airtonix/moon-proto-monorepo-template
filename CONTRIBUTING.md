# Contributing

Thank you for your interest in contributing to this project! This guide explains how to set up your development environment, our contribution conventions, and the CI pipeline.

## Prerequisites

Before you start, ensure you have:

- **mise** — polyglot runtime manager (install from [mise.jdx.dev](https://mise.jdx.dev))
- **moon** — task orchestrator (managed by mise)
- **proto** — toolchain manager (managed by mise)

## Setup

1. **Clone the repo and install tools:**
   ```bash
   git clone <repo-url>
   cd <repo-name>
   ```

2. **Install global moon and proto via mise:**
   ```bash
   mise use -g --pin github:moonrepo/moon
   mise use -g --pin github:moonrepo/proto
   ```

3. **Install project tools and setup:**
   ```bash
   proto install
   hk install
   moon run :setup
   ```

   This will:
   - Install all pinned tool versions (from `.prototools` and `.proto/`)
   - Set up git hooks via `hk` (linters, formatters)
   - Run project-specific setup tasks

4. **Verify everything works:**
   ```bash
   moon run :lint
   moon run :test
   moon run :build
   ```

## Development Conventions

### Use Moon tasks, not npm scripts

- **All project work** must go through `moon run` commands
- This repo uses the `no-package-scripts` linter to enforce this in `pkgs/*` (libraries and CLI tools)
- Apps in `apps/*` may proxy scripts through moon tasks for convenience
- See `moon.yml` (project root) and per-project `moon.yml` files for available tasks

**Example:**
```bash
# ✅ Correct
moon run :lint
moon run :test

# ❌ Avoid
npm run lint
npm test
```

### Proto for tool pinning

- All tool versions are declared in `.prototools` and managed by proto
- Custom plugins are in `proto/plugins/` (e.g., `hk.toml` for git hooks)
- Run `proto install` to fetch and cache tool versions

### Git hooks via hk

- Pre-commit hooks run linters and auto-fixers automatically before commit
- Hooks are configured in `hk.pkl` with linters for ESLint, Prettier, Actionlint (GitHub workflows), Pkl, and custom rules
- Run `hk check` to validate, `hk fix` to auto-fix issues

## Commit conventions

This project uses **semantic commit messages** (enforced by `pr-title.yml`):

```
<type>(<scope>): <description>

<body>

Closes #<issue>
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

**Example:**
```
feat(dashboard): add dark mode toggle

Adds a new theme selector to the dashboard UI and persists 
user preference to localStorage.

Closes #42
```

## CI Pipeline

The project has three GitHub Actions workflows:

### 1. **PR checks** (`.github/workflows/pr.yml`)

Runs on every pull request:
- Sets up mise, moon, and proto
- Validates counter internal-only guardrails (`private: true`, no-op `counter-lib:package`/`counter-lib:publish`)
- Runs `moon run :lint` — code style and quality checks
- Runs `moon run :test` — unit and integration tests
- Runs `moon run :build` — compilation and bundling

**Must pass before merging.**

### 2. **Release** (`.github/workflows/release.yml`)

Triggers when you push to `master`:
- Uses [Release Please](https://github.com/google-github-actions/release-please-action) for automated versioning
- Analyzes commit messages to determine version bumps (major.minor.patch)
- Creates release PRs and publishes GitHub releases
- Dispatches publish workflow for `hello-lib` when a release/prerelease is created

### 3. **Publish** (`.github/workflows/publish.yml`)

Triggered by the release workflow (repository_dispatch) and available for manual use (workflow_dispatch):
- Resolves target/tag inputs and runs target `:package`/`:publish` tasks
- Enforces guardrail that `pkgs/libs/counter/package.json` stays `private: true`
- `counter-lib` is internal-only: `counter-lib:package` and `counter-lib:publish` are explicit no-op success tasks
- Registry publishing is only for publishable targets (for example `hello-lib`), never `counter-lib`
- `hello-lib:publish` validates tags (`latest|next|vX.Y.Z`) and requires auth token (`NODE_AUTH_TOKEN` or `GITHUB_TOKEN`/`GH_TOKEN`)
- Workflow grants `packages: write` and passes `NODE_AUTH_TOKEN` for GitHub Packages publish
- Explicit environment target is derived from publish target (`publish-<target>`)
- Fails fast on unknown targets, missing tags, or missing GitHub publish tokens
- Writes a publish summary (`target`, `tag`, `trigger`, `result`) to `GITHUB_STEP_SUMMARY`
- `dashboard:publish` performs a real Cloudflare Pages deploy unless `DEPLOY=false`/`NO_DEPLOY=true`

### 4. **Dashboard Pages publish** (`.github/workflows/publish-cloudflare-pages.yml`)

Manual workflow for packaging + deploying `apps/dashboard` to Cloudflare Pages.

Required repository configuration:
- **Secrets**: `CLOUDFLARE_ACCOUNT_ID`, and one of `CLOUDFLARE_API_TOKEN` or `CLOUDFLARE_OIDC_TOKEN`
- **Variable**: `CF_PAGES_PROJECT_NAME`

Optional variables:
- `CF_PAGES_PRODUCTION_BRANCH` (defaults to `master` for `tag=latest`)
- `CF_PAGES_PREVIEW_BRANCH` (defaults to `next` for `tag=next`)

Workflow input `deploy=false` is package-only dry-run mode. It still builds and uploads the dashboard artifact, but skips Cloudflare deployment.
The workflow uses explicit environment protection targets (`cloudflare-pages` / `cloudflare-pages-dry-run`) and writes a deployment summary.

### 5. **API service Workers publish** (`.github/workflows/publish-cloudflare-workers.yml`)

Manual workflow for packaging/deploying `apps/api_service` to Cloudflare Workers.

Required repository configuration for deploy mode:
- **Secret**: `CLOUDFLARE_ACCOUNT_ID`
- **Secret**: one of `CLOUDFLARE_API_TOKEN` or `CLOUDFLARE_OIDC_TOKEN`

Optional repository configuration:
- **Variable**: `CF_WORKER_ROUTES`

The workflow enforces environment protection per Wrangler target (`cloudflare-workers-preview|staging|production`) and writes a deployment summary.

### 6. **something-cli release assets** (`.github/workflows/publish-github-release-assets.yml`)

Manual workflow for packaging and uploading `something-cli` binaries to GitHub release assets.

- Input tag supports `latest|next|vX.Y.Z`
- Uses `something-cli:package` + `something-cli:publish`
- Uses `GH_TOKEN` for GitHub release API uploads
- Fails fast when tag/token are missing
- Uses explicit environment protection target `github-release-assets`
- This workflow does **not** publish npm/GitHub Packages artifacts

## Review process

1. Create a feature branch from `master`
2. Make your changes, commit with semantic messages
3. Push and open a pull request
4. Ensure PR title follows semantic format (e.g., `feat: add new feature`)
5. Address any CI failures or review comments
6. Once approved and CI passes, your PR will be merged to `master`
7. The release workflow automatically creates releases and triggers publish workflows for publishable targets (internal-only targets like `counter-lib` stay no-op)

## Project structure

- **`apps/`** — runnable applications
- **`pkgs/`** — publishable and internal packages
- **`.moon/`** — moon workspace configuration
- **`.prototools`** — toolchain version pinning
- **`proto/`** — custom proto plugins
- **`.github/workflows/`** — CI/CD pipelines

## Questions?

If you have questions, feel free to:
- Open an issue for bugs or feature requests
- Check existing issues and discussions
- Review the main `README.md` for project overview
