# Repository Guidelines

## Project Structure & Module Organization
- `chocolatey/`: Package sources. `sonos-controller.nuspec` (metadata, version, URL, checksum) and `ChocolateyInstall.ps1` (install script).
- `.github/workflows/`: CI to fetch the latest installer, compute SHA256, update nuspec, and push.
- `scripts/`: Local helpers (e.g., `download_and_hash.sh` to fetch and hash the installer). Do not commit downloaded artifacts.

## Build, Test, and Development Commands
- Fetch + hash locally (Linux/macOS): `bash scripts/download_and_hash.sh` → see `downloads/sonos-controller-info.txt`.
- Update fields: bump `<version>` in `chocolatey/sonos-controller.nuspec`; set `url` and `checksum` in `ChocolateyInstall.ps1`.
- Pack (Windows with Chocolatey): `choco pack chocolatey/sonos-controller.nuspec` → produces `.nupkg` in `out/`.
- Install locally for validation: `choco install sonos-controller --source out -y`.
- Publish (requires API key): `choco push out/<pkg>.nupkg --source https://push.chocolatey.org/`.

## Coding Style & Naming Conventions
- PowerShell: use consistent indentation (2 or 4 spaces), single quotes for literals, and descriptive variable names (e.g., `$version`, `$checksum`).
- Shell: POSIX-compatible commands; keep scripts idempotent.
- Keep version, URL, and checksum consistent across `.nuspec` and `ChocolateyInstall.ps1`.

## Testing Guidelines
- Verify checksum: Linux `sha256sum downloads/sonos-controller.exe`; Windows `Get-FileHash -Algorithm SHA256`.
- Install test: confirm silent install completes and Sonos shortcut removal succeeds.
- PRs should state how checksum and version were obtained and validated.

## Commit & Pull Request Guidelines
- Commits: imperative tense, concise scope (e.g., "chore: update to 16.0.0.401").
- PRs: include version, URL, checksum, validation steps, and link any related issues. Screenshots optional.
- CI: `CI` checks ensure nuspec/PS1 consistency and block binaries. Use `Update and Publish Chocolatey Package` (manual) to update/publish. If `version` is not provided, the workflow auto-detects the EXE FileVersion (prefers 16.x), falling back to ProductVersion.

## Security & Configuration Tips
- Never commit downloaded binaries or secrets. Configure Chocolatey API key locally: `choco apikey -k <KEY> -s https://push.chocolatey.org/`.
- Only use the official Sonos download URL in package metadata.
