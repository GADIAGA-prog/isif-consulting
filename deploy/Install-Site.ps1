param(
  [Parameter(Mandatory=$true)][string]$Archive,
  [ValidatePattern('^[a-zA-Z0-9_-]+$')][string]$Release = (Get-Date -Format 'yyyyMMdd-HHmmss')
)
$ErrorActionPreference = 'Stop'
Import-Module ServerManager
$basePath = 'C:\Sites\ISIF'
$releasePath = Join-Path $basePath ('releases\' + $Release)
if (Test-Path -LiteralPath $releasePath) { throw 'La version existe deja. Utiliser un nouvel identifiant.' }
if (!(Test-Path -LiteralPath $Archive -PathType Leaf)) { throw 'Archive absente.' }
New-Item -ItemType Directory -Force -Path $releasePath | Out-Null
Expand-Archive -LiteralPath $Archive -DestinationPath $releasePath
if (!(Test-Path -LiteralPath (Join-Path $releasePath 'index.html'))) { throw 'index.html absent.' }
$freshIis = !(Get-WindowsFeature Web-Server).Installed
if ($freshIis) {
  if (Get-NetTCPConnection -State Listen -LocalPort 80 -ErrorAction SilentlyContinue) { throw 'Port 80 deja occupe.' }
  $install = Install-WindowsFeature Web-Server,Web-Scripting-Tools -IncludeManagementTools
  if (!$install.Success -or $install.RestartNeeded -eq 'Yes') { throw 'Installation IIS incomplete ou redemarrage requis.' }
}
Import-Module WebAdministration
if ($freshIis -and (Test-Path 'IIS:\Sites\Default Web Site')) { Stop-Website -Name 'Default Web Site' }
$otherSites = Get-Website | Where-Object { $_.Name -ne 'ISIF-Consulting' -and $_.State -eq 'Started' }
foreach ($otherSite in $otherSites) {
  if ($otherSite.Bindings.Collection | Where-Object { $_.protocol -eq 'http' -and $_.bindingInformation -match ':80:' }) { throw 'Un autre site utilise le port 80. Configuration manuelle requise.' }
}
$backupName = 'ISIF-before-' + $Release
Backup-WebConfiguration -Name $backupName
if (!(Test-Path 'IIS:\AppPools\ISIF-Consulting')) { New-WebAppPool -Name 'ISIF-Consulting' | Out-Null }
Set-ItemProperty 'IIS:\AppPools\ISIF-Consulting' -Name managedRuntimeVersion -Value ''
& icacls.exe $releasePath /grant '*S-1-5-32-568:(OI)(CI)(RX)' /T | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Attribution des droits de lecture echouee.' }
$previousPath = $null
if (Test-Path 'IIS:\Sites\ISIF-Consulting') {
  $previousPath = (Get-Item 'IIS:\Sites\ISIF-Consulting').PhysicalPath
  Set-ItemProperty 'IIS:\Sites\ISIF-Consulting' -Name physicalPath -Value $releasePath
} else {
  New-Website -Name 'ISIF-Consulting' -PhysicalPath $releasePath -Port 80 -ApplicationPool 'ISIF-Consulting' | Out-Null
}
Start-Website -Name 'ISIF-Consulting'
if (!(Get-NetFirewallRule -Name 'ISIF-HTTP' -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule -Name 'ISIF-HTTP' -DisplayName 'ISIF Consulting HTTP' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80 | Out-Null
}
try {
  $response = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1/contact.html'
  if ($response.StatusCode -ne 200 -or $response.Content -notmatch 'project-form') { throw 'Verification du site echouee.' }
} catch {
  if ($previousPath) { Set-ItemProperty 'IIS:\Sites\ISIF-Consulting' -Name physicalPath -Value $previousPath }
  throw
}
[pscustomobject]@{ Site = 'ISIF-Consulting'; Path = $releasePath; PreviousPath = $previousPath; IisBackup = $backupName; Status = $response.StatusCode } | ConvertTo-Json
