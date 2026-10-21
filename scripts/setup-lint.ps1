$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
# Same linter as CI (.github/workflows/test.yml): gdtoolkit 4.5.0. Everything stays in .tools/lint,
# no system Python. SHA-256 pinned at the first download from the official hosts (21 October 2026).
$pythonVersion = '3.12.10'
$pythonName = "python-$pythonVersion-embed-amd64.zip"
$pythonSha256 = '4ACBED6DD1C744B0376E3B1CF57CE906F9DC9E95E68824584C8099A63025A3C3'
$pipName = 'pip-24.3.1.pyz'
$pipSha256 = 'C59DF64B826D5BAA978829FD1E1B3EA2E748F73DCE7CCE58D09AA28A1C9323A7'
$gdtoolkit = 'gdtoolkit==4.5.0'
$root = Split-Path $PSScriptRoot -Parent
$destination = Join-Path $root '.tools/lint'
$python = Join-Path $destination 'python'
New-Item -ItemType Directory -Force $destination | Out-Null
Set-Content -LiteralPath (Join-Path $root '.tools/.gdignore') -Value ''
function Download([string]$Url, [string]$Name, [string]$Expected) {
    $target = Join-Path $destination $Name
    & curl.exe --silent --show-error --location --fail --retry 2 --output $target $Url
    if ($LASTEXITCODE -ne 0) { throw "Téléchargement impossible : $Name" }
    if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash -ne $Expected) { throw "Empreinte SHA256 incorrecte : $Name" }
    return $target
}
$zip = Download "https://www.python.org/ftp/python/$pythonVersion/$pythonName" $pythonName $pythonSha256
$pip = Download "https://bootstrap.pypa.io/pip/zipapp/$pipName" $pipName $pipSha256
if (Test-Path -LiteralPath $python) { Remove-Item -LiteralPath $python -Recurse -Force }
Expand-Archive -LiteralPath $zip -DestinationPath $python -Force
# The embeddable distribution ignores PYTHONPATH: declare the package folder in its ._pth file.
$pth = Get-ChildItem -LiteralPath $python -Filter 'python*._pth' | Select-Object -First 1
Add-Content -LiteralPath $pth.FullName -Value 'site-packages' -Encoding ASCII
& (Join-Path $python 'python.exe') $pip install --quiet --disable-pip-version-check --no-warn-script-location --target (Join-Path $python 'site-packages') $gdtoolkit
if ($LASTEXITCODE -ne 0) { throw "Installation impossible : $gdtoolkit" }
Write-Output "gdlint ($gdtoolkit) préparé dans $destination ; archives vérifiées par SHA-256."
