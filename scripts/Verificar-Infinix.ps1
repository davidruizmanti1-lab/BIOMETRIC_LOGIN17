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
$devicesJson = & flutter devices --machine
if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar los dispositivos.' }
$devices = @($devicesJson | Out-String | ConvertFrom-Json)
$android = @($devices | Where-Object { $_.targetPlatform -like 'android-*' -and $_.isSupported -eq $true })
if ($android.Count -eq 0) { throw 'No se detecta Android. Desbloquea el Infinix, acepta depuracion USB y revisa el cable.' }
$android | Select-Object name,id,targetPlatform | Format-Table
if (-not $DeviceId -and $android.Count -eq 1) { $DeviceId = $android[0].id }
if (-not $DeviceId) { $DeviceId = Read-Host 'Pega el identificador Android que aparece en flutter devices' }
if (-not ($android | Where-Object { $_.id -eq $DeviceId })) { throw 'Selecciona un identificador Android detectado.' }
Invoke-Flutter @('run','-d',$DeviceId,'--dart-define-from-file=secureapp.config.json')
