[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$VerificationRoot = Join-Path $RepositoryRoot 'volumes\VOLUME_I_FOUNDATION\verification'
$ReadinessRoot = Join-Path $VerificationRoot 'readiness'

$TrialDefinitions = @(
    [pscustomobject]@{
        TheoremID = 'MS-T1'
        TrialName = 'MS-T1_GOVERNED_INITIATION_TRIAL'
        Files = @(
            [pscustomobject]@{
                Name = 'TRIAL_CASES.csv'
                Role = 'CASE_DEFINITION'
            },
            [pscustomobject]@{
                Name = 'OBSERVER_RESPONSES.csv'
                Role = 'PRIMARY_EVIDENCE'
            },
            [pscustomobject]@{
                Name = 'SEMANTIC_ASSESSMENTS.csv'
                Role = 'ASSESSMENT_EVIDENCE'
            }
        )
    },
    [pscustomobject]@{
        TheoremID = 'MS-T2'
        TrialName = 'MS-T2_DEPENDENCY_PROPAGATION_TRIAL'
        Files = @(
            [pscustomobject]@{
                Name = 'DEPENDENCY_CHAINS.csv'
                Role = 'CHAIN_DEFINITION'
            },
            [pscustomobject]@{
                Name = 'TRIAL_CASES.csv'
                Role = 'CASE_DEFINITION'
            },
            [pscustomobject]@{
                Name = 'PROPAGATION_EVENTS.csv'
                Role = 'PRIMARY_EVIDENCE'
            },
            [pscustomobject]@{
                Name = 'DOWNSTREAM_ASSESSMENTS.csv'
                Role = 'ASSESSMENT_EVIDENCE'
            }
        )
    }
)

function Get-CsvColumns {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $Header = Get-Content -LiteralPath $Path -TotalCount 1

    if ([string]::IsNullOrWhiteSpace($Header)) {
        return @()
    }

    return @(
        $Header -split ',' |
        ForEach-Object {
            $_.Trim().Trim('"')
        }
    )
}

function Test-RowMeaningful {
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

function Get-RowIdentity {
    param(
        [Parameter(Mandatory)]
        [object]$Row,

        [Parameter(Mandatory)]
        [int]$RowNumber
    )

    $PreferredColumns = @(
        'TrialCaseID',
        'CaseID',
        'ObserverResponseID',
        'ResponseID',
        'AssessmentID',
        'DependencyChainID',
        'ChainID',
        'PropagationEventID',
        'EventID'
    )

    foreach ($Column in $PreferredColumns) {
        $Property = $Row.PSObject.Properties[$Column]

        if (
            $null -ne $Property -and
            -not [string]::IsNullOrWhiteSpace([string]$Property.Value)
        ) {
            return [string]$Property.Value
        }
    }

    return "CSV-ROW-$RowNumber"
}

function Get-FileValidation {
    param(
        [Parameter(Mandatory)]
        [string]$TheoremID,

        [Parameter(Mandatory)]
        [string]$TrialName,

        [Parameter(Mandatory)]
        [string]$FileName,

        [Parameter(Mandatory)]
        [string]$Role
    )

    $TrialRoot = Join-Path $VerificationRoot $TrialName
    $Path = Join-Path $TrialRoot $FileName

    if (-not (Test-Path -LiteralPath $Path)) {
        return [pscustomobject]@{
            TheoremID = $TheoremID
            TrialName = $TrialName
            FileName = $FileName
            FileRole = $Role
            Exists = $false
            SchemaPresent = $false
            RowCount = 0
            MeaningfulRows = 0
            CompleteRows = 0
            IncompleteRows = 0
            DuplicateIdentityCount = 0
            ValidationStatus = 'MISSING_FILE'
            Blocking = $true
        }
    }

    $Columns = @(Get-CsvColumns -Path $Path)
    $Rows = @(Import-Csv -LiteralPath $Path)

    $MeaningfulRows = @(
        $Rows |
        Where-Object {
            Test-RowMeaningful -Row $_
        }
    )

    $CompleteRows = 0
    $IncompleteRows = 0
    $Identities = [System.Collections.Generic.List[string]]::new()

    for ($Index = 0; $Index -lt $MeaningfulRows.Count; $Index++) {
        $Row = $MeaningfulRows[$Index]
        $Complete = $true

        foreach ($Column in $Columns) {
            $Property = $Row.PSObject.Properties[$Column]

            if (
                $null -eq $Property -or
                [string]::IsNullOrWhiteSpace([string]$Property.Value)
            ) {
                $Complete = $false
            }
        }

        if ($Complete) {
            $CompleteRows++
        }
        else {
            $IncompleteRows++
        }

        $Identities.Add(
            (Get-RowIdentity -Row $Row -RowNumber ($Index + 2))
        )
    }

    $DuplicateCount = @(
        $Identities |
        Group-Object |
        Where-Object Count -gt 1
    ).Count

    $ValidationStatus = if ($Columns.Count -eq 0) {
        'INVALID_SCHEMA'
    }
    elseif ($MeaningfulRows.Count -eq 0) {
        'EMPTY_EVIDENCE'
    }
    elseif ($IncompleteRows -gt 0) {
        'INCOMPLETE_ROWS'
    }
    elseif ($DuplicateCount -gt 0) {
        'DUPLICATE_IDENTITIES'
    }
    else {
        'VALID'
    }

    [pscustomobject]@{
        TheoremID = $TheoremID
        TrialName = $TrialName
        FileName = $FileName
        FileRole = $Role
        Exists = $true
        SchemaPresent = ($Columns.Count -gt 0)
        RowCount = $Rows.Count
        MeaningfulRows = $MeaningfulRows.Count
        CompleteRows = $CompleteRows
        IncompleteRows = $IncompleteRows
        DuplicateIdentityCount = $DuplicateCount
        ValidationStatus = $ValidationStatus
        Blocking = ($ValidationStatus -ne 'VALID')
    }
}

$Controls = [System.Collections.Generic.List[object]]::new()
$Validation = [System.Collections.Generic.List[object]]::new()

foreach ($Trial in $TrialDefinitions) {

    foreach ($File in $Trial.Files) {

        $Record = Get-FileValidation `
            -TheoremID $Trial.TheoremID `
            -TrialName $Trial.TrialName `
            -FileName $File.Name `
            -Role $File.Role

        $Validation.Add($Record)
    }

    $Controls.Add(
        [pscustomobject]@{
            ControlID = "$($Trial.TheoremID)-CTRL-001"
            TheoremID = $Trial.TheoremID
            ControlClass = 'SCHEMA_VALIDATION'
            ControlDescription = 'Every governed CSV must exist and preserve its declared schema.'
            ControlStatus = 'IMPLEMENTED'
        }
    )

    $Controls.Add(
        [pscustomobject]@{
            ControlID = "$($Trial.TheoremID)-CTRL-002"
            TheoremID = $Trial.TheoremID
            ControlClass = 'EVIDENCE_COMPLETENESS'
            ControlDescription = 'Every material evidence row must contain values for all declared fields.'
            ControlStatus = 'IMPLEMENTED'
        }
    )

    $Controls.Add(
        [pscustomobject]@{
            ControlID = "$($Trial.TheoremID)-CTRL-003"
            TheoremID = $Trial.TheoremID
            ControlClass = 'IDENTITY_UNIQUENESS'
            ControlDescription = 'Evidence identities must not be duplicated within a governed CSV.'
            ControlStatus = 'IMPLEMENTED'
        }
    )

    $Controls.Add(
        [pscustomobject]@{
            ControlID = "$($Trial.TheoremID)-CTRL-004"
            TheoremID = $Trial.TheoremID
            ControlClass = 'NO_SYNTHETIC_EVIDENCE'
            ControlDescription = 'The harness validates supplied evidence but does not invent observations, assessments, or outcomes.'
            ControlStatus = 'ENFORCED'
        }
    )

    $Controls.Add(
        [pscustomobject]@{
            ControlID = "$($Trial.TheoremID)-CTRL-005"
            TheoremID = $Trial.TheoremID
            ControlClass = 'DISPOSITION_GATING'
            ControlDescription = 'Theorem scoring and disposition remain blocked until all required evidence files validate.'
            ControlStatus = 'ENFORCED'
        }
    )
}

$ValidationPath = Join-Path $ReadinessRoot 'MS-T1_T2_EXECUTION_VALIDATION_REGISTER.csv'
$ControlPath = Join-Path $ReadinessRoot 'MS-T1_T2_EXECUTION_CONTROL_REGISTER.csv'
$JsonPath = Join-Path $ReadinessRoot 'MS-T1_T2_EXECUTION_VALIDATION.json'
$ReportPath = Join-Path $ReadinessRoot 'MS-T1_T2_CONTROLLED_EXECUTION_HARNESS.md'

$Validation |
Sort-Object TheoremID, FileName |
Export-Csv `
    -LiteralPath $ValidationPath `
    -NoTypeInformation `
    -Encoding UTF8

$Controls |
Sort-Object TheoremID, ControlID |
Export-Csv `
    -LiteralPath $ControlPath `
    -NoTypeInformation `
    -Encoding UTF8

$TheoremStatus = foreach ($Trial in $TrialDefinitions) {

    $TrialValidation = @(
        $Validation |
        Where-Object TheoremID -eq $Trial.TheoremID
    )

    $BlockingCount = @(
        $TrialValidation |
        Where-Object Blocking -eq $true
    ).Count

    [pscustomobject]@{
        TheoremID = $Trial.TheoremID
        RequiredFileCount = $TrialValidation.Count
        ValidFileCount = @(
            $TrialValidation |
            Where-Object ValidationStatus -eq 'VALID'
        ).Count
        BlockingFileCount = $BlockingCount
        ExecutionState = if ($BlockingCount -eq 0) {
            'READY_FOR_SCORING'
        }
        else {
            'EVIDENCE_ENTRY_REQUIRED'
        }
        ScoringPermitted = ($BlockingCount -eq 0)
    }
}

$OverallState = if (
    @(
        $TheoremStatus |
        Where-Object ScoringPermitted -eq $false
    ).Count -eq 0
) {
    'READY_FOR_CONTROLLED_SCORING'
}
else {
    'EVIDENCE_ENTRY_REQUIRED'
}

$JsonObject = [ordered]@{
    generatedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'
    overallState = $OverallState
    validateOnly = [bool]$ValidateOnly
    theoremStatus = @($TheoremStatus)
    fileValidation = @($Validation)
    controls = @($Controls)
}

$JsonObject |
ConvertTo-Json -Depth 8 |
Set-Content -LiteralPath $JsonPath -Encoding UTF8

$Report = [System.Collections.Generic.List[string]]::new()

$Report.Add('# MS-T1 and MS-T2 Controlled Execution Harness')
$Report.Add('')
$Report.Add("**Generated:** $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')")
$Report.Add('')
$Report.Add("**Overall State:** $OverallState")
$Report.Add('')
$Report.Add('## Harness Function')
$Report.Add('')
$Report.Add('This harness validates schemas, row completeness, evidence identity uniqueness, and theorem scoring eligibility. It does not create observations or force a theorem disposition.')
$Report.Add('')
$Report.Add('## Theorem State')
$Report.Add('')
$Report.Add('| Theorem | Required Files | Valid Files | Blocking Files | Execution State | Scoring Permitted |')
$Report.Add('|---|---:|---:|---:|---|---|')

foreach ($Status in $TheoremStatus) {
    $Report.Add(
        "| $($Status.TheoremID) | $($Status.RequiredFileCount) | $($Status.ValidFileCount) | $($Status.BlockingFileCount) | $($Status.ExecutionState) | $($Status.ScoringPermitted) |"
    )
}

$Report.Add('')
$Report.Add('## File Validation')
$Report.Add('')
$Report.Add('| Theorem | File | Role | Meaningful Rows | Complete | Incomplete | Duplicates | Status |')
$Report.Add('|---|---|---|---:|---:|---:|---:|---|')

foreach ($Record in $Validation | Sort-Object TheoremID, FileName) {
    $Report.Add(
        "| $($Record.TheoremID) | $($Record.FileName) | $($Record.FileRole) | $($Record.MeaningfulRows) | $($Record.CompleteRows) | $($Record.IncompleteRows) | $($Record.DuplicateIdentityCount) | $($Record.ValidationStatus) |"
    )
}

$Report.Add('')
$Report.Add('## Implemented Controls')
$Report.Add('')
$Report.Add('| Control | Theorem | Class | Status | Description |')
$Report.Add('|---|---|---|---|---|')

foreach ($Control in $Controls | Sort-Object TheoremID, ControlID) {
    $SafeDescription = $Control.ControlDescription.Replace('|', '\|')

    $Report.Add(
        "| $($Control.ControlID) | $($Control.TheoremID) | $($Control.ControlClass) | $($Control.ControlStatus) | $SafeDescription |"
    )
}

$Report.Add('')
$Report.Add('## Current Gate')
$Report.Add('')

if ($OverallState -eq 'READY_FOR_CONTROLLED_SCORING') {
    $Report.Add('All required evidence files validate. Controlled metric calculation may begin.')
}
else {
    $Report.Add('Controlled scoring remains prohibited. Populate the governed evidence registers using the trial procedures, then rerun this harness.')
}

$Report |
Set-Content `
    -LiteralPath $ReportPath `
    -Encoding UTF8

Write-Host ''
Write-Host '==============================================================' -ForegroundColor Cyan
Write-Host 'MS-T1 / MS-T2 CONTROLLED EXECUTION HARNESS' -ForegroundColor Yellow
Write-Host '==============================================================' -ForegroundColor Cyan
Write-Host ''

$TheoremStatus |
Format-Table `
    TheoremID,
    RequiredFileCount,
    ValidFileCount,
    BlockingFileCount,
    ExecutionState,
    ScoringPermitted `
    -AutoSize

Write-Host ''
Write-Host "Overall State: $OverallState" -ForegroundColor $(
    if ($OverallState -eq 'READY_FOR_CONTROLLED_SCORING') {
        'Green'
    }
    else {
        'Red'
    }
)

Write-Host "Validation register: $ValidationPath" -ForegroundColor Green
Write-Host "Control register: $ControlPath" -ForegroundColor Green
Write-Host "Harness report: $ReportPath" -ForegroundColor Green
