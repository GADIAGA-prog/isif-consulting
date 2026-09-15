param([Parameter(Mandatory=$true)][ValidatePattern('^[a-zA-Z0-9_.@-]+$')][string]$Server)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
Push-Location $projectRoot
try {
  node scripts/check.cjs
  if ($LASTEXITCODE -ne 0) { throw 'Verification locale echouee.' }
  $releaseId = 'release-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
  $zipPath = Join-Path ([System.IO.Path]::GetTempPath()) ($releaseId + '.zip')
  Compress-Archive -Path (Join-Path $projectRoot 'site\*') -DestinationPath $zipPath
  & scp $zipPath ($Server + ':' + $releaseId + '.zip')
  if ($LASTEXITCODE -ne 0) { throw 'Transfert du site echoue.' }
  & scp (Join-Path $PSScriptRoot 'Install-Site.ps1') ($Server + ':Install-Site.ps1')
  if ($LASTEXITCODE -ne 0) { throw 'Transfert du script echoue.' }
  & ssh $Server ('powershell -NoProfile -ExecutionPolicy Bypass -File Install-Site.ps1 -Archive ' + $releaseId + '.zip -Release ' + $releaseId)
  if ($LASTEXITCODE -ne 0) { throw 'Publication interrompue. Verifier le message du serveur.' }
  Remove-Item -LiteralPath $zipPath
} finally { Pop-Location }
