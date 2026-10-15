param([switch]$WithExportTemplates)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$version = '4.7.2-stable'
$destination = Join-Path (Split-Path $PSScriptRoot -Parent) '.tools/godot'
New-Item -ItemType Directory -Force $destination | Out-Null
Set-Content -LiteralPath (Join-Path (Split-Path $destination -Parent) '.gdignore') -Value ''
$baseUrl = "https://github.com/godotengine/godot-builds/releases/download/$version"
function Download([string]$Name) {
    $target = Join-Path $destination $Name
    & curl.exe --silent --show-error --location --fail --retry 2 --output $target "$baseUrl/$Name"
    if ($LASTEXITCODE -ne 0) { throw "Téléchargement impossible : $Name" }
    return $target
}
$sumsPath = Download 'SHA512-SUMS.txt'
function Verify([string]$Path, [string]$Name) {
    $match = Select-String -LiteralPath $sumsPath -Pattern ([regex]::Escape($Name) + '$')
    if (-not $match -or @($match).Count -ne 1) { throw "Empreinte absente : $Name" }
    $expected = $match.Line.Split(' ')[0]
    if ((Get-FileHash -LiteralPath $Path -Algorithm SHA512).Hash -ne $expected) {
        throw "Empreinte SHA512 incorrecte : $Name"
    }
}
$editorName = "Godot_v${version}_win64.exe.zip"
$editorZip = Download $editorName
Verify $editorZip $editorName
Expand-Archive -LiteralPath $editorZip -DestinationPath $destination -Force
if ($WithExportTemplates) {
    $templatesName = "Godot_v${version}_export_templates.tpz"
    $templatesZip = Download $templatesName
    Verify $templatesZip $templatesName
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [IO.Compression.ZipFile]::OpenRead($templatesZip)
    try {
        foreach ($name in @('windows_debug_x86_64.exe', 'windows_release_x86_64.exe')) {
            $entry = $archive.GetEntry("templates/$name")
            if (-not $entry) { throw "Modèle absent : $name" }
            [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $destination $name), $true)
        }
    } finally { $archive.Dispose() }
}
Write-Output "Godot $version préparé dans $destination ; archives vérifiées avec les empreintes officielles."
