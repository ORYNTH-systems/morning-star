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
    'engineering\reports\batch-2\B2-PASS-04'

$BackupRoot = Join-Path `
    $RepositoryRoot `
    'engineering\backups\batch-2\B2-PASS-04'

$ManifestPath = Join-Path `
    $RepositoryRoot `
    'engineering\manifests\batch-2\B2-PASS-04_MANIFEST.json'

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

$ValidationInventory = @(
    foreach ($Script in $Scripts) {
        $Parse = Get-ParseResult -Path $Script.FullName

        if ($Parse.Errors.Count -gt 0) {
            throw "Preexisting syntax error: $($Script.FullName)"
        }

        foreach ($Function in $Parse.Functions) {
            if ($Function.Name -match 'Validate|Verification|Invariant') {
                $NormalizedText = (
                    $Function.Extent.Text -replace '\s+', ' '
                ).Trim()

                [pscustomobject][ordered]@{
                    ScriptPath = $Script.FullName
                    RelativePath = $Script.FullName.
                        Substring($RepositoryRoot.Length).
                        TrimStart('\')
                    FunctionName = $Function.Name
                    NormalizedText = $NormalizedText
                    FunctionLength = $Function.Extent.Text.Length
                    FunctionSHA256 = Get-MSDeterministicHash `
                        -InputText $NormalizedText `
                        -Length 64
                }
            }
        }
    }
)

$InventoryPath = Join-Path `
    $ReportRoot `
    'B2_PASS04_VALIDATION_FUNCTION_INVENTORY.csv'

$ValidationInventory |
    Export-Csv `
        -LiteralPath $InventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$DuplicateGroups = @(
    $ValidationInventory |
    Group-Object FunctionSHA256 |
    Where-Object Count -gt 1
)

$DuplicateRegister = @(
    foreach ($Group in $DuplicateGroups) {
        foreach ($Item in $Group.Group) {
            [pscustomobject][ordered]@{
                FunctionSHA256 = $Group.Name
                DuplicateCount = $Group.Count
                FunctionName = $Item.FunctionName
                ScriptPath = $Item.ScriptPath
                RelativePath = $Item.RelativePath
                Disposition = 'REVIEWED_DUPLICATE'
            }
        }
    }
)

$DuplicatePath = Join-Path `
    $ReportRoot `
    'B2_PASS04_DUPLICATE_VALIDATION_REGISTER.csv'

$DuplicateRegister |
    Export-Csv `
        -LiteralPath $DuplicatePath `
        -NoTypeInformation `
        -Encoding UTF8

# No automatic migration occurs unless exact duplicate validation functions exist.
$ExecutionRegister = [System.Collections.Generic.List[object]]::new()

if ($DuplicateGroups.Count -gt 0) {
    foreach ($Group in $DuplicateGroups) {
        $CanonicalFunction = $Group.Group |
            Sort-Object RelativePath |
            Select-Object -First 1

        foreach ($DuplicateFunction in @(
            $Group.Group |
            Where-Object ScriptPath -ne $CanonicalFunction.ScriptPath
        )) {
            $ExecutionRegister.Add(
                [pscustomobject][ordered]@{
                    FunctionName = $DuplicateFunction.FunctionName
                    SourceScript = $DuplicateFunction.ScriptPath
                    CanonicalSourceScript = $CanonicalFunction.ScriptPath
                    FunctionSHA256 = $Group.Name
                    MigrationStatus = 'DEFERRED_FOR_EXPLICIT_MODULE_ADMISSION'
                    Reason = 'Exact duplicate identified, but automatic removal is prohibited without explicit module-admission mapping.'
                    GovernanceLogicChanged = $false
                    RecordedAt = (Get-Date).ToString('o')
                }
            )
        }
    }
}

$ExecutionPath = Join-Path `
    $ReportRoot `
    'B2_PASS04_EXECUTION_REGISTER.csv'

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

$BatchContext = Get-MSBatchContext `
    -RepositoryRoot $RepositoryRoot `
    -BatchID 'BATCH_A'

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
    -Message 'Stage 5 regression failed.' `
    -InvariantID 'MS-B2-P4-STAGE5'

Assert-MSCondition `
    -Condition (
        $Stage6Status.Result -eq 'PASS' -and
        $Stage6Status.BatchClosureEligibility -eq 'ELIGIBLE'
    ) `
    -Message 'Stage 6 regression failed.' `
    -InvariantID 'MS-B2-P4-STAGE6'

[ordered]@{
    PassID = 'B2-PASS-04'
    Result = 'PASS'
    ValidationFunctionsInventoried = $ValidationInventory.Count
    ExactDuplicateGroups = $DuplicateGroups.Count
    DuplicateFunctionsRegistered = $DuplicateRegister.Count
    AutomaticMigrationsPerformed = 0
    DeferredModuleAdmissions = $ExecutionRegister.Count
    SyntaxFailures = $SyntaxFailures.Count
    Stage5RegressionStatus = $Stage5Status.Result
    Stage6RegressionStatus = $Stage6Status.Result
    GovernanceLogicChanged = $false
    CompletedAt = (Get-Date).ToString('o')
} |
    ConvertTo-Json -Depth 6 |
    Set-Content `
        -LiteralPath $ManifestPath `
        -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — BATCH 2 PASS 04' -ForegroundColor Cyan
Write-Host 'VALIDATION CONSOLIDATION' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Validation functions inventoried:      $($ValidationInventory.Count)"
Write-Host "Exact duplicate groups:                $($DuplicateGroups.Count)"
Write-Host "Duplicate functions registered:        $($DuplicateRegister.Count)"
Write-Host "Automatic migrations performed:        0"
Write-Host "Deferred module admissions:            $($ExecutionRegister.Count)"
Write-Host "Syntax failures:                       $($SyntaxFailures.Count)"
Write-Host "Stage 5 regression:                    $($Stage5Status.Result)"
Write-Host "Stage 6 regression:                    $($Stage6Status.Result)"
Write-Host "Governance logic changed:              False"
Write-Host ''
Write-Host 'BATCH 2 PASS 04: PASS' -ForegroundColor Green
Write-Host 'VALIDATION HELPERS WERE INVENTORIED AND DUPLICATES REGISTERED.' -ForegroundColor Green
Write-Host 'NO STAGE-SPECIFIC VALIDATION SEMANTICS WERE AUTOMATICALLY ALTERED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
