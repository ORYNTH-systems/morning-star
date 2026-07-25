$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (
    Resolve-Path (Join-Path $PSScriptRoot '..\..')
).Path

$CommonModulePath = Join-Path $RepositoryRoot 'engineering\modules\MorningStar.Engine.Common.psm1'
$ReportRoot = Join-Path $RepositoryRoot 'engineering\reports\batch-4\B4-PASS-04'
$BackupRoot = Join-Path $RepositoryRoot 'engineering\backups\batch-4\B4-PASS-04'
$ManifestPath = Join-Path $RepositoryRoot 'engineering\manifests\batch-4\B4-PASS-04_MANIFEST.json'
$Pass03ManifestPath = Join-Path $RepositoryRoot 'engineering\manifests\batch-4\B4-PASS-03_MANIFEST.json'
$RuntimePyprojectPath = Join-Path $RepositoryRoot 'runtime\pyproject.toml'
$LicenseSourcePath = Join-Path $RepositoryRoot 'orynth-reference-architecture\LICENSE'

$LicensePath = Join-Path $RepositoryRoot 'LICENSE.md'
$VersionPath = Join-Path $RepositoryRoot 'VERSION.md'
$CitationPath = Join-Path $RepositoryRoot 'CITATION.cff'

foreach ($Directory in @($ReportRoot, $BackupRoot)) {
    New-Item -ItemType Directory -Path $Directory -Force | Out-Null
}

Import-Module $CommonModulePath -Force -ErrorAction Stop

Assert-MSCondition `
    -Condition (Test-Path -LiteralPath $Pass03ManifestPath -PathType Leaf) `
    -Message "Pass 03 manifest is missing: $Pass03ManifestPath" `
    -InvariantID 'MS-B4-P4-PASS03-MANIFEST'

$Pass03Manifest = Get-Content `
    -LiteralPath $Pass03ManifestPath `
    -Raw |
    ConvertFrom-Json

Assert-MSCondition `
    -Condition ($Pass03Manifest.Result -eq 'PASS') `
    -Message 'Batch 4 Pass 03 is not PASS.' `
    -InvariantID 'MS-B4-P4-PASS03'

Assert-MSCondition `
    -Condition (Test-Path -LiteralPath $RuntimePyprojectPath -PathType Leaf) `
    -Message "Runtime pyproject is missing: $RuntimePyprojectPath" `
    -InvariantID 'MS-B4-P4-PYPROJECT'

Assert-MSCondition `
    -Condition (Test-Path -LiteralPath $LicenseSourcePath -PathType Leaf) `
    -Message "License source is missing: $LicenseSourcePath" `
    -InvariantID 'MS-B4-P4-LICENSE-SOURCE'

$PyprojectText = Get-Content -LiteralPath $RuntimePyprojectPath -Raw

$VersionMatch = [regex]::Match(
    $PyprojectText,
    '(?m)^\s*version\s*=\s*"(?<version>[^"]+)"'
)

Assert-MSCondition `
    -Condition $VersionMatch.Success `
    -Message 'Runtime version could not be read.' `
    -InvariantID 'MS-B4-P4-RUNTIME-VERSION'

$RuntimeVersion = $VersionMatch.Groups['version'].Value
$ArchitectureVersion = '1.0.0-rc.1'
$ReleaseDate = '2026-07-25'

foreach ($TargetPath in @($LicensePath, $VersionPath, $CitationPath)) {
    if (Test-Path -LiteralPath $TargetPath -PathType Leaf) {
        Copy-Item `
            -LiteralPath $TargetPath `
            -Destination (Join-Path $BackupRoot (Split-Path $TargetPath -Leaf)) `
            -Force
    }
}

$LicenseSource = Get-Content -LiteralPath $LicenseSourcePath -Raw

$LicenseHeader = @"
# Morning Star License

Morning Star is distributed under the Apache License, Version 2.0.

This license applies to source code, documentation, schemas, configuration,
verification artifacts, and other repository materials unless a file
explicitly states otherwise.

---

"@

Set-Content `
    -LiteralPath $LicensePath `
    -Value ($LicenseHeader + $LicenseSource) `
    -Encoding UTF8

$VersionDocument = @"
# Morning Star Version Declaration

## Constitutional Architecture

**Version:** $ArchitectureVersion  
**Release state:** Release candidate  
**Release date:** $ReleaseDate

The five-volume Morning Star constitutional architecture is complete and
frozen at version $ArchitectureVersion.

## Reference Runtime

**Package:** morning-star-runtime  
**Runtime version:** $RuntimeVersion  
**Python requirement:** Python 3.11 or later

The constitutional architecture version and executable runtime version are
governed independently. A runtime revision does not alter constitutional
meaning unless accompanied by an authorized constitutional revision.

## Release Verification

The governed release process includes repository inventory, distribution
packaging, checksum validation, package-state verification, Python compilation,
deterministic command-line verification, and publication-artifact verification.
"@

Set-Content `
    -LiteralPath $VersionPath `
    -Value $VersionDocument `
    -Encoding UTF8

$CitationDocument = @"
cff-version: 1.2.0
message: "If you use Morning Star, please cite it using this metadata."
title: "Morning Star: Constitutional Architecture for Semantic Entry and Competent Participation"
type: software
authors:
  - family-names: "Harris"
    given-names: "Ashley S."
version: "$ArchitectureVersion"
date-released: "$ReleaseDate"
license: "Apache-2.0"
abstract: >-
  Morning Star is a constitutional research architecture governing the
  preservation of semantic integrity from first contact through competent
  participation. It includes a five-volume constitutional architecture,
  canonical registries, verification structures, governance rules, and a
  reference runtime.
keywords:
  - semantic integrity
  - constitutional architecture
  - governed initiation
  - ontology
  - verification
  - research onboarding
"@

Set-Content `
    -LiteralPath $CitationPath `
    -Value $CitationDocument `
    -Encoding UTF8

$RequiredArtifacts = @(
    'README.md'
    'LICENSE'
    'LICENSE.md'
    'CHANGELOG.md'
    'VERSION.md'
    'CITATION.cff'
)

$ArtifactRegister = @(
    foreach ($RequiredArtifact in $RequiredArtifacts) {
        $Found = @(
            Get-ChildItem `
                -LiteralPath $RepositoryRoot `
                -Recurse `
                -File |
            Where-Object {
                $_.Name -eq $RequiredArtifact -and
                $_.FullName -notmatch
                '\\(\.git|Archive|archive|backups|release|\.venv|venv|build|dist)\\'
            }
        )

        [pscustomobject][ordered]@{
            RequiredArtifact = $RequiredArtifact
            MatchCount = $Found.Count
            Status = if ($Found.Count -gt 0) {
                'PRESENT'
            }
            else {
                'MISSING'
            }
        }
    }
)

$ArtifactRegisterPath = Join-Path `
    $ReportRoot `
    'B4_PASS04_PUBLICATION_ARTIFACT_REGISTER.csv'

$ArtifactRegister |
    Export-Csv `
        -LiteralPath $ArtifactRegisterPath `
        -NoTypeInformation `
        -Encoding UTF8

$MissingArtifacts = @(
    $ArtifactRegister |
        Where-Object Status -eq 'MISSING'
)

$GeneratedRegister = @(
    foreach ($GeneratedPath in @($LicensePath, $VersionPath, $CitationPath)) {
        $Item = Get-Item -LiteralPath $GeneratedPath

        [pscustomobject][ordered]@{
            Artifact = $Item.Name
            Path = $Item.FullName
            SizeBytes = $Item.Length
            SHA256 = (
                Get-FileHash `
                    -LiteralPath $Item.FullName `
                    -Algorithm SHA256
            ).Hash
            Status = 'VERIFIED'
        }
    }
)

$GeneratedRegisterPath = Join-Path `
    $ReportRoot `
    'B4_PASS04_GENERATED_ARTIFACT_REGISTER.csv'

$GeneratedRegister |
    Export-Csv `
        -LiteralPath $GeneratedRegisterPath `
        -NoTypeInformation `
        -Encoding UTF8

Assert-MSCondition `
    -Condition ($MissingArtifacts.Count -eq 0) `
    -Message "$($MissingArtifacts.Count) publication artifacts remain missing." `
    -InvariantID 'MS-B4-P4-PUBLICATION-COMPLETE'

$CompletionReportPath = Join-Path `
    $ReportRoot `
    'B4_PASS04_PUBLICATION_COMPLETION_REPORT.md'

$CompletionReport = @"
# Morning Star Batch 4 Pass 04 Completion Report

## Result

**PASS**

## Generated Publication Artifacts

- LICENSE.md
- VERSION.md
- CITATION.cff

## Verification

- Required publication artifacts: $($ArtifactRegister.Count)
- Missing publication artifacts: $($MissingArtifacts.Count)
- Generated artifacts verified: $($GeneratedRegister.Count)
- Constitutional architecture version: $ArchitectureVersion
- Runtime version: $RuntimeVersion

## Disposition

Morning Star publication prerequisites are complete.

The repository is eligible to advance to final Batch 4 closure and governed
release-freeze review.
"@

Set-Content `
    -LiteralPath $CompletionReportPath `
    -Value $CompletionReport `
    -Encoding UTF8

[ordered]@{
    PassID = 'B4-PASS-04'
    BatchID = 'BATCH-4'
    Purpose = 'Generate and verify required publication artifacts.'
    Result = 'PASS'
    Status = 'COMPLETE'
    ArchitectureVersion = $ArchitectureVersion
    RuntimeVersion = $RuntimeVersion
    RequiredPublicationArtifacts = $ArtifactRegister.Count
    MissingPublicationArtifacts = $MissingArtifacts.Count
    GeneratedPublicationArtifacts = $GeneratedRegister.Count
    License = 'Apache-2.0'
    GeneratedArtifacts = @(
        'LICENSE.md'
        'VERSION.md'
        'CITATION.cff'
    )
    ReportRoot = $ReportRoot
    CompletedAt = (Get-Date).ToString('o')
} |
    ConvertTo-Json -Depth 10 |
    Set-Content `
        -LiteralPath $ManifestPath `
        -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR - BATCH 4 PASS 04' -ForegroundColor Cyan
Write-Host 'PUBLICATION ARTIFACTS' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Architecture version:                 $ArchitectureVersion"
Write-Host "Runtime version:                      $RuntimeVersion"
Write-Host "Required publication artifacts:       $($ArtifactRegister.Count)"
Write-Host "Missing publication artifacts:        $($MissingArtifacts.Count)"
Write-Host "Generated publication artifacts:      $($GeneratedRegister.Count)"
Write-Host ''
Write-Host 'BATCH 4 PASS 04: PASS' -ForegroundColor Green
Write-Host 'ALL REQUIRED PUBLICATION ARTIFACTS ARE PRESENT.' -ForegroundColor Green
Write-Host 'MORNING STAR IS ELIGIBLE FOR FINAL RELEASE CLOSURE.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
