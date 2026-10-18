function Assert-ExportIdentity {
    param([string]$Directory, [string]$Commit, [string]$Version)
    $identityPath = Join-Path $Directory 'BUILD.json'
    $executable = Join-Path $Directory 'PandemicHorizon.exe'
    if (-not (Test-Path -LiteralPath $identityPath)) { throw 'Missing build identity. Export from the committed source first.' }
    $identity = Get-Content -LiteralPath $identityPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($identity.schema -ne 1 -or $identity.commit -cne $Commit -or $identity.version -cne $Version) { throw 'Stale export: source commit/version differs from the build. Re-export before packaging.' }
    if (-not (Test-Path -LiteralPath $executable) -or (Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash -cne $identity.executableSha256) { throw 'Export executable differs from its build identity.' }
    return $identity
}
