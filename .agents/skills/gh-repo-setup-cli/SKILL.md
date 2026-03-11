---
name: gh-repo-setup-cli
description: Configures GitHub repositories via gh CLI and API fallbacks, when creating or standardizing repo settings and protections, resulting in reproducible branch/merge policy setup with verifiable commands.
---

# GH Repo Setup CLI

## Overview
Use this skill to create or standardize a GitHub repository with required merge and branch-protection policies. Prefer `gh` commands first; use `gh api` when settings are not exposed via flags.

## When to Use
- New repository bootstrap.
- Existing repository missing branch protection or merge policy.
- Team wants one repeatable setup path.

Do not use when you lack admin permissions for the target repo.

## Required Policy Outcome
- Pull requests required on default branch.
- Auto-delete branch on merge enabled.
- Only squash merges enabled.
- Squash commit message mode set to `PR_TITLE` + `PR_BODY`.

## Workflow
1. **Preflight**
   ```bash
   gh auth status
   gh repo view OWNER/REPO --json name,defaultBranchRef
   
   ```
2. **Create repo (if needed)**
   ```bash
   gh repo create OWNER/REPO --private --clone=false --confirm
   ```
3. **Set repository settings**

   ```bash
   gh repo edit OWNER/REPO \
     --enable-squash-merge true \
     --enable-merge-commit false \
     --enable-rebase-merge false \
     --delete-branch-on-merge true \
     --enable-wiki false \
     --enable-auto-merge true \
     --allow-update-branch true \
   ```
4. **Allow workflows to manipulate PRs**

   ```bash
      # 1) Ensure Actions is enabled for the repo
      gh api \
      -X PUT \
      repos/OWNER/REPO/actions/permissions \
      -f enabled=true \
      -f allowed_actions=all

      # 2) Set workflow token default permissions + allow PR approvals
      gh api \
      -X PUT \
      repos/OWNER/REPO/actions/permissions/workflow \
      -f default_workflow_permissions=write \
      -F can_approve_pull_request_reviews=true
   ```

5. **Set squash commit defaults (API fallback path)**
   ```bash
   gh api -X PATCH repos/OWNER/REPO \
     -f squash_merge_commit_title=PR_TITLE \
     -f squash_merge_commit_message=PR_BODY
   ```
6. **Require PRs on default branch (safe apply)**
   > ⚠️ `PUT /branches/{branch}/protection` is full-replacement style for branch protection. Default path: fetch, merge, then apply. Do not continue on fetch errors except explicit 404 (no existing protection yet).

   ```bash
   BRANCH=$(gh repo view OWNER/REPO --json defaultBranchRef -q '.defaultBranchRef.name')
   PROTECTION_ENDPOINT="repos/OWNER/REPO/branches/$BRANCH/protection"

   # 1) Fetch current protection. Abort on non-404 errors.
   if gh api "$PROTECTION_ENDPOINT" > /tmp/current-protection.json 2>/tmp/protection-fetch.err; then
     echo "Existing protection found"
   else
     if grep -q "404" /tmp/protection-fetch.err; then
       echo "No existing protection (fresh branch protection setup)"
       printf '{}\n' > /tmp/current-protection.json
     else
       echo "Failed to fetch existing protection; aborting to avoid unsafe overwrite." >&2
       cat /tmp/protection-fetch.err >&2
       exit 1
     fi
   fi

   # 2) Define intended changes and merge with current protection.
   cat > /tmp/intended-protection.json <<'JSON'
   {
     "required_status_checks": null,
     "enforce_admins": true,
     "required_pull_request_reviews": {
       "dismiss_stale_reviews": true,
       "required_approving_review_count": 1,
       "require_code_owner_reviews": false
     },
     "restrictions": null,
     "required_linear_history": true,
     "allow_force_pushes": false,
     "allow_deletions": false,
     "block_creations": false,
     "required_conversation_resolution": true,
     "lock_branch": false,
     "allow_fork_syncing": true
   }
   JSON

   jq -s '.[0] * .[1]' \
     /tmp/current-protection.json \
     /tmp/intended-protection.json > /tmp/merged-protection.json

   # 3) Apply merged payload.
   gh api -X PUT "$PROTECTION_ENDPOINT" \
     -H "Accept: application/vnd.github+json" \
     --input /tmp/merged-protection.json
   ```

   Full direct `-f ...` payload usage is acceptable only for fresh repos/branches with no prior protection to preserve.
6. **Verify**
   ```bash
   gh repo view OWNER/REPO --json deleteBranchOnMerge,mergeCommitAllowed,rebaseMergeAllowed,squashMergeAllowed
   gh api repos/OWNER/REPO/branches/$BRANCH/protection
   ```

## Caveats
- `required_status_checks='null'` keeps PR requirement without forcing checks; adjust per repo policy.
- Some org rulesets can override repo-level settings; if settings revert, inspect org rulesets.
- Do not claim successful remote updates without command output proving it.

## Quick Triage
- `403/404` on protection endpoint: verify admin role and repo visibility.
- branch not found: fetch default branch from API before applying protection.
- setting mismatch after apply: check org rulesets and inherited branch protections.
