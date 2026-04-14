---
title: Gate downstream publish jobs on upstream push success, not just environment approval
date: 2026-04-14
tags: [ci, github-actions, supply-chain, publish-workflows]
related:
  - docs/plans/2026-04-14-001-chore-open-source-public-release-plan.md
---

# Gate downstream publish jobs on upstream push success, not just environment approval

## Problem

A GitHub Actions workflow split into two jobs — `update` (fetch installer,
compute hash, commit, push to main) and `publish` (pack `.nupkg`, push to
Chocolatey) — had a silent-failure path that would publish a release whose
source commit never reached `main`.

The `update` job used `continue-on-error: true` on its `Push to main` step,
with a PR-fallback step that opened `auto/choco-update-*` when the push was
rejected. The `publish` job was gated only on the `publish: true` dispatcher
input, and was protected at secret-consumption time by an environment
approval (`environment: chocolatey-publish` with a required reviewer). The
intent was: environment approval is the last line of defense — if anything
goes wrong upstream, the approver will notice in the logs and reject.

That intent failed in practice because a clean-looking `update` job log does
not obviously show "the push was rejected and a PR was opened instead" — the
step reports as `Successful` (due to `continue-on-error: true`), the fallback
step reports as `Successful` (because opening a PR succeeded), and the
`publish` job shows up in the approver's queue looking normal. A sleep-
deprived or inattentive approver approves. The package is pushed to the
Chocolatey community feed from a commit that lives only on a PR branch. The
audit trail on `main` doesn't include it.

## Root causes

1. **`continue-on-error: true` erases the failure signal from downstream
   consumers** unless they actively check `steps.*.outcome`. Nothing in
   GitHub Actions forces you to check it.
2. **Environment approval gates protect *secret consumption*, not
   *correctness*.** They answer "should `CHOCO_API_KEY` be handed to this
   job?", not "is this job's inputs still valid?". They depend on the
   approver's vigilance, which is a human-error vector.
3. **Checkout without a pinned ref** (`actions/checkout@v4` with no `ref:`)
   resolves at job-start time, not at dispatch time. During a long human
   approval wait, main-tip can drift relative to the commit the upstream job
   actually produced — so the publish job ends up packing a Frankenstein
   tree: the two tracked files from the artifact handoff, but everything else
   from whatever commit is on main at approval time.

## The fix

Two mechanical changes, both in `.github/workflows/update-and-publish.yml`:

### 1. Surface `push_outcome` as a job output and gate on it

```yaml
jobs:
  update:
    outputs:
      push_outcome: ${{ steps.push_changes.outcome }}
      commit_sha:   ${{ steps.export.outputs.commit_sha }}
    steps:
      - name: Push to main
        id: push_changes
        if: ${{ fromJSON(github.event.inputs.commit_push) }}
        continue-on-error: true
        ...

      - name: Export
        id: export
        shell: bash
        run: |
          set -euo pipefail
          if [ "${{ steps.push_changes.outcome }}" = "success" ]; then
            echo "commit_sha=$(git rev-parse HEAD)" >> "$GITHUB_OUTPUT"
          else
            echo "commit_sha=" >> "$GITHUB_OUTPUT"
          fi

  publish:
    needs: update
    if: |
      fromJSON(github.event.inputs.publish) &&
      (!fromJSON(github.event.inputs.commit_push) || needs.update.outputs.push_outcome == 'success')
```

Notes:

- `push_outcome` reads `steps.push_changes.outcome` directly from the job's
  `outputs:` block. This works even when the step is skipped — the value
  will be `'skipped'`, which is handled by the `!commit_push` branch of the
  `if:` expression.
- `commit_sha` is populated *only* when the push succeeded. When publishing
  from an uncommitted state (`commit_push: false`), the ref is left empty
  and the publish job falls back to the dispatch-time ref plus an artifact
  overlay — preserving that legitimate path without pretending it came from
  a pushed commit.

### 2. Pin the publish job's checkout to the upstream commit

```yaml
  publish:
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ needs.update.outputs.commit_sha }}
          persist-credentials: false
```

An empty ref falls back to the default behavior (dispatch-time ref) — which
is the correct behavior for the `commit_push: false` fallback path.

## Why the simpler alternatives don't work

- **"Just trust the environment approval gate."** Relies on a human noticing
  a subtle log anomaly. Not a defense.
- **"Set `continue-on-error: false` on the push step."** Then the PR
  fallback never fires, because the job terminates before reaching it. The
  fallback exists for legitimate reasons (branch protection blocks direct
  pushes), so this breaks the happy path for that case.
- **"Check out `github.sha` in the publish job."** `github.sha` for
  `workflow_dispatch` is the branch tip *at dispatch time*, not the commit
  the upstream job just pushed. Doesn't fix the TOCTOU.

## Generalized rule

> Any time a split CI workflow has an upstream job that may partially fail
> (typically via `continue-on-error: true`) and a downstream job that
> consumes its output, the downstream job must check the upstream's step
> outcomes explicitly — either via `needs.<job>.outputs.*` or by failing
> loudly in the upstream. Environment approvals are not a substitute. They
> gate *secret release*, not *correctness*.

Applies equally to:

- Publish workflows of any kind (`npm publish`, `cargo publish`, container
  image push, Chocolatey push, Homebrew tap updates, apt/yum repo updates).
- Deployment workflows with pre-deploy validation steps marked as
  `continue-on-error: true`.
- Any job using artifact handoff between stages — always pin the downstream
  checkout to the upstream's produced ref, not to the dispatch-time ref.

## References

- Plan: `docs/plans/2026-04-14-001-chore-open-source-public-release-plan.md`
- Review: `.context/compound-engineering/ce-review/20260414-181010-0ce5a5ea/summary.md`
- Commits: `3daa960` (fix), `3dc2ff1` (earlier autofix pass that narrowed
  publish permissions, added concurrency group, and added timeouts)
- Original finding: `reliability-reviewer` rel-1 (P1, 0.90 confidence) and
  rel-2 (P2, 0.80 confidence), flagged during ce:review autofix mode.
