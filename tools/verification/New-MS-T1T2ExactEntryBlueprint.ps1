[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$VerificationRoot = Join-Path $RepositoryRoot 'volumes\VOLUME_I_FOUNDATION\verification'
$ExecutionRoot = Join-Path $VerificationRoot 'execution'
$ReadinessRoot = Join-Path $VerificationRoot 'readiness'
$OutputPath = Join-Path $ReadinessRoot 'MS-T1_T2_EXACT_ENTRY_BLUEPRINT.md'

$Trials = @(
    [pscustomobject]@{
        TheoremID = 'MS-T1'
        TrialName = 'MS-T1_GOVERNED_INITIATION_TRIAL'
        WorkspaceName = 'MS-T1_CONTROLLED_EXECUTION'
        Files = @(
            [pscustomobject]@{ FileName = 'TRIAL_CASES.csv'; Folder = '01_INPUT' },
            [pscustomobject]@{ FileName = 'OBSERVER_RESPONSES.csv'; Folder = '02_EVIDENCE' },
            [pscustomobject]@{ FileName = 'SEMANTIC_ASSESSMENTS.csv'; Folder = '03_ASSESSMENT' }
        )
    },
    [pscustomobject]@{
        TheoremID = 'MS-T2'
        TrialName = 'MS-T2_DEPENDENCY_PROPAGATION_TRIAL'
        WorkspaceName = 'MS-T2_CONTROLLED_EXECUTION'
        Files = @(
            [pscustomobject]@{ FileName = 'DEPENDENCY_CHAINS.csv'; Folder = '01_INPUT' },
            [pscustomobject]@{ FileName = 'TRIAL_CASES.csv'; Folder = '01_INPUT' },
            [pscustomobject]@{ FileName = 'PROPAGATION_EVENTS.csv'; Folder = '02_EVIDENCE' },
            [pscustomobject]@{ FileName = 'DOWNSTREAM_ASSESSMENTS.csv'; Folder = '03_ASSESSMENT' }
        )
    }
)

function Convert-ToMarkdownValue {
    param(
        [AllowNull()]
        [object]$Value
    )

    $Text = [string]$Value

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return '**MISSING**'
    }

    return $Text.Replace('|', '\|')
}

function Get-CsvHeader {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $Header = Get-Content -LiteralPath $Path -TotalCount 1

    if ([string]::IsNullOrWhiteSpace($Header)) {
        throw "CSV header missing: $Path"
    }

    return $Header
}

New-Item -ItemType Directory -Force -Path $ReadinessRoot | Out-Null

if (Test-Path -LiteralPath $OutputPath) {
    Remove-Item -LiteralPath $OutputPath -Force
}

$Blueprint = [System.Collections.Generic.List[string]]::new()

[void]$Blueprint.Add('# MS-T1 and MS-T2 Exact Entry Blueprint')
[void]$Blueprint.Add('')
[void]$Blueprint.Add(('**Generated:** {0}' -f (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')))
[void]$Blueprint.Add('')
[void]$Blueprint.Add('This blueprint records exact schemas, current values, missing fields, entry authorities, and governing source documents.')
[void]$Blueprint.Add('')

foreach ($Trial in $Trials) {

    $TrialRoot = Join-Path $VerificationRoot $Trial.TrialName
    $WorkspaceRoot = Join-Path $ExecutionRoot $Trial.WorkspaceName
    $PacketRoot = Join-Path $WorkspaceRoot '00_COLLECTION_PACKET'

    foreach ($RequiredDirectory in @($TrialRoot, $WorkspaceRoot, $PacketRoot)) {
        if (-not (Test-Path -LiteralPath $RequiredDirectory -PathType Container)) {
            throw "Required directory missing: $RequiredDirectory"
        }
    }

    [void]$Blueprint.Add(('## {0}' -f $Trial.TheoremID))
    [void]$Blueprint.Add('')
    [void]$Blueprint.Add(('**Trial:** `{0}`' -f $Trial.TrialName))
    [void]$Blueprint.Add('')

    Write-Host ''
    Write-Host '==============================================================' -ForegroundColor Cyan
    Write-Host ("{0} EXACT ENTRY BLUEPRINT" -f $Trial.TheoremID) -ForegroundColor Yellow
    Write-Host '==============================================================' -ForegroundColor Cyan

    foreach ($FileDefinition in $Trial.Files) {

        $FileName = $FileDefinition.FileName
        $Stem = [System.IO.Path]::GetFileNameWithoutExtension($FileName)

        $WorkingPath = Join-Path `
            (Join-Path $WorkspaceRoot $FileDefinition.Folder) `
            $FileName

        $FieldGuidePath = Join-Path $PacketRoot "$Stem.FIELD_GUIDE.csv"
        $MissingPath = Join-Path $PacketRoot "$Stem.MISSING_VALUES.csv"
        $CollectionCopyPath = Join-Path $PacketRoot "$Stem.COLLECTION_COPY.csv"

        if (-not (Test-Path -LiteralPath $WorkingPath -PathType Leaf)) {
            throw "Working CSV missing: $WorkingPath"
        }

        foreach ($PacketFile in @(
            $FieldGuidePath,
            $MissingPath,
            $CollectionCopyPath
        )) {
            if (-not (Test-Path -LiteralPath $PacketFile -PathType Leaf)) {
                throw "Collection packet artifact missing: $PacketFile"
            }
        }

        $Header = Get-CsvHeader -Path $WorkingPath
        $Rows = @(Import-Csv -LiteralPath $WorkingPath)
        $FieldGuide = @(Import-Csv -LiteralPath $FieldGuidePath)
        $Missing = @(Import-Csv -LiteralPath $MissingPath)

        Write-Host ''
        Write-Host ("--------------- {0} ---------------" -f $FileName) -ForegroundColor Green
        Write-Host ("Path: {0}" -f $WorkingPath) -ForegroundColor DarkGray
        Write-Host ("Rows: {0}" -f $Rows.Count) -ForegroundColor DarkGray
        Write-Host ("Missing entries: {0}" -f $Missing.Count) -ForegroundColor Yellow

        [void]$Blueprint.Add(('### {0}' -f $FileName))
        [void]$Blueprint.Add('')
        [void]$Blueprint.Add(('**Working path:** `{0}`' -f $WorkingPath))
        [void]$Blueprint.Add('')
        [void]$Blueprint.Add(('**Collection copy:** `{0}`' -f $CollectionCopyPath))
        [void]$Blueprint.Add('')
        [void]$Blueprint.Add(('**Current row count:** {0}' -f $Rows.Count))
        [void]$Blueprint.Add('')

        [void]$Blueprint.Add('#### Schema')
        [void]$Blueprint.Add('')
        [void]$Blueprint.Add('```text')
        [void]$Blueprint.Add($Header)
        [void]$Blueprint.Add('```')
        [void]$Blueprint.Add('')

        [void]$Blueprint.Add('#### Current Rows')
        [void]$Blueprint.Add('')

        if ($Rows.Count -eq 0) {
            [void]$Blueprint.Add('No rows currently exist. Governed execution must create at least one admissible row.')
            [void]$Blueprint.Add('')
        }
        else {
            for ($RowIndex = 0; $RowIndex -lt $Rows.Count; $RowIndex++) {

                [void]$Blueprint.Add(('##### CSV Row {0}' -f ($RowIndex + 2)))
                [void]$Blueprint.Add('')
                [void]$Blueprint.Add('| Field | Current Value |')
                [void]$Blueprint.Add('|---|---|')

                foreach ($Property in $Rows[$RowIndex].PSObject.Properties) {
                    $MarkdownValue = Convert-ToMarkdownValue $Property.Value
                    [void]$Blueprint.Add("| $($Property.Name) | $MarkdownValue |")
                }

                [void]$Blueprint.Add('')
            }
        }

        [void]$Blueprint.Add('#### Field Authorities')
        [void]$Blueprint.Add('')
        [void]$Blueprint.Add('| # | Field | Identity | Authority | Instruction |')
        [void]$Blueprint.Add('|---:|---|---|---|---|')

        foreach ($Field in $FieldGuide | Sort-Object { [int]$_.Sequence }) {
            $MarkdownInstruction = Convert-ToMarkdownValue $Field.Instruction
            [void]$Blueprint.Add("| $($Field.Sequence) | $($Field.FieldName) | $($Field.IdentityField) | $($Field.EntryAuthority) | $MarkdownInstruction |")
        }

        [void]$Blueprint.Add('')
        [void]$Blueprint.Add('#### Missing-Value Worklist')
        [void]$Blueprint.Add('')

        if ($Missing.Count -eq 0) {
            [void]$Blueprint.Add('No missing values identified.')
        }
        else {
            [void]$Blueprint.Add('| CSV Row | Identity | Missing Field | Authority | Instruction |')
            [void]$Blueprint.Add('|---|---|---|---|---|')

            foreach ($Item in $Missing) {
                $MarkdownIdentity = Convert-ToMarkdownValue $Item.RecordIdentity
                $MarkdownInstruction = Convert-ToMarkdownValue $Item.Instruction
                [void]$Blueprint.Add("| $($Item.CsvRow) | $MarkdownIdentity | $($Item.MissingField) | $($Item.EntryAuthority) | $MarkdownInstruction |")
            }
        }

        [void]$Blueprint.Add('')
    }

    [void]$Blueprint.Add('### Governing Source Documents')
    [void]$Blueprint.Add('')

    foreach ($DocumentName in @(
        'DESIGN.md',
        'PROCEDURE.md',
        'SCORING_MODEL.md',
        'DATA_DICTIONARY.md'
    )) {
        $DocumentPath = Join-Path $TrialRoot $DocumentName

        if (-not (Test-Path -LiteralPath $DocumentPath -PathType Leaf)) {
            throw "Governing document missing: $DocumentPath"
        }

        [void]$Blueprint.Add(('#### {0}' -f $DocumentName))
        [void]$Blueprint.Add('')
        [void]$Blueprint.Add('```markdown')

        foreach ($Line in Get-Content -LiteralPath $DocumentPath) {
            [void]$Blueprint.Add($Line)
        }

        [void]$Blueprint.Add('```')
        [void]$Blueprint.Add('')
    }
}

[void]$Blueprint.Add('## Governing Execution Boundary')
[void]$Blueprint.Add('')
[void]$Blueprint.Add('Case and dependency definitions may be completed only from governed design sources. Observer responses, propagation events, semantic assessments, and downstream assessments require actual controlled execution evidence and may not be inferred merely to close a theorem.')
[void]$Blueprint.Add('')

$Blueprint |
Set-Content `
    -LiteralPath $OutputPath `
    -Encoding UTF8

$GeneratedContent = Get-Content -LiteralPath $OutputPath -Raw

if ($GeneratedContent -match '\|Oliver Paynter\|') {
    throw 'Blueprint validation failed: unrelated Git-log content detected.'
}

if ($GeneratedContent -notmatch '^# MS-T1 and MS-T2 Exact Entry Blueprint') {
    throw 'Blueprint validation failed: expected heading missing.'
}

foreach ($RequiredHeading in @(
    '## MS-T1',
    '## MS-T2',
    '### Governing Source Documents',
    '## Governing Execution Boundary'
)) {
    if ($GeneratedContent -notmatch [regex]::Escape($RequiredHeading)) {
        throw "Blueprint validation failed: missing heading $RequiredHeading"
    }
}

Write-Host ''
Write-Host '==============================================================' -ForegroundColor Cyan
Write-Host 'EXACT ENTRY BLUEPRINT CORRECTED AND VALIDATED' -ForegroundColor Yellow
Write-Host '==============================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host ("Blueprint: {0}" -f $OutputPath) -ForegroundColor Green
Write-Host ("Lines: {0}" -f (Get-Content -LiteralPath $OutputPath).Count) -ForegroundColor Green
Write-Host ''

Get-Content -LiteralPath $OutputPath |
Select-Object -First 120






