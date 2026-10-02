param(
    [Parameter(Mandatory=$false)]
    [string]$Source = ".",
    [Parameter(Mandatory=$false)]
    [string]$Output = ""
)

$ErrorActionPreference = "Stop"

$sourcePath = (Resolve-Path $Source).Path
if (-not (Test-Path (Join-Path $sourcePath "expath-pkg.xml"))) {
    throw "The source directory must contain expath-pkg.xml at its root."
}

if ([string]::IsNullOrWhiteSpace($Output)) {
    $Output = Join-Path (Split-Path $sourcePath -Parent) "applicationTracking.xar"
} elseif (-not [System.IO.Path]::IsPathRooted($Output)) {
    $Output = Join-Path (Get-Location) $Output
}

$outputPath = [System.IO.Path]::GetFullPath($Output)
$tempZip = [System.IO.Path]::ChangeExtension($outputPath, ".zip")

if (Test-Path $tempZip) { Remove-Item $tempZip -Force }
if (Test-Path $outputPath) { Remove-Item $outputPath -Force }

$staging = Join-Path ([System.IO.Path]::GetTempPath()) ("applicationTracking-xar-" + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $staging | Out-Null

try {
    Get-ChildItem -LiteralPath $sourcePath -Force |
        Where-Object { $_.Name -notin @(".git") } |
        Copy-Item -Destination $staging -Recurse -Force

    Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $tempZip -Force

    Move-Item -LiteralPath $tempZip -Destination $outputPath -Force

    Write-Host "Created valid eXist-db XAR: $outputPath"
    Write-Host "Package root contains: expath-pkg.xml and repo.xml"
}
finally {
    if (Get-Location) { Pop-Location -ErrorAction SilentlyContinue }
    if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
    if (Test-Path $tempZip) { Remove-Item $tempZip -Force }
}
