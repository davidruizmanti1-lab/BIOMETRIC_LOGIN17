$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$url = 'https://xsbrwkxptxqnfdzvygwl.supabase.co'
$key = (Read-Host 'Pega la clave publicable sb_publishable_ del proyecto velero2hcol').Trim()
if ($key -notmatch '^sb_publishable_[A-Za-z0-9_-]+$') {
  throw 'Solo se admite la clave publicable de Supabase. No uses claves secretas.'
}
try {
  $settings = Invoke-RestMethod -Method Get -Uri ($url + '/auth/v1/settings') -Headers @{apikey=$key} -TimeoutSec 20
} catch {
  $status = 'sin respuesta HTTP'
  if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode }
  throw "No se pudo verificar Supabase Auth ($status). No se cambio la configuracion."
}
if ($settings.external.email -eq $false) {
  throw 'El proveedor de correo esta deshabilitado. No se cambio la configuracion.'
}
$path = Join-Path (Get-Location) 'secureapp.config.json'
$config = [ordered]@{}
if (Test-Path $path) {
  $old = Get-Content $path -Raw | ConvertFrom-Json
  foreach ($property in $old.PSObject.Properties) {
    $config[$property.Name] = $property.Value
  }
  $backup = "$path.$(Get-Date -Format 'yyyyMMdd-HHmmssfff').bak"
  Copy-Item -LiteralPath $path -Destination $backup -ErrorAction Stop
}
$config['SUPABASE_URL'] = $url
$config['SUPABASE_PUBLISHABLE_KEY'] = $key
if (-not $config.Contains('VELERO2H_BRISA_AI')) {
  $config['VELERO2H_BRISA_AI'] = 'true'
}
$json = $config | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($path, $json, (New-Object System.Text.UTF8Encoding($false)))
Write-Host 'PASS: Configuracion de Velero2H guardada y Supabase Auth verificado.'
Write-Host 'Ejecuta flutter run con --dart-define-from-file=secureapp.config.json.'
