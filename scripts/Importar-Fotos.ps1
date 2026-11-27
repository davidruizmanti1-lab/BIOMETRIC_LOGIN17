param([Parameter(Mandatory=$true)][string]$Zip)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path (Join-Path $root 'pubspec.yaml'))) { throw 'Proyecto Flutter no encontrado.' }
$dest = Join-Path $root 'assets\images\velero'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $Zip).Path)
try {
  $allowed = '^(habitacion_0[1-3]|dos_camas_0[1-7]|bano_0[1-3]|cocina_0[1-3])\.webp$'
  $entries = @($archive.Entries | Where-Object { $_.FullName -match '/overlay/assets/images/velero/' -and $_.Name -match $allowed })
  if ($entries.Count -ne 16 -or @($entries.Name | Sort-Object -Unique).Count -ne 16) { throw 'El ZIP no contiene las 16 fotos esperadas.' }
  foreach ($entry in $entries) {
    if ($entry.Length -lt 12 -or $entry.Length -gt 3000000) { throw 'Imagen fuera de rango.' }
    $stream = $entry.Open()
    try {
      $header = New-Object byte[] 12
      if ($stream.Read($header,0,12) -ne 12 -or [Text.Encoding]::ASCII.GetString($header,0,4) -ne 'RIFF' -or [Text.Encoding]::ASCII.GetString($header,8,4) -ne 'WEBP') { throw 'Formato WebP invalido.' }
    } finally { $stream.Dispose() }
  }
  foreach ($entry in $entries) {
    [IO.Compression.ZipFileExtensions]::ExtractToFile($entry,(Join-Path $dest $entry.Name),$true)
  }
  Write-Host '16 fotos integradas. Deten flutter run y recompila.'
} finally { $archive.Dispose() }
