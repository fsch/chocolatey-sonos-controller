#!/bin/bash

# Create a directory to store the downloaded binary
mkdir -p downloads

# Download the latest Sonos Controller binary
curl -L -o downloads/sonos-controller.exe https://www.sonos.com/redir/controller_software_pc2

# Calculate the hash of the downloaded binary
HASH=$(sha256sum downloads/sonos-controller.exe | cut -d ' ' -f 1)

# Output the URL and hash to a file
echo "URL=https://www.sonos.com/redir/controller_software_pc2" > downloads/sonos-controller-info.txt
echo "HASH=$HASH" >> downloads/sonos-controller-info.txt
