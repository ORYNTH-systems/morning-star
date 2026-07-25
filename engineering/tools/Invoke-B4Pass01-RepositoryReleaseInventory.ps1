$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (
    Resolve-Path (Join-Path $PSScriptRoot '..\..')
).Path

$CommonModulePath = Join-Path `
    $RepositoryRoot `
    'engineering\modules\MorningStar.Engine.Common.psm1'

$ReportRoot = Join-Path `
    $RepositoryRoot `
    'engineering\reports\batch-4\B4-PASS-01'

$ManifestPath = Join-Path `
    $RepositoryRoot `
    'engineering\manifests\batch-4\B4-PASS-01_MANIFEST.json'

New-Item `
    -ItemType Directory `
    -Path $ReportRoot `
    -Force |
    Out-Null

Import-Module `
    $CommonModulePath `
    -Force `
    -ErrorAction Stop

$ExcludedPatterns = @(
    '\\.git\\'
    '\\Archive\\'
    '\\archive\\'
    '\\backups\\'
    '\\Repository_Cleanup\\'
    '\\node_modules\\'
    '\\\.venv\\'
    '\\venv\\'
    '\\dist\\'
    '\\build\\'
    '\\__pycache__\\'
)

$AllFiles = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Recurse `
        -File |
    Where-Object {
        $Path = $_.FullName

        @(
            $ExcludedPatterns |
                Where-Object {
                    $Path -match $_
                }
        ).Count -eq 0
    }
)

Assert-MSCondition `
    -Condition ($AllFiles.Count -gt 0) `
    -Message 'No repository files were discovered.' `
    -InvariantID 'MS-B4-P1-INVENTORY'

$RepositoryInventory = @(
    foreach ($File in $AllFiles) {
        $RelativePath = $File.FullName.
            Substring($RepositoryRoot.Length).
            TrimStart('\')

        [pscustomobject][ordered]@{
            RelativePath = $RelativePath
            FileName = $File.Name
            Extension = $File.Extension
            SizeBytes = $File.Length
            Directory = (
                Split-Path `
                    -Parent `
                    $RelativePath
            )
            SHA256 = (
                Get-FileHash `
                    -LiteralPath $File.FullName `
                    -Algorithm SHA256
            ).Hash
            LastWriteTime = $File.LastWriteTime.ToString('o')
        }
    }
)

$RepositoryInventoryPath = Join-Path `
    $ReportRoot `
    'B4_PASS01_REPOSITORY_INVENTORY.csv'

$RepositoryInventory |
    Sort-Object RelativePath |
    Export-Csv `
        -LiteralPath $RepositoryInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$ArtifactInventory = @(
    foreach ($Row in $RepositoryInventory) {
        $Class = if (
            $Row.RelativePath -match
            '(^|\\)(constitution|governance|registries)(\\|$)'
        ) {
            'CONSTITUTIONAL'
        }
        elseif (
            $Row.RelativePath -match
            '(^|\\)(runtime|api|cli|config|schemas|models)(\\|$)'
        ) {
            'RUNTIME'
        }
        elseif (
            $Row.RelativePath -match
            '(^|\\)(verification|execution|trials|evidence)(\\|$)'
        ) {
            'VERIFICATION'
        }
        elseif (
            $Row.RelativePath -match
            '(^|\\)(engineering)(\\|$)'
        ) {
            'ENGINEERING'
        }
        elseif (
            $Row.Extension -in @(
                '.md'
                '.pdf'
                '.docx'
                '.txt'
            )
        ) {
            'DOCUMENTATION'
        }
        else {
            'OTHER'
        }

        [pscustomobject][ordered]@{
            RelativePath = $Row.RelativePath
            ArtifactClass = $Class
            Extension = $Row.Extension
            SizeBytes = $Row.SizeBytes
            SHA256 = $Row.SHA256
            ReleaseEligibility = if (
                $Class -eq 'OTHER'
            ) {
                'REVIEW'
            }
            else {
                'ELIGIBLE'
            }
        }
    }
)

$ArtifactInventoryPath = Join-Path `
    $ReportRoot `
    'B4_PASS01_ARTIFACT_INVENTORY.csv'

$ArtifactInventory |
    Sort-Object ArtifactClass, RelativePath |
    Export-Csv `
        -LiteralPath $ArtifactInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$RuntimeInventory = @(
    $ArtifactInventory |
        Where-Object ArtifactClass -eq 'RUNTIME'
)

$RuntimeInventoryPath = Join-Path `
    $ReportRoot `
    'B4_PASS01_RUNTIME_INVENTORY.csv'

$RuntimeInventory |
    Export-Csv `
        -LiteralPath $RuntimeInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$DocumentationInventory = @(
    $ArtifactInventory |
        Where-Object ArtifactClass -eq 'DOCUMENTATION'
)

$DocumentationInventoryPath = Join-Path `
    $ReportRoot `
    'B4_PASS01_DOCUMENTATION_INVENTORY.csv'

$DocumentationInventory |
    Export-Csv `
        -LiteralPath $DocumentationInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$VerificationInventory = @(
    $ArtifactInventory |
        Where-Object ArtifactClass -eq 'VERIFICATION'
)

$VerificationInventoryPath = Join-Path `
    $ReportRoot `
    'B4_PASS01_VERIFICATION_INVENTORY.csv'

$VerificationInventory |
    Export-Csv `
        -LiteralPath $VerificationInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$EngineeringInventory = @(
    $ArtifactInventory |
        Where-Object ArtifactClass -eq 'ENGINEERING'
)

$EngineeringInventoryPath = Join-Path `
    $ReportRoot `
    'B4_PASS01_ENGINEERING_INVENTORY.csv'

$EngineeringInventory |
    Export-Csv `
        -LiteralPath $EngineeringInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$PublicationCandidates = @(
    $RepositoryInventory |
        Where-Object {
            $_.FileName -match
            '(?i)readme|license|changelog|release|version|publication|citation'
        }
)

$PublicationInventoryPath = Join-Path `
    $ReportRoot `
    'B4_PASS01_PUBLICATION_INVENTORY.csv'

$PublicationCandidates |
    Sort-Object RelativePath |
    Export-Csv `
        -LiteralPath $PublicationInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$RequiredReleaseArtifacts = @(
    'README.md'
    'LICENSE'
    'LICENSE.md'
    'CHANGELOG.md'
    'VERSION.md'
    'CITATION.cff'
)

$RequiredArtifactRegister = @(
    foreach ($RequiredName in $RequiredReleaseArtifacts) {
        $Matches = @(
            $RepositoryInventory |
                Where-Object FileName -eq $RequiredName
        )

        [pscustomobject][ordered]@{
            RequiredArtifact = $RequiredName
            MatchCount = $Matches.Count
            Paths = (
                @(
                    $Matches |
                        Select-Object -ExpandProperty RelativePath
                ) -join ' | '
            )
            Status = if ($Matches.Count -gt 0) {
                'PRESENT'
            }
            else {
                'MISSING'
            }
        }
    }
)

$RequiredArtifactRegisterPath = Join-Path `
    $ReportRoot `
    'B4_PASS01_REQUIRED_RELEASE_ARTIFACT_REGISTER.csv'

$RequiredArtifactRegister |
    Export-Csv `
        -LiteralPath $RequiredArtifactRegisterPath `
        -NoTypeInformation `
        -Encoding UTF8

$MissingRequiredArtifacts = @(
    $RequiredArtifactRegister |
        Where-Object Status -eq 'MISSING'
)

$ExtensionSummary = @(
    $RepositoryInventory |
        Group-Object Extension |
        Sort-Object Count -Descending |
        ForEach-Object {
            [pscustomobject][ordered]@{
                Extension = if (
                    [string]::IsNullOrWhiteSpace($_.Name)
                ) {
                    '[none]'
                }
                else {
                    $_.Name
                }
                Count = $_.Count
                TotalBytes = (
                    $_.Group |
                        Measure-Object `
                            -Property SizeBytes `
                            -Sum
                ).Sum
            }
        }
)

$ExtensionSummaryPath = Join-Path `
    $ReportRoot `
    'B4_PASS01_EXTENSION_SUMMARY.csv'

$ExtensionSummary |
    Export-Csv `
        -LiteralPath $ExtensionSummaryPath `
        -NoTypeInformation `
        -Encoding UTF8

$ClassSummary = @(
    $ArtifactInventory |
        Group-Object ArtifactClass |
        Sort-Object Name |
        ForEach-Object {
            [pscustomobject][ordered]@{
                ArtifactClass = $_.Name
                Count = $_.Count
                TotalBytes = (
                    $_.Group |
                        Measure-Object `
                            -Property SizeBytes `
                            -Sum
                ).Sum
            }
        }
)

$ClassSummaryPath = Join-Path `
    $ReportRoot `
    'B4_PASS01_ARTIFACT_CLASS_SUMMARY.csv'

$ClassSummary |
    Export-Csv `
        -LiteralPath $ClassSummaryPath `
        -NoTypeInformation `
        -Encoding UTF8

$RepositoryStateMaterial = (
    $RepositoryInventory |
        Sort-Object RelativePath |
        ForEach-Object {
            '{0}|{1}|{2}' -f
            $_.RelativePath,
            $_.SizeBytes,
            $_.SHA256
        }
) -join "`n"

$RepositoryStateHash = Get-MSDeterministicHash `
    -InputText $RepositoryStateMaterial `
    -Length 64

$ReleaseManifestPath = Join-Path `
    $ReportRoot `
    'B4_PASS01_RELEASE_BASELINE_MANIFEST.json'

$ReleaseManifest = [ordered]@{
    SchemaVersion = '1.0.0'
    BatchID = 'BATCH-4'
    PassID = 'B4-PASS-01'
    RepositoryRoot = $RepositoryRoot
    RepositoryFiles = $RepositoryInventory.Count
    RepositoryBytes = (
        $RepositoryInventory |
            Measure-Object `
                -Property SizeBytes `
                -Sum
    ).Sum
    RepositoryStateSHA256 = $RepositoryStateHash
    ArtifactClasses = $ClassSummary
    RuntimeArtifacts = $RuntimeInventory.Count
    DocumentationArtifacts = $DocumentationInventory.Count
    VerificationArtifacts = $VerificationInventory.Count
    EngineeringArtifacts = $EngineeringInventory.Count
    PublicationCandidates = $PublicationCandidates.Count
    RequiredReleaseArtifacts = $RequiredArtifactRegister.Count
    MissingRequiredReleaseArtifacts = $MissingRequiredArtifacts.Count
    SourceFilesModified = 0
    InventoryGeneratedAt = (Get-Date).ToString('o')
}

$ReleaseManifest |
    ConvertTo-Json -Depth 10 |
    Set-Content `
        -LiteralPath $ReleaseManifestPath `
        -Encoding UTF8

$ExistingManifest = Get-Content `
    -LiteralPath $ManifestPath `
    -Raw |
    ConvertFrom-Json

[ordered]@{
    PassID = 'B4-PASS-01'
    BatchID = 'BATCH-4'
    Purpose = if (
        $ExistingManifest.PSObject.Properties.Name -contains 'Purpose'
    ) {
        $ExistingManifest.Purpose
    }
    else {
        'Generate the authoritative repository release inventory.'
    }
    Result = 'PASS'
    Status = 'COMPLETE'
    RepositoryFilesInventoried = $RepositoryInventory.Count
    RuntimeArtifacts = $RuntimeInventory.Count
    DocumentationArtifacts = $DocumentationInventory.Count
    VerificationArtifacts = $VerificationInventory.Count
    EngineeringArtifacts = $EngineeringInventory.Count
    PublicationCandidates = $PublicationCandidates.Count
    MissingRequiredReleaseArtifacts = $MissingRequiredArtifacts.Count
    RepositoryStateSHA256 = $RepositoryStateHash
    SourceFilesModified = 0
    ReleaseManifestPath = $ReleaseManifestPath
    CompletedAt = (Get-Date).ToString('o')
} |
    ConvertTo-Json -Depth 10 |
    Set-Content `
        -LiteralPath $ManifestPath `
        -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — BATCH 4 PASS 01' -ForegroundColor Cyan
Write-Host 'REPOSITORY RELEASE INVENTORY' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Repository files inventoried:          $($RepositoryInventory.Count)"
Write-Host "Runtime artifacts:                     $($RuntimeInventory.Count)"
Write-Host "Documentation artifacts:               $($DocumentationInventory.Count)"
Write-Host "Verification artifacts:                $($VerificationInventory.Count)"
Write-Host "Engineering artifacts:                 $($EngineeringInventory.Count)"
Write-Host "Publication candidates:                $($PublicationCandidates.Count)"
Write-Host "Missing required release artifacts:    $($MissingRequiredArtifacts.Count)"
Write-Host "Repository state SHA256:               $RepositoryStateHash"
Write-Host "Source files modified:                 0"
Write-Host ''
Write-Host "Release baseline manifest:             $ReleaseManifestPath"
Write-Host ''
Write-Host 'BATCH 4 PASS 01: PASS' -ForegroundColor Green
Write-Host 'THE AUTHORITATIVE RELEASE BASELINE IS NOW INVENTORIED.' -ForegroundColor Green
Write-Host 'NO SOURCE, RUNTIME, GOVERNANCE, OR VERIFICATION FILES WERE MODIFIED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
