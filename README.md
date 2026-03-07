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

## Quick start

```bash
proto install
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
