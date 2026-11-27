param([string]$DeviceId, [switch]$SoloDiagnostico)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
function Invoke-Flutter([string[]]$Arguments) {
  & flutter @Arguments
  if ($LASTEXITCODE -ne 0) { throw "Flutter fallo: $($Arguments -join ' ')" }
}
if (-not (Test-Path 'secureapp.config.json')) { throw 'Falta secureapp.config.json. Conserva la configuracion original de Supabase.' }
$config = Get-Content 'secureapp.config.json' -Raw | ConvertFrom-Json
if ($config.SUPABASE_URL -notmatch '^https://[a-z0-9-]+\.supabase\.co/?$' -or $config.SUPABASE_PUBLISHABLE_KEY -notmatch '^sb_publishable_') { throw 'Configuracion de Supabase no valida. No uses claves secretas.' }
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { throw 'Flutter no esta disponible en PATH.' }
Write-Host 'Version del proyecto:'
Select-String -Path 'pubspec.yaml' -Pattern '^version:' | ForEach-Object { Write-Host $_.Line }
if ($config.SUPABASE_URL.TrimEnd('/') -ne 'https://xsbrwkxptxqnfdzvygwl.supabase.co') {
  Write-Warning 'La URL no coincide con el proyecto velero2hcol donde BRISA esta desplegada. Verifica el proyecto antes de iniciar sesion.'
}
if ([string]$config.VELERO2H_BRISA_AI -ne 'true') {
  Write-Warning 'BRISA en modo local. Activa VELERO2H_BRISA_AI en la configuracion si deseas probar Groq.'
}
Invoke-Flutter @('doctor','-v')
Invoke-Flutter @('pub','get')
Invoke-Flutter @('analyze','--no-fatal-infos')
Invoke-Flutter @('test')
Invoke-Flutter @('devices')
$devicesJson = & flutter devices --machine
if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar los dispositivos.' }
$devices = @($devicesJson | Out-String | ConvertFrom-Json)
$android = @($devices | Where-Object { $_.targetPlatform -like 'android-*' -and $_.isSupported -eq $true -and $_.emulator -ne $true })
if ($android.Count -eq 0) { throw 'No se detecta Android. Desbloquea el Infinix, acepta depuracion USB y revisa el cable.' }
$android | Select-Object name,id,targetPlatform | Format-Table
if ($SoloDiagnostico) { Write-Host 'Diagnostico finalizado; no se ha instalado la app.'; return }
if (-not $DeviceId -and $android.Count -eq 1) { $DeviceId = $android[0].id }
if (-not $DeviceId) { $DeviceId = Read-Host 'Pega el identificador Android que aparece en flutter devices' }
if (-not ($android | Where-Object { $_.id -eq $DeviceId })) { throw 'Selecciona un identificador Android detectado.' }
Invoke-Flutter @('run','-d',$DeviceId,'--dart-define-from-file=secureapp.config.json')
