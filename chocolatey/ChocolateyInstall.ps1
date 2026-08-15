#Sonos Controller
#2016-2021 foo.li systeme + software, felix schwenk

$packageName	= 'sonos-controller'
$packageSearch  = 'Sonos Controller'
$installerType	= 'exe'
$version 		= '90.0.77070'
# Use the version-pinned installer on update-software.sonos.com, NOT the
# https://www.sonos.com/redir/controller_software_pc2 shortlink. That host sits
# behind Akamai bot management and now answers every non-browser client -- curl,
# Invoke-WebRequest, and Chocolatey's downloader alike -- with HTTP 403, so the
# package could not fetch the installer at all. The redirect target is also a
# moving URL, which is incompatible with a pinned checksum anyway.
$url			= 'https://update-software.sonos.com/software/rT0797IawE/Sonos_90.0-77070.exe'
$silentArgs		= '/s /v"/qn"'
$validExitCodes	= @(0,3010)
$checksum       = '041d3a74d60f94d2b2c4f63909e765efd9648fc5407e970ef6441e66db8bd8ca'
$checksumType   = 'sha256'

$app = Get-ItemProperty -Path @('HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*') `
		-ErrorAction:SilentlyContinue | Where-Object { $_.DisplayName -like $packageSearch }

# Parse defensively: an uninstall key can carry a missing or non-numeric
# DisplayVersion, and a bare [version] cast on that throws and aborts the
# install before it starts. Anything unparseable simply means "unknown", which
# falls through to a normal install.
[version]$installedVersion = $null
if ($app) {
    [void][version]::TryParse((@($app)[0].DisplayVersion), [ref]$installedVersion)
}

if ($installedVersion -and ($installedVersion -ge [version]$version)) {
    Write-Output $(
    'Sonos Controller is already installed. ' +
    'No need to download and install again.'
    )
} else {
    Install-ChocolateyPackage $packageName $installerType $silentArgs $url `
		-checksum $checksum -checksumType $checksumType `
        -validExitCodes $validExitCodes 
	Write-Verbose 'removing desktop shortcut'
    Remove-Item -Path "${env:PUBLIC}\Desktop\Sonos.lnk" -ErrorAction SilentlyContinue
}
