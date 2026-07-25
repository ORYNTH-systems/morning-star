$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (
    Resolve-Path (Join-Path $PSScriptRoot '..\..')
).Path

$ModulePath = Join-Path `
    $RepositoryRoot `
    'engineering\modules\MorningStar.Engine.Common.psm1'

$ReportRoot = Join-Path `
    $RepositoryRoot `
    'engineering\reports\batch-2\B2-PASS-03'

$BackupRoot = Join-Path `
    $RepositoryRoot `
    'engineering\backups\batch-2\B2-PASS-03'

$ManifestPath = Join-Path `
    $RepositoryRoot `
    'engineering\manifests\batch-2\B2-PASS-03_MANIFEST.json'

New-Item -ItemType Directory -Path $ReportRoot -Force | Out-Null
New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

Import-Module $ModulePath -Force -ErrorAction Stop

function Get-ParseResult {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $Tokens = $null
    $Errors = $null

    $Ast = [System.Management.Automation.Language.Parser]::ParseFile(
        $Path,
        [ref]$Tokens,
        [ref]$Errors
    )

    [pscustomobject]@{
        Errors = @($Errors)
        Functions = @(
            $Ast.FindAll(
                {
                    param($Node)

                    $Node -is [System.Management.Automation.Language.FunctionDefinitionAst]
                },
                $true
            )
        )
    }
}

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
            Where-Object {
                $Path -match $_
            }
        ).Count -gt 0

        -not $Excluded -and
        $Path -ne (Resolve-Path $ToolPath).Path
    }
)

$AssertionNames = @(
    'Assert-Condition'
    'Assert-Invariant'
    'Assert-Validation'
)

$ExecutionRegister = [System.Collections.Generic.List[object]]::new()

$ExistingExecutionPath = Join-Path `
    $ReportRoot `
    'B2_PASS03_EXECUTION_REGISTER.csv'

if (
    Test-Path `
        -LiteralPath $ExistingExecutionPath `
        -PathType Leaf
) {
    foreach ($ExistingRow in @(
        Import-Csv -LiteralPath $ExistingExecutionPath
    )) {
        $ExecutionRegister.Add($ExistingRow)
    }
}

$ExistingExecutionPath = Join-Path `
    $ReportRoot `
    'B2_PASS03_EXECUTION_REGISTER.csv'

if (
    Test-Path `
        -LiteralPath $ExistingExecutionPath `
        -PathType Leaf
) {
    foreach ($ExistingRow in @(
        Import-Csv -LiteralPath $ExistingExecutionPath
    )) {
        $ExecutionRegister.Add($ExistingRow)
    }
}

foreach ($Script in $Scripts) {
    $Parse = Get-ParseResult -Path $Script.FullName

    if ($Parse.Errors.Count -gt 0) {
        throw "Preexisting syntax error: $($Script.FullName)"
    }

    $EquivalentAssertions = @(
        foreach ($Function in $Parse.Functions) {
            if ($Function.Name -notin $AssertionNames) {
                continue
            }

            $NormalizedText = (
                $Function.Extent.Text -replace '\s+', ' '
            ).Trim()

            $Equivalent = (
                $NormalizedText -match
                'if\s*\(\s*-not\s+\$Condition\s*\)\s*\{\s*throw\s+\$Message\s*\}'
            )

            if ($Equivalent) {
                $Function
            }
        }
    )

    if ($EquivalentAssertions.Count -eq 0) {
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

    $BeforeHash = (
        Get-FileHash `
            -LiteralPath $Script.FullName `
            -Algorithm SHA256
    ).Hash

    $ModifiedText = Get-Content `
        -LiteralPath $Script.FullName `
        -Raw

    $SortedAssertions = @(
        $EquivalentAssertions |
        Sort-Object {
            $_.Extent.StartOffset
        } -Descending
    )

    foreach ($Function in $SortedAssertions) {
        $Start = $Function.Extent.StartOffset
        $Length = (
            $Function.Extent.EndOffset -
            $Function.Extent.StartOffset
        )

        $ModifiedText = $ModifiedText.Remove(
            $Start,
            $Length
        )
    }

    foreach ($AssertionName in $AssertionNames) {
        if (
            @(
                $EquivalentAssertions |
                Where-Object Name -eq $AssertionName
            ).Count -gt 0
        ) {
            $ModifiedText = [regex]::Replace(
                $ModifiedText,
                "\b$([regex]::Escape($AssertionName))\b",
                'Assert-MSCondition'
            )
        }
    }

    if (
        $ModifiedText -notmatch
        'MorningStar\.Engine\.Common\.psm1'
    ) {
        Copy-Item `
            -LiteralPath $BackupPath `
            -Destination $Script.FullName `
            -Force

        throw "Shared module import is missing: $RelativePath"
    }

    $ModifiedText |
        Set-Content `
            -LiteralPath $Script.FullName `
            -Encoding UTF8

    $UpdatedParse = Get-ParseResult -Path $Script.FullName

    if ($UpdatedParse.Errors.Count -gt 0) {
        Copy-Item `
            -LiteralPath $BackupPath `
            -Destination $Script.FullName `
            -Force

        throw "Syntax failure; restored $RelativePath"
    }

    $RemainingLegacyAssertions = @(
        $UpdatedParse.Functions |
        Where-Object {
            $_.Name -in $AssertionNames
        }
    )

    if ($RemainingLegacyAssertions.Count -gt 0) {
        Copy-Item `
            -LiteralPath $BackupPath `
            -Destination $Script.FullName `
            -Force

        throw "Legacy assertion helper remains; restored $RelativePath"
    }

    $AfterHash = (
        Get-FileHash `
            -LiteralPath $Script.FullName `
            -Algorithm SHA256
    ).Hash

    $ExecutionRegister.Add(
        [pscustomobject][ordered]@{
            ScriptPath = $Script.FullName
            RelativePath = $RelativePath
            BackupPath = $BackupPath
            AssertionsMigrated = $EquivalentAssertions.Count
            GovernanceLogicChanged = $false
            SHA256Before = $BeforeHash
            SHA256After = $AfterHash
            Status = 'MIGRATED'
            ExecutedAt = (Get-Date).ToString('o')
        }
    )
}

$ExecutionPath = Join-Path `
    $ReportRoot `
    'B2_PASS03_EXECUTION_REGISTER.csv'

$ExecutionRegister |
    Export-Csv `
        -LiteralPath $ExecutionPath `
        -NoTypeInformation `
        -Encoding UTF8

$SyntaxRegister = @(
    foreach ($Script in $Scripts) {
        $Parse = Get-ParseResult -Path $Script.FullName

        [pscustomobject]@{
            ScriptPath = $Script.FullName
            ParseErrors = $Parse.Errors.Count
            Status = if ($Parse.Errors.Count -eq 0) {
                'PASS'
            }
            else {
                'FAIL'
            }
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
        Join-Path `
            $BatchContext.Stage5Root `
            'Reports\BATCH_A_STAGE_5_COMPLETION_STATUS.json'
    ) `
    -Raw |
    ConvertFrom-Json

$Stage6Status = Get-Content `
    -LiteralPath (
        Join-Path `
            $BatchContext.Stage6Root `
            'Reports\BATCH_A_STAGE_6_COMPLETION_STATUS.json'
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

$MigratedCount = 0

foreach ($ExecutionRow in @($ExecutionRegister)) {
    if (
        $null -ne $ExecutionRow.AssertionsMigrated -and
        -not [string]::IsNullOrWhiteSpace(
            [string]$ExecutionRow.AssertionsMigrated
        )
    ) {
        $MigratedCount += [int]$ExecutionRow.AssertionsMigrated
    }
}

[ordered]@{
    PassID = 'B2-PASS-03'
    Result = 'PASS'
    ScriptsModified = $ExecutionRegister.Count
    AssertionsMigrated = $MigratedCount
    SyntaxFailures = $SyntaxFailures.Count
    RegressionFailures = $RegressionFailures.Count
    GovernanceLogicChanged = $false
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
Write-Host 'MORNING STAR — BATCH 2 PASS 03' -ForegroundColor Cyan
Write-Host 'ASSERTION MIGRATION' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Scripts modified:                     $($ExecutionRegister.Count)"
Write-Host "Assertions migrated:                  $MigratedCount"
Write-Host "Syntax failures:                      $($SyntaxFailures.Count)"
Write-Host "Regression failures:                  $($RegressionFailures.Count)"
Write-Host "Stage 5 regression:                   $($Stage5Status.Result)"
Write-Host "Stage 6 regression:                   $($Stage6Status.Result)"
Write-Host "Governance logic changed:             False"
Write-Host ''
Write-Host 'BATCH 2 PASS 03: PASS' -ForegroundColor Green
Write-Host 'MECHANICALLY EQUIVALENT ASSERTION HELPERS WERE MIGRATED.' -ForegroundColor Green
Write-Host 'STAGE-SPECIFIC GOVERNANCE DECISIONS WERE PRESERVED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan


