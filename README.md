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

Root orchestration commands:

```bash
# package all allowed targets
moon run repo:package

# publish all allowed targets with a tag/channel
PUBLISH_TARGET=all PUBLISH_TAG=latest moon run repo:publish

# publish a single target
PUBLISH_TARGET=hello-lib PUBLISH_TAG=latest moon run repo:publish

# unknown target exits non-zero
PUBLISH_TARGET=not-a-target PUBLISH_TAG=latest moon run repo:publish
```

Lightweight smoke verification (router hardening):

```bash
# all mode still works
PUBLISH_TARGET=all PUBLISH_TAG=latest moon run repo:package

# single-target mode still works
PUBLISH_TARGET=hello-lib PUBLISH_TAG=latest moon run repo:publish

# unknown targets must fail (non-zero)
if PUBLISH_TARGET=not-a-target PUBLISH_TAG=latest moon run repo:publish; then
  echo "expected failure for unknown target" >&2
  exit 1
fi
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

## GitHub release assets publish workflow (something-cli)

Use `.github/workflows/publish-github-release-assets.yml` to upload `something-cli` archives to GitHub releases.
This workflow is for release assets only (not npm/GitHub Packages publishing).

Required:
- GitHub token (`github.token`, exposed as `GH_TOKEN` in workflow)
- Input tag (`latest|next|vX.Y.Z`)

## Cloudflare Pages publish configuration (dashboard)

Required for real dashboard deploys (`moon run dashboard:publish -- <tag>` and `.github/workflows/publish-cloudflare-pages.yml`):

- GitHub **secret**: `CLOUDFLARE_ACCOUNT_ID`
- GitHub **secret**: `CLOUDFLARE_API_TOKEN` (or `CLOUDFLARE_OIDC_TOKEN`)
- GitHub **repository variable**: `CF_PAGES_PROJECT_NAME`

Optional repository variables:

- `CF_PAGES_PRODUCTION_BRANCH` (default: `master`, used for `tag=latest`)
- `CF_PAGES_PREVIEW_BRANCH` (default: `next`, used for `tag=next`)

Dry-run without deploy:

```bash
DEPLOY=false moon run dashboard:publish -- latest
```

## Cloudflare Workers publish configuration (api-service)

Required for real Worker deploys (`moon run api-service:publish -- <tag> <environment>` and `.github/workflows/publish-cloudflare-workers.yml`):

- GitHub **secret**: `CLOUDFLARE_ACCOUNT_ID`
- GitHub **secret**: `CLOUDFLARE_API_TOKEN` (or `CLOUDFLARE_OIDC_TOKEN`)

Optional:
- GitHub **repository variable**: `CF_WORKER_ROUTES`

The workflow supports manual dry-run (`deploy=false`) and deploy mode per Wrangler environment (`preview|staging|production`).

## Notes

- CI installs global `moon` + `proto`, then runs `proto install` and `moon` tasks.
- CI and publish workflows enforce that `counter-lib` remains internal-only (`private: true`) and that its package/publish tasks are noop guardrails.
- `pkgs/cli/something` demonstrates a Go project living cleanly beside Bun/TS projects in one repo.
