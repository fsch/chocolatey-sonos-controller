Security Policy
===============

Scope
-----

This policy covers the **packaging code** in this repository — the Chocolatey
nuspec, the `ChocolateyInstall.ps1` install script, and the GitHub Actions
workflows that update and publish the package.

It does **not** cover the Sonos Controller S2 application itself. This project
is an unofficial community Chocolatey package; it downloads the official Sonos
installer from Sonos's own public URL and does not modify the binary. If you
believe you have found a vulnerability in the Sonos Controller software, please
report it to Sonos directly through their official support channels.

Reporting a Vulnerability
-------------------------

**Preferred channel: GitHub private vulnerability reporting.**

Use the "Report a vulnerability" button on this repository's Security tab
(GitHub → Security → Advisories → Report a vulnerability). This creates a
private advisory visible only to the maintainers.

Examples of issues that belong here:

- A change to the install script that would execute unintended code on end-user
  machines.
- A way for an unauthorized contributor to cause `CHOCO_API_KEY` to be used by
  a workflow run, or to influence what gets published to the Chocolatey feed.
- Any way to push a package to the Chocolatey feed without maintainer approval.
- Exposure of secrets in logs, artifacts, or git history.

Lower-severity concerns (dependency hygiene, hardening suggestions) can be
opened as a regular GitHub issue.

What to Expect
--------------

This is a single-maintainer, best-effort project. You should expect:

- Acknowledgement within about a week of a private report.
- A fix or mitigation discussed in the private advisory before any public
  disclosure.
- Credit in the advisory once a fix is shipped, unless you prefer otherwise.

Out of Scope
------------

- Vulnerabilities in the Sonos Controller S2 application — report to Sonos.
- Vulnerabilities in Chocolatey itself — report to the
  [Chocolatey project](https://github.com/chocolatey).
- Vulnerabilities in third-party GitHub Actions used by this repo's workflows —
  report to the action's own maintainers; mention here if the action is being
  consumed in an unsafe way.
