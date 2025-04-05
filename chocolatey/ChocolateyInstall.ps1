#Sonos Controller
#2016-2021 foo.li systeme + software, felix schwenk

$packageName	= 'sonos-controller'
$packageSearch  = 'Sonos Controller'
$installerType	= 'exe'
$version 		= '16.0.0.401'
$url			= 'https://www.sonos.com/redir/controller_software_pc2'
$silentArgs		= '/s /v"/qn"'
$validExitCodes	= @(0,3010)
$checksum       = '03041f39d4f183e5c523e3d63997063afcfad5d4cc956f5f478a59e6c80b62a8'
$checksumType   = 'sha256'

$app = Get-ItemProperty -Path @('HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*') `
		-ErrorAction:SilentlyContinue | Where-Object { $_.DisplayName -like $packageSearch }

if ($app -and ([version]$app.DisplayVersion -ge [version]$version)) {
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
