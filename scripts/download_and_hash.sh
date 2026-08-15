#!/bin/bash
set -euo pipefail

# Download the Sonos Controller installer and print the URL + SHA256 to paste
# into chocolatey/ChocolateyInstall.ps1.
#
# Pass the direct, version-pinned installer URL, e.g.
#   bash scripts/download_and_hash.sh https://update-software.sonos.com/software/rT0797IawE/Sonos_90.0-77070.exe
#
# https://www.sonos.com/redir/controller_software_pc2 does NOT work here: it is
# behind Akamai bot management and returns HTTP 403 to every non-browser client.
# See README ("Getting the download URL") for how to resolve the direct URL.

URL="${1:-}"
if [ -z "$URL" ]; then
  echo "usage: $0 <direct-installer-url>" >&2
  exit 2
fi

case "$URL" in
  https://www.sonos.com/redir/*|https://sonos.com/redir/*)
    echo "error: the sonos.com/redir shortlink is bot-protected (403). Use the direct update-software.sonos.com URL." >&2
    exit 2;;
esac

mkdir -p downloads

# --fail so an HTTP error page is never mistaken for an installer.
curl --fail --location --output downloads/sonos-controller.exe "$URL"

HASH=$(sha256sum downloads/sonos-controller.exe | cut -d ' ' -f 1)

{
  echo "URL=$URL"
  echo "HASH=$HASH"
} | tee downloads/sonos-controller-info.txt
