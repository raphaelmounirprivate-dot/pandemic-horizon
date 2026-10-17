$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$gitArgs = @('-c', "safe.directory=$($projectRoot.Replace('\','/'))", '-C', $projectRoot)
$status = & git @gitArgs status --porcelain
if ($LASTEXITCODE -ne 0 -or $status) { throw 'Commit the reviewed step before creating its checkpoint.' }
$sha = (& git @gitArgs rev-parse HEAD).Trim()
$version = [regex]::Match((Get-Content (Join-Path $projectRoot 'project.godot') -Raw), 'config/version="([0-9.]+)"').Groups[1].Value
if (-not $version) { throw 'Missing project version.' }
$checkpointDirectory = Join-Path $projectRoot ('build/checkpoints/' + $version + '-' + $sha.Substring(0,7))
$manifestPath = Join-Path $checkpointDirectory 'manifest.json'
if (Test-Path -LiteralPath $manifestPath) { Write-Output "Checkpoint already exists: $checkpointDirectory"; exit 0 }
New-Item -ItemType Directory -Force $checkpointDirectory | Out-Null
$bundle = Join-Path $checkpointDirectory 'repository.bundle'
& git @gitArgs bundle create $bundle HEAD
if ($LASTEXITCODE -ne 0) { throw 'Git bundle failed.' }
& git @gitArgs bundle verify $bundle
if ($LASTEXITCODE -ne 0) { throw 'Git bundle verification failed.' }
$archive = Join-Path $checkpointDirectory 'sources.zip'
& git @gitArgs archive --format=zip "--output=$archive" HEAD
if ($LASTEXITCODE -ne 0) { throw 'Source archive failed.' }
$exe = Join-Path $projectRoot "build/windows-$version/PandemicHorizon.exe"
$manifest = [ordered]@{ version=$version; commit=$sha; bundleSha256=(Get-FileHash $bundle).Hash; sourcesSha256=(Get-FileHash $archive).Hash; executable=$null; executableSha256=$null }
if (Test-Path -LiteralPath $exe) { $manifest.executable=$exe; $manifest.executableSha256=(Get-FileHash $exe).Hash }
$manifest | ConvertTo-Json | Set-Content -LiteralPath $manifestPath -Encoding UTF8
Write-Output "Verified checkpoint: $checkpointDirectory"
