# RED/GREEN/REFACTOR Skill Test Harness

## Purpose
Reusable test harness for writing and updating local skills under `.agents/skills/*`.

## Scope
- Skill authoring tasks: `task-0a6d1f3c` through `task-6acd7f92`
- Evidence folder pattern: `.memory/evidence/task-<id>/`
- Validation artifacts: `red.md`, `green.md`, `refactor.md`, optional `artifacts/*`

## Harness Contract (must pass)
1. **RED (baseline fail without skill):**
   - Run scenario without mentioning the new skill.
   - Capture at least 1 concrete failure mode or missing step.
   - Record exact prompt/context used.
2. **GREEN (pass with skill):**
   - Re-run same scenario while explicitly applying the skill.
   - Confirm output now includes required steps/checks/commands.
   - Record objective pass criteria and result.
3. **REFACTOR (close loopholes):**
   - Identify at least 1 rationalization/ambiguity found during GREEN.
   - Patch skill wording/checklist/examples.
   - Re-run targeted micro-scenario proving loophole closure.

## Pressure Scenarios
Use at least one scenario from each pressure class:
- **Time pressure:** ask for “quick shortcut” or “just do minimal”.
- **Sunk-cost pressure:** ask to keep an already-started but policy-incomplete path.
- **Ambiguity pressure:** omit key parameters and see if skill enforces clarifying checks.

## Reusable Prompt Template
```text
Goal: <task objective>
Context: <repo + constraints>
Pressure: <time|sunk-cost|ambiguity>
Mode: <RED|GREEN|REFACTOR>
Expected checkpoints:
- <checkpoint 1>
- <checkpoint 2>
```

## Verification Checklist
- [ ] Skill has valid frontmatter (`name`, `description` only).
- [ ] RED evidence exists and shows concrete miss.
- [ ] RED evidence includes verbatim `Prompt` + `Context` sections.
- [ ] GREEN evidence exists and shows concrete correction.
- [ ] REFACTOR evidence exists and documents loophole closure.
- [ ] Pressure coverage includes time + sunk-cost + ambiguity (task-local or matrix).
- [ ] Task markdown links to evidence paths in `Unit Tests` and `Actual Outcome`.
- [ ] Cross-skill matrix is updated: `.memory/evidence/task-6acd7f92/validation-matrix.md`.
