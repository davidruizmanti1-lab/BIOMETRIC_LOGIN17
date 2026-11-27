param([string]$DeviceId)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
function Invoke-Flutter([string[]]$Arguments) {
  & flutter @Arguments
  if ($LASTEXITCODE -ne 0) { throw "Flutter fallo: $($Arguments -join ' ')" }
}
if (-not (Test-Path 'secureapp.config.json')) { throw 'Falta secureapp.config.json. Conserva la configuracion original de Supabase.' }
$config = Get-Content 'secureapp.config.json' -Raw | ConvertFrom-Json
if ($config.SUPABASE_URL -notmatch '^https://[a-z0-9-]+\.supabase\.co/?$' -or $config.SUPABASE_PUBLISHABLE_KEY -notmatch '^sb_publishable_') { throw 'Configuracion de Supabase no valida. No uses claves secretas.' }
Invoke-Flutter @('doctor','-v')
Invoke-Flutter @('pub','get')
Invoke-Flutter @('analyze','--no-fatal-infos')
Invoke-Flutter @('test')
Invoke-Flutter @('devices')
if (-not $DeviceId) { $DeviceId = Read-Host 'Pega el identificador Android que aparece en flutter devices' }
if (-not $DeviceId) { throw 'No se ha seleccionado el Infinix.' }
Invoke-Flutter @('run','-d',$DeviceId,'--dart-define-from-file=secureapp.config.json')
