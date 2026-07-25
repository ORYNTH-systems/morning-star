param(
    [Parameter(Mandatory)]
    [string]$WorklistPath,

    [Parameter(Mandatory)]
    [string]$RegisterPath,

    [Parameter(Mandatory)]
    [string]$UnresolvedPath,

    [Parameter(Mandatory)]
    [string]$ProposalReportPath,

    [Parameter(Mandatory)]
    [string]$StatusPath
)

$MorningStarCommonModule = Join-Path $PSScriptRoot '..\..\..\..\..\..\..\engineering\modules\MorningStar.Engine.Common.psm1'
Import-Module $MorningStarCommonModule -Force -ErrorAction Stop

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest



function Get-IdentifierPrefix {
    param(
        [Parameter(Mandatory)]
        [string]$FieldName
    )

    $Map = @{
        AssessmentID     = 'ASSESS'
        AssessorID       = 'ASSR'
        CaseID           = 'CASE'
        DependencyEdgeID = 'EDGE'
        EventID          = 'EVENT'
        FrameworkID      = 'FRAME'
        GovernedObjectID = 'GOBJ'
        ObjectID         = 'OBJ'
        ObserverID       = 'OBS'
        PropertyID       = 'PROP'
        ResponseID       = 'RESP'
        RootObjectID     = 'ROOT'
        SeedObjectID     = 'SEED'
        SourceObjectID   = 'SOURCE'
        TargetObjectID   = 'TARGET'
        TerminalObjectID = 'TERMINAL'
    }

    if (-not $Map.ContainsKey($FieldName)) {
        throw "No controlled identifier prefix is defined for field '$FieldName'."
    }

    return $Map[$FieldName]
}

function Get-DeterministicIdentifier {
    param(
        [Parameter(Mandatory)]
        [psobject]$WorkItem
    )

    $Prefix = Get-IdentifierPrefix -FieldName $WorkItem.FieldName

    $CanonicalKey = @(
        $WorkItem.TheoremID
        $WorkItem.FileName
        $WorkItem.CsvRow
        $WorkItem.RecordIdentity
        $WorkItem.FieldName
    ) -join '|'

    $Hash = Get-MSDeterministicHash -Value $CanonicalKey
    $Suffix = $Hash.Substring(0, 12)

    return "$($WorkItem.TheoremID)-$Prefix-$Suffix"
}



$Columns = @(
    'TransactionID'
    'BatchID'
    'EngineName'
    'EngineVersion'
    'TransactionType'
    'TransactionStatus'
    'TheoremID'
    'SourceFile'
    'CsvRow'
    'RecordIdentity'
    'EntryAuthority'
    'FieldName'
    'CurrentValue'
    'ProposedValue'
    'SourceReference'
    'SourceSHA256'
    'TargetCompletionForm'
    'IssuanceID'
    'DependencyID'
    'CaseID'
    'EvidenceID'
    'AssessmentID'
    'ProposedBy'
    'ProposedAt'
    'ValidationStatus'
    'ValidationMessage'
    'SynchronizationStatus'
    'SynchronizedBy'
    'SynchronizedAt'
    'RollbackStatus'
    'RollbackReference'
    'SupersedesTransactionID'
    'Notes'
)

$Worklist = @(Import-Csv -LiteralPath $WorklistPath)

if ($Worklist.Count -ne 42) {
    throw "Expected 42 canonical work items; discovered $($Worklist.Count)."
}

[object[]]$ExistingTransactions = @()

if (
    Test-Path -LiteralPath $RegisterPath -PathType Leaf
) {
    [object[]]$ExistingTransactions = @(
        Import-Csv -LiteralPath $RegisterPath
    )
}

if (@($ExistingTransactions).Count -gt 0) {
    throw "The transaction register already contains $($ExistingTransactions.Count) transaction rows. Stage 3 will not overwrite existing audit evidence."
}

$SourceHash = (
    Get-FileHash -LiteralPath $WorklistPath -Algorithm SHA256
).Hash

$ProposedAt = (Get-Date).ToString('o')
$Transactions = [System.Collections.Generic.List[object]]::new()
$Unresolved = [System.Collections.Generic.List[object]]::new()
$Sequence = 0

foreach ($WorkItem in $Worklist) {
    $Sequence++

    $TransactionKey = @(
        'BATCH-A'
        $WorkItem.TheoremID
        $WorkItem.FileName
        $WorkItem.CsvRow
        $WorkItem.RecordIdentity
        $WorkItem.EntryAuthority
        $WorkItem.FieldName
    ) -join '|'

    $TransactionHash = Get-MSDeterministicHash -Value $TransactionKey
    $TransactionID = 'BATCH-A-TXN-' + $TransactionHash.Substring(0, 16)

    $EngineName = switch ($WorkItem.EntryAuthority) {
        'CONTROLLED_ID_ASSIGNMENT' {
            'CONTROLLED_ID_ENGINE'
        }

        'GOVERNED_CASE_DESIGN' {
            'GOVERNED_CASE_DESIGN_ENGINE'
        }

        'GOVERNED_DEPENDENCY_DESIGN' {
            'GOVERNED_DEPENDENCY_DESIGN_ENGINE'
        }

        default {
            throw "Unsupported entry authority '$($WorkItem.EntryAuthority)'."
        }
    }

    $ProposedValue = ''
    $TransactionStatus = 'PROPOSED'
    $ValidationStatus = 'NOT_RUN'
    $ValidationMessage = ''
    $Notes = ''

    if ($WorkItem.EntryAuthority -eq 'CONTROLLED_ID_ASSIGNMENT') {
        $ProposedValue = Get-DeterministicIdentifier -WorkItem $WorkItem
        $Notes = 'Deterministic controlled identifier generated from the canonical work-item identity.'
    }
    else {
        $TransactionStatus = 'PROPOSED'
        $ValidationStatus = 'INDETERMINATE'
        $ValidationMessage = 'Governed design value requires constitutional review and cannot be generated automatically.'
        $Notes = 'Preserved as unresolved; no design value was inferred or fabricated.'

        $Unresolved.Add(
            [pscustomobject]@{
                WorkItemIndex = $Sequence
                TransactionID = $TransactionID
                TheoremID = $WorkItem.TheoremID
                SourceFile = $WorkItem.FileName
                CsvRow = $WorkItem.CsvRow
                RecordIdentity = $WorkItem.RecordIdentity
                EntryAuthority = $WorkItem.EntryAuthority
                FieldName = $WorkItem.FieldName
                Instruction = $WorkItem.Instruction
                Reason = 'GOVERNED_DESIGN_REVIEW_REQUIRED'
                RequiredResolution = 'Provide a constitutionally supported value before validation and synchronization.'
                ResolutionStatus = 'OPEN'
            }
        )
    }

    $Transactions.Add(
        [pscustomobject]@{
            TransactionID = $TransactionID
            BatchID = 'BATCH-A'
            EngineName = $EngineName
            EngineVersion = '1.0.0'
            TransactionType = 'PROPOSE_WORKLIST_VALUE'
            TransactionStatus = $TransactionStatus
            TheoremID = $WorkItem.TheoremID
            SourceFile = $WorkItem.FileName
            CsvRow = $WorkItem.CsvRow
            RecordIdentity = $WorkItem.RecordIdentity
            EntryAuthority = $WorkItem.EntryAuthority
            FieldName = $WorkItem.FieldName
            CurrentValue = $WorkItem.CurrentValue
            ProposedValue = $ProposedValue
            SourceReference = $WorklistPath.Replace('\', '/')
            SourceSHA256 = $SourceHash
            TargetCompletionForm = $WorkItem.FileName
            IssuanceID = ''
            DependencyID = ''
            CaseID = if ($WorkItem.FieldName -eq 'CaseID') { $ProposedValue } else { '' }
            EvidenceID = ''
            AssessmentID = if ($WorkItem.FieldName -eq 'AssessmentID') { $ProposedValue } else { '' }
            ProposedBy = 'BATCH_A_STAGE_3_PROPOSAL_ENGINE'
            ProposedAt = $ProposedAt
            ValidationStatus = $ValidationStatus
            ValidationMessage = $ValidationMessage
            SynchronizationStatus = 'NOT_SYNCHRONIZED'
            SynchronizedBy = ''
            SynchronizedAt = ''
            RollbackStatus = 'NOT_APPLICABLE'
            RollbackReference = ''
            SupersedesTransactionID = ''
            Notes = $Notes
        }
    )
}

$DuplicateTransactionIDs = @(
    $Transactions |
        Group-Object TransactionID |
        Where-Object Count -gt 1
)

$ControlledTransactions = @(
    $Transactions |
        Where-Object EntryAuthority -eq 'CONTROLLED_ID_ASSIGNMENT'
)

$DuplicateControlledValues = @(
    $ControlledTransactions |
        Group-Object ProposedValue |
        Where-Object Count -gt 1
)

if ($DuplicateTransactionIDs.Count -gt 0) {
    throw "Duplicate deterministic transaction identifiers were generated."
}

if ($DuplicateControlledValues.Count -gt 0) {
    throw "Duplicate controlled identifiers were generated."
}

Export-MSAtomicCsv `
    -Data $Transactions `
    -Path $RegisterPath `
    -Columns $Columns

$UnresolvedColumns = @(
    'WorkItemIndex'
    'TransactionID'
    'TheoremID'
    'SourceFile'
    'CsvRow'
    'RecordIdentity'
    'EntryAuthority'
    'FieldName'
    'Instruction'
    'Reason'
    'RequiredResolution'
    'ResolutionStatus'
)

Export-MSAtomicCsv `
    -Data $Unresolved `
    -Path $UnresolvedPath `
    -Columns $UnresolvedColumns

$ProposalReport = @(
    $Transactions |
        Select-Object `
            TransactionID,
            TheoremID,
            SourceFile,
            CsvRow,
            RecordIdentity,
            EntryAuthority,
            FieldName,
            ProposedValue,
            TransactionStatus,
            ValidationStatus,
            SynchronizationStatus
)

$ProposalColumns = @(
    'TransactionID'
    'TheoremID'
    'SourceFile'
    'CsvRow'
    'RecordIdentity'
    'EntryAuthority'
    'FieldName'
    'ProposedValue'
    'TransactionStatus'
    'ValidationStatus'
    'SynchronizationStatus'
)

Export-MSAtomicCsv `
    -Data $ProposalReport `
    -Path $ProposalReportPath `
    -Columns $ProposalColumns

$Status = [ordered]@{
    BatchID = 'BATCH-A'
    Stage = 'STAGE-3-PROPOSAL-GENERATION'
    EngineVersion = '1.0.0'
    ExecutedAt = $ProposedAt
    Status = if (
        $Transactions.Count -eq 42 -and
        $ControlledTransactions.Count -eq 22 -and
        $Unresolved.Count -eq 20
    ) {
        'PASS_WITH_GOVERNED_REVIEW_REQUIRED'
    }
    else {
        'FAIL'
    }
    CanonicalWorkItems = $Worklist.Count
    TransactionsGenerated = $Transactions.Count
    ControlledIDProposals = $ControlledTransactions.Count
    GovernedDesignItemsUnresolved = $Unresolved.Count
    DuplicateTransactionIDs = $DuplicateTransactionIDs.Count
    DuplicateControlledIdentifiers = $DuplicateControlledValues.Count
    CanonicalWorklistSHA256 = $SourceHash
    CanonicalWorklistModified = $false
    RequiredNextStage = 'Resolve the 20 governed design items before Stage 4 validation.'
}

$Status |
    ConvertTo-Json -Depth 8 |
    Set-Content -LiteralPath $StatusPath -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — BATCH A STAGE 3 PROPOSAL ENGINE' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Canonical work items:          $($Worklist.Count)"
Write-Host "Transactions generated:        $($Transactions.Count)"
Write-Host "Controlled ID proposals:       $($ControlledTransactions.Count)"
Write-Host "Governed design unresolved:    $($Unresolved.Count)"
Write-Host "Duplicate transaction IDs:     $($DuplicateTransactionIDs.Count)"
Write-Host "Duplicate controlled IDs:      $($DuplicateControlledValues.Count)"
Write-Host ''
Write-Host "Transaction register:          $RegisterPath"
Write-Host "Unresolved report:             $UnresolvedPath"
Write-Host "Proposal report:               $ProposalReportPath"
Write-Host "Stage 3 status:                $StatusPath"
Write-Host ''
Write-Host 'CANONICAL WORKLIST WAS NOT MODIFIED.' -ForegroundColor Yellow
Write-Host '======================================================================' -ForegroundColor Cyan



