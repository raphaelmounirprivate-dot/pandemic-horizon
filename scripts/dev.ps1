param(
    [ValidateSet('Import', 'Test', 'Play', 'Export', 'Capture', 'CaptureObjectives', 'CaptureArctic', 'CaptureDecisions', 'Balance', 'BalanceObjectives', 'BalanceArctic', 'BalanceDecisions', 'BalanceParameters')]
    [string]$Action = 'Test',
    [string]$Godot = "$PSScriptRoot/../.tools/godot/Godot_v4.7.2-stable_win64_console.exe"
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$engine = (Resolve-Path -LiteralPath $Godot).Path
# Isolate development preferences and test writes from the user's real saves.
$env:APPDATA = Join-Path $projectRoot '.tools/user/roaming'
$env:LOCALAPPDATA = Join-Path $projectRoot '.tools/user/local'
New-Item -ItemType Directory -Force $env:APPDATA, $env:LOCALAPPDATA | Out-Null
Set-Content -LiteralPath (Join-Path $projectRoot '.tools/.gdignore') -Value ''
$buildDirectory = Join-Path $projectRoot 'build'
New-Item -ItemType Directory -Force $buildDirectory | Out-Null
Set-Content -LiteralPath (Join-Path $buildDirectory '.gdignore') -Value ''
function Invoke-Godot([string[]]$EngineArgs) {
    $output = & $engine @EngineArgs 2>&1
    $exit = $LASTEXITCODE
    $output | ForEach-Object { Write-Output $_ }
    if ($exit -ne 0 -or ($output -match 'SCRIPT ERROR:|ERROR:|FAIL:')) {
        throw "Godot a signalé un échec (code $exit)."
    }
}
$baseArgs = @('--headless', '--path', $projectRoot)
switch ($Action) {
    'Import' { Invoke-Godot ($baseArgs + @('--editor', '--import', '--quit')) }
    'Test' { Invoke-Godot ($baseArgs + @('--script', 'res://tests/run_tests.gd', '--', '--no-autosave')) }
    'Balance' { Invoke-Godot ($baseArgs + @('--script', 'res://scripts/analysis/balance.gd')) }
    'BalanceObjectives' { Invoke-Godot ($baseArgs + @('--script', 'res://scripts/analysis/balance_objectives.gd')) }
    'BalanceArctic' { Invoke-Godot ($baseArgs + @('--script', 'res://scripts/analysis/balance_arctic.gd')) }
    'BalanceDecisions' { Invoke-Godot ($baseArgs + @('--script', 'res://scripts/analysis/balance_decisions.gd')) }
    'BalanceParameters' { Invoke-Godot ($baseArgs + @('--script', 'res://scripts/analysis/balance_parameters.gd')) }
    'Play' { & $engine --path $projectRoot }
    'Export' {
        $gitArgs = @('-c', "safe.directory=$($projectRoot.Replace('\','/'))", '-C', $projectRoot)
        $dirty = & git @gitArgs status --porcelain
        if ($LASTEXITCODE -ne 0 -or $dirty) { throw 'Commit source changes before exporting a release candidate.' }
        $sourceCommit = (& git @gitArgs rev-parse HEAD).Trim()
        $version = [regex]::Match((Get-Content -LiteralPath (Join-Path $projectRoot 'project.godot') -Raw), 'config/version="([0-9]+\.[0-9]+\.[0-9]+)"').Groups[1].Value
        if (-not $version) { throw 'Project version missing' }
        $exportDirectory = Join-Path $projectRoot "build/windows-$version"
        New-Item -ItemType Directory -Force $exportDirectory | Out-Null
        Invoke-Godot ($baseArgs + @('--export-release', 'Windows Desktop', (Join-Path $exportDirectory 'PandemicHorizon.exe')))
        $identity = [ordered]@{schema=1;version=$version;commit=$sourceCommit;executableSha256=(Get-FileHash -LiteralPath (Join-Path $exportDirectory 'PandemicHorizon.exe')).Hash;engineSha256=(Get-FileHash -LiteralPath $engine).Hash}
        $identity | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $exportDirectory 'BUILD.json') -Encoding UTF8
        Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/GUIDE-JOUEUR.md') -Destination (Join-Path $exportDirectory 'GUIDE-JOUEUR.md')
        $licenceDirectory = Join-Path $exportDirectory 'licences'
        New-Item -ItemType Directory -Force $licenceDirectory | Out-Null
        foreach ($licence in (Get-ChildItem -LiteralPath (Join-Path $projectRoot 'docs/licences') -File)) {
            $target = Join-Path $licenceDirectory $licence.Name
            if ((Test-Path -LiteralPath $target) -and (Get-FileHash $target).Hash -eq (Get-FileHash $licence.FullName).Hash) { continue }
            Copy-Item -LiteralPath $licence.FullName -Destination $target -Force
        }
        Write-Output "Export: $exportDirectory"
    }
    'Capture' {
        Invoke-Godot @('--path', $projectRoot, '--script', 'res://tests/capture.gd', '--', '--no-autosave')
    }
    'CaptureObjectives' {
        Invoke-Godot @('--path', $projectRoot, '--script', 'res://tests/capture_objectives.gd', '--', '--no-autosave')
    }
    'CaptureArctic' {
        Invoke-Godot @('--path', $projectRoot, '--script', 'res://tests/capture_arctic.gd', '--', '--no-autosave')
    }
    'CaptureDecisions' {
        Invoke-Godot @('--path', $projectRoot, '--script', 'res://tests/capture_decisions.gd', '--', '--no-autosave')
    }
}
