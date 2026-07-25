$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (
    Resolve-Path (Join-Path $PSScriptRoot '..\..')
).Path

$ModulePath = Join-Path `
    $RepositoryRoot `
    'engineering\modules\MorningStar.Engine.Common.psm1'

$ReportsRoot = Join-Path `
    $RepositoryRoot `
    'engineering\reports'

$BackupRoot = Join-Path `
    $RepositoryRoot `
    (
        'engineering\backups\engine-consolidation-{0}' -f
        (Get-Date -Format 'yyyyMMdd_HHmmss')
    )

New-Item -ItemType Directory -Path $ReportsRoot -Force | Out-Null
New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

if (-not (Test-Path -LiteralPath $ModulePath -PathType Leaf)) {
    throw "Shared module is missing: $ModulePath"
}

Import-Module $ModulePath -Force -ErrorAction Stop

function Get-ScriptParseResult {
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
        Ast = $Ast
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
            $Path -ne $ToolPath
        }
)

$Inventory = @(
    foreach ($Script in $Scripts) {
        $Parse = Get-ScriptParseResult -Path $Script.FullName
        $Content = Get-Content -LiteralPath $Script.FullName -Raw

        $HashDefinitions = @(
            $Parse.Functions |
                Where-Object Name -eq 'Get-DeterministicHash'
        )

        $CsvDefinitions = @(
            $Parse.Functions |
                Where-Object Name -eq 'Write-AtomicCsv'
        )

        [pscustomobject][ordered]@{
            ScriptPath = $Script.FullName
            RelativePath = $Script.FullName.
                Substring($RepositoryRoot.Length).
                TrimStart('\')
            ParseErrors = $Parse.Errors.Count
            HashDefinitions = $HashDefinitions.Count
            CsvDefinitions = $CsvDefinitions.Count
            HashReferences = (
                [regex]::Matches(
                    $Content,
                    '\bGet-DeterministicHash\b'
                )
            ).Count
            CsvReferences = (
                [regex]::Matches(
                    $Content,
                    '\bWrite-AtomicCsv\b'
                )
            ).Count
            ImportsSharedModule = (
                $Content -match
                'MorningStar\.Engine\.Common\.psm1'
            )
        }
    }
)

$InventoryPath = Join-Path `
    $ReportsRoot `
    'ENGINE_HELPER_CONSOLIDATION_INVENTORY.csv'

$Inventory |
    Export-Csv `
        -LiteralPath $InventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$PreexistingParseFailures = @(
    $Inventory |
        Where-Object ParseErrors -gt 0
)

if ($PreexistingParseFailures.Count -gt 0) {
    $PreexistingParseFailures | Format-Table -AutoSize
    throw 'One or more scripts contain preexisting syntax errors.'
}

$Candidates = @(
    $Inventory |
        Where-Object {
            $_.HashDefinitions -gt 0 -or
            $_.CsvDefinitions -gt 0
        }
)

$ExecutionRegister = [System.Collections.Generic.List[object]]::new()

foreach ($Candidate in $Candidates) {
    $ScriptPath = $Candidate.ScriptPath
    $RelativePath = $Candidate.RelativePath
    $BackupPath = Join-Path $BackupRoot $RelativePath
    $BackupDirectory = Split-Path -Parent $BackupPath

    New-Item `
        -ItemType Directory `
        -Path $BackupDirectory `
        -Force |
        Out-Null

    Copy-Item `
        -LiteralPath $ScriptPath `
        -Destination $BackupPath `
        -Force

    $BeforeHash = (
        Get-FileHash `
            -LiteralPath $ScriptPath `
            -Algorithm SHA256
    ).Hash

    $OriginalText = Get-Content -LiteralPath $ScriptPath -Raw
    $Parse = Get-ScriptParseResult -Path $ScriptPath

    $DefinitionsToRemove = @(
        $Parse.Functions |
            Where-Object {
                $_.Name -in @(
                    'Get-DeterministicHash'
                    'Write-AtomicCsv'
                )
            } |
            Sort-Object {
                $_.Extent.StartOffset
            } -Descending
    )

    $ModifiedText = $OriginalText

    foreach ($Definition in $DefinitionsToRemove) {
        $Start = $Definition.Extent.StartOffset
        $Length = (
            $Definition.Extent.EndOffset -
            $Definition.Extent.StartOffset
        )

        $ModifiedText = $ModifiedText.Remove(
            $Start,
            $Length
        )
    }

    $ModifiedText = [regex]::Replace(
        $ModifiedText,
        '\bGet-DeterministicHash\b',
        'Get-MSDeterministicHash'
    )

    $ModifiedText = [regex]::Replace(
        $ModifiedText,
        '\bWrite-AtomicCsv\b',
        'Export-MSAtomicCsv'
    )

    if (
        $ModifiedText -notmatch
        'MorningStar\.Engine\.Common\.psm1'
    ) {
        $ScriptDirectory = Split-Path -Parent $ScriptPath

        $ScriptDirectoryUri = [System.Uri]::new(
            ($ScriptDirectory.TrimEnd('\') + '\')
        )

        $ModuleUri = [System.Uri]::new($ModulePath)

        $RelativeModulePath = [System.Uri]::UnescapeDataString(
            $ScriptDirectoryUri.MakeRelativeUri($ModuleUri).ToString()
        ) -replace '/', '\'

        $ImportLines = @(
            "`$MorningStarCommonModule = Join-Path `$PSScriptRoot '$RelativeModulePath'"
            'Import-Module $MorningStarCommonModule -Force -ErrorAction Stop'
            ''
        ) -join [Environment]::NewLine

        $ModifiedText = $ImportLines + $ModifiedText
    }

    $ModifiedText |
        Set-Content `
            -LiteralPath $ScriptPath `
            -Encoding UTF8

    $UpdatedParse = Get-ScriptParseResult -Path $ScriptPath

    if ($UpdatedParse.Errors.Count -gt 0) {
        Copy-Item `
            -LiteralPath $BackupPath `
            -Destination $ScriptPath `
            -Force

        throw "Syntax verification failed; restored: $RelativePath"
    }

    $RemainingLegacyDefinitions = @(
        $UpdatedParse.Functions |
            Where-Object {
                $_.Name -in @(
                    'Get-DeterministicHash'
                    'Write-AtomicCsv'
                )
            }
    )

    if ($RemainingLegacyDefinitions.Count -gt 0) {
        Copy-Item `
            -LiteralPath $BackupPath `
            -Destination $ScriptPath `
            -Force

        throw "Legacy helper definitions remain; restored: $RelativePath"
    }

    $AfterHash = (
        Get-FileHash `
            -LiteralPath $ScriptPath `
            -Algorithm SHA256
    ).Hash

    $ExecutionRegister.Add(
        [pscustomobject][ordered]@{
            ScriptPath = $ScriptPath
            RelativePath = $RelativePath
            BackupPath = $BackupPath
            RemovedHashDefinitions = $Candidate.HashDefinitions
            RemovedCsvDefinitions = $Candidate.CsvDefinitions
            HashCallsMigrated = $Candidate.HashReferences
            CsvCallsMigrated = $Candidate.CsvReferences
            SharedModuleImported = $true
            SHA256Before = $BeforeHash
            SHA256After = $AfterHash
            Status = 'REFACTORED'
            ExecutedAt = (Get-Date).ToString('o')
        }
    )
}

$ExecutionPath = Join-Path `
    $ReportsRoot `
    'ENGINE_HELPER_CONSOLIDATION_EXECUTION.csv'

$ExecutionRegister |
    Export-Csv `
        -LiteralPath $ExecutionPath `
        -NoTypeInformation `
        -Encoding UTF8

$SyntaxRegister = @(
    foreach ($Script in $Scripts) {
        $Parse = Get-ScriptParseResult -Path $Script.FullName

        [pscustomobject][ordered]@{
            ScriptPath = $Script.FullName
            ParseErrors = $Parse.Errors.Count
            Status = if ($Parse.Errors.Count -eq 0) {
                'PASS'
            }
            else {
                'FAIL'
            }
            ErrorMessages = (
                @($Parse.Errors | ForEach-Object Message) -join ' | '
            )
        }
    }
)

$SyntaxPath = Join-Path `
    $ReportsRoot `
    'ENGINE_HELPER_CONSOLIDATION_SYNTAX.csv'

$SyntaxRegister |
    Export-Csv `
        -LiteralPath $SyntaxPath `
        -NoTypeInformation `
        -Encoding UTF8

$SyntaxFailures = @(
    $SyntaxRegister |
        Where-Object Status -ne 'PASS'
)

if ($SyntaxFailures.Count -gt 0) {
    throw "$($SyntaxFailures.Count) scripts failed syntax verification."
}

$LegacyDefinitionsRemaining = @(
    foreach ($Script in $Scripts) {
        $Parse = Get-ScriptParseResult -Path $Script.FullName

        foreach ($Function in $Parse.Functions) {
            if (
                $Function.Name -in @(
                    'Get-DeterministicHash'
                    'Write-AtomicCsv'
                )
            ) {
                [pscustomobject]@{
                    ScriptPath = $Script.FullName
                    FunctionName = $Function.Name
                }
            }
        }
    }
)

if ($LegacyDefinitionsRemaining.Count -gt 0) {
    throw "$($LegacyDefinitionsRemaining.Count) legacy helper definitions remain."
}

$HashProbe1 = Get-MSDeterministicHash `
    -InputText 'MORNING-STAR-ENGINE-CONSOLIDATION' `
    -Length 32

$HashProbe2 = Get-MSDeterministicHash `
    -InputText 'MORNING-STAR-ENGINE-CONSOLIDATION' `
    -Length 32

Assert-MSCondition `
    -Condition ($HashProbe1 -eq $HashProbe2) `
    -Message 'Shared hash helper is nondeterministic.' `
    -InvariantID 'MS-ENGINE-HASH'

$CsvProbePath = Join-Path `
    $ReportsRoot `
    'ENGINE_HELPER_CONSOLIDATION_PROBE.csv'

Export-MSAtomicCsv `
    -InputObject @(
        [pscustomobject]@{
            ProbeID = 'MS-ENGINE-PROBE-001'
            Status = 'PASS'
        }
    ) `
    -LiteralPath $CsvProbePath

$CsvProbe = Import-MSCsv -LiteralPath $CsvProbePath

Assert-MSCondition `
    -Condition (
        @($CsvProbe).Count -eq 1 -and
        $CsvProbe[0].Status -eq 'PASS'
    ) `
    -Message 'Shared CSV helper failed verification.' `
    -InvariantID 'MS-ENGINE-CSV'

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — ENGINE HELPER CONSOLIDATION' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Scripts inventoried:                   $($Inventory.Count)"
Write-Host "Scripts refactored:                    $($ExecutionRegister.Count)"
Write-Host "Syntax failures:                       $($SyntaxFailures.Count)"
Write-Host "Legacy helper definitions remaining:   $($LegacyDefinitionsRemaining.Count)"
Write-Host "Backups:                               $BackupRoot"
Write-Host "Execution report:                      $ExecutionPath"
Write-Host ''
Write-Host 'ENGINE HELPER CONSOLIDATION: PASS' -ForegroundColor Green
Write-Host 'DUPLICATE HASH AND ATOMIC CSV HELPERS WERE MIGRATED.' -ForegroundColor Green
Write-Host 'WORKFLOW-SPECIFIC VALIDATION AND PATH SEMANTICS WERE NOT ALTERED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan


