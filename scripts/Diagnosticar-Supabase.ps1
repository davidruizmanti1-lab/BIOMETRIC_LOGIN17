$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$config = Get-Content 'secureapp.config.json' -Raw | ConvertFrom-Json
$url = [string]$config.SUPABASE_URL
$key = [string]$config.SUPABASE_PUBLISHABLE_KEY
if ($url.TrimEnd('/') -ne 'https://xsbrwkxptxqnfdzvygwl.supabase.co') {
  throw 'La URL no coincide con el proyecto velero2hcol.'
}
if ($key -notmatch '^sb_publishable_[A-Za-z0-9_-]+$') {
  throw 'Falta una clave publicable valida. No uses claves secretas.'
}
try {
  $settings = Invoke-RestMethod -Method Get -Uri ($url.TrimEnd('/') + '/auth/v1/settings') -Headers @{apikey=$key} -TimeoutSec 20
  Write-Host 'PASS: Supabase Auth responde con esta URL y clave publicable.'
  if ($null -ne $settings.external.email) {
    Write-Host "Proveedor correo habilitado: $($settings.external.email)"
  }
  Write-Host 'Esta prueba no verifica contrasena ni biometria.'
} catch {
  $status = 'sin respuesta HTTP'
  if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode }
  throw "Supabase Auth no pudo verificarse: $status. Revisa la clave publicable, el proyecto y la red."
}
