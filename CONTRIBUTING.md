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
- Hooks are configured in `hk.pkl` with linters for ESLint, Prettier, Pkl, and custom rules
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
- Runs `moon run :lint` — code style and quality checks
- Runs `moon run :test` — unit and integration tests
- Runs `moon run :build` — compilation and bundling

**Must pass before merging.**

### 2. **Release** (`.github/workflows/release.yml`)

Triggers when you push to `master`:
- Uses [Release Please](https://github.com/google-github-actions/release-please-action) for automated versioning
- Analyzes commit messages to determine version bumps (major.minor.patch)
- Creates release PRs and publishes GitHub releases
- Dispatches publish workflow when a release is created

### 3. **Publish** (`.github/workflows/publish.yml`)

Triggered by the release workflow:
- Installs tools and builds the project
- Publishes to npm with OIDC authentication
- Uses the tag from release workflow (latest or next)

## Review process

1. Create a feature branch from `master`
2. Make your changes, commit with semantic messages
3. Push and open a pull request
4. Ensure PR title follows semantic format (e.g., `feat: add new feature`)
5. Address any CI failures or review comments
6. Once approved and CI passes, your PR will be merged to `master`
7. The release workflow automatically creates releases and publishes to npm

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
