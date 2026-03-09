# Moonrepo Monorepo Template Smoke Test (Executable Procedure)

## Overview
This procedure validates that a repository generated from this template can:
1. accept parallel feature PRs across projects,
2. pass CI and merge cleanly,
3. trigger DEV deployment workflows after feature merges,
4. generate and merge a Release Please PR,
5. trigger PROD deployment workflows after Release Please merge.

This procedure is written so a pi-messenger team can execute it reliably.

## Required Inputs
- **template_repo**: (optional, default: this repo. use gh cli to discover this).
- **test_repo_owner**: (optiona, default current owner. (use gh cli to discover).
- **test_repo_name** (optional, default `moonrepo-monorepo-smoketest`)
- **default_branch** (optional, default: same as this repo)
- **visibility** (optional, default: `public`): `public|private`
- **max_wait_minutes_ci** (optional, default: `30`)
- **max_wait_minutes_release** (optional, default: `45`)

### Discover `default_branch` with gh CLI
Use GitHub as source of truth instead of guessing branch names.

```bash
gh repo view "${test_repo_owner}/${test_repo_name}" --json defaultBranchRef -q '.defaultBranchRef.name'
```

Set `default_branch` from that output and use it for all branch-sensitive checks.

## Hard Constraints
- You MUST fail fast if `gh`, `git`, `moon`, or `proto` are unavailable.
- You MUST authenticate `gh` before continuing.
- You MUST NOT run against production repos; only use `test_repo_name`.
- You MUST capture evidence links for every gate (PR, workflow run, release PR).
- You MUST treat timeout as failure and report the blocking gate.
- You MUST run this SOP in a dedicated **manager session**.
- The manager session MUST coordinate work with `pi_messenger`.
- The manager session MUST NOT implement per-project code changes directly.
- Each per-project branch/change/PR flow MUST be executed by a separate subagent.

---

## State Machine (ASCII, dot-point)
Happy path (compact):
`INIT -> READY -> REPO_PREPARED -> DISPATCHING -> PROJECT_WORK_IN_PROGRESS -> PROJECT_WORK_COMPLETE -> AWAIT_RELEASE_PLEASE -> PROD_MONITORING -> PASS`

- `INIT`
  -> validate tools/auth
  -> `READY`

- `READY`
  -> clean/reset target repo
  -> create repo from template
  -> `REPO_PREPARED`

- `REPO_PREPARED`
  -> discover moon projects
  -> create per-project messenger tasks
  -> `DISPATCHING`

- `DISPATCHING`
  -> manager launches one subagent per project
  -> `PROJECT_WORK_IN_PROGRESS`

- `PROJECT_WORK_IN_PROGRESS`
  -> each subagent: branch -> change -> checks -> push -> PR
  -> if any subagent fails/timeout -> `PROJECT_WORK_FAILED`
  -> if all PRs opened + green -> `PROJECT_WORK_COMPLETE`

- `PROJECT_WORK_FAILED`
  -> manager records blocker/evidence
  -> FAIL (or reset/retry policy if explicitly allowed)

- `PROJECT_WORK_COMPLETE`
  -> merge feature PRs
  -> monitor DEV workflows
  -> if DEV workflows fail/timeout -> `DEV_FAILED`
  -> if DEV ok -> `AWAIT_RELEASE_PLEASE`

- `DEV_FAILED`
  -> manager records workflow evidence
  -> FAIL

- `AWAIT_RELEASE_PLEASE`
  -> wait for Release Please PR
  -> validate changelog + green checks
  -> merge Release Please PR
  -> if missing/failing/timeout -> `RELEASE_FAILED`
  -> else -> `PROD_MONITORING`

- `RELEASE_FAILED`
  -> manager records PR/workflow evidence
  -> FAIL

- `PROD_MONITORING`
  -> verify PROD workflows/artifacts
  -> if fail/timeout -> `PROD_FAILED`
  -> if success -> `PASS`

- `PROD_FAILED`
  -> manager records workflow evidence
  -> FAIL

---

## Steps

### 1) Environment & Tooling Validation
Run and record:
- `gh --version`
- `gh auth status`
- `git --version`
- `moon --version`
- `proto --version`

Also read `AGENTS.md` and verify any local prerequisites it defines.

**Pass criteria:** all commands succeed; auth is valid.

---

### 2) Clean Reset (Idempotent)
Target repo: `${test_repo_owner}/${test_repo_name}`

1. Check if repo exists.
2. If it exists, delete it.
3. Re-check and confirm deletion before creating a new one.

**Pass criteria:** repo does not exist before setup begins.

---

### 3) Create Test Repo from Template
1. Generate repo from `${template_repo}` with name `${test_repo_name}`.
2. Clone locally. Don't use https, use ssh.
3. Run the `gh-repo-setup-cli` skill for initial setup.
4. Discover actual default branch via `gh repo view` and set/confirm `${default_branch}` from that value.
5. Validate repo default branch equals `${default_branch}`.
6. Validate `.github/workflows/*.yml` are compatible with `${default_branch}` triggers.

**Pass criteria:** repo exists, cloned, setup completed, branch/workflow alignment confirmed.

---

### 4) Plan and Launch Parallel Project PRs (Manager + Subagents)
1. Manager lists moon projects (`moon query projects`).
2. Manager filters to smoke-eligible layers: `application`, `library`, `tool`.
3. Manager creates one task per smoke-eligible project in `pi_messenger`.
4. For each smoke-eligible project task, manager dispatches a separate subagent responsible for:
   - creating branch `smoke/<project>-change`
   - making a minimal meaningful change in that project
   - running project-local checks/tests
   - committing and pushing
   - opening a PR with label `smoke-test`
5. Manager creates one dedicated review-monitor agent that:
   - watches all smoke PRs
   - responds to review comments
   - pushes fixes until checks are green
6. Manager tracks progress via `pi_messenger` feed/task status and enforces timeouts.

**Pass criteria:** one open PR per smoke-eligible project with successful CI, and every PR was created by a distinct subagent.

---

### 5) Merge Feature PRs (DEV Trigger Gate)
1. Merge all green smoke PRs into `${default_branch}`.
2. Monitor `release.yml` and `publish.yml` workflow runs.
3. Verify DEV behavior:
   - packages publish to `next` channel with `-next-*` suffix
   - apps deploy to DEV environment with CALVER versioning

**Pass criteria:** required workflow runs complete successfully and artifacts match DEV rules.

---

### 6) Release Please PR Validation
1. Wait for Release Please PR creation.
2. Validate changelog includes all merged smoke changes.
3. Wait until Release Please PR checks are green.
4. Merge Release Please PR.

**Pass criteria:** Release Please PR exists, changelog complete, checks green, merged.

---

### 7) PROD Trigger Gate
After Release Please merge, monitor deployment workflows and verify:
- packages publish to `latest` channel with release-please computed versions,
- apps deploy to PROD environment using CALVER.

**Pass criteria:** production deployment workflows succeed and publish targets are correct.

---

## Timeout Policy
- CI checks exceeding `${max_wait_minutes_ci}` => FAIL
- Release/deploy checks exceeding `${max_wait_minutes_release}` => FAIL

Failures MUST include: blocking PR/workflow URL, last known status, and suspected cause.

---

## Required Evidence Output
At completion, produce:
1. Repo URL
2. List of smoke PR URLs (one per project)
3. Workflow run URLs for DEV trigger
4. Release Please PR URL
5. Workflow run URLs for PROD trigger
6. Final verdict: `PASS|FAIL`
7. If FAIL: concise root-cause summary and exact failed gate

---

## Suggested Manager Orchestration Pattern (pi-messenger + subagents)
Manager session orchestration shape (example):
- `pi_messenger({ action: "join" })`
- `pi_messenger({ action: "set_status", message: "smoke-test manager" })`
- `pi_messenger({ action: "plan", prompt: "Execute .pi/prompts/smoke-test.md with required inputs" })`
- `pi_messenger({ action: "task.list" })`
- `pi_messenger({ action: "task.start", id: "task-project-<name>" })` (per project)
- Manager dispatches one subagent per project task (parallel)
- `pi_messenger({ action: "feed", limit: 50 })` (monitor)
- `pi_messenger({ action: "send", to: "ReviewMonitor", message: "Track PRs and fix reviews" })`
- `pi_messenger({ action: "review", target: "task-project-<name>" })` (quality gate)
- `pi_messenger({ action: "task.done", id: "task-project-<name>", summary: "PR opened and green" })`

Recommended manager rules:
- Manager SHOULD reserve shared paths before coordination-heavy steps.
- Manager MUST keep subagent tasks isolated (one project per subagent).
- Manager MUST fail any project task that exceeds timeout policy.
- Use `reserve` for shared paths and `send` for coordination messages between monitor and worker agents.

---

## Execution Skeleton (Manager Session)
Use this as a concrete control-flow template.

1. Join + plan
   - `pi_messenger({ action: "join" })`
   - `pi_messenger({ action: "set_status", message: "running smoke-test manager" })`
   - `pi_messenger({ action: "plan", prompt: "Execute .pi/prompts/smoke-test.md with required inputs" })`

2. Discover/prepare project tasks
   - Manager discovers projects with moon and filters layers to `application|library|tool`.
   - For each smoke-eligible project `<name>`, manager ensures a messenger task exists (e.g. `task-project-<name>`).
   - Manager starts each task: `pi_messenger({ action: "task.start", id: "task-project-<name>" })`.

3. Dispatch parallel subagents (one per project)
   - For each smoke-eligible project `<name>`, manager dispatches one subagent with scope limited to that project task:
     - branch `smoke/<name>-change`
     - minimal change
     - local checks
     - commit/push
     - open PR
   - Manager MUST keep a mapping table:
     - `project -> messenger_task_id -> subagent_run_id -> pr_url`

4. Monitor and reconcile state
   - Poll manager feed: `pi_messenger({ action: "feed", limit: 50 })`.
   - Poll subagent state via `subagent_status` until each run is completed or failed.
   - On success:
     - record PR URL/evidence,
     - mark task done: `pi_messenger({ action: "task.done", id: "task-project-<name>", summary: "PR opened and green" })`.
   - On failure:
     - post blocker summary,
     - keep task open or reset with reason,
     - enforce timeout failure policy.

5. Review-monitor coordination
   - Create/assign dedicated review monitor agent.
   - Use `pi_messenger({ action: "send", to: "ReviewMonitor", message: "Track PRs, resolve reviews, keep checks green" })`.
   - Use `pi_messenger({ action: "review", target: "task-project-<name>" })` as quality gate before merge.

6. Merge gate
   - Merge only when every project task is done and CI is green.
   - Continue with Step 5+ (DEV trigger, Release Please, PROD trigger).
