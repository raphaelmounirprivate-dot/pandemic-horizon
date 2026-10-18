$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'build-identity.ps1')
$fixture = Join-Path (Split-Path $PSScriptRoot -Parent) ('build/qa/identity-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $fixture | Out-Null
$exe = Join-Path $fixture 'PandemicHorizon.exe'
[IO.File]::WriteAllBytes($exe,[byte[]]@(1,2,3,4))
$commit = '1111111111111111111111111111111111111111'
@{schema=1;commit=$commit;version='0.21.0';executableSha256=(Get-FileHash $exe).Hash} | ConvertTo-Json | Set-Content (Join-Path $fixture 'BUILD.json') -Encoding UTF8
$null = Assert-ExportIdentity $fixture $commit '0.21.0'
$checks = 1
foreach ($case in @('stale-commit','stale-version','changed-exe','missing-manifest')) {
    $expectedCommit = $commit
    $expectedVersion = '0.21.0'
    switch ($case) {
        'stale-commit' { $expectedCommit = '2222222222222222222222222222222222222222' }
        'stale-version' { $expectedVersion = '0.22.0' }
        'changed-exe' { [IO.File]::WriteAllBytes($exe,[byte[]]@(9,9)) }
        'missing-manifest' { Remove-Item -LiteralPath (Join-Path $fixture 'BUILD.json') }
    }
    $rejected = $false
    try { $null = Assert-ExportIdentity $fixture $expectedCommit $expectedVersion } catch { $rejected = $true }
    if (-not $rejected) { throw "Identity test failed: $case" }
    $checks++
}
Write-Output "BUILD_IDENTITY: $checks checks passed; stale commit/version, altered binary and missing identity rejected."
