Sonos Controller S2 — Chocolatey Package
========================================

This repository contains the Chocolatey package definition for the Sonos Controller S2 desktop app. It includes the nuspec metadata, the PowerShell install script, and GitHub Actions to manually update, pack, and optionally publish the package.

Getting Started
---------------
- Requirements (local): Windows with Chocolatey (`choco`), PowerShell.
- Key paths: `chocolatey/sonos-controller.nuspec`, `chocolatey/ChocolateyInstall.ps1`.

Manual Update & Publish (GitHub Actions)
----------------------------------------
Use the workflow “Update and Publish Chocolatey Package”:
- `url`: default is the official Sonos download URL.
- `version` (optional): if omitted, the workflow extracts the file version from the downloaded EXE.
- `commit_push`: commit updated files to `main`.
- `publish`: build `.nupkg` and push to Chocolatey (needs `CHOCO_API_KEY` secret).

Notes
-----
- The workflow requests `contents: write` permission. If it cannot push to `main` (e.g., branch protections), it automatically opens a PR with the changes.

Local Build & Test
------------------
1. Download + hash (optionally): `bash scripts/download_and_hash.sh` (Linux/macOS).
2. Update version in `sonos-controller.nuspec`; update URL and checksum only in `ChocolateyInstall.ps1`.
3. Pack: `choco pack chocolatey/sonos-controller.nuspec` → `out/*.nupkg`.
4. Install test: `choco install sonos-controller --source out -y`.

Contributing
------------
See `AGENTS.md` for contribution guidelines. Please avoid committing binaries or secrets. Open an issue for major changes.

License
-------
MIT. See `LICENSE`.
