[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$VerificationRoot = Join-Path $RepositoryRoot 'volumes\VOLUME_I_FOUNDATION\verification'
$OutputRoot       = Join-Path $VerificationRoot 'readiness'

New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null

$TrialDefinitions = @(
    [pscustomobject]@{
        TheoremID = 'MS-T1'
        TrialName = 'MS-T1_GOVERNED_INITIATION_TRIAL'
        RequiredCsvFiles = @(
            'TRIAL_CASES.csv'
            'OBSERVER_RESPONSES.csv'
            'SEMANTIC_ASSESSMENTS.csv'
        )
        ExecutionOrder = @(
            'Complete and validate governed trial cases.'
            'Register observers and entry conditions.'
            'Collect governed and unrestricted observer responses.'
            'Assess each material semantic property.'
            'Adjudicate disputed assessments.'
            'Calculate divergence, failure, and agreement measures.'
            'Assign the theorem disposition from collected evidence.'
        )
    }
    [pscustomobject]@{
        TheoremID = 'MS-T2'
        TrialName = 'MS-T2_DEPENDENCY_PROPAGATION_TRIAL'
        RequiredCsvFiles = @(
            'DEPENDENCY_CHAINS.csv'
            'TRIAL_CASES.csv'
            'PROPAGATION_EVENTS.csv'
            'DOWNSTREAM_ASSESSMENTS.csv'
        )
        ExecutionOrder = @(
            'Complete and validate dependency-chain definitions.'
            'Complete canonical and divergent paired cases.'
            'Execute each dependency-chain condition.'
            'Register every observed propagation event.'
            'Assess downstream semantic effects.'
            'Execute available correction attempts.'
            'Calculate propagation, correction, and residual-divergence measures.'
            'Assign the theorem disposition from collected evidence.'
        )
    }
)

function Get-CellValue {
    param(
        [Parameter(Mandatory)]
        [object]$Row,

        [Parameter(Mandatory)]
        [string]$Column
    )

    $Property = $Row.PSObject.Properties[$Column]

    if ($null -eq $Property) {
        return $null
    }

    return [string]$Property.Value
}

function Test-MeaningfulRow {
    param(
        [Parameter(Mandatory)]
        [object]$Row
    )

    foreach ($Property in $Row.PSObject.Properties) {
        if (-not [string]::IsNullOrWhiteSpace([string]$Property.Value)) {
            return $true
        }
    }

    return $false
}

function Get-CsvAudit {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$TheoremID
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return [pscustomobject]@{
            TheoremID          = $TheoremID
            FileName           = Split-Path $Path -Leaf
            Exists             = $false
            ImportedRowCount   = 0
            MeaningfulRowCount = 0
            CompleteRowCount   = 0
            IncompleteRowCount = 0
            BlankCellCount     = 0
            ColumnCount        = 0
            Columns            = ''
            Readiness           = 'MISSING_FILE'
        }
    }

    $Rows = @(Import-Csv -LiteralPath $Path)

    $Columns = @()

    if ($Rows.Count -gt 0) {
        $Columns = @($Rows[0].PSObject.Properties.Name)
    }
    else {
        $Header = Get-Content -LiteralPath $Path -TotalCount 1
        if (-not [string]::IsNullOrWhiteSpace($Header)) {
            $Columns = @($Header -split ',')
        }
    }

    $MeaningfulRows = @(
        $Rows | Where-Object {
            Test-MeaningfulRow -Row $_
        }
    )

    $CompleteRows = 0
    $IncompleteRows = 0
    $BlankCells = 0

    foreach ($Row in $MeaningfulRows) {
        $RowIsComplete = $true

        foreach ($Column in $Columns) {
            $Value = Get-CellValue -Row $Row -Column $Column

            if ([string]::IsNullOrWhiteSpace($Value)) {
                $BlankCells++
                $RowIsComplete = $false
            }
        }

        if ($RowIsComplete) {
            $CompleteRows++
        }
        else {
            $IncompleteRows++
        }
    }

    $Readiness = if ($MeaningfulRows.Count -eq 0) {
        'EMPTY_TEMPLATE'
    }
    elseif ($IncompleteRows -gt 0) {
        'POPULATED_INCOMPLETE'
    }
    else {
        'POPULATED_COMPLETE'
    }

    [pscustomobject]@{
        TheoremID          = $TheoremID
        FileName           = Split-Path $Path -Leaf
        Exists             = $true
        ImportedRowCount   = $Rows.Count
        MeaningfulRowCount = $MeaningfulRows.Count
        CompleteRowCount   = $CompleteRows
        IncompleteRowCount = $IncompleteRows
        BlankCellCount     = $BlankCells
        ColumnCount        = $Columns.Count
        Columns            = $Columns -join ' | '
        Readiness           = $Readiness
    }
}

function Get-MissingFieldRecords {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$TheoremID
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    $Rows = @(Import-Csv -LiteralPath $Path)

    for ($Index = 0; $Index -lt $Rows.Count; $Index++) {
        $Row = $Rows[$Index]

        if (-not (Test-MeaningfulRow -Row $Row)) {
            continue
        }

        foreach ($Property in $Row.PSObject.Properties) {
            if ([string]::IsNullOrWhiteSpace([string]$Property.Value)) {
                [pscustomobject]@{
                    TheoremID = $TheoremID
                    FileName  = Split-Path $Path -Leaf
                    CsvRow    = $Index + 2
                    Column    = $Property.Name
                    Issue     = 'REQUIRED_VALUE_MISSING'
                }
            }
        }
    }
}

$CsvAudit = [System.Collections.Generic.List[object]]::new()
$MissingFields = [System.Collections.Generic.List[object]]::new()
$TrialSummary = [System.Collections.Generic.List[object]]::new()
$ExecutionPlan = [System.Collections.Generic.List[object]]::new()

foreach ($Definition in $TrialDefinitions) {
    $TrialPath = Join-Path $VerificationRoot $Definition.TrialName

    if (-not (Test-Path -LiteralPath $TrialPath)) {
        throw "Required trial directory not found: $TrialPath"
    }

    foreach ($FileName in $Definition.RequiredCsvFiles) {
        $CsvPath = Join-Path $TrialPath $FileName

        $AuditRecord = Get-CsvAudit `
            -Path $CsvPath `
            -TheoremID $Definition.TheoremID

        $CsvAudit.Add($AuditRecord)

        $FieldRecords = @(
            Get-MissingFieldRecords `
                -Path $CsvPath `
                -TheoremID $Definition.TheoremID
        )

        foreach ($Record in $FieldRecords) {
            $MissingFields.Add($Record)
        }
    }

    $ResultsPath = Join-Path $TrialPath 'RESULTS.md'
    $DispositionPath = Join-Path $TrialPath 'DISPOSITION.md'

    $ResultsText = if (Test-Path -LiteralPath $ResultsPath) {
        Get-Content -LiteralPath $ResultsPath -Raw
    }
    else {
        ''
    }

    $DispositionText = if (Test-Path -LiteralPath $DispositionPath) {
        Get-Content -LiteralPath $DispositionPath -Raw
    }
    else {
        ''
    }

    $ResultStatus = if ($ResultsText -match '\*\*Result Status:\*\*\s*([A-Z0-9_]+)') {
        $Matches[1]
    }
    else {
        'UNDETERMINED'
    }

    $Disposition = if ($DispositionText -match '\*\*Disposition:\*\*\s*([A-Z0-9_]+)') {
        $Matches[1]
    }
    else {
        'UNDETERMINED'
    }

    $TrialCsv = @(
        $CsvAudit |
        Where-Object TheoremID -eq $Definition.TheoremID
    )

    $MissingFileCount = @(
        $TrialCsv |
        Where-Object Exists -eq $false
    ).Count

    $EmptyTemplateCount = @(
        $TrialCsv |
        Where-Object Readiness -eq 'EMPTY_TEMPLATE'
    ).Count

    $IncompleteFileCount = @(
        $TrialCsv |
        Where-Object Readiness -eq 'POPULATED_INCOMPLETE'
    ).Count

    $CompleteFileCount = @(
        $TrialCsv |
        Where-Object Readiness -eq 'POPULATED_COMPLETE'
    ).Count

    $ExecutionReadiness = if (
        $MissingFileCount -eq 0 -and
        $EmptyTemplateCount -eq 0 -and
        $IncompleteFileCount -eq 0
    ) {
        'EVIDENCE_READY_FOR_SCORING'
    }
    else {
        'EVIDENCE_COLLECTION_REQUIRED'
    }

    $CertificationEffect = if (
        $ResultStatus -eq 'COMPLETE' -and
        $Disposition -match '^VERIFIED_'
    ) {
        'NON_BLOCKING'
    }
    else {
        'BLOCKING'
    }

    $TrialSummary.Add(
        [pscustomobject]@{
            TheoremID            = $Definition.TheoremID
            TrialName            = $Definition.TrialName
            RequiredCsvCount     = $Definition.RequiredCsvFiles.Count
            MissingFileCount     = $MissingFileCount
            EmptyTemplateCount   = $EmptyTemplateCount
            IncompleteFileCount  = $IncompleteFileCount
            CompleteFileCount    = $CompleteFileCount
            ResultStatus         = $ResultStatus
            Disposition          = $Disposition
            ExecutionReadiness   = $ExecutionReadiness
            CertificationEffect  = $CertificationEffect
        }
    )

    for ($Step = 0; $Step -lt $Definition.ExecutionOrder.Count; $Step++) {
        $ExecutionPlan.Add(
            [pscustomobject]@{
                TheoremID = $Definition.TheoremID
                Step      = $Step + 1
                Action    = $Definition.ExecutionOrder[$Step]
                Status    = 'NOT_STARTED'
            }
        )
    }
}

$Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'
$DateStamp = Get-Date -Format 'yyyyMMdd-HHmmss'

$CsvAuditPath = Join-Path $OutputRoot 'MS-T1_T2_CSV_READINESS_REGISTER.csv'
$MissingFieldPath = Join-Path $OutputRoot 'MS-T1_T2_MISSING_FIELD_REGISTER.csv'
$TrialSummaryPath = Join-Path $OutputRoot 'MS-T1_T2_TRIAL_READINESS_REGISTER.csv'
$ExecutionPlanPath = Join-Path $OutputRoot 'MS-T1_T2_EXECUTION_PLAN.csv'
$JsonPath = Join-Path $OutputRoot 'MS-T1_T2_EXECUTION_READINESS.json'
$ReportPath = Join-Path $OutputRoot 'MS-T1_T2_EXECUTION_READINESS.md'

$CsvAudit |
    Sort-Object TheoremID, FileName |
    Export-Csv -LiteralPath $CsvAuditPath -NoTypeInformation -Encoding UTF8

$MissingFields |
    Sort-Object TheoremID, FileName, CsvRow, Column |
    Export-Csv -LiteralPath $MissingFieldPath -NoTypeInformation -Encoding UTF8

$TrialSummary |
    Sort-Object TheoremID |
    Export-Csv -LiteralPath $TrialSummaryPath -NoTypeInformation -Encoding UTF8

$ExecutionPlan |
    Sort-Object TheoremID, Step |
    Export-Csv -LiteralPath $ExecutionPlanPath -NoTypeInformation -Encoding UTF8

$OverallStatus = if (
    @($TrialSummary | Where-Object CertificationEffect -eq 'BLOCKING').Count -eq 0
) {
    'CERTIFICATION_READY'
}
else {
    'CERTIFICATION_BLOCKED'
}

$JsonObject = [ordered]@{
    generatedAt = $Timestamp
    repositoryRoot = $RepositoryRoot
    verificationRoot = $VerificationRoot
    overallStatus = $OverallStatus
    theoremSummary = @($TrialSummary)
    csvReadiness = @($CsvAudit)
    missingFields = @($MissingFields)
    executionPlan = @($ExecutionPlan)
}

$JsonObject |
    ConvertTo-Json -Depth 8 |
    Set-Content -LiteralPath $JsonPath -Encoding UTF8

$Report = [System.Collections.Generic.List[string]]::new()

$Report.Add('# MS-T1 and MS-T2 Execution Readiness')
$Report.Add('')
$Report.Add("**Generated:** $Timestamp")
$Report.Add('')
$Report.Add("**Overall Status:** $OverallStatus")
$Report.Add('')
$Report.Add('## Constitutional Finding')
$Report.Add('')
$Report.Add('MS-T1 and MS-T2 remain certification-blocking because their required evidence registers are empty or materially incomplete. Their OPEN statuses must not be replaced until evidence collection, assessment, scoring, and disposition have been completed.')
$Report.Add('')
$Report.Add('## Theorem Readiness')
$Report.Add('')
$Report.Add('| Theorem | Result | Disposition | Evidence Readiness | Certification Effect |')
$Report.Add('|---|---|---|---|---|')

foreach ($Trial in $TrialSummary | Sort-Object TheoremID) {
    $Report.Add(
        "| $($Trial.TheoremID) | $($Trial.ResultStatus) | $($Trial.Disposition) | $($Trial.ExecutionReadiness) | $($Trial.CertificationEffect) |"
    )
}

$Report.Add('')
$Report.Add('## CSV Evidence Readiness')
$Report.Add('')
$Report.Add('| Theorem | File | Meaningful Rows | Complete Rows | Incomplete Rows | Blank Cells | Status |')
$Report.Add('|---|---|---:|---:|---:|---:|---|')

foreach ($Record in $CsvAudit | Sort-Object TheoremID, FileName) {
    $Report.Add(
        "| $($Record.TheoremID) | $($Record.FileName) | $($Record.MeaningfulRowCount) | $($Record.CompleteRowCount) | $($Record.IncompleteRowCount) | $($Record.BlankCellCount) | $($Record.Readiness) |"
    )
}

$Report.Add('')
$Report.Add('## Required Execution Sequence')
$Report.Add('')

foreach ($TheoremID in @('MS-T1','MS-T2')) {
    $Report.Add("### $TheoremID")
    $Report.Add('')

    foreach ($Step in $ExecutionPlan | Where-Object TheoremID -eq $TheoremID | Sort-Object Step) {
        $Report.Add("$($Step.Step). $($Step.Action)")
    }

    $Report.Add('')
}

$Report.Add('## Generated Registers')
$Report.Add('')
$Report.Add('- `MS-T1_T2_CSV_READINESS_REGISTER.csv`')
$Report.Add('- `MS-T1_T2_MISSING_FIELD_REGISTER.csv`')
$Report.Add('- `MS-T1_T2_TRIAL_READINESS_REGISTER.csv`')
$Report.Add('- `MS-T1_T2_EXECUTION_PLAN.csv`')
$Report.Add('- `MS-T1_T2_EXECUTION_READINESS.json`')
$Report.Add('')
$Report.Add('## Governance Constraint')
$Report.Add('')
$Report.Add('This readiness audit does not create observations, assessments, propagation events, verification results, or theorem dispositions. It preserves the distinction between architecture completion and evidentiary verification.')

$Report |
    Set-Content -LiteralPath $ReportPath -Encoding UTF8

Write-Host ''
Write-Host '==============================================================' -ForegroundColor Cyan
Write-Host 'MS-T1 / MS-T2 EXECUTION READINESS AUDIT' -ForegroundColor Yellow
Write-Host '==============================================================' -ForegroundColor Cyan

$TrialSummary |
    Sort-Object TheoremID |
    Format-Table `
        TheoremID,
        ResultStatus,
        Disposition,
        ExecutionReadiness,
        CertificationEffect `
        -AutoSize

Write-Host ''
Write-Host "Overall Status: $OverallStatus" -ForegroundColor $(if ($OverallStatus -eq 'CERTIFICATION_READY') { 'Green' } else { 'Red' })
Write-Host "Report: $ReportPath" -ForegroundColor Green
Write-Host "Missing-field register: $MissingFieldPath" -ForegroundColor Green
Write-Host "Execution plan: $ExecutionPlanPath" -ForegroundColor Green
