$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (
    Resolve-Path (Join-Path $PSScriptRoot '..\..')
).Path

$CommonModulePath = Join-Path `
    $RepositoryRoot `
    'engineering\modules\MorningStar.Engine.Common.psm1'

$Pass01ReportRoot = Join-Path `
    $RepositoryRoot `
    'engineering\reports\batch-4\B4-PASS-01'

$RepositoryInventoryPath = Join-Path `
    $Pass01ReportRoot `
    'B4_PASS01_REPOSITORY_INVENTORY.csv'

$ArtifactInventoryPath = Join-Path `
    $Pass01ReportRoot `
    'B4_PASS01_ARTIFACT_INVENTORY.csv'

$Pass01ManifestPath = Join-Path `
    $RepositoryRoot `
    'engineering\manifests\batch-4\B4-PASS-01_MANIFEST.json'

$ReportRoot = Join-Path `
    $RepositoryRoot `
    'engineering\reports\batch-4\B4-PASS-02'

$ManifestPath = Join-Path `
    $RepositoryRoot `
    'engineering\manifests\batch-4\B4-PASS-02_MANIFEST.json'

$BackupRoot = Join-Path `
    $RepositoryRoot `
    'engineering\backups\batch-4\B4-PASS-02'

$ReleaseRoot = Join-Path `
    $RepositoryRoot `
    'release'

$StagingRoot = Join-Path `
    $ReleaseRoot `
    'staging'

$PackageName = 'morning-star-release-candidate'

$PackageRoot = Join-Path `
    $StagingRoot `
    $PackageName

foreach ($Directory in @(
    $ReportRoot
    $BackupRoot
    $ReleaseRoot
    $StagingRoot
)) {
    New-Item `
        -ItemType Directory `
        -Path $Directory `
        -Force |
        Out-Null
}

Import-Module `
    $CommonModulePath `
    -Force `
    -ErrorAction Stop

Assert-MSCondition `
    -Condition (
        Test-Path `
            -LiteralPath $RepositoryInventoryPath `
            -PathType Leaf
    ) `
    -Message "Pass 01 repository inventory is missing: $RepositoryInventoryPath" `
    -InvariantID 'MS-B4-P2-REPOSITORY-INVENTORY'

Assert-MSCondition `
    -Condition (
        Test-Path `
            -LiteralPath $ArtifactInventoryPath `
            -PathType Leaf
    ) `
    -Message "Pass 01 artifact inventory is missing: $ArtifactInventoryPath" `
    -InvariantID 'MS-B4-P2-ARTIFACT-INVENTORY'

$Pass01Manifest = Get-Content `
    -LiteralPath $Pass01ManifestPath `
    -Raw |
    ConvertFrom-Json

Assert-MSCondition `
    -Condition (
        $Pass01Manifest.Result -eq 'PASS'
    ) `
    -Message 'Batch 4 Pass 01 is not PASS.' `
    -InvariantID 'MS-B4-P2-PASS01'

$RepositoryInventory = @(
    Import-Csv `
        -LiteralPath $RepositoryInventoryPath
)

$ArtifactInventory = @(
    Import-Csv `
        -LiteralPath $ArtifactInventoryPath
)

Assert-MSCondition `
    -Condition (
        $RepositoryInventory.Count -gt 0
    ) `
    -Message 'Repository inventory contains no files.' `
    -InvariantID 'MS-B4-P2-EMPTY-INVENTORY'

# =====================================================================
# Remove only the previous generated staging package.
# Source files are never deleted or modified.
# =====================================================================

$PreviousPackageBackup = $null

if (
    Test-Path `
        -LiteralPath $PackageRoot `
        -PathType Container
) {
    $PreviousPackageBackup = Join-Path `
        $BackupRoot `
        (
            'previous-package-{0}' -f
            (Get-Date -Format 'yyyyMMdd_HHmmss')
        )

    New-Item `
        -ItemType Directory `
        -Path (Split-Path -Parent $PreviousPackageBackup) `
        -Force |
        Out-Null

    Move-Item `
        -LiteralPath $PackageRoot `
        -Destination $PreviousPackageBackup `
        -Force
}

$PackageDirectories = [ordered]@{
    CONSTITUTIONAL = Join-Path $PackageRoot 'constitutional'
    RUNTIME        = Join-Path $PackageRoot 'runtime'
    VERIFICATION   = Join-Path $PackageRoot 'verification'
    ENGINEERING    = Join-Path $PackageRoot 'engineering'
    DOCUMENTATION  = Join-Path $PackageRoot 'documentation'
    OTHER          = Join-Path $PackageRoot 'other'
    METADATA       = Join-Path $PackageRoot 'metadata'
}

foreach ($Directory in $PackageDirectories.Values) {
    New-Item `
        -ItemType Directory `
        -Path $Directory `
        -Force |
        Out-Null
}

# =====================================================================
# Create authoritative class lookup.
# =====================================================================

$ClassLookup = @{}

foreach ($Artifact in $ArtifactInventory) {
    $ClassLookup[$Artifact.RelativePath] = $Artifact.ArtifactClass
}

# =====================================================================
# Copy every Pass 01 baseline file into its governed package class.
# =====================================================================

$PackagingRegister = [System.Collections.Generic.List[object]]::new()

foreach ($InventoryRow in $RepositoryInventory) {
    $RelativePath = [string]$InventoryRow.RelativePath

    # Prevent package recursion if Pass 01 inventory ever contained release/.
    if (
        $RelativePath -match
        '^(release|dist|build)\\'
    ) {
        continue
    }

    $SourcePath = Join-Path `
        $RepositoryRoot `
        $RelativePath

    Assert-MSCondition `
        -Condition (
            Test-Path `
                -LiteralPath $SourcePath `
                -PathType Leaf
        ) `
        -Message "Inventory source is missing: $SourcePath" `
        -InvariantID 'MS-B4-P2-SOURCE'

    $ArtifactClass = if (
        $ClassLookup.ContainsKey($RelativePath)
    ) {
        [string]$ClassLookup[$RelativePath]
    }
    else {
        'OTHER'
    }

    if (
        -not $PackageDirectories.Contains($ArtifactClass)
    ) {
        $ArtifactClass = 'OTHER'
    }

    $ClassRoot = $PackageDirectories[$ArtifactClass]

    $DestinationPath = Join-Path `
        $ClassRoot `
        $RelativePath

    $DestinationDirectory = Split-Path `
        -Parent `
        $DestinationPath

    New-Item `
        -ItemType Directory `
        -Path $DestinationDirectory `
        -Force |
        Out-Null

    Copy-Item `
        -LiteralPath $SourcePath `
        -Destination $DestinationPath `
        -Force

    $SourceHash = (
        Get-FileHash `
            -LiteralPath $SourcePath `
            -Algorithm SHA256
    ).Hash

    $DestinationHash = (
        Get-FileHash `
            -LiteralPath $DestinationPath `
            -Algorithm SHA256
    ).Hash

    $HashPreserved = (
        $SourceHash -eq $DestinationHash
    )

    Assert-MSCondition `
        -Condition $HashPreserved `
        -Message "Package hash mismatch: $RelativePath" `
        -InvariantID 'MS-B4-P2-HASH'

    $PackagingRegister.Add(
        [pscustomobject][ordered]@{
            RelativePath = $RelativePath
            ArtifactClass = $ArtifactClass
            SourcePath = $SourcePath
            DestinationPath = $DestinationPath
            SizeBytes = (
                Get-Item `
                    -LiteralPath $DestinationPath
            ).Length
            SourceSHA256 = $SourceHash
            PackageSHA256 = $DestinationHash
            HashPreserved = $HashPreserved
            PackagingStatus = 'COPIED_AND_VERIFIED'
            PackagedAt = (Get-Date).ToString('o')
        }
    )
}

Assert-MSCondition `
    -Condition (
        $PackagingRegister.Count -gt 0
    ) `
    -Message 'No files were packaged.' `
    -InvariantID 'MS-B4-P2-NO-PACKAGE'

# =====================================================================
# Generate package checksums.
# =====================================================================

$ChecksumsPath = Join-Path `
    $PackageDirectories.METADATA `
    'CHECKSUMS.sha256'

$ChecksumLines = @(
    $PackagingRegister |
        Sort-Object DestinationPath |
        ForEach-Object {
            $PackageRelativePath = $_.DestinationPath.
                Substring($PackageRoot.Length).
                TrimStart('\')

            '{0}  {1}' -f
            $_.PackageSHA256,
            ($PackageRelativePath -replace '\\', '/')
        }
)

$Utf8WithoutBom = New-Object `
    System.Text.UTF8Encoding `
    $false

[System.IO.File]::WriteAllLines(
    $ChecksumsPath,
    [string[]]$ChecksumLines,
    $Utf8WithoutBom
)

# =====================================================================
# Generate package inventories and manifest.
# =====================================================================

$PackagingRegisterPath = Join-Path `
    $ReportRoot `
    'B4_PASS02_PACKAGING_REGISTER.csv'

$PackageInventoryPath = Join-Path `
    $PackageDirectories.METADATA `
    'PACKAGE_INVENTORY.csv'

$PackagingRegister |
    Export-Csv `
        -LiteralPath $PackagingRegisterPath `
        -NoTypeInformation `
        -Encoding UTF8

$PackagingRegister |
    Select-Object `
        RelativePath,
        ArtifactClass,
        SizeBytes,
        PackageSHA256,
        HashPreserved,
        PackagingStatus |
    Sort-Object ArtifactClass, RelativePath |
    Export-Csv `
        -LiteralPath $PackageInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$ClassSummary = @(
    $PackagingRegister |
        Group-Object ArtifactClass |
        Sort-Object Name |
        ForEach-Object {
            $TotalBytes = 0

            foreach ($Item in $_.Group) {
                $TotalBytes += [long]$Item.SizeBytes
            }

            [pscustomobject][ordered]@{
                ArtifactClass = $_.Name
                FileCount = $_.Count
                TotalBytes = $TotalBytes
            }
        }
)

$ClassSummaryPath = Join-Path `
    $PackageDirectories.METADATA `
    'PACKAGE_CLASS_SUMMARY.csv'

$ClassSummary |
    Export-Csv `
        -LiteralPath $ClassSummaryPath `
        -NoTypeInformation `
        -Encoding UTF8

$PackageStateMaterial = (
    $PackagingRegister |
        Sort-Object {
            $_.DestinationPath.
                Substring($PackageRoot.Length).
                TrimStart('\')
        } |
        ForEach-Object {
            $PackageRelativePath = $_.DestinationPath.
                Substring($PackageRoot.Length).
                TrimStart('\')

            '{0}|{1}|{2}' -f
            ($PackageRelativePath -replace '\\', '/'),
            $_.SizeBytes,
            $_.PackageSHA256
        }
) -join "`n"

$PackageStateHash = Get-MSDeterministicHash `
    -InputText $PackageStateMaterial `
    -Length 64

$PackageManifestPath = Join-Path `
    $PackageDirectories.METADATA `
    'PACKAGE_MANIFEST.json'

$PackageManifest = [ordered]@{
    SchemaVersion = '1.0.0'
    PackageName = $PackageName
    PackageState = 'RELEASE_CANDIDATE'
    SourceRepositoryStateSHA256 = $Pass01Manifest.RepositoryStateSHA256
    PackageStateSHA256 = $PackageStateHash
    PackagedFiles = $PackagingRegister.Count
    PackageBytes = (
        $PackagingRegister |
            ForEach-Object {
                [long]$_.SizeBytes
            } |
            Measure-Object -Sum
    ).Sum
    ArtifactClasses = $ClassSummary
    ChecksumsPath = 'metadata/CHECKSUMS.sha256'
    InventoryPath = 'metadata/PACKAGE_INVENTORY.csv'
    SourceFilesModified = 0
    PackagedAt = (Get-Date).ToString('o')
}

$PackageManifest |
    ConvertTo-Json -Depth 10 |
    Set-Content `
        -LiteralPath $PackageManifestPath `
        -Encoding UTF8

# =====================================================================
# Independent package read-back verification.
# =====================================================================

$ReadBackInventory = @(
    Import-Csv `
        -LiteralPath $PackageInventoryPath
)

$ReadBackFailures = [System.Collections.Generic.List[object]]::new()

foreach ($PackageRow in $PackagingRegister) {
    $DestinationExists = Test-Path `
        -LiteralPath $PackageRow.DestinationPath `
        -PathType Leaf

    if (-not $DestinationExists) {
        $ReadBackFailures.Add(
            [pscustomobject][ordered]@{
                RelativePath = $PackageRow.RelativePath
                FailureClass = 'MISSING_PACKAGED_FILE'
            }
        )

        continue
    }

    $CurrentHash = (
        Get-FileHash `
            -LiteralPath $PackageRow.DestinationPath `
            -Algorithm SHA256
    ).Hash

    if (
        $CurrentHash -ne
        $PackageRow.PackageSHA256
    ) {
        $ReadBackFailures.Add(
            [pscustomobject][ordered]@{
                RelativePath = $PackageRow.RelativePath
                FailureClass = 'PACKAGE_HASH_MISMATCH'
            }
        )
    }
}

$PackageVerificationPass = (
    $ReadBackInventory.Count -eq
    $PackagingRegister.Count -and
    $ReadBackFailures.Count -eq 0
)

Assert-MSCondition `
    -Condition $PackageVerificationPass `
    -Message (
        'Distribution package failed read-back verification. ' +
        "Inventory=$($ReadBackInventory.Count); " +
        "Expected=$($PackagingRegister.Count); " +
        "Failures=$($ReadBackFailures.Count)"
    ) `
    -InvariantID 'MS-B4-P2-READBACK'

# =====================================================================
# Complete Pass 02 manifest.
# =====================================================================

$ExistingManifest = if (
    Test-Path `
        -LiteralPath $ManifestPath `
        -PathType Leaf
) {
    Get-Content `
        -LiteralPath $ManifestPath `
        -Raw |
        ConvertFrom-Json
}
else {
    $null
}

[ordered]@{
    PassID = 'B4-PASS-02'
    BatchID = 'BATCH-4'
    Purpose = 'Build and independently verify the governed distribution package.'
    Result = 'PASS'
    Status = 'COMPLETE'
    PackageName = $PackageName
    PackageRoot = $PackageRoot
    SourceRepositoryStateSHA256 = $Pass01Manifest.RepositoryStateSHA256
    PackageStateSHA256 = $PackageStateHash
    PackagedFiles = $PackagingRegister.Count
    PackageInventoryRows = $ReadBackInventory.Count
    PackageVerificationFailures = $ReadBackFailures.Count
    ChecksumEntries = $ChecksumLines.Count
    ArtifactClasses = $ClassSummary.Count
    SourceFilesModified = 0
    PreviousPackageArchived = (
        $null -ne $PreviousPackageBackup
    )
    BackupRoot = $BackupRoot
    CompletedAt = (Get-Date).ToString('o')
} |
    ConvertTo-Json -Depth 10 |
    Set-Content `
        -LiteralPath $ManifestPath `
        -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — BATCH 4 PASS 02' -ForegroundColor Cyan
Write-Host 'DISTRIBUTION PACKAGING' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Package name:                         $PackageName"
Write-Host "Packaged files:                       $($PackagingRegister.Count)"
Write-Host "Package inventory rows:               $($ReadBackInventory.Count)"
Write-Host "Checksum entries:                     $($ChecksumLines.Count)"
Write-Host "Artifact classes:                     $($ClassSummary.Count)"
Write-Host "Package verification failures:        $($ReadBackFailures.Count)"
Write-Host "Package state SHA256:                 $PackageStateHash"
Write-Host "Source files modified:                0"
Write-Host ''
Write-Host "Package root:                         $PackageRoot"
Write-Host "Package manifest:                     $PackageManifestPath"
Write-Host "Checksums:                            $ChecksumsPath"
Write-Host ''
Write-Host 'BATCH 4 PASS 02: PASS' -ForegroundColor Green
Write-Host 'THE RELEASE-CANDIDATE DISTRIBUTION PACKAGE WAS CREATED.' -ForegroundColor Green
Write-Host 'EVERY PACKAGED FILE WAS HASH-VERIFIED AGAINST ITS SOURCE.' -ForegroundColor Green
Write-Host 'NO SOURCE, GOVERNANCE, RUNTIME, OR VERIFICATION FILES WERE MODIFIED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
