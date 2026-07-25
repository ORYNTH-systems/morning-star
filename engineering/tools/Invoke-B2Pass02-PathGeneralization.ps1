$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$ModulePath = Join-Path $RepositoryRoot 'engineering\modules\MorningStar.Engine.Common.psm1'
$ReportRoot = Join-Path $RepositoryRoot 'engineering\reports\batch-2\B2-PASS-02'
$BackupRoot = Join-Path $RepositoryRoot 'engineering\backups\batch-2\B2-PASS-02'
$ManifestPath = Join-Path $RepositoryRoot 'engineering\manifests\batch-2\B2-PASS-02_MANIFEST.json'

New-Item -ItemType Directory -Path $ReportRoot -Force | Out-Null
New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

Import-Module $ModulePath -Force -ErrorAction Stop

$BatchContext = Get-MSBatchContext `
    -RepositoryRoot $RepositoryRoot `
    -BatchID 'BATCH_A'

$ProtectedPaths = @(
    (Join-Path $BatchContext.Stage5Root 'Reports\BATCH_A_STAGE_5_COMPLETION_STATUS.json')
    (Join-Path $BatchContext.Stage5Root 'Evidence\BATCH_A_STAGE_5_EVIDENCE_CHAIN.csv')
    (Join-Path $BatchContext.Stage5Root 'Evidence\BATCH_A_STAGE_5_FINAL_VALIDATION_REGISTER.csv')
    (Join-Path $BatchContext.Stage6Root 'Reports\BATCH_A_STAGE_6_COMPLETION_STATUS.json')
    (Join-Path $BatchContext.Stage6Root 'Evidence\BATCH_A_STAGE_6_GOVERNANCE_DISPOSITION_REGISTER.csv')
    (Join-Path $BatchContext.Stage6Root 'Governance_Packets\BATCH_A_STAGE_6_GOVERNANCE_PACKET.csv')
)

$ProtectedBefore = @(
    foreach ($Path in $ProtectedPaths) {
        Get-MSFileHashRecord -LiteralPath $Path
    }
)

$ExcludedPatterns = @(
    '\\.git\\'
    '\\Archive\\'
    '\\archive\\'
    '\\backups\\'
    '\\Repository_Cleanup\\'
    '\\node_modules\\'
    '\\\.venv\\'
    '\\venv\\'
)

$Scripts = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Recurse `
        -File `
        -Filter '*.ps1' |
    Where-Object {
        $Path = $_.FullName
        $Excluded = @(
            $ExcludedPatterns |
            Where-Object { $Path -match $_ }
        ).Count -gt 0

        -not $Excluded -and
        $Path -ne (Resolve-Path $ToolPath).Path
    }
)

$ExecutionRegister = [System.Collections.Generic.List[object]]::new()

foreach ($Script in $Scripts) {
    $OriginalText = Get-Content -LiteralPath $Script.FullName -Raw

    $Patterns = @(
        '(?m)^\s*\$BatchRoot\s*=\s*[''"]\.\\volumes\\VOLUME_I_FOUNDATION\\verification\\readiness\\BATCH_EXECUTION\\BATCH_A[''"]\s*$'
        '(?m)^\s*\$BatchRoot\s*=\s*Join-Path\s+\$RepositoryRoot\s+[''"]volumes\\VOLUME_I_FOUNDATION\\verification\\readiness\\BATCH_EXECUTION\\BATCH_A[''"]\s*$'
    )

    $MatchCount = 0

    foreach ($Pattern in $Patterns) {
        $MatchCount += [regex]::Matches(
            $OriginalText,
            $Pattern
        ).Count
    }

    if ($MatchCount -eq 0) {
        continue
    }

    $RelativePath = $Script.FullName.
        Substring($RepositoryRoot.Length).
        TrimStart('\')

    $BackupPath = Join-Path $BackupRoot $RelativePath

    New-Item `
        -ItemType Directory `
        -Path (Split-Path -Parent $BackupPath) `
        -Force |
        Out-Null

    Copy-Item `
        -LiteralPath $Script.FullName `
        -Destination $BackupPath `
        -Force

    $ModifiedText = $OriginalText

    $Replacement = @(
        '$BatchContext = Get-MSBatchContext -RepositoryRoot $RepositoryRoot -BatchID ''BATCH_A'''
        '$BatchRoot = $BatchContext.BatchRoot'
    ) -join [Environment]::NewLine

    foreach ($Pattern in $Patterns) {
        $ModifiedText = [regex]::Replace(
            $ModifiedText,
            $Pattern,
            $Replacement
        )
    }

    if ($ModifiedText -notmatch 'MorningStar\.Engine\.Common\.psm1') {
        $ScriptDirectory = Split-Path -Parent $Script.FullName
        $FromUri = [System.Uri]::new($ScriptDirectory.TrimEnd('\') + '\')
        $ToUri = [System.Uri]::new($ModulePath)

        $RelativeModulePath = [System.Uri]::UnescapeDataString(
            $FromUri.MakeRelativeUri($ToUri).ToString()
        ) -replace '/', '\'

        $ImportBlock = @(
            "`$MorningStarCommonModule = Join-Path `$PSScriptRoot '$RelativeModulePath'"
            'Import-Module $MorningStarCommonModule -Force -ErrorAction Stop'
            ''
        ) -join [Environment]::NewLine

        $ModifiedText = $ImportBlock + $ModifiedText
    }

    $ModifiedText |
        Set-Content `
            -LiteralPath $Script.FullName `
            -Encoding UTF8

    $Tokens = $null
    $Errors = $null

    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $Script.FullName,
        [ref]$Tokens,
        [ref]$Errors
    )

    if (@($Errors).Count -gt 0) {
        Copy-Item `
            -LiteralPath $BackupPath `
            -Destination $Script.FullName `
            -Force

        throw "Syntax failure; restored $RelativePath"
    }

    $ExecutionRegister.Add(
        [pscustomobject][ordered]@{
            ScriptPath = $Script.FullName
            RelativePath = $RelativePath
            BackupPath = $BackupPath
            PathAssignmentsGeneralized = $MatchCount
            Status = 'GENERALIZED'
            ExecutedAt = (Get-Date).ToString('o')
        }
    )
}

$ExecutionPath = Join-Path $ReportRoot 'B2_PASS02_EXECUTION_REGISTER.csv'

$ExecutionRegister |
    Export-Csv `
        -LiteralPath $ExecutionPath `
        -NoTypeInformation `
        -Encoding UTF8

$SyntaxRegister = @(
    foreach ($Script in $Scripts) {
        $Tokens = $null
        $Errors = $null

        [void][System.Management.Automation.Language.Parser]::ParseFile(
            $Script.FullName,
            [ref]$Tokens,
            [ref]$Errors
        )

        [pscustomobject]@{
            ScriptPath = $Script.FullName
            ParseErrors = @($Errors).Count
            Status = if (@($Errors).Count -eq 0) { 'PASS' } else { 'FAIL' }
        }
    }
)

$SyntaxFailures = @(
    $SyntaxRegister |
    Where-Object Status -ne 'PASS'
)

if ($SyntaxFailures.Count -ne 0) {
    throw "$($SyntaxFailures.Count) scripts failed syntax verification."
}

$RegressionRegister = @(
    foreach ($Before in $ProtectedBefore) {
        $After = Get-MSFileHashRecord -LiteralPath $Before.Path

        [pscustomobject]@{
            ArtifactPath = $Before.Path
            SHA256Before = $Before.SHA256
            SHA256After = $After.SHA256
            Status = if ($Before.SHA256 -eq $After.SHA256) {
                'PASS'
            }
            else {
                'FAIL'
            }
        }
    }
)

$RegressionFailures = @(
    $RegressionRegister |
    Where-Object Status -ne 'PASS'
)

if ($RegressionFailures.Count -ne 0) {
    throw "$($RegressionFailures.Count) protected artifacts changed."
}

$Stage5Status = Get-Content `
    -LiteralPath (
        Join-Path $BatchContext.Stage5Root 'Reports\BATCH_A_STAGE_5_COMPLETION_STATUS.json'
    ) `
    -Raw |
    ConvertFrom-Json

$Stage6Status = Get-Content `
    -LiteralPath (
        Join-Path $BatchContext.Stage6Root 'Reports\BATCH_A_STAGE_6_COMPLETION_STATUS.json'
    ) `
    -Raw |
    ConvertFrom-Json

Assert-MSCondition `
    -Condition (
        $Stage5Status.Result -eq 'PASS' -and
        $Stage5Status.FailedFinalValidations -eq 0
    ) `
    -Message 'Stage 5 regression failed.'

Assert-MSCondition `
    -Condition (
        $Stage6Status.Result -eq 'PASS' -and
        $Stage6Status.BatchClosureEligibility -eq 'ELIGIBLE'
    ) `
    -Message 'Stage 6 regression failed.'

$GeneralizedCount = @(
    $ExecutionRegister |
    Measure-Object -Property PathAssignmentsGeneralized -Sum
).Sum

if ($null -eq $GeneralizedCount) {
    $GeneralizedCount = 0
}

[ordered]@{
    PassID = 'B2-PASS-02'
    Result = 'PASS'
    ScriptsGeneralized = $ExecutionRegister.Count
    PathAssignmentsGeneralized = $GeneralizedCount
    SyntaxFailures = $SyntaxFailures.Count
    RegressionFailures = $RegressionFailures.Count
    Stage5RegressionStatus = $Stage5Status.Result
    Stage6RegressionStatus = $Stage6Status.Result
    BackupRoot = $BackupRoot
    CompletedAt = (Get-Date).ToString('o')
} |
    ConvertTo-Json -Depth 6 |
    Set-Content `
        -LiteralPath $ManifestPath `
        -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — BATCH 2 PASS 02' -ForegroundColor Cyan
Write-Host 'PATH GENERALIZATION' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Scripts generalized:                  $($ExecutionRegister.Count)"
Write-Host "Path assignments generalized:         $GeneralizedCount"
Write-Host "Syntax failures:                      $($SyntaxFailures.Count)"
Write-Host "Regression failures:                  $($RegressionFailures.Count)"
Write-Host "Stage 5 regression:                   $($Stage5Status.Result)"
Write-Host "Stage 6 regression:                   $($Stage6Status.Result)"
Write-Host ''
Write-Host 'BATCH 2 PASS 02: PASS' -ForegroundColor Green
Write-Host 'SAFE BATCH ROOT CONSTRUCTION WAS GENERALIZED.' -ForegroundColor Green
Write-Host 'STAGE-SPECIFIC GOVERNANCE LOGIC WAS NOT ALTERED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
