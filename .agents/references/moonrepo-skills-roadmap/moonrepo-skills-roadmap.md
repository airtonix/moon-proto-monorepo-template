# Moonrepo Skills Roadmap

## Purpose
Prioritized follow-on skills after the initial 4 authored skills.

## Candidate Matrix

| Skill candidate | Trigger symptoms | Expected outcome | Priority |
| --- | --- | --- | --- |
| `moonrepo-cache-debugging` | Frequent cache misses, inconsistent local vs CI results | Deterministic cache triage flow with root-cause checkpoints | **Now** |
| `moonrepo-ci-pipelines` | Slow CI pipelines, repeated full-repo runs | Standard CI recipe for affected targets + cache-aware execution | **Now** |
| `moonrepo-affected-targets-workflows` | Developers run too much work per change | Fast local/CI incremental workflows with predictable scope | **Now** |
| `moonrepo-task-graph-troubleshooting` | Unexpected dependency fan-out or cycles | Repeatable graph-debugging playbook with decision tree | **Later** |
| `moonrepo-migration-playbook` | Existing repos need staged adoption | Low-risk migration sequence with rollback gates | **Later** |

## Now vs Later Rationale
- **Now:** immediate operational savings on runtime and developer feedback cycles.
- **Later:** useful, but lower frequency or requires wider organizational alignment.
