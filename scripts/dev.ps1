param(
    [ValidateSet('Import', 'Test', 'Play', 'Export', 'Capture', 'Balance')]
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
    'Test' { Invoke-Godot ($baseArgs + @('--script', 'res://tests/run_tests.gd')) }
    'Balance' { Invoke-Godot ($baseArgs + @('--script', 'res://scripts/balance.gd')) }
    'Play' { & $engine --path $projectRoot }
    'Export' {
        $version = [regex]::Match((Get-Content -LiteralPath (Join-Path $projectRoot 'project.godot') -Raw), 'config/version="([0-9]+\.[0-9]+\.[0-9]+)"').Groups[1].Value
        if (-not $version) { throw 'Project version missing' }
        $exportDirectory = Join-Path $projectRoot "build/windows-$version"
        New-Item -ItemType Directory -Force $exportDirectory | Out-Null
        Invoke-Godot ($baseArgs + @('--export-release', 'Windows Desktop', (Join-Path $exportDirectory 'PandemicHorizon.exe')))
        Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/GUIDE-JOUEUR.md') -Destination (Join-Path $exportDirectory 'GUIDE-JOUEUR.md')
        Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/licences') -Destination $exportDirectory -Recurse -Force
        Write-Output "Export: $exportDirectory"
    }
    'Capture' {
        Invoke-Godot @('--path', $projectRoot, '--script', 'res://tests/capture.gd')
    }
}
