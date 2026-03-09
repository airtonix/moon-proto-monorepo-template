# moonrepo + proto template (mixed-language)

A starter monorepo template built around **moonrepo** task orchestration and **proto** toolchain management, with a mixed-language example setup:

- **TypeScript app**: `apps/dashboard` (TanStack Start)
- **TypeScript library**: `pkgs/libs/hello`
- **Go CLI**: `pkgs/cli/something`

## Requirements

You must have both CLIs installed globally:

- `moon` (moonrepo CLI)
- `proto` (moonrepo proto CLI)

Recommended install (global, pinned) via `mise`:

```bash
mise use -g --pin github:moonrepo/moon
mise use -g --pin github:moonrepo/proto
```

## Layout

- `apps/` — runnable applications
- `pkgs/` — publishable/internal packages
- `.moon/` + `moon.yml` — moon workspace/project task config
- `.prototools` + `proto/` — project toolchain versions and plugins

## Proto toolchain

This repo uses **proto** to pin and manage tool versions. Tools are defined in `.prototools` and custom plugins in `proto/plugins/`.

### Custom plugins

- **`hk`** (`proto/plugins/hk.toml`) — Git hook manager for linting and formatting
  - Configured in `hk.pkl` with linters: ESLint, Prettier, Pkl, and custom `no-package-scripts` rule
  - Run `hk fix` to auto-fix linter issues, `hk check` to validate

### Conventions

- **Moon tasks over npm scripts**: Use `moon run` for all project tasks. The `no-package-scripts` linter enforces this in `pkgs/*` (libraries/tools). Apps may proxy scripts through moon tasks.
- **Project layers are explicit**: projects declare `layer` in `moon.yml` (`application`, `library`, or `tool`) so orchestration (like smoke tests) can target only product-bearing projects.
- **Proto for tool pinning**: All tool versions are declared in `.prototools` and auto-installed by `proto install`.
- **Git hooks via hk**: Pre-commit hooks run linters and fixers automatically before commit. Configure in `hk.pkl`.

## Quick start

```bash
proto install
hk install
moon run :lint
moon run :test
moon run :build
```

## Example commands

```bash
# app
bun --cwd apps/dashboard run dev

# lib tests
bun --cwd pkgs/libs/hello test

# go cli
cd pkgs/cli/something && go run . greet world
```

## Publish contracts

- `dashboard` (TanStack Start app) → Cloudflare Pages
- `docs-site` (TanStack static docs scaffold) → GitHub Pages (`https://airtonix.github.io/moon-proto-monorepo-template/`)
- `api-service` (service target) → Cloudflare Workers (not GitHub Pages); supports preview/staging/production and dry-run/no-deploy mode
- `something-cli` (Go CLI) → release binaries attached to GitHub releases
- `hello-lib` (Bun package) → GitHub Packages registry
- `counter-lib` (Bun package) → internal-only (`private: true`), package/publish are explicit no-op success

Publish command patterns:

```bash
# package/publish per target directly
moon run hello-lib:publish
moon run dashboard:publish
moon run something-cli:publish

# unknown target fails fast in CI publish workflow validation
# (workflow_dispatch input: target)
```

Smoke verification (local, no deploy side effects):

```bash
# run CI-equivalent quality gates
moon run :lint
moon run :test
moon run :build
```

## GitHub Packages publish configuration (hello-lib)

`hello-lib` publishes to `https://npm.pkg.github.com` and accepts `latest`, `next`, or `vX.Y.Z` tags.

Local publish requirements:

- `NODE_AUTH_TOKEN` (preferred), or `GITHUB_TOKEN`/`GH_TOKEN`
- Package scope in `pkgs/libs/hello/package.json` should match the GitHub owner when publishing with `GITHUB_TOKEN`

Examples:

```bash
# verify package contents and metadata without publishing
moon run hello-lib:package -- latest

# publish with a channel tag
NODE_AUTH_TOKEN=ghp_xxx moon run hello-lib:publish -- next
```

## Target publish workflows (current state)

This template currently includes only these root workflows:
- `.github/workflows/pr.yml`
- `.github/workflows/release.yml`
- `.github/workflows/publish.yml`
- `.github/workflows/pr-title.yml`
- `.github/workflows/stale.yml`

Project `:publish` tasks for `dashboard`, `docs-site`, `api-service`, and `something-cli` are intentionally skeletal right now (they validate CI flow without performing real external deployments).

If you want real deploys later, add dedicated workflows and replace skeletal `:publish` tasks with concrete deploy logic.

## Notes

- CI installs global `moon` + `proto`, then runs `proto install` and `moon` tasks.
- CI and publish workflows enforce that `counter-lib` remains internal-only (`private: true`) and that its package/publish tasks are noop guardrails.
- `pkgs/cli/something` demonstrates a Go project living cleanly beside Bun/TS projects in one repo.
