---
title: "chore: Open-source and public release readiness"
type: chore
status: active
date: 2026-04-14
---

# chore: Open-source and public release readiness

## Overview

Prepare `chocolatey-sonos-controller` to be flipped from private to public on GitHub. The repository already has MIT `LICENSE`, a `README.md`, and `AGENTS.md`. The remaining gaps are (1) a clear unofficial/trademark disclaimer on the README so visitors understand the project's relationship to Sonos, Inc., (2) ownership and security contact metadata (`CODEOWNERS`, `SECURITY.md`), (3) hardening the auto-publish workflow so that a drive-by fork PR cannot exfiltrate `CHOCO_API_KEY` or push a poisoned `.nupkg`, and (4) a documented secret-audit pass of git history.

The goal is not to redesign the package — it is to make public exposure safe and legally clear.

## Problem Frame

Making the repo public changes the threat model in three ways:

1. **Brand/legal exposure.** "Sonos" is a registered trademark. The package repackages Sonos's own installer and should be unambiguously labeled as an unofficial community Chocolatey package so visitors (and Sonos) don't mistake it for an official distribution channel.
2. **Supply-chain exposure.** The `update-and-publish.yml` workflow holds a Chocolatey push credential (`CHOCO_API_KEY`) that can publish packages under the maintainer's Chocolatey account. A malicious PR that edits the workflow file itself could, in principle, push a poisoned nupkg. GitHub's default `pull_request` restrictions on forks mitigate this, but secrets-in-repo plus a `workflow_dispatch` push step deserve belt-and-braces hardening.
3. **Maintainer bandwidth.** Once public, the repo will get drive-by issues and PRs. Without `CODEOWNERS` and a `SECURITY.md`, there is no defined channel for review assignment or vulnerability reports.

## Requirements Trace

- R1. A visitor landing on the public README understands within 10 seconds that this is an unofficial community package, and that Sonos is not affiliated.
- R2. The repo has an MIT `LICENSE` with a current copyright year. *(Already satisfied — verify only.)*
- R3. Workflow edits to `.github/workflows/**` require maintainer review before merge.
- R4. `CHOCO_API_KEY` cannot be consumed by a workflow run that did not pass maintainer approval.
- R5. Security reports have a documented contact path (`SECURITY.md`).
- R6. Git history has been audited for literal secrets and the audit result is recorded in the PR description.
- R7. Nothing in the plan changes the package's runtime behavior (version, URL, checksum, install script) — this is pure release-readiness work.

## Scope Boundaries

- Not changing the nuspec, install script, or the package name.
- Not moving to a new Chocolatey account or rotating `CHOCO_API_KEY` unless the secret audit finds a leak.
- Not adding issue/PR templates, a Code of Conduct, or dependabot config — those are nice-to-have and can be follow-ups.
- Not adding signing or SBOM generation to the publish flow.

### Deferred to Separate Tasks

- **Issue and PR templates** (`.github/ISSUE_TEMPLATE/`, `pull_request_template.md`): follow-up PR once the repo has seen real inbound traffic and we know what templates would actually help.
- **Dependabot / workflow version pinning by SHA**: follow-up once the repo is public and Dependabot can run.
- **Code of Conduct**: optional; add if/when the project grows a contributor base.

## Context & Research

### Relevant Code and Patterns

- `LICENSE` — MIT, copyright "felix schwenk 2025". Verify year and spelling before going public.
- `README.md` — user-facing intro; currently lacks trademark disclaimer and does not name the upstream installer source explicitly as Sonos's own redirect URL.
- `AGENTS.md` — already documents contribution conventions; will be referenced from the new `SECURITY.md` so reporters have one authoritative entry point.
- `.github/workflows/update-and-publish.yml` — contains `secrets.CHOCO_API_KEY` consumption (lines around the `Pack and Push to Chocolatey` step). The `Setup Chocolatey` action was just removed in the prior turn; this plan builds on that state.
- `.github/workflows/ci.yml` — lint/consistency CI; no secret access, no changes needed.
- `chocolatey/sonos-controller.nuspec`, `chocolatey/ChocolateyInstall.ps1` — unchanged by this plan.

### Institutional Learnings

- None on disk (`docs/solutions/` does not exist in this repo). Institutional learning: GitHub's default behavior already blocks secrets from flowing to workflows triggered by `pull_request` from a fork, but does *not* block secrets for `workflow_dispatch` or pushes to `main`. The publish step runs under `workflow_dispatch`, so the attack surface is "who can trigger workflow_dispatch and what code is on `main` at that moment". Environment approvals close this gap.

### External References

- GitHub Docs — "Using environments for deployment" (required reviewers on environment → blocks job until approved).
- GitHub Docs — "Security hardening for GitHub Actions" (CODEOWNERS-gated workflow edits, fork PR secret policy).
- Chocolatey Community — "Creating Chocolatey Packages" trademark guidance: unofficial third-party packages are permitted but must not imply endorsement.

## Key Technical Decisions

- **Use a GitHub `Environment` called `chocolatey-publish` with a required reviewer, rather than a branch protection rule alone.** Branch protection guards `main` merges; the environment additionally gates the `Pack and Push to Chocolatey` *job* at run time, so even a `workflow_dispatch` triggered by an outside collaborator (should that ever be allowed) cannot consume `CHOCO_API_KEY` without explicit approval.
  - **Rationale:** defense in depth. Branch protection can be misconfigured or bypassed; environment reviewers are a second independent gate at the secret boundary.
- **Scope `CHOCO_API_KEY` to the environment, not the repo.** Move the secret from repo-level to environment-level so it is only available to jobs that declare `environment: chocolatey-publish`.
- **CODEOWNERS covers `.github/workflows/**` and the top-level nuspec/install script.** Required reviews on these paths prevent a drive-by PR from silently editing the publish job.
- **`SECURITY.md` points at GitHub private vulnerability reporting**, not a personal email. Keeps the contact channel auditable and rotatable.
- **Trademark disclaimer lives in the README (above the fold) and in the nuspec description eventually**, but the nuspec copy is out of scope for this plan — only README is touched here so the public landing page is clear on day one.
- **Do NOT rotate `CHOCO_API_KEY` unless the secret audit finds a leak.** Rotation without cause is churn.

## Open Questions

### Resolved During Planning

- *Should we use a separate Chocolatey account for community publishes?* — No. Out of scope; would force a package ownership transfer on the Chocolatey community feed.
- *Does the existing LICENSE need to be updated?* — Verify copyright year/name only. If still accurate for 2026, leave it. Otherwise, bump the year.
- *Should CODEOWNERS use a team or a user?* — User (`@fsch`). This is a single-maintainer repo.

### Deferred to Implementation

- Exact wording of the trademark disclaimer — draft during Unit 1, confirm it reads naturally in GitHub's rendered README.
- Whether `SECURITY.md` references a private vulnerability reporting link that must first be enabled in repo settings — enable during Unit 4 if not already on.

## Implementation Units

- [ ] **Unit 1: Add trademark disclaimer and public-facing framing to README**

  **Goal:** Make it unambiguous from the first paragraph that this is an unofficial community Chocolatey package, not an official Sonos distribution.

  **Requirements:** R1

  **Dependencies:** None

  **Files:**
  - Modify: `README.md`

  **Approach:**
  - Insert a short disclaimer block near the top (after the title, before "Getting Started") that states: (a) unofficial/community package, (b) not affiliated with or endorsed by Sonos, Inc., (c) "Sonos" is a trademark of Sonos, Inc., (d) the package only downloads the official installer from `sonos.com`.
  - Add a one-line "unofficial community package" tagline under the title so it also appears in GitHub's social preview.
  - Leave the existing "Getting Started", "Manual Update & Publish", "Local Build & Test", and "License" sections intact.
  - Add a "Reporting Issues / Security" section that points at `SECURITY.md` (created in Unit 4).

  **Patterns to follow:**
  - Existing README heading style (underline-style headings with `---`). Stay consistent.

  **Test scenarios:**
  - Test expectation: none — documentation only. Verification is visual review of the rendered Markdown.

  **Verification:**
  - Rendering the README on GitHub (or a local Markdown preview) shows the disclaimer above the fold.
  - A reader unfamiliar with the project can identify within 10 seconds that this is not an official Sonos product.

- [ ] **Unit 2: Add CODEOWNERS to gate workflow and package edits**

  **Goal:** Require maintainer review for changes to CI workflows and the package definition so a drive-by PR cannot silently alter publish behavior.

  **Requirements:** R3

  **Dependencies:** None

  **Files:**
  - Create: `.github/CODEOWNERS`

  **Approach:**
  - One CODEOWNERS file covering:
    - `/.github/workflows/**` → `@fsch`
    - `/chocolatey/**` → `@fsch`
    - `/LICENSE` → `@fsch`
    - `/SECURITY.md` → `@fsch`
  - Rely on a branch protection rule (configured in Unit 5, step 5b) to make CODEOWNERS review *required*, not just requested. CODEOWNERS without branch protection is only a review-request hint.

  **Patterns to follow:**
  - Standard GitHub CODEOWNERS syntax. No globs more complex than needed.

  **Test scenarios:**
  - Test expectation: none — configuration file. Verified by Unit 5's branch-protection settings taking effect.

  **Verification:**
  - After Unit 5 completes, opening a test PR that edits `.github/workflows/ci.yml` from a branch shows `@fsch` listed as a required reviewer in the PR sidebar.

- [ ] **Unit 3: Gate `CHOCO_API_KEY` behind a GitHub Environment with required reviewer**

  **Goal:** Prevent `CHOCO_API_KEY` from being consumed by any job that has not been explicitly approved, even when triggered via `workflow_dispatch`.

  **Requirements:** R4

  **Dependencies:** None (workflow edit is independent of the environment creation, but both must land together for the gate to be effective)

  **Files:**
  - Modify: `.github/workflows/update-and-publish.yml`

  **Approach:**
  - Add an `environment: chocolatey-publish` key to the `update` job (or split the `Pack and Push to Chocolatey` step into a dedicated downstream job that depends on `update` and carries the `environment:` key, if that reads cleaner). Prefer a single-job approach to keep the workflow simple unless splitting makes the approval prompt clearer.
  - Leave the `if: ${{ fromJSON(github.event.inputs.publish) }}` guard on the step — the environment check is additive, not a replacement.
  - Document in a short YAML comment above the `environment:` key that the environment gates `CHOCO_API_KEY` at run time and that a maintainer must approve the deployment from the Actions UI.
  - Environment creation, reviewer assignment, and secret migration are **repo settings changes** documented in Unit 5 — they are not file edits and cannot be made by this workflow edit alone.

  **Patterns to follow:**
  - Existing job structure in `.github/workflows/update-and-publish.yml`. Keep step ordering intact.

  **Test scenarios:**
  - Happy path: trigger `workflow_dispatch` with `publish: true`, observe that the job pauses waiting for environment approval, approve from the Actions UI, observe successful publish.
  - Happy path: trigger with `publish: false`, observe the job runs to completion without prompting for environment approval (because the publish step's `if:` guard short-circuits).
  - Error path: trigger with `publish: true`, *reject* the environment approval, observe that the publish step is skipped and `CHOCO_API_KEY` is never exposed in job logs.

  **Verification:**
  - A dry run of the workflow with `publish: true` halts at the `chocolatey-publish` environment gate and waits for maintainer approval.
  - `CHOCO_API_KEY` does not appear in any job log (GitHub masks it by default, but confirm no accidental `echo` was added).

- [ ] **Unit 4: Add SECURITY.md with vulnerability reporting contact**

  **Goal:** Give security researchers and drive-by reporters a documented channel.

  **Requirements:** R5

  **Dependencies:** None

  **Files:**
  - Create: `SECURITY.md`

  **Approach:**
  - Short file: supported scope (this packaging repo, not the Sonos software itself — direct Sonos vulnerabilities to Sonos), preferred reporting method (GitHub private vulnerability reporting, with a fallback to opening a non-sensitive issue for low-severity concerns), expected response time ("best effort, maintainer-run project").
  - Explicitly disclaim responsibility for the upstream installer's contents and point at Sonos's own security contact for software bugs.

  **Patterns to follow:**
  - Typical GitHub `SECURITY.md` structure. Keep it short — maintainer-run project, not an enterprise policy.

  **Test scenarios:**
  - Test expectation: none — documentation only.

  **Verification:**
  - GitHub's "Security" tab on the repo surfaces the SECURITY.md content once the repo is public.
  - Private vulnerability reporting is enabled in repo settings (Unit 5, step 5c).

- [ ] **Unit 5: Secret audit and repo-settings checklist**

  **Goal:** Confirm no literal secrets exist in history, and capture the repo-settings changes that must be made in the GitHub UI (not via files in the repo) before flipping the repo public.

  **Requirements:** R4, R6

  **Dependencies:** Units 1–4 merged (so the public-facing state is final before the audit snapshot)

  **Files:**
  - No files modified. This unit produces a checklist that belongs in the PR description (or a throwaway note in the PR thread) — not a committed artifact, because a committed checklist rots.

  **Approach:**
  - **5a. Secret audit of git history.** Run a scan for literal secret patterns across all history:
    - `git log --all -p` piped through a grep for `api.?key`, `secret`, `token`, `password`, `BEGIN .* PRIVATE KEY`, base64-looking blobs near those words.
    - Spot-check `choco apikey -k` occurrences to confirm every one is a placeholder (`<KEY>`, `$env:CHOCO_API_KEY`, `${{ secrets.CHOCO_API_KEY }}`), not a literal.
    - Record the audit result (clean vs. findings) in the PR description. If findings, **stop and rotate** `CHOCO_API_KEY` before continuing.
  - **5b. Branch protection on `main`.** Enable: require PR, require 1 approving review, require review from Code Owners, restrict who can dismiss reviews, disallow force-push. Document in the PR description so future maintainers can re-verify after settings drift.
  - **5c. Create `chocolatey-publish` environment.** In Settings → Environments, create `chocolatey-publish`, add `@fsch` as a required reviewer, and move `CHOCO_API_KEY` from repo-level secrets to this environment's secrets. Delete the repo-level copy only after confirming the workflow still sees the secret from the environment scope.
  - **5d. Fork-PR hardening.** Settings → Actions → General → "Fork pull request workflows from outside collaborators" → *Require approval for all outside collaborators*. Confirm workflow permissions default to read-only where possible (the update-and-publish job still needs `contents: write`, but `ci.yml` does not).
  - **5e. Enable private vulnerability reporting.** Settings → Code security → Private vulnerability reporting → Enable. This is what `SECURITY.md` directs reporters to.
  - **5f. Final visibility flip.** Settings → General → Change visibility → Public. Do this last, after all of the above are in place.

  **Test scenarios:**
  - Happy path: After 5c, trigger `workflow_dispatch` with `publish: false` and confirm the job completes with no secret prompt (publish step is skipped and never references the secret).
  - Happy path: After 5c, trigger with `publish: true` and confirm the job pauses at the environment approval gate.
  - Error path: Open a test PR from a throwaway fork that edits `.github/workflows/update-and-publish.yml`. Expected: (a) CODEOWNERS marks `@fsch` as required reviewer, (b) the workflow does not run automatically on the fork PR (outside-collaborator approval required), (c) even if run, `CHOCO_API_KEY` is not in scope because `pull_request`-triggered runs from forks do not receive secrets.
  - Edge case: Verify `git log --all -p | grep -iE 'ghp_|gho_|ghs_|ghr_'` produces no hits (GitHub token prefixes).

  **Verification:**
  - Secret audit result recorded in the PR description: "clean" or enumerated findings with rotation status.
  - Branch protection, environment gate, fork-PR approval, and private vulnerability reporting all visible in repo settings screenshots or recorded as checked items in the PR description.
  - Repo visibility is Public and the rendered README, SECURITY.md, and LICENSE all appear on the public landing page.

## System-Wide Impact

- **Interaction graph:** The only runtime interaction affected is the auto-publish workflow. The environment gate adds a human-approval step between "workflow triggered" and "secret consumed". CI (`ci.yml`) is unchanged.
- **Error propagation:** If a maintainer rejects an environment approval, the publish step is skipped cleanly — the workflow reports success on the non-publish steps and skipped on the publish step. No dangling state.
- **State lifecycle risks:** Moving `CHOCO_API_KEY` from repo secrets to environment secrets is a one-way migration from the workflow's point of view. If the environment secret is created before the repo secret is deleted, there is a brief window where both exist; Actions will prefer the environment scope when the job declares it. Confirm the workflow sees the environment secret before deleting the repo-level one.
- **API surface parity:** None — the package's public API (the Chocolatey `sonos-controller` listing) is unchanged.
- **Integration coverage:** Unit 5's test scenarios exercise the environment gate end-to-end via a dry-run `workflow_dispatch` — this is the only way to prove the gate is wired correctly, because the approval flow cannot be mocked.
- **Unchanged invariants:** The package version, URL, checksum, install script, nuspec metadata, and `ci.yml` consistency checks are explicitly unchanged by this plan. The auto-update flow (fetch installer → compute hash → update nuspec → commit/PR) is preserved bit-for-bit.

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| Misconfigured environment gate silently bypasses approval | Unit 5's dry-run test scenarios exercise both `publish: true` (expect prompt) and `publish: false` (expect no prompt) before flipping the repo public. |
| Secret audit misses a literal key because it was scrubbed by rebase but remains in a dangling object | `git log --all -p` covers refs; a fuller `git fsck --unreachable` + object scan is possible but overkill for a repo this small. Document the audit command in the PR so a future maintainer can re-run it. |
| Trademark disclaimer wording is still legally insufficient | Use the standard "unofficial / not affiliated / trademark of" phrasing that's common across community Chocolatey packages (e.g., how other vendor-software community packages phrase it). This is the accepted community convention, not a novel claim. |
| Maintainer becomes a single point of failure on environment approvals | Accepted risk for a single-maintainer project. If the project grows, promote a second maintainer and add them to CODEOWNERS + environment reviewers. Documented in "Deferred to Separate Tasks". |
| Repo is flipped public before Unit 5 settings are applied | Unit 5 sequences the visibility flip as the *final* step (5f), after all gates are in place. |

## Documentation / Operational Notes

- The PR description for this work should include the secret-audit result, the list of repo settings changed in Unit 5, and a screenshot or checklist confirming the environment gate fires on a `publish: true` dry run.
- After going public, the next maintenance action is unrelated to this plan: consider a Dependabot config and pinning third-party actions (`peter-evans/create-pull-request@v6`, `actions/checkout@v4`) by SHA. Out of scope here.

## Sources & References

- Related file: `.github/workflows/update-and-publish.yml`
- Related file: `README.md`
- Related file: `LICENSE`
- Related file: `AGENTS.md`
- GitHub Docs: "Using environments for deployment" (environment-scoped secrets and required reviewers)
- GitHub Docs: "Security hardening for GitHub Actions" (fork PR secret policy, CODEOWNERS-gated workflow edits)
