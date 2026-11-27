param([Parameter(Mandatory=$true)][string]$Zip)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$zipPath = (Resolve-Path -LiteralPath $Zip).Path
$names = @(
 'resort_balcon_atardecer','resort_sala_atardecer','resort_sala_dia',
 'resort_habitacion_1','resort_habitacion_2','resort_terraza','resort_cocina',
 'resort_piscinas','resort_vista_mar','resort_habitacion_atardecer',
 'tour_bahia_concha','tour_velero_concha','tour_katamaran','tour_barranquilla'
)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
$stage = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $stage | Out-Null
try {
 foreach ($name in $names) {
   $entryName = "assets/images/velero/$name.webp"
   $matches = @($archive.Entries | Where-Object { $_.FullName -ceq $entryName })
   if ($matches.Count -ne 1 -or $matches[0].Length -lt 12 -or $matches[0].Length -gt 2097152) {
     throw "Recurso ausente, duplicado o invalido: $entryName"
   }
   $file = Join-Path $stage "$name.webp"
   [System.IO.Compression.ZipFileExtensions]::ExtractToFile($matches[0], $file, $false)
   $bytes = [System.IO.File]::ReadAllBytes($file)
   if ([System.Text.Encoding]::ASCII.GetString($bytes,0,4) -ne 'RIFF' -or
       [System.Text.Encoding]::ASCII.GetString($bytes,8,4) -ne 'WEBP') {
     throw "Formato de imagen invalido: $name"
   }
 }
 $dest = Join-Path $root 'assets\images\velero'
 New-Item -ItemType Directory -Path $dest -Force | Out-Null
 foreach ($name in $names) {
   Copy-Item -LiteralPath (Join-Path $stage "$name.webp") -Destination (Join-Path $dest "$name.webp") -Force
 }
 Write-Host "PASS: $($names.Count) recursos Resort Luxury instalados."
} finally {
 $archive.Dispose()
 Remove-Item -LiteralPath $stage -Recurse -Force
}
