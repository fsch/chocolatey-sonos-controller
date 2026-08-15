Sonos Controller S2 — Chocolatey Package
========================================

[![Chocolatey Version](https://img.shields.io/chocolatey/v/sonos-controller?label=chocolatey&color=brightgreen)](https://community.chocolatey.org/packages/sonos-controller)
[![Chocolatey Downloads](https://img.shields.io/chocolatey/dt/sonos-controller?label=downloads)](https://community.chocolatey.org/packages/sonos-controller)
[![CI](https://github.com/fsch/chocolatey-sonos-controller/actions/workflows/ci.yml/badge.svg)](https://github.com/fsch/chocolatey-sonos-controller/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/github/license/fsch/chocolatey-sonos-controller)](LICENSE)

> **Unofficial community Chocolatey package.** This project is not affiliated with, endorsed by, or sponsored by Sonos, Inc. "Sonos" and the Sonos logo are trademarks of Sonos, Inc. This repository packages the **official** Sonos Controller S2 installer by downloading it from Sonos's own public URL (`https://update-software.sonos.com/software/<id>/Sonos_<version>.exe`); it does not redistribute or modify the installer binary. For issues with the Sonos Controller software itself, contact Sonos support. For issues with this Chocolatey package, see [SECURITY.md](SECURITY.md) or open an issue.

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
- `url`: the direct, version-pinned installer URL, e.g. `https://update-software.sonos.com/software/rT0797IawE/Sonos_90.0-77070.exe`. See “Getting the download URL” below — the old `https://www.sonos.com/redir/controller_software_pc2` shortlink no longer works for scripted clients and the workflow rejects it.
- `version` (optional): if omitted, the workflow derives it from the installer filename (`Sonos_90.0-77070.exe` → `90.0.77070`), falling back to the EXE ProductVersion and then FileVersion. It refuses to publish a version lower than the one already packaged.
- `commit_push`: commit updated files to `main`.
- `publish`: build `.nupkg` and push to Chocolatey (needs `CHOCO_API_KEY` secret).

Getting the download URL
------------------------
`https://www.sonos.com/redir/controller_software_pc2` is fronted by Akamai bot management and answers every non-browser client — `curl`, `Invoke-WebRequest`, and Chocolatey's own downloader — with **HTTP 403**. A package pointing at it cannot install, so the URL must be the direct one:

1. Open <https://support.sonos.com/en-us/downloads> in a browser and start the Windows download.
2. Copy the resolved URL from the browser's download list, or read it off the saved file:

```powershell
Get-Content "$env:USERPROFILE\Downloads\Sonos_90.0-77070.exe" -Stream Zone.Identifier
# HostUrl=https://update-software.sonos.com/software/rT0797IawE/Sonos_90.0-77070.exe
```

The path segment (`rT0797IawE` above) changes with each release, so this step is manual per update.

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
