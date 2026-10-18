$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$env:APPDATA = Join-Path $projectRoot '.tools/user/roaming'
$env:LOCALAPPDATA = Join-Path $projectRoot '.tools/user/local'
$version = [regex]::Match((Get-Content -LiteralPath (Join-Path $projectRoot 'project.godot') -Raw), 'config/version="([0-9]+\.[0-9]+\.[0-9]+)"').Groups[1].Value
if (-not $version) { throw 'Project version missing' }
$exportExe = Join-Path $projectRoot "build/windows-$version/PandemicHorizon.exe"
$testFolder = Join-Path $projectRoot ("build/Essai Windows $version " + [char]0xe9 + 't' + [char]0xe9)
$qaFolder = Join-Path $projectRoot 'build/qa'
New-Item -ItemType Directory -Force $testFolder, $qaFolder, $env:APPDATA, $env:LOCALAPPDATA | Out-Null
Copy-Item -LiteralPath $exportExe -Destination $testFolder -Force
$exe = Join-Path $testFolder 'PandemicHorizon.exe'
function Check-Run([string]$Name, [string[]]$GameArgs) {
    $log = Join-Path $qaFolder "$Name.log"
    $process = Start-Process -FilePath $exe -WindowStyle Hidden -WorkingDirectory $testFolder -ArgumentList (@('--log-file', ('"' + $log + '"')) + $GameArgs) -PassThru
    if (-not $process.WaitForExit(30000)) {
        $process.Kill()
        throw "Export test timeout: $Name"
    }
    if ($process.ExitCode -ne 0) { throw "Export test failed: $Name ($($process.ExitCode))" }
    $output = Get-Content -LiteralPath $log -Raw
    Write-Output $output
    if ($output -match 'SCRIPT ERROR:|ERROR:') { throw "Runtime error: $Name" }
    if ($Name -eq 'export-smoke' -and $output -notmatch 'RUNTIME_SMOKE_OK') { throw 'Missing success marker' }
}
Check-Run 'export-smoke' @('--headless', '--', '--smoke-test')
# Hosted CI runners have no physical audio endpoint; select Dummy explicitly there.
$renderArgs = if ($env:CI -eq 'true') { @('--audio-driver', 'Dummy', '--quit-after', '10') } else { @('--quit-after', '10') }
Check-Run 'export-render' $renderArgs
Get-FileHash -LiteralPath $exportExe -Algorithm SHA256
