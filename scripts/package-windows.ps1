$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$gitArgs = @('-c', "safe.directory=$($projectRoot.Replace('\','/'))", '-C', $projectRoot)
$status = & git @gitArgs status --porcelain
if ($LASTEXITCODE -ne 0 -or $status) { throw 'Commit the tested candidate before packaging.' }
$sha = (& git @gitArgs rev-parse HEAD).Trim()
$version = [regex]::Match((Get-Content (Join-Path $projectRoot 'project.godot') -Raw), 'config/version="([0-9.]+)"').Groups[1].Value
if (-not $version) { throw 'Missing version.' }
$exportDirectory = Join-Path $projectRoot "build/windows-$version"
$exe = Join-Path $exportDirectory 'PandemicHorizon.exe'
if (-not (Test-Path -LiteralPath $exe)) { throw 'Export the candidate first.' }
# Verify the exact executable that will be archived, including its packed resources.
& (Join-Path $PSScriptRoot 'verify-export.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Executable verification failed.' }
Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/GUIDE-JOUEUR.md') -Destination $exportDirectory -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/TESTS-JOUEURS.md') -Destination $exportDirectory -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/NOTES-VERSION-0.19.md') -Destination $exportDirectory -Force
$licenceDirectory = Join-Path $exportDirectory 'licences'
New-Item -ItemType Directory -Force $licenceDirectory | Out-Null
foreach ($licence in (Get-ChildItem -LiteralPath (Join-Path $projectRoot 'docs/licences') -File)) {
    $destination = Join-Path $licenceDirectory $licence.Name
    # Preserve identical export files; Copy-Item -Force can fail when replacing
    # inherited Windows permissions even though their content is already correct.
    if ((Test-Path -LiteralPath $destination) -and (Get-FileHash -LiteralPath $destination).Hash -eq (Get-FileHash -LiteralPath $licence.FullName).Hash) { continue }
    Copy-Item -LiteralPath $licence.FullName -Destination $destination -Force
    if ((Get-FileHash -LiteralPath $destination).Hash -ne (Get-FileHash -LiteralPath $licence.FullName).Hash) { throw "Licence copy mismatch: $($licence.Name)" }
}
$exeHash = (Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash
$manifest = [ordered]@{version=$version;commit=$sha;status='candidate; human tests pending';executableSha256=$exeHash}
$manifest | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $exportDirectory 'VERSION.json') -Encoding UTF8
$releaseDirectory = Join-Path $projectRoot 'build/releases'
New-Item -ItemType Directory -Force $releaseDirectory | Out-Null
$archive = Join-Path $releaseDirectory "PandemicHorizon-$version-Windows-x64-$($sha.Substring(0,7)).zip"
if (Test-Path -LiteralPath $archive) { throw "Archive exists; preserved: $archive" }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($exportDirectory,$archive,[IO.Compression.CompressionLevel]::Optimal,$false)
$zip = [IO.Compression.ZipFile]::OpenRead($archive)
try {
    foreach ($required in @('PandemicHorizon.exe','GUIDE-JOUEUR.md','TESTS-JOUEURS.md','NOTES-VERSION-0.19.md','VERSION.json','licences/Godot-LICENSE.txt','licences/Godot-COPYRIGHT.txt','licences/Natural-Earth.txt')) {
        if (-not ($zip.Entries | Where-Object { $_.FullName.Replace('\','/') -eq $required })) { throw "Missing archive entry: $required" }
    }
    $entry = $zip.Entries | Where-Object { $_.FullName -eq 'PandemicHorizon.exe' }
    $stream = $entry.Open()
    $hasher = [Security.Cryptography.SHA256]::Create()
    try { $insideHash = [BitConverter]::ToString($hasher.ComputeHash($stream)).Replace('-','') }
    finally { $stream.Dispose(); $hasher.Dispose() }
    if ($insideHash -ne $exeHash) { throw 'Archived executable hash mismatch.' }
} finally { $zip.Dispose() }
$archiveHash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
"$archiveHash  $([IO.Path]::GetFileName($archive))" | Set-Content -LiteralPath ($archive + '.sha256') -Encoding ASCII
Write-Output "Verified Windows candidate: $archive"
Write-Output "SHA256: $archiveHash"
