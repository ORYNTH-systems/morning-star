$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

$ManifestPath = Join-Path $RepositoryRoot 'engineering\manifests\batch-2\B2-PASS-01_MANIFEST.json'
$ReportRoot   = Join-Path $RepositoryRoot 'engineering\reports\batch-2\B2-PASS-01'

New-Item -ItemType Directory -Path $ReportRoot -Force | Out-Null

$Excluded = @(
    '\\.git\\',
    '\\Archive\\',
    '\\archive\\',
    '\\backups\\',
    '\\node_modules\\',
    '\\\.venv\\',
    '\\venv\\'
)

$Inventory = Get-ChildItem `
    -LiteralPath $RepositoryRoot `
    -Recurse `
    -File `
    -Filter '*.ps1' |
Where-Object {
    $Keep = $true

    foreach ($Pattern in $Excluded) {
        if ($_.FullName -match $Pattern) {
            $Keep = $false
            break
        }
    }

    $Keep
} |
ForEach-Object {

    $Content = Get-Content -LiteralPath $_.FullName -Raw

    [pscustomobject][ordered]@{
        ScriptName = $_.Name
        RelativePath = $_.FullName.Substring($RepositoryRoot.Length).TrimStart('\')
        SizeBytes = $_.Length

        ImportsSharedModule =
            $Content -match 'MorningStar\.Engine\.Common'

        UsesHashing =
            $Content -match 'Get-MSDeterministicHash|SHA256|ComputeHash'

        UsesCsv =
            $Content -match 'Import-MSCsv|Export-MSAtomicCsv|Import-Csv|Export-Csv'

        UsesAssertions =
            $Content -match 'Assert-MSCondition|Assert-'

        UsesBatchContext =
            $Content -match 'Get-MSBatchContext'

        HardcodedBatchA =
            $Content -match 'BATCH_A'

        FunctionCount =
            ([regex]::Matches(
                $Content,
                '(?m)^function\s+[A-Za-z0-9_-]+'
            )).Count
    }
}

$InventoryPath = Join-Path `
    $ReportRoot `
    'B2_PASS01_ENGINE_INVENTORY.csv'

$Inventory |
Sort-Object RelativePath |
Export-Csv `
    -LiteralPath $InventoryPath `
    -NoTypeInformation `
    -Encoding UTF8

$Summary = [ordered]@{
    PassID = 'B2-PASS-01'
    Result = 'PASS'
    ScriptsInventoried = @($Inventory).Count
    SharedModuleImports = @($Inventory | Where-Object ImportsSharedModule).Count
    HashConsumers = @($Inventory | Where-Object UsesHashing).Count
    CsvConsumers = @($Inventory | Where-Object UsesCsv).Count
    AssertionConsumers = @($Inventory | Where-Object UsesAssertions).Count
    BatchContextConsumers = @($Inventory | Where-Object UsesBatchContext).Count
    HardcodedBatchAConsumers = @($Inventory | Where-Object HardcodedBatchA).Count
    CompletedAt = (Get-Date).ToString('o')
}

$Summary |
ConvertTo-Json -Depth 5 |
Set-Content `
    -LiteralPath (
        Join-Path $ReportRoot 'B2_PASS01_STATUS.json'
    ) `
    -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — BATCH 2 PASS 01' -ForegroundColor Cyan
Write-Host 'ENGINE INVENTORY' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host ("Scripts inventoried:              {0}" -f $Summary.ScriptsInventoried)
Write-Host ("Shared module consumers:          {0}" -f $Summary.SharedModuleImports)
Write-Host ("Hash consumers:                  {0}" -f $Summary.HashConsumers)
Write-Host ("CSV consumers:                   {0}" -f $Summary.CsvConsumers)
Write-Host ("Assertion consumers:             {0}" -f $Summary.AssertionConsumers)
Write-Host ("BatchContext consumers:          {0}" -f $Summary.BatchContextConsumers)
Write-Host ("Hard-coded Batch A references:   {0}" -f $Summary.HardcodedBatchAConsumers)
Write-Host ''
Write-Host ("Inventory report:                {0}" -f $InventoryPath)
Write-Host ''
Write-Host 'BATCH 2 PASS 01: PASS' -ForegroundColor Green
Write-Host 'NO ENGINE FILES WERE MODIFIED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
