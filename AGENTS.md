# AGENTS.md

## Overview
This repository is a template/starting point.

After creating a new repo from this project, follow the guidance below to standardize setup and daily operation.

## First-Generation Setup (New Repo)

When a new repository is generated from this template, you **MUST** initialize and configure the GitHub repo using `gh` CLI.

### Required bootstrap flow
1. Authenticate and verify access:
   - `gh auth status`
2. Ensure the remote repo exists and is connected.
3. Apply repository policy settings:
   - Default branch protection requires pull requests.
   - Auto-delete merged branches is enabled.
   - Only squash merges are enabled.
   - Squash commit message mode is title + description.

If available, use the local skill:
- `.agents/skills/gh-repo-setup-cli/SKILL.md`

## Monorepo Operations

`moon` CLI is the **primary** interface for interacting with this monorepo and its projects.

Agents and maintainers **SHOULD** prefer `moon` commands over ad hoc per-package scripts for:
- running targets/tasks,
- project/task discovery,
- scoped/affected execution,
- build/test/lint orchestration.

Examples:
- `moon query projects`
- `moon query tasks <project>`
- `moon run <project>:<target>`
- `moon run :<target> --affected`

If available, use local moon skills under `.agents/skills/`.

## About Current Apps and Packages

The current `apps/` and `pkgs/` contents are examples, but they are also **indicative** of intended structure and conventions.

Treat them as reference implementations for:
- project layout,
- task naming,
- dependency wiring,
- moonrepo configuration patterns.

You **MAY** replace or remove example projects, but you **SHOULD** preserve established structural and operational conventions unless there is a deliberate migration plan.


## Required Tools

Not provided by this repo or its tool are two tools you must have.

> In Github CI, these two tools are provided by a specialised action we use.
> On your local machine you need to install them somehow. Mise, Nix... whatever.

- Proto: A Tool manager. https://moonrepo.dev/docs/proto/install
- Moon: A monorepo manager. install it with proto.
