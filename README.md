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
moon run :setup
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

## Notes

- CI installs global `moon` + `proto`, then runs `proto install` and `moon` tasks.
- `pkgs/cli/something` demonstrates a Go project living cleanly beside Bun/TS projects in one repo.
