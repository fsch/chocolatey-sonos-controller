Sonos Controller S2 — Chocolatey Package
========================================

[![Chocolatey Version](https://img.shields.io/chocolatey/v/sonos-controller?label=chocolatey&color=brightgreen)](https://community.chocolatey.org/packages/sonos-controller)
[![Chocolatey Downloads](https://img.shields.io/chocolatey/dt/sonos-controller?label=downloads)](https://community.chocolatey.org/packages/sonos-controller)
[![CI](https://github.com/fsch/chocolatey-sonos-controller/actions/workflows/ci.yml/badge.svg)](https://github.com/fsch/chocolatey-sonos-controller/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/github/license/fsch/chocolatey-sonos-controller)](LICENSE)

> **Unofficial community Chocolatey package.** This project is not affiliated with, endorsed by, or sponsored by Sonos, Inc. "Sonos" and the Sonos logo are trademarks of Sonos, Inc. This repository packages the **official** Sonos Controller S2 installer by downloading it from Sonos's own public URL (`https://www.sonos.com/redir/controller_software_pc2`); it does not redistribute or modify the installer binary. For issues with the Sonos Controller software itself, contact Sonos support. For issues with this Chocolatey package, see [SECURITY.md](SECURITY.md) or open an issue.

This repository contains the Chocolatey package definition for the Sonos Controller S2 desktop app. It includes the nuspec metadata, the PowerShell install script, and GitHub Actions to manually update, pack, and optionally publish the package.

Install
-------

```powershell
choco install sonos-controller
```

The package is published at https://community.chocolatey.org/packages/sonos-controller.

Getting Started
---------------
- Requirements (local): Windows with Chocolatey (`choco`), PowerShell.
- Key paths: `chocolatey/sonos-controller.nuspec`, `chocolatey/ChocolateyInstall.ps1`.

Manual Update & Publish (GitHub Actions)
----------------------------------------
Use the workflow “Update and Publish Chocolatey Package”:
- `url`: default is the official Sonos download URL.
- `version` (optional): if omitted, the workflow extracts the EXE FileVersion (preferred; e.g., 16.x). It falls back to ProductVersion if FileVersion is unavailable.
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

Reporting Issues & Security
---------------------------
- **Package bugs or questions:** open a GitHub issue.
- **Security vulnerabilities in this packaging code or the publish workflow:** see `SECURITY.md` for private reporting.
- **Vulnerabilities in the Sonos Controller software itself:** report to Sonos directly — this project does not modify the upstream installer.

License
-------
MIT. See `LICENSE`. The MIT license covers only this packaging repository (the nuspec, install script, and workflows). The Sonos Controller S2 installer is distributed by Sonos under its own license terms.
