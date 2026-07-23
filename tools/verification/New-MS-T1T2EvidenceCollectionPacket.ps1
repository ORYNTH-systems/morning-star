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

$GeneratedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'

$Trials = @(
    [pscustomobject]@{
        TheoremID = 'MS-T1'
        TrialName = 'MS-T1_GOVERNED_INITIATION_TRIAL'
        WorkspaceName = 'MS-T1_CONTROLLED_EXECUTION'
        CollectionFiles = @(
            [pscustomobject]@{
                FileName = 'TRIAL_CASES.csv'
                Folder = '01_INPUT'
                CollectionClass = 'CASE_DEFINITION'
            },
            [pscustomobject]@{
                FileName = 'OBSERVER_RESPONSES.csv'
                Folder = '02_EVIDENCE'
                CollectionClass = 'DIRECT_OBSERVATION'
            },
            [pscustomobject]@{
                FileName = 'SEMANTIC_ASSESSMENTS.csv'
                Folder = '03_ASSESSMENT'
                CollectionClass = 'SEMANTIC_ASSESSMENT'
            }
        )
    },
    [pscustomobject]@{
        TheoremID = 'MS-T2'
        TrialName = 'MS-T2_DEPENDENCY_PROPAGATION_TRIAL'
        WorkspaceName = 'MS-T2_CONTROLLED_EXECUTION'
        CollectionFiles = @(
            [pscustomobject]@{
                FileName = 'DEPENDENCY_CHAINS.csv'
                Folder = '01_INPUT'
                CollectionClass = 'CHAIN_DEFINITION'
            },
            [pscustomobject]@{
                FileName = 'TRIAL_CASES.csv'
                Folder = '01_INPUT'
                CollectionClass = 'CASE_DEFINITION'
            },
            [pscustomobject]@{
                FileName = 'PROPAGATION_EVENTS.csv'
                Folder = '02_EVIDENCE'
                CollectionClass = 'DIRECT_OBSERVATION'
            },
            [pscustomobject]@{
                FileName = 'DOWNSTREAM_ASSESSMENTS.csv'
                Folder = '03_ASSESSMENT'
                CollectionClass = 'DOWNSTREAM_ASSESSMENT'
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
        throw "Missing CSV header: $Path"
    }

    return @(
        $Header -split ',' |
        ForEach-Object {
            $_.Trim().Trim('"')
        }
    )
}

function Get-IdentityColumn {
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

    foreach ($Name in $Preferred) {
        if ($Columns -contains $Name) {
            return $Name
        }
    }

    return $Columns[0]
}

function Get-FieldAuthority {
    param(
        [Parameter(Mandatory)]
        [string]$CollectionClass,

        [Parameter(Mandatory)]
        [string]$FieldName
    )

    if ($FieldName -match '(^|_)ID$|ID$') {
        return 'CONTROLLED_ID_ASSIGNMENT'
    }

    switch ($CollectionClass) {
        'CASE_DEFINITION' {
            return 'GOVERNED_CASE_DESIGN'
        }

        'CHAIN_DEFINITION' {
            return 'GOVERNED_DEPENDENCY_DESIGN'
        }

        'DIRECT_OBSERVATION' {
            return 'OBSERVED_EXECUTION_ONLY'
        }

        'SEMANTIC_ASSESSMENT' {
            return 'GOVERNED_ASSESSOR_JUDGMENT'
        }

        'DOWNSTREAM_ASSESSMENT' {
            return 'GOVERNED_ASSESSOR_JUDGMENT'
        }

        default {
            return 'GOVERNED_INPUT_REQUIRED'
        }
    }
}

function Get-FieldInstruction {
    param(
        [Parameter(Mandatory)]
        [string]$CollectionClass,

        [Parameter(Mandatory)]
        [string]$FieldName
    )

    if ($FieldName -match '(^|_)ID$|ID$') {
        return 'Assign a unique stable identifier. Do not reuse an existing identity.'
    }

    if ($FieldName -match 'Date|Time|Timestamp|Created|Recorded') {
        return 'Record the actual execution or assessment time using the format required by the source data dictionary.'
    }

    if ($FieldName -match 'Status|Result|Outcome|Disposition') {
        return 'Use only an authorized value defined by the trial procedure or data dictionary.'
    }

    if ($FieldName -match 'Evidence|Reference|Source|Provenance') {
        return 'Provide a traceable reference to the supporting controlled source or observation.'
    }

    if ($FieldName -match 'Notes|Rationale|Explanation|Justification') {
        return 'State the evidence-based rationale. Preserve uncertainty and contradictory observations.'
    }

    switch ($CollectionClass) {
        'CASE_DEFINITION' {
            return 'Complete from the governed trial design before execution begins.'
        }

        'CHAIN_DEFINITION' {
            return 'Define the canonical dependency relationship and expected propagation boundary.'
        }

        'DIRECT_OBSERVATION' {
            return 'Enter only what was directly observed during controlled execution. Do not infer missing facts.'
        }

        'SEMANTIC_ASSESSMENT' {
            return 'Assess against the declared semantic criteria and cite the supporting response evidence.'
        }

        'DOWNSTREAM_ASSESSMENT' {
            return 'Assess the downstream effect against the declared dependency and propagation criteria.'
        }

        default {
            return 'Complete from a governed source. Do not substitute assumptions.'
        }
    }
}

$PacketRegister = [System.Collections.Generic.List[object]]::new()
$FieldRegister = [System.Collections.Generic.List[object]]::new()
$MissingValueRegister = [System.Collections.Generic.List[object]]::new()
$GateRegister = [System.Collections.Generic.List[object]]::new()

foreach ($Trial in $Trials) {

    $WorkspaceRoot = Join-Path $ExecutionRoot $Trial.WorkspaceName
    $PacketRoot = Join-Path $WorkspaceRoot '00_COLLECTION_PACKET'

    New-Item -ItemType Directory -Force -Path $PacketRoot | Out-Null

    $TrialSequence = 0

    foreach ($Definition in $Trial.CollectionFiles) {

        $TrialSequence++

        $WorkingPath = Join-Path `
            (Join-Path $WorkspaceRoot $Definition.Folder) `
            $Definition.FileName

        if (-not (Test-Path -LiteralPath $WorkingPath)) {
            throw "Execution workspace file missing: $WorkingPath"
        }

        $Columns = @(Get-CsvColumns -Path $WorkingPath)
        $IdentityColumn = Get-IdentityColumn -Columns $Columns
        $Rows = @(Import-Csv -LiteralPath $WorkingPath)

        $FileStem = [System.IO.Path]::GetFileNameWithoutExtension(
            $Definition.FileName
        )

        $FieldGuidePath = Join-Path $PacketRoot "$FileStem.FIELD_GUIDE.csv"
        $MissingValuesPath = Join-Path $PacketRoot "$FileStem.MISSING_VALUES.csv"
        $CollectionCopyPath = Join-Path $PacketRoot "$FileStem.COLLECTION_COPY.csv"

        $FieldGuide = [System.Collections.Generic.List[object]]::new()

        for ($ColumnIndex = 0; $ColumnIndex -lt $Columns.Count; $ColumnIndex++) {

            $Column = $Columns[$ColumnIndex]
            $Authority = Get-FieldAuthority `
                -CollectionClass $Definition.CollectionClass `
                -FieldName $Column

            $Instruction = Get-FieldInstruction `
                -CollectionClass $Definition.CollectionClass `
                -FieldName $Column

            $FieldRecord = [pscustomobject]@{
                TheoremID = $Trial.TheoremID
                FileName = $Definition.FileName
                CollectionClass = $Definition.CollectionClass
                Sequence = $ColumnIndex + 1
                FieldName = $Column
                IdentityField = ($Column -eq $IdentityColumn)
                EntryAuthority = $Authority
                Instruction = $Instruction
                Required = $true
            }

            $FieldGuide.Add($FieldRecord)
            $FieldRegister.Add($FieldRecord)
        }

        $FieldGuide |
        Export-Csv `
            -LiteralPath $FieldGuidePath `
            -NoTypeInformation `
            -Encoding UTF8

        if ($Rows.Count -gt 0) {
            $Rows |
            Export-Csv `
                -LiteralPath $CollectionCopyPath `
                -NoTypeInformation `
                -Encoding UTF8
        }
        else {
            $Header = (
                $Columns |
                ForEach-Object {
                    '"' + $_.Replace('"','""') + '"'
                }
            ) -join ','

            Set-Content `
                -LiteralPath $CollectionCopyPath `
                -Value $Header `
                -Encoding UTF8
        }

        $LocalMissing = [System.Collections.Generic.List[object]]::new()

        if ($Rows.Count -eq 0) {

            foreach ($Column in $Columns) {

                $Record = [pscustomobject]@{
                    TheoremID = $Trial.TheoremID
                    FileName = $Definition.FileName
                    CsvRow = 'NEW_ROW_REQUIRED'
                    RecordIdentity = ''
                    MissingField = $Column
                    EntryAuthority = Get-FieldAuthority `
                        -CollectionClass $Definition.CollectionClass `
                        -FieldName $Column
                    Instruction = Get-FieldInstruction `
                        -CollectionClass $Definition.CollectionClass `
                        -FieldName $Column
                    CompletionStatus = 'NOT_ENTERED'
                }

                $LocalMissing.Add($Record)
                $MissingValueRegister.Add($Record)
            }
        }
        else {

            for ($RowIndex = 0; $RowIndex -lt $Rows.Count; $RowIndex++) {

                $Row = $Rows[$RowIndex]
                $IdentityProperty = $Row.PSObject.Properties[$IdentityColumn]

                $IdentityValue = if (
                    $null -ne $IdentityProperty -and
                    -not [string]::IsNullOrWhiteSpace(
                        [string]$IdentityProperty.Value
                    )
                ) {
                    [string]$IdentityProperty.Value
                }
                else {
                    "UNASSIGNED-ROW-$($RowIndex + 2)"
                }

                foreach ($Column in $Columns) {

                    $Property = $Row.PSObject.Properties[$Column]
                    $Value = if ($null -eq $Property) {
                        ''
                    }
                    else {
                        [string]$Property.Value
                    }

                    if ([string]::IsNullOrWhiteSpace($Value)) {

                        $Record = [pscustomobject]@{
                            TheoremID = $Trial.TheoremID
                            FileName = $Definition.FileName
                            CsvRow = $RowIndex + 2
                            RecordIdentity = $IdentityValue
                            MissingField = $Column
                            EntryAuthority = Get-FieldAuthority `
                                -CollectionClass $Definition.CollectionClass `
                                -FieldName $Column
                            Instruction = Get-FieldInstruction `
                                -CollectionClass $Definition.CollectionClass `
                                -FieldName $Column
                            CompletionStatus = 'NOT_ENTERED'
                        }

                        $LocalMissing.Add($Record)
                        $MissingValueRegister.Add($Record)
                    }
                }
            }
        }

        $LocalMissing |
        Export-Csv `
            -LiteralPath $MissingValuesPath `
            -NoTypeInformation `
            -Encoding UTF8

        $FileState = if ($Rows.Count -eq 0) {
            'NEW_EVIDENCE_ROWS_REQUIRED'
        }
        elseif ($LocalMissing.Count -gt 0) {
            'EXISTING_ROWS_REQUIRE_COMPLETION'
        }
        else {
            'COMPLETE_PENDING_VALIDATION'
        }

        $PacketRegister.Add(
            [pscustomobject]@{
                TheoremID = $Trial.TheoremID
                Sequence = $TrialSequence
                FileName = $Definition.FileName
                CollectionClass = $Definition.CollectionClass
                WorkingPath = $WorkingPath
                CollectionCopyPath = $CollectionCopyPath
                FieldGuidePath = $FieldGuidePath
                MissingValuesPath = $MissingValuesPath
                ExistingRowCount = $Rows.Count
                ColumnCount = $Columns.Count
                MissingValueCount = $LocalMissing.Count
                CollectionState = $FileState
            }
        )
    }

    $TrialFiles = @(
        $PacketRegister |
        Where-Object TheoremID -eq $Trial.TheoremID
    )

    $CaseBlocking = @(
        $TrialFiles |
        Where-Object {
            $_.CollectionClass -in @(
                'CASE_DEFINITION',
                'CHAIN_DEFINITION'
            ) -and
            $_.CollectionState -ne 'COMPLETE_PENDING_VALIDATION'
        }
    ).Count

    $EvidenceBlocking = @(
        $TrialFiles |
        Where-Object {
            $_.CollectionClass -eq 'DIRECT_OBSERVATION' -and
            $_.CollectionState -ne 'COMPLETE_PENDING_VALIDATION'
        }
    ).Count

    $AssessmentBlocking = @(
        $TrialFiles |
        Where-Object {
            $_.CollectionClass -in @(
                'SEMANTIC_ASSESSMENT',
                'DOWNSTREAM_ASSESSMENT'
            ) -and
            $_.CollectionState -ne 'COMPLETE_PENDING_VALIDATION'
        }
    ).Count

    $GateRegister.Add(
        [pscustomobject]@{
            TheoremID = $Trial.TheoremID
            CaseDefinitionGate = if ($CaseBlocking -eq 0) {
                'READY'
            }
            else {
                'BLOCKED'
            }
            EvidenceCollectionGate = if (
                $CaseBlocking -eq 0 -and
                $EvidenceBlocking -eq 0
            ) {
                'READY'
            }
            else {
                'BLOCKED'
            }
            AssessmentGate = if (
                $CaseBlocking -eq 0 -and
                $EvidenceBlocking -eq 0 -and
                $AssessmentBlocking -eq 0
            ) {
                'READY'
            }
            else {
                'BLOCKED'
            }
            ScoringGate = if (
                $CaseBlocking -eq 0 -and
                $EvidenceBlocking -eq 0 -and
                $AssessmentBlocking -eq 0
            ) {
                'PENDING_VALIDATION'
            }
            else {
                'BLOCKED'
            }
            CurrentExecutionPhase = if ($CaseBlocking -gt 0) {
                'CASE_AND_CHAIN_COMPLETION'
            }
            elseif ($EvidenceBlocking -gt 0) {
                'CONTROLLED_EVIDENCE_COLLECTION'
            }
            elseif ($AssessmentBlocking -gt 0) {
                'GOVERNED_ASSESSMENT'
            }
            else {
                'VALIDATION'
            }
        }
    )

    $Instructions = @"
# $($Trial.TheoremID) Evidence Collection Packet

**Generated:** $GeneratedAt  
**Trial:** $($Trial.TrialName)  
**Workspace:** $WorkspaceRoot  

## Purpose

This packet defines the exact governed fields that must be completed before theorem scoring can occur.

## Required Order

1. Complete all case and dependency definitions.
2. Validate identities and controlled conditions.
3. Execute the governed trial.
4. Record direct observations without inference.
5. Complete assessments against the declared criteria.
6. Preserve uncertainty and contradictory evidence.
7. Run the controlled execution validation harness.
8. Calculate metrics only after validation passes.

## Files

Each governed CSV has three packet artifacts:

- `*.COLLECTION_COPY.csv` — working collection copy
- `*.FIELD_GUIDE.csv` — field authority and completion instructions
- `*.MISSING_VALUES.csv` — exact missing-value worklist

## Evidence Rule

Do not fill a field merely to make a row complete. A value is admissible only when supported by governed case design, controlled observation, or an authorized assessment.

## Promotion Rule

Collection copies must not overwrite the authoritative trial package until validation, evidence review, and promotion controls pass.
"@

    Set-Content `
        -LiteralPath (Join-Path $PacketRoot 'README.md') `
        -Value $Instructions `
        -Encoding UTF8
}

$PacketRegisterPath = Join-Path $ReadinessRoot 'MS-T1_T2_COLLECTION_PACKET_REGISTER.csv'
$FieldRegisterPath = Join-Path $ReadinessRoot 'MS-T1_T2_FIELD_AUTHORITY_REGISTER.csv'
$MissingRegisterPath = Join-Path $ReadinessRoot 'MS-T1_T2_MISSING_VALUE_WORKLIST.csv'
$GateRegisterPath = Join-Path $ReadinessRoot 'MS-T1_T2_EXECUTION_GATE_REGISTER.csv'
$ManifestPath = Join-Path $ReadinessRoot 'MS-T1_T2_COLLECTION_PACKET_MANIFEST.json'
$ReportPath = Join-Path $ReadinessRoot 'MS-T1_T2_COLLECTION_PACKET_REPORT.md'

$PacketRegister |
Sort-Object TheoremID, Sequence |
Export-Csv `
    -LiteralPath $PacketRegisterPath `
    -NoTypeInformation `
    -Encoding UTF8

$FieldRegister |
Sort-Object TheoremID, FileName, Sequence |
Export-Csv `
    -LiteralPath $FieldRegisterPath `
    -NoTypeInformation `
    -Encoding UTF8

$MissingValueRegister |
Sort-Object TheoremID, FileName, CsvRow, MissingField |
Export-Csv `
    -LiteralPath $MissingRegisterPath `
    -NoTypeInformation `
    -Encoding UTF8

$GateRegister |
Sort-Object TheoremID |
Export-Csv `
    -LiteralPath $GateRegisterPath `
    -NoTypeInformation `
    -Encoding UTF8

$Manifest = [ordered]@{
    generatedAt = $GeneratedAt
    governanceState = 'EVIDENCE_COLLECTION_PACKET_CREATED'
    packetFiles = @($PacketRegister)
    fieldAuthorities = @($FieldRegister)
    missingValues = @($MissingValueRegister)
    executionGates = @($GateRegister)
}

$Manifest |
ConvertTo-Json -Depth 10 |
Set-Content `
    -LiteralPath $ManifestPath `
    -Encoding UTF8

$Report = [System.Collections.Generic.List[string]]::new()

$Report.Add('# MS-T1 and MS-T2 Evidence Collection Packet')
$Report.Add('')
$Report.Add("**Generated:** $GeneratedAt")
$Report.Add('')
$Report.Add('**State:** EVIDENCE_COLLECTION_PACKET_CREATED')
$Report.Add('')
$Report.Add('## Execution Gates')
$Report.Add('')
$Report.Add('| Theorem | Case Definitions | Evidence Collection | Assessment | Scoring | Current Phase |')
$Report.Add('|---|---|---|---|---|---|')

foreach ($Gate in $GateRegister | Sort-Object TheoremID) {
    $Report.Add(
        "| $($Gate.TheoremID) | $($Gate.CaseDefinitionGate) | $($Gate.EvidenceCollectionGate) | $($Gate.AssessmentGate) | $($Gate.ScoringGate) | $($Gate.CurrentExecutionPhase) |"
    )
}

$Report.Add('')
$Report.Add('## Collection Files')
$Report.Add('')
$Report.Add('| Theorem | File | Class | Existing Rows | Missing Values | State |')
$Report.Add('|---|---|---|---:|---:|---|')

foreach ($Packet in $PacketRegister | Sort-Object TheoremID, Sequence) {
    $Report.Add(
        "| $($Packet.TheoremID) | $($Packet.FileName) | $($Packet.CollectionClass) | $($Packet.ExistingRowCount) | $($Packet.MissingValueCount) | $($Packet.CollectionState) |"
    )
}

$Report.Add('')
$Report.Add('## Governance Constraint')
$Report.Add('')
$Report.Add('This packet identifies required evidence-entry work but does not populate observations, assessments, results, or dispositions.')

$Report |
Set-Content `
    -LiteralPath $ReportPath `
    -Encoding UTF8

Write-Host ''
Write-Host '==============================================================' -ForegroundColor Cyan
Write-Host 'MS-T1 / MS-T2 EVIDENCE COLLECTION PACKETS CREATED' -ForegroundColor Yellow
Write-Host '==============================================================' -ForegroundColor Cyan
Write-Host ''

$GateRegister |
Format-Table `
    TheoremID,
    CaseDefinitionGate,
    EvidenceCollectionGate,
    AssessmentGate,
    ScoringGate,
    CurrentExecutionPhase `
    -AutoSize

Write-Host ''
Write-Host 'Collection inventory:' -ForegroundColor Cyan

$PacketRegister |
Select-Object `
    TheoremID,
    FileName,
    CollectionClass,
    ExistingRowCount,
    MissingValueCount,
    CollectionState |
Format-Table -AutoSize

Write-Host ''
Write-Host "Packet register: $PacketRegisterPath" -ForegroundColor Green
Write-Host "Field authority register: $FieldRegisterPath" -ForegroundColor Green
Write-Host "Missing-value worklist: $MissingRegisterPath" -ForegroundColor Green
Write-Host "Execution gate register: $GateRegisterPath" -ForegroundColor Green
Write-Host "Manifest: $ManifestPath" -ForegroundColor Green
Write-Host "Report: $ReportPath" -ForegroundColor Green
