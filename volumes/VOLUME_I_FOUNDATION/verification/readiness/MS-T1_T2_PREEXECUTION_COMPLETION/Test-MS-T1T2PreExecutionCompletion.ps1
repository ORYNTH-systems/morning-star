[CmdletBinding()]
param(
    [string]$CompletionRoot = (Split-Path -Parent $MyInvocation.MyCommand.Path)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$FormsRoot = Join-Path $CompletionRoot 'completion_forms'
$FormRegisterPath = Join-Path $CompletionRoot 'PREEXECUTION_FORM_REGISTER.csv'
$ValidationRegisterPath = Join-Path $CompletionRoot 'PREEXECUTION_VALIDATION_REGISTER.csv'
$GatePath = Join-Path $CompletionRoot 'PREEXECUTION_FINAL_GATE.csv'
$ReportPath = Join-Path $CompletionRoot 'PREEXECUTION_VALIDATION_REPORT.md'

if (-not (Test-Path -LiteralPath $FormRegisterPath -PathType Leaf)) {
    throw "Form register not found: $FormRegisterPath"
}

$FormRegister = @(Import-Csv -LiteralPath $FormRegisterPath)
$ValidationRows = [System.Collections.Generic.List[object]]::new()

foreach ($Form in $FormRegister) {

    if (-not (Test-Path -LiteralPath $Form.FormPath -PathType Leaf)) {
        [void]$ValidationRows.Add(
            [pscustomobject][ordered]@{
                TheoremID      = $Form.TheoremID
                SourceFile     = $Form.SourceFile
                CsvRow         = $Form.CsvRow
                RecordIdentity = $Form.RecordIdentity
                FieldName      = ''
                Validation     = 'FORM_MISSING'
                GateStatus     = 'BLOCKED'
                Detail         = $Form.FormPath
            }
        )

        continue
    }

    $Rows = @(Import-Csv -LiteralPath $Form.FormPath)

    foreach ($Row in $Rows) {

        $Failures = [System.Collections.Generic.List[string]]::new()

        if ([string]::IsNullOrWhiteSpace($Row.ProposedValue)) {
            [void]$Failures.Add('PROPOSED_VALUE_MISSING')
        }

        if ([string]::IsNullOrWhiteSpace($Row.SourceReference)) {
            [void]$Failures.Add('SOURCE_REFERENCE_MISSING')
        }

        if ([string]::IsNullOrWhiteSpace($Row.CompletedBy)) {
            [void]$Failures.Add('COMPLETED_BY_MISSING')
        }

        $CompletedAtValue = [datetime]::MinValue

        if (
            [string]::IsNullOrWhiteSpace($Row.CompletedAt) -or
            -not [datetime]::TryParse(
                $Row.CompletedAt,
                [ref]$CompletedAtValue
            )
        ) {
            [void]$Failures.Add('COMPLETED_AT_INVALID')
        }

        if ($Row.ReviewStatus -ne 'APPROVED') {
            [void]$Failures.Add('REVIEW_NOT_APPROVED')
        }

        if ([string]::IsNullOrWhiteSpace($Row.Reviewer)) {
            [void]$Failures.Add('REVIEWER_MISSING')
        }

        $ReviewDateValue = [datetime]::MinValue

        if (
            [string]::IsNullOrWhiteSpace($Row.ReviewDate) -or
            -not [datetime]::TryParse(
                $Row.ReviewDate,
                [ref]$ReviewDateValue
            )
        ) {
            [void]$Failures.Add('REVIEW_DATE_INVALID')
        }

        $Validation = if ($Failures.Count -eq 0) {
            'PASS'
        }
        else {
            $Failures -join '|'
        }

        $GateStatus = if ($Failures.Count -eq 0) {
            'READY'
        }
        else {
            'BLOCKED'
        }

        [void]$ValidationRows.Add(
            [pscustomobject][ordered]@{
                TheoremID      = $Row.TheoremID
                SourceFile     = $Row.SourceFile
                CsvRow         = $Row.CsvRow
                RecordIdentity = $Row.RecordIdentity
                FieldName      = $Row.FieldName
                Validation     = $Validation
                GateStatus     = $GateStatus
                Detail         = ''
            }
        )
    }
}

$ValidationRows |
Export-Csv `
    -LiteralPath $ValidationRegisterPath `
    -NoTypeInformation `
    -Encoding UTF8

$GateRows = foreach ($TheoremID in @('MS-T1', 'MS-T2')) {

    $Rows = @(
        $ValidationRows |
        Where-Object TheoremID -eq $TheoremID
    )

    $Blocked = @(
        $Rows |
        Where-Object GateStatus -eq 'BLOCKED'
    )

    [pscustomobject][ordered]@{
        TheoremID       = $TheoremID
        RequiredFields  = $Rows.Count
        ReadyFields     = @($Rows | Where-Object GateStatus -eq 'READY').Count
        BlockedFields   = $Blocked.Count
        FinalGate       = if ($Rows.Count -gt 0 -and $Blocked.Count -eq 0) {
            'PASS'
        }
        else {
            'BLOCKED'
        }
        GateReason      = if ($Rows.Count -eq 0) {
            'NO_VALIDATION_ROWS'
        }
        elseif ($Blocked.Count -gt 0) {
            'PREEXECUTION_COMPLETION_INCOMPLETE'
        }
        else {
            'ALL_PREEXECUTION_FIELDS_APPROVED'
        }
        EvaluatedAt     = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'
    }
}

$GateRows |
Export-Csv `
    -LiteralPath $GatePath `
    -NoTypeInformation `
    -Encoding UTF8

$Report = [System.Collections.Generic.List[string]]::new()

[void]$Report.Add('# MS-T1 and MS-T2 Pre-Execution Validation Report')
[void]$Report.Add('')
[void]$Report.Add(('**Evaluated:** {0}' -f (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')))
[void]$Report.Add('')
[void]$Report.Add('## Gate Summary')
[void]$Report.Add('')
[void]$Report.Add('| Theorem | Required | Ready | Blocked | Final Gate | Reason |')
[void]$Report.Add('|---|---:|---:|---:|---|---|')

foreach ($Gate in $GateRows) {
    [void]$Report.Add(
        (
            '| {0} | {1} | {2} | {3} | {4} | {5} |' -f @(
                $Gate.TheoremID
                $Gate.RequiredFields
                $Gate.ReadyFields
                $Gate.BlockedFields
                $Gate.FinalGate
                $Gate.GateReason
            )
        )
    )
}

[void]$Report.Add('')
[void]$Report.Add('## Blocked Fields')
[void]$Report.Add('')
[void]$Report.Add('| Theorem | File | Row | Record | Field | Validation |')
[void]$Report.Add('|---|---|---:|---|---|---|')

foreach ($Row in $ValidationRows | Where-Object GateStatus -eq 'BLOCKED') {
    [void]$Report.Add(
        (
            '| {0} | {1} | {2} | {3} | {4} | {5} |' -f @(
                $Row.TheoremID
                $Row.SourceFile
                $Row.CsvRow
                $Row.RecordIdentity
                $Row.FieldName
                $Row.Validation
            )
        )
    )
}

[void]$Report.Add('')

$Report |
Set-Content `
    -LiteralPath $ReportPath `
    -Encoding UTF8

Write-Host ''
Write-Host '==============================================================' -ForegroundColor Cyan
Write-Host 'PRE-EXECUTION VALIDATION COMPLETE' -ForegroundColor Green
Write-Host '==============================================================' -ForegroundColor Cyan
Write-Host ''

$GateRows |
Format-Table `
    TheoremID,
    RequiredFields,
    ReadyFields,
    BlockedFields,
    FinalGate,
    GateReason `
    -AutoSize

Write-Host ''
Write-Host "Validation register: $ValidationRegisterPath" -ForegroundColor Green
Write-Host "Final gate: $GatePath" -ForegroundColor Green
Write-Host "Report: $ReportPath" -ForegroundColor Green
