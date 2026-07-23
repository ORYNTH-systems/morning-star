[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$VerificationRoot = Join-Path $RepositoryRoot 'volumes\VOLUME_I_FOUNDATION\verification'
$ExecutionRoot = Join-Path $VerificationRoot 'execution'
$ReadinessRoot = Join-Path $VerificationRoot 'readiness'

New-Item -ItemType Directory -Force -Path $ExecutionRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ReadinessRoot | Out-Null

$Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'

$Trials = @(
    [pscustomobject]@{
        TheoremID = 'MS-T1'
        TrialName = 'MS-T1_GOVERNED_INITIATION_TRIAL'
        WorkspaceName = 'MS-T1_CONTROLLED_EXECUTION'
        Files = @(
            'TRIAL_CASES.csv',
            'OBSERVER_RESPONSES.csv',
            'SEMANTIC_ASSESSMENTS.csv'
        )
        Stages = @(
            'CASE_PREPARATION',
            'OBSERVER_REGISTRATION',
            'RESPONSE_COLLECTION',
            'SEMANTIC_ASSESSMENT',
            'ADJUDICATION',
            'METRIC_CALCULATION',
            'RESULT_DRAFTING',
            'DISPOSITION_REVIEW'
        )
    },
    [pscustomobject]@{
        TheoremID = 'MS-T2'
        TrialName = 'MS-T2_DEPENDENCY_PROPAGATION_TRIAL'
        WorkspaceName = 'MS-T2_CONTROLLED_EXECUTION'
        Files = @(
            'DEPENDENCY_CHAINS.csv',
            'TRIAL_CASES.csv',
            'PROPAGATION_EVENTS.csv',
            'DOWNSTREAM_ASSESSMENTS.csv'
        )
        Stages = @(
            'CHAIN_PREPARATION',
            'CASE_PREPARATION',
            'PAIR_VALIDATION',
            'CONTROLLED_EXECUTION',
            'PROPAGATION_REGISTRATION',
            'DOWNSTREAM_ASSESSMENT',
            'CORRECTION_ATTEMPT',
            'METRIC_CALCULATION',
            'RESULT_DRAFTING',
            'DISPOSITION_REVIEW'
        )
    }
)

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

function Get-RowIdColumn {
    param(
        [Parameter(Mandatory)]
        [string[]]$Columns
    )

    $Preferred = @(
        'TrialCaseID',
        'CaseID',
        'ObserverResponseID',
        'ResponseID',
        'SemanticAssessmentID',
        'AssessmentID',
        'DependencyChainID',
        'ChainID',
        'PropagationEventID',
        'EventID'
    )

    foreach ($Column in $Preferred) {
        if ($Columns -contains $Column) {
            return $Column
        }
    }

    return $Columns[0]
}

function New-BlankCsvRecord {
    param(
        [Parameter(Mandatory)]
        [string[]]$Columns,

        [Parameter(Mandatory)]
        [string]$IdentityColumn,

        [Parameter(Mandatory)]
        [string]$IdentityValue
    )

    $Record = [ordered]@{}

    foreach ($Column in $Columns) {
        if ($Column -eq $IdentityColumn) {
            $Record[$Column] = $IdentityValue
        }
        else {
            $Record[$Column] = ''
        }
    }

    return [pscustomobject]$Record
}

$WorkspaceRegister = [System.Collections.Generic.List[object]]::new()
$StageRegister = [System.Collections.Generic.List[object]]::new()
$FileRegister = [System.Collections.Generic.List[object]]::new()
$EntryRegister = [System.Collections.Generic.List[object]]::new()

foreach ($Trial in $Trials) {

    $SourceRoot = Join-Path $VerificationRoot $Trial.TrialName
    $WorkspaceRoot = Join-Path $ExecutionRoot $Trial.WorkspaceName
    $InputRoot = Join-Path $WorkspaceRoot '01_INPUT'
    $EvidenceRoot = Join-Path $WorkspaceRoot '02_EVIDENCE'
    $AssessmentRoot = Join-Path $WorkspaceRoot '03_ASSESSMENT'
    $ScoringRoot = Join-Path $WorkspaceRoot '04_SCORING'
    $ReviewRoot = Join-Path $WorkspaceRoot '05_REVIEW'
    $OutputRoot = Join-Path $WorkspaceRoot '06_OUTPUT'
    $ArchiveRoot = Join-Path $WorkspaceRoot '99_ARCHIVE'

    foreach ($Directory in @(
        $WorkspaceRoot,
        $InputRoot,
        $EvidenceRoot,
        $AssessmentRoot,
        $ScoringRoot,
        $ReviewRoot,
        $OutputRoot,
        $ArchiveRoot
    )) {
        New-Item -ItemType Directory -Force -Path $Directory | Out-Null
    }

    $WorkspaceRegister.Add(
        [pscustomobject]@{
            TheoremID = $Trial.TheoremID
            TrialName = $Trial.TrialName
            Workspace = $WorkspaceRoot
            CreatedAt = $Timestamp
            ExecutionStatus = 'NOT_STARTED'
            EvidenceStatus = 'NOT_COLLECTED'
            ScoringStatus = 'BLOCKED'
            DispositionStatus = 'OPEN'
        }
    )

    for ($StageIndex = 0; $StageIndex -lt $Trial.Stages.Count; $StageIndex++) {

        $StageRegister.Add(
            [pscustomobject]@{
                TheoremID = $Trial.TheoremID
                StageNumber = $StageIndex + 1
                StageName = $Trial.Stages[$StageIndex]
                StageStatus = 'NOT_STARTED'
                StartedAt = ''
                CompletedAt = ''
                Executor = ''
                Reviewer = ''
                EvidenceReference = ''
                Notes = ''
            }
        )
    }

    foreach ($FileName in $Trial.Files) {

        $SourcePath = Join-Path $SourceRoot $FileName

        if (-not (Test-Path -LiteralPath $SourcePath)) {
            throw "Required governed CSV missing: $SourcePath"
        }

        $Header = Get-CsvHeader -Path $SourcePath

        $Columns = @(
            $Header -split ',' |
            ForEach-Object {
                $_.Trim().Trim('"')
            }
        )

        $IdentityColumn = Get-RowIdColumn -Columns $Columns
        $SourceRows = @(Import-Csv -LiteralPath $SourcePath)

        $DestinationFolder = switch -Regex ($FileName) {
            '^TRIAL_CASES\.csv$' {
                $InputRoot
                break
            }
            '^DEPENDENCY_CHAINS\.csv$' {
                $InputRoot
                break
            }
            '^OBSERVER_RESPONSES\.csv$' {
                $EvidenceRoot
                break
            }
            '^PROPAGATION_EVENTS\.csv$' {
                $EvidenceRoot
                break
            }
            '^SEMANTIC_ASSESSMENTS\.csv$' {
                $AssessmentRoot
                break
            }
            '^DOWNSTREAM_ASSESSMENTS\.csv$' {
                $AssessmentRoot
                break
            }
            default {
                $InputRoot
            }
        }

        $WorkingPath = Join-Path $DestinationFolder $FileName

        if (-not (Test-Path -LiteralPath $WorkingPath)) {
            Copy-Item -LiteralPath $SourcePath -Destination $WorkingPath
        }

        $SchemaPath = Join-Path $DestinationFolder (
            [System.IO.Path]::GetFileNameWithoutExtension($FileName) +
            '.schema.txt'
        )

        $Columns |
        ForEach-Object {
            $_
        } |
        Set-Content -LiteralPath $SchemaPath -Encoding UTF8

        $FileRegister.Add(
            [pscustomobject]@{
                TheoremID = $Trial.TheoremID
                FileName = $FileName
                SourcePath = $SourcePath
                WorkingPath = $WorkingPath
                IdentityColumn = $IdentityColumn
                ColumnCount = $Columns.Count
                SourceRowCount = $SourceRows.Count
                WorkingStatus = 'CREATED'
                EvidenceAuthority = 'CONTROLLED_EXECUTION_ONLY'
            }
        )

        if ($SourceRows.Count -eq 0) {

            $Prefix = switch ($FileName) {
                'OBSERVER_RESPONSES.csv' {
                    "$($Trial.TheoremID)-RESPONSE"
                }
                'SEMANTIC_ASSESSMENTS.csv' {
                    "$($Trial.TheoremID)-ASSESSMENT"
                }
                'PROPAGATION_EVENTS.csv' {
                    "$($Trial.TheoremID)-EVENT"
                }
                'DOWNSTREAM_ASSESSMENTS.csv' {
                    "$($Trial.TheoremID)-DOWNSTREAM"
                }
                default {
                    "$($Trial.TheoremID)-ENTRY"
                }
            }

            $EntryRegister.Add(
                [pscustomobject]@{
                    TheoremID = $Trial.TheoremID
                    FileName = $FileName
                    IdentityColumn = $IdentityColumn
                    SuggestedNextIdentity = "$Prefix-001"
                    EntryStatus = 'NOT_CREATED'
                    EntryAuthority = 'HUMAN_OR_CONTROLLED_RUNTIME_OBSERVATION_REQUIRED'
                }
            )
        }
        else {

            for ($RowIndex = 0; $RowIndex -lt $SourceRows.Count; $RowIndex++) {

                $Row = $SourceRows[$RowIndex]
                $IdentityValue = [string]$Row.PSObject.Properties[$IdentityColumn].Value

                if ([string]::IsNullOrWhiteSpace($IdentityValue)) {
                    $IdentityValue = "$($Trial.TheoremID)-UNASSIGNED-$($RowIndex + 1)"
                }

                $MissingColumns = @(
                    $Row.PSObject.Properties |
                    Where-Object {
                        [string]::IsNullOrWhiteSpace([string]$_.Value)
                    } |
                    Select-Object -ExpandProperty Name
                )

                $EntryRegister.Add(
                    [pscustomobject]@{
                        TheoremID = $Trial.TheoremID
                        FileName = $FileName
                        IdentityColumn = $IdentityColumn
                        SuggestedNextIdentity = $IdentityValue
                        EntryStatus = if ($MissingColumns.Count -eq 0) {
                            'COMPLETE'
                        }
                        else {
                            'REQUIRES_COMPLETION'
                        }
                        EntryAuthority = if ($MissingColumns.Count -eq 0) {
                            'SOURCE_DEFINED'
                        }
                        else {
                            'GOVERNED_INPUT_REQUIRED'
                        }
                    }
                )
            }
        }
    }

    $ScoringTemplate = @"
# $($Trial.TheoremID) Controlled Scoring Record

**Theorem:** $($Trial.TheoremID)  
**Trial:** $($Trial.TrialName)  
**Generated:** $Timestamp  
**Scoring Status:** BLOCKED  
**Evidence Validation Status:** NOT_VALIDATED  

## Required Preconditions

- [ ] All required case definitions complete
- [ ] All required evidence rows complete
- [ ] All evidence identities unique
- [ ] All assessments traceable to evidence
- [ ] Disputed assessments adjudicated
- [ ] Required minimum case count satisfied
- [ ] Reproducibility requirements satisfied
- [ ] Controlled execution harness reports READY_FOR_SCORING

## Metric Record

| Metric | Formula | Numerator | Denominator | Result | Threshold | Status |
|---|---|---:|---:|---:|---:|---|
| UNASSIGNED | UNASSIGNED |  |  |  |  | NOT_CALCULATED |

## Governance Constraint

No metric may be calculated from assumed, fabricated, inferred, or placeholder evidence.
"@

    Set-Content `
        -LiteralPath (Join-Path $ScoringRoot 'SCORING_RECORD.md') `
        -Value $ScoringTemplate `
        -Encoding UTF8

    $ReviewTemplate = @"
# $($Trial.TheoremID) Evidence Review Record

**Theorem:** $($Trial.TheoremID)  
**Generated:** $Timestamp  
**Review Status:** NOT_STARTED  

## Review Checklist

- [ ] Source identities verified
- [ ] Case definitions complete
- [ ] Evidence provenance preserved
- [ ] Evidence rows complete
- [ ] No duplicated identities
- [ ] Assessments trace to evidence
- [ ] Contradictory observations preserved
- [ ] Uncertainty explicitly recorded
- [ ] Scoring formulas independently checked
- [ ] Disposition criteria independently checked

## Review Authority

**Executor:**  
**Reviewer:**  
**Review Date:**  
**Review Outcome:**  

## Exceptions

None recorded.
"@

    Set-Content `
        -LiteralPath (Join-Path $ReviewRoot 'EVIDENCE_REVIEW.md') `
        -Value $ReviewTemplate `
        -Encoding UTF8

    $ResultTemplate = @"
# $($Trial.TheoremID) Controlled Trial Results

**Theorem:** $($Trial.TheoremID)  
**Trial:** $($Trial.TrialName)  
**Generated:** $Timestamp  
**Result Status:** NOT_CALCULATED  
**Evidence Status:** NOT_COLLECTED  
**Disposition Eligibility:** BLOCKED  

## Execution Summary

Controlled execution has not yet been completed.

## Evidence Summary

No evidence summary is authorized until governed evidence collection is complete.

## Metrics

No metrics calculated.

## Result

OPEN
"@

    Set-Content `
        -LiteralPath (Join-Path $OutputRoot 'RESULTS_DRAFT.md') `
        -Value $ResultTemplate `
        -Encoding UTF8

    $DispositionTemplate = @"
# $($Trial.TheoremID) Disposition Review

**Theorem:** $($Trial.TheoremID)  
**Generated:** $Timestamp  
**Disposition:** OPEN  
**Disposition Status:** BLOCKED_PENDING_EVIDENCE  

## Eligibility Conditions

- [ ] Evidence collection complete
- [ ] Evidence validation passed
- [ ] Metrics calculated
- [ ] Thresholds evaluated
- [ ] Limitations recorded
- [ ] Reproducibility reviewed
- [ ] Independent review complete

## Authorized Disposition

OPEN

No evidentiary disposition is authorized at this stage.
"@

    Set-Content `
        -LiteralPath (Join-Path $OutputRoot 'DISPOSITION_DRAFT.md') `
        -Value $DispositionTemplate `
        -Encoding UTF8

    $WorkspaceReadme = @"
# $($Trial.TheoremID) Controlled Execution Workspace

**Trial Package:** $($Trial.TrialName)  
**Created:** $Timestamp  
**Status:** NOT_STARTED  

## Directory Structure

- `01_INPUT` — governed case and dependency definitions
- `02_EVIDENCE` — direct observations and propagation events
- `03_ASSESSMENT` — semantic and downstream assessments
- `04_SCORING` — controlled metric calculation
- `05_REVIEW` — evidence and disposition review
- `06_OUTPUT` — draft results and disposition
- `99_ARCHIVE` — superseded execution records

## Execution Rule

This workspace may receive evidence only through documented controlled execution. Blank fields must remain blank until supported by an observation, governed assessment, or verified source.

## Source Preservation

The governed source trial package remains authoritative. Workspace files are execution copies and must not replace source files until validation and review pass.
"@

    Set-Content `
        -LiteralPath (Join-Path $WorkspaceRoot 'README.md') `
        -Value $WorkspaceReadme `
        -Encoding UTF8
}

$WorkspaceRegisterPath = Join-Path $ReadinessRoot 'MS-T1_T2_EXECUTION_WORKSPACE_REGISTER.csv'
$StageRegisterPath = Join-Path $ReadinessRoot 'MS-T1_T2_EXECUTION_STAGE_REGISTER.csv'
$FileRegisterPath = Join-Path $ReadinessRoot 'MS-T1_T2_EXECUTION_FILE_REGISTER.csv'
$EntryRegisterPath = Join-Path $ReadinessRoot 'MS-T1_T2_EXECUTION_ENTRY_REGISTER.csv'
$ManifestPath = Join-Path $ReadinessRoot 'MS-T1_T2_EXECUTION_WORKSPACE_MANIFEST.json'
$ReportPath = Join-Path $ReadinessRoot 'MS-T1_T2_EXECUTION_WORKSPACE_REPORT.md'

$WorkspaceRegister |
Sort-Object TheoremID |
Export-Csv `
    -LiteralPath $WorkspaceRegisterPath `
    -NoTypeInformation `
    -Encoding UTF8

$StageRegister |
Sort-Object TheoremID, StageNumber |
Export-Csv `
    -LiteralPath $StageRegisterPath `
    -NoTypeInformation `
    -Encoding UTF8

$FileRegister |
Sort-Object TheoremID, FileName |
Export-Csv `
    -LiteralPath $FileRegisterPath `
    -NoTypeInformation `
    -Encoding UTF8

$EntryRegister |
Sort-Object TheoremID, FileName, SuggestedNextIdentity |
Export-Csv `
    -LiteralPath $EntryRegisterPath `
    -NoTypeInformation `
    -Encoding UTF8

$Manifest = [ordered]@{
    generatedAt = $Timestamp
    repositoryRoot = $RepositoryRoot
    executionRoot = $ExecutionRoot
    governanceState = 'CONTROLLED_EXECUTION_WORKSPACES_CREATED'
    workspaces = @($WorkspaceRegister)
    stages = @($StageRegister)
    files = @($FileRegister)
    entries = @($EntryRegister)
}

$Manifest |
ConvertTo-Json -Depth 10 |
Set-Content `
    -LiteralPath $ManifestPath `
    -Encoding UTF8

$Report = [System.Collections.Generic.List[string]]::new()

$Report.Add('# MS-T1 and MS-T2 Controlled Execution Workspaces')
$Report.Add('')
$Report.Add("**Generated:** $Timestamp")
$Report.Add('')
$Report.Add('**Governance State:** CONTROLLED_EXECUTION_WORKSPACES_CREATED')
$Report.Add('')
$Report.Add('## Workspace Status')
$Report.Add('')
$Report.Add('| Theorem | Workspace | Execution | Evidence | Scoring | Disposition |')
$Report.Add('|---|---|---|---|---|---|')

foreach ($Workspace in $WorkspaceRegister | Sort-Object TheoremID) {
    $Report.Add(
        "| $($Workspace.TheoremID) | $($Workspace.Workspace) | $($Workspace.ExecutionStatus) | $($Workspace.EvidenceStatus) | $($Workspace.ScoringStatus) | $($Workspace.DispositionStatus) |"
    )
}

$Report.Add('')
$Report.Add('## Execution Stages')
$Report.Add('')
$Report.Add('| Theorem | Step | Stage | Status |')
$Report.Add('|---|---:|---|---|')

foreach ($Stage in $StageRegister | Sort-Object TheoremID, StageNumber) {
    $Report.Add(
        "| $($Stage.TheoremID) | $($Stage.StageNumber) | $($Stage.StageName) | $($Stage.StageStatus) |"
    )
}

$Report.Add('')
$Report.Add('## Governed Files')
$Report.Add('')
$Report.Add('| Theorem | File | Rows | Identity Column | Status |')
$Report.Add('|---|---|---:|---|---|')

foreach ($File in $FileRegister | Sort-Object TheoremID, FileName) {
    $Report.Add(
        "| $($File.TheoremID) | $($File.FileName) | $($File.SourceRowCount) | $($File.IdentityColumn) | $($File.WorkingStatus) |"
    )
}

$Report.Add('')
$Report.Add('## Governance Constraint')
$Report.Add('')
$Report.Add('The workspaces are structurally ready, but evidence collection remains unperformed. No theorem result or disposition has been altered.')

$Report |
Set-Content `
    -LiteralPath $ReportPath `
    -Encoding UTF8

Write-Host ''
Write-Host '==============================================================' -ForegroundColor Cyan
Write-Host 'MS-T1 / MS-T2 EXECUTION WORKSPACES CREATED' -ForegroundColor Yellow
Write-Host '==============================================================' -ForegroundColor Cyan
Write-Host ''

$WorkspaceRegister |
Format-Table `
    TheoremID,
    ExecutionStatus,
    EvidenceStatus,
    ScoringStatus,
    DispositionStatus `
    -AutoSize

Write-Host ''
Write-Host "Execution root: $ExecutionRoot" -ForegroundColor Green
Write-Host "Workspace register: $WorkspaceRegisterPath" -ForegroundColor Green
Write-Host "Stage register: $StageRegisterPath" -ForegroundColor Green
Write-Host "File register: $FileRegisterPath" -ForegroundColor Green
Write-Host "Entry register: $EntryRegisterPath" -ForegroundColor Green
Write-Host "Manifest: $ManifestPath" -ForegroundColor Green
Write-Host "Report: $ReportPath" -ForegroundColor Green
