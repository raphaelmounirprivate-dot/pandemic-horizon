$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$env:APPDATA = Join-Path $projectRoot '.tools/user/roaming'
$env:LOCALAPPDATA = Join-Path $projectRoot '.tools/user/local'
$testFolder = Join-Path $projectRoot ("build/Essai Windows " + [char]0xe9 + 't' + [char]0xe9)
$qaFolder = Join-Path $projectRoot 'build/qa'
New-Item -ItemType Directory -Force $testFolder, $qaFolder, $env:APPDATA, $env:LOCALAPPDATA | Out-Null
Copy-Item -LiteralPath (Join-Path $projectRoot 'build/windows/PandemicHorizon.exe') -Destination $testFolder -Force
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
Check-Run 'export-render' @('--quit-after', '10')
Get-FileHash -LiteralPath (Join-Path $projectRoot 'build/windows/PandemicHorizon.exe') -Algorithm SHA256
