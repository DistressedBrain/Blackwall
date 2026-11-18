<#
.SYNOPSIS
  Builds a Blackwall release package for GitHub Releases.

.DESCRIPTION
  1. Reads the version from src\Directory.Build.props and its notes from CHANGELOG.md.
  2. Publishes the app and the service (Release, framework-dependent, win-x64) into one folder.
  3. Zips it as publish\Blackwall-<version>-win-x64.zip and writes its SHA-256 next to it.
  4. Prints the command that creates the GitHub release with both files.

  Blackwall installs an update only if the zip matches that SHA-256, so upload both files unchanged.
  Bump <Version> and add a "## <version>" section to CHANGELOG.md before running this.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\make-release.ps1
#>
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

[xml]$props = Get-Content 'src\Directory.Build.props'
$version = ($props.Project.PropertyGroup | Where-Object { $_.Version } | Select-Object -First 1).Version
if ($version -notmatch '^\d+\.\d+\.\d+$') { throw "src\Directory.Build.props has no version like 0.3.0 (found '$version')." }

# Release notes: the CHANGELOG section for this version.
$lines = Get-Content 'CHANGELOG.md' -Encoding UTF8
$start = [array]::IndexOf($lines, "## $version")
if ($start -lt 0) { throw "CHANGELOG.md has no '## $version' section. Write what changed first." }
$end = $start + 1
while ($end -lt $lines.Count -and -not $lines[$end].StartsWith('## ')) { $end++ }
$notes = ($lines[($start + 1)..($end - 1)] -join "`n").Trim()

$name = "Blackwall-$version-win-x64"
$out = Join-Path $root 'publish'
# Built in its own folder, so an unpacked copy someone is running from publish\ is never in the way.
$stage = Join-Path $out "staging\$name"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory $stage -Force | Out-Null

Write-Host "Publishing Blackwall $version…"
foreach ($project in 'src\Blackwall.Client.Windows', 'src\Blackwall.Service') {
  dotnet publish $project -c Release -r win-x64 --self-contained false -o $stage -nologo -v q
  if ($LASTEXITCODE -ne 0) { throw "dotnet publish $project failed." }
}

foreach ($f in 'Blackwall.exe', 'Blackwall.dll', 'Blackwall.Service.exe', 'Blackwall.Service.dll', 'Blackwall.Core.dll', 'Blackwall.Windows.dll') {
  if (-not (Test-Path (Join-Path $stage $f))) { throw "The package is missing $f." }
}
Get-ChildItem $stage -Filter *.pdb | Remove-Item

# The licence and the third-party notices travel with every copy (the MIT licence of our dependencies requires it).
foreach ($f in 'LICENSE', 'THIRD-PARTY-NOTICES.txt') { if (-not (Test-Path $f)) { throw "$f is missing." } }
Copy-Item 'LICENSE' (Join-Path $stage 'LICENSE.txt')
Copy-Item 'THIRD-PARTY-NOTICES.txt' (Join-Path $stage 'THIRD-PARTY-NOTICES.txt')

# One-step install / uninstall (double-click; they run Blackwall.Service.exe setup).
foreach ($f in 'Install Blackwall.cmd', 'Uninstall Blackwall.cmd') {
  $from = Join-Path 'tools\package' $f
  if (-not (Test-Path $from)) { throw "tools\package\$f is missing." }
  Copy-Item $from (Join-Path $stage $f)
}

$zip = Join-Path $out "$name.zip"
if (Test-Path $zip) { Remove-Item $zip }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($stage, $zip, [IO.Compression.CompressionLevel]::Optimal, $false)

$sha = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLowerInvariant()
$shaFile = "$zip.sha256"
[IO.File]::WriteAllText($shaFile, "$sha  $name.zip`n")
$notesFile = Join-Path $out "release-notes-$version.md"
[IO.File]::WriteAllText($notesFile, $notes + "`n", [Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "Package:  $zip"
Write-Host "SHA-256:  $sha"
Write-Host "Notes:    $notesFile"
Write-Host ""
Write-Host "Create the release (tag v$version) with both files, e.g. with the GitHub CLI:"
Write-Host "  gh release create v$version `"$zip`" `"$shaFile`" --title `"Blackwall $version`" --notes-file `"$notesFile`""
Write-Host "Or on github.com: Releases → Draft a new release → tag v$version, attach both files, paste the notes, Publish."
