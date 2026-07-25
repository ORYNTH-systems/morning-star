$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (
    Resolve-Path (Join-Path $PSScriptRoot '..\..')
).Path

$ReportRoot = Join-Path `
    $RepositoryRoot `
    'engineering\reports\batch-3\B3-PASS-01'

$ManifestPath = Join-Path `
    $RepositoryRoot `
    'engineering\manifests\batch-3\B3-PASS-01_MANIFEST.json'

New-Item `
    -ItemType Directory `
    -Path $ReportRoot `
    -Force |
    Out-Null

$ExcludedPatterns = @(
    '\\.git\\'
    '\\Archive\\'
    '\\archive\\'
    '\\backups\\'
    '\\Repository_Cleanup\\'
    '\\node_modules\\'
    '\\\.venv\\'
    '\\venv\\'
    '\\dist\\'
    '\\build\\'
)

$RuntimeFiles = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Recurse `
        -File |
    Where-Object {
        $Path = $_.FullName

        $Excluded = @(
            $ExcludedPatterns |
            Where-Object {
                $Path -match $_
            }
        ).Count -gt 0

        $RelevantExtension = $_.Extension -in @(
            '.py'
            '.ps1'
            '.psm1'
            '.json'
            '.toml'
            '.yaml'
            '.yml'
        )

        -not $Excluded -and
        $RelevantExtension
    }
)

$RuntimeInventory = @(
    foreach ($File in $RuntimeFiles) {
        $Content = Get-Content `
            -LiteralPath $File.FullName `
            -Raw `
            -ErrorAction SilentlyContinue

        if ($null -eq $Content) {
            $Content = ''
        }

        $RelativePath = $File.FullName.
            Substring($RepositoryRoot.Length).
            TrimStart('\')

        [pscustomobject][ordered]@{
            FileName = $File.Name
            RelativePath = $RelativePath
            Extension = $File.Extension
            SizeBytes = $File.Length
            IsRuntimeFile = (
                $RelativePath -match
                '(^|\\)(runtime|cli|api|config|models|schemas)(\\|$)'
            )
            IsEntryPointCandidate = (
                $File.Name -in @(
                    '__main__.py'
                    'main.py'
                    'runtime.py'
                    'pyproject.toml'
                ) -or
                $Content -match
                '(?i)\[project\.scripts\]|if __name__ == [''"]__main__[''"]'
            )
            UsesArgumentParsing = (
                $Content -match
                '(?i)argparse|click|typer|Parameter\(|param\('
            )
            UsesConfiguration = (
                $Content -match
                '(?i)config|configuration|runtime\.config|schema'
            )
            UsesLogging = (
                $Content -match
                '(?i)logging|logger|Write-Host|Write-Verbose|Write-Error|Write-Warning'
            )
            UsesExplicitExit = (
                $Content -match
                '(?i)\bexit\s+\d+|sys\.exit|ExitCode'
            )
            UsesExceptions = (
                $Content -match
                '(?i)\bthrow\b|\braise\b|catch\s*\{|except\s+'
            )
            UsesTimestamps = (
                $Content -match
                '(?i)Get-Date|datetime\.|time\.time|utcnow|now\('
            )
            UsesGuidOrUuid = (
                $Content -match
                '(?i)\[guid\]|NewGuid|uuid\.|uuid4'
            )
            UsesRandomness = (
                $Content -match
                '(?i)Get-Random|random\.|secrets\.'
            )
            UsesFilesystemEnumeration = (
                $Content -match
                '(?i)Get-ChildItem|os\.listdir|glob\(|rglob\('
            )
            UsesCultureSensitiveOperations = (
                $Content -match
                '(?i)ToString\(|locale\.|culture|CurrentCulture'
            )
            SHA256 = (
                Get-FileHash `
                    -LiteralPath $File.FullName `
                    -Algorithm SHA256
            ).Hash
        }
    }
)

$RuntimeInventoryPath = Join-Path `
    $ReportRoot `
    'B3_PASS01_RUNTIME_INVENTORY.csv'

$RuntimeInventory |
    Sort-Object RelativePath |
    Export-Csv `
        -LiteralPath $RuntimeInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$CommandInventory = @(
    foreach ($File in $RuntimeFiles) {
        $Content = Get-Content `
            -LiteralPath $File.FullName `
            -Raw `
            -ErrorAction SilentlyContinue

        if ($null -eq $Content) {
            continue
        }

        $RelativePath = $File.FullName.
            Substring($RepositoryRoot.Length).
            TrimStart('\')

        $CommandMatches = @(
            [regex]::Matches(
                $Content,
                '(?im)^\s*(?:@(?:app|cli)\.command\([^\)]*\)\s*)?def\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('
            )
        )

        foreach ($Match in $CommandMatches) {
            [pscustomobject][ordered]@{
                RelativePath = $RelativePath
                CommandName = $Match.Groups[1].Value
                CommandType = if (
                    $Content -match
                    '(?i)@(?:app|cli)\.command'
                ) {
                    'CLI_COMMAND'
                }
                else {
                    'FUNCTION_ENTRY'
                }
                HasArgumentParsing = (
                    $Content -match
                    '(?i)argparse|click|typer'
                )
                HasExplicitExitBehavior = (
                    $Content -match
                    '(?i)sys\.exit|\bexit\s+\d+|ExitCode'
                )
                HasErrorBoundary = (
                    $Content -match
                    '(?i)try\s*:|except\s+|catch\s*\{'
                )
            }
        }
    }
)

$CommandInventoryPath = Join-Path `
    $ReportRoot `
    'B3_PASS01_COMMAND_INVENTORY.csv'

$CommandInventory |
    Sort-Object RelativePath, CommandName |
    Export-Csv `
        -LiteralPath $CommandInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$ConfigurationInventory = @(
    foreach ($File in $RuntimeFiles) {
        if (
            $File.Extension -notin @(
                '.json'
                '.toml'
                '.yaml'
                '.yml'
                '.py'
                '.ps1'
                '.psm1'
            )
        ) {
            continue
        }

        $Content = Get-Content `
            -LiteralPath $File.FullName `
            -Raw `
            -ErrorAction SilentlyContinue

        if ($null -eq $Content) {
            continue
        }

        if (
            $Content -notmatch
            '(?i)config|configuration|schema|environment|default'
        ) {
            continue
        }

        [pscustomobject][ordered]@{
            RelativePath = $File.FullName.
                Substring($RepositoryRoot.Length).
                TrimStart('\')
            FileType = $File.Extension
            IsConfigurationFile = (
                $File.Name -match
                '(?i)config|settings|schema|pyproject'
            )
            DefinesDefaults = (
                $Content -match
                '(?i)default|defaults'
            )
            ReadsEnvironment = (
                $Content -match
                '(?i)os\.environ|os\.getenv|\$env:'
            )
            PerformsValidation = (
                $Content -match
                '(?i)validate|schema|assert|raise|throw'
            )
            UsesHardcodedPaths = (
                $Content -match
                '(?i)C:\\Users\\|BATCH_A|VOLUME_I_FOUNDATION'
            )
        }
    }
)

$ConfigurationInventoryPath = Join-Path `
    $ReportRoot `
    'B3_PASS01_CONFIGURATION_INVENTORY.csv'

$ConfigurationInventory |
    Sort-Object RelativePath |
    Export-Csv `
        -LiteralPath $ConfigurationInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$LoggingInventory = @(
    foreach ($File in $RuntimeFiles) {
        $Content = Get-Content `
            -LiteralPath $File.FullName `
            -Raw `
            -ErrorAction SilentlyContinue

        if ($null -eq $Content) {
            continue
        }

        $LoggingMatches = @(
            [regex]::Matches(
                $Content,
                '(?i)\b(logging\.(debug|info|warning|error|critical)|logger\.(debug|info|warning|error|critical)|Write-(Host|Verbose|Warning|Error|Information))\b'
            )
        )

        if ($LoggingMatches.Count -eq 0) {
            continue
        }

        [pscustomobject][ordered]@{
            RelativePath = $File.FullName.
                Substring($RepositoryRoot.Length).
                TrimStart('\')
            LoggingCalls = $LoggingMatches.Count
            UsesPythonLogging = (
                $Content -match
                '(?i)logging\.|logger\.'
            )
            UsesPowerShellHostOutput = (
                $Content -match
                '(?i)Write-Host'
            )
            UsesStructuredLogging = (
                $Content -match
                '(?i)json.*log|structured.*log|extra\s*='
            )
            UsesSeverityLevels = (
                $Content -match
                '(?i)debug|info|warning|error|critical'
            )
        }
    }
)

$LoggingInventoryPath = Join-Path `
    $ReportRoot `
    'B3_PASS01_LOGGING_INVENTORY.csv'

$LoggingInventory |
    Sort-Object RelativePath |
    Export-Csv `
        -LiteralPath $LoggingInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$DeterminismInventory = @(
    foreach ($Row in $RuntimeInventory) {
        if (
            $Row.UsesTimestamps -or
            $Row.UsesGuidOrUuid -or
            $Row.UsesRandomness -or
            $Row.UsesFilesystemEnumeration -or
            $Row.UsesCultureSensitiveOperations
        ) {
            [pscustomobject][ordered]@{
                RelativePath = $Row.RelativePath
                UsesTimestamps = $Row.UsesTimestamps
                UsesGuidOrUuid = $Row.UsesGuidOrUuid
                UsesRandomness = $Row.UsesRandomness
                UsesFilesystemEnumeration = $Row.UsesFilesystemEnumeration
                UsesCultureSensitiveOperations = $Row.UsesCultureSensitiveOperations
                DeterminismRisk = if (
                    $Row.UsesRandomness -or
                    $Row.UsesGuidOrUuid
                ) {
                    'HIGH'
                }
                elseif (
                    $Row.UsesTimestamps -or
                    $Row.UsesFilesystemEnumeration -or
                    $Row.UsesCultureSensitiveOperations
                ) {
                    'MODERATE'
                }
                else {
                    'LOW'
                }
                ReviewDisposition = 'REQUIRES_PASS04_REVIEW'
            }
        }
    }
)

$DeterminismInventoryPath = Join-Path `
    $ReportRoot `
    'B3_PASS01_DETERMINISM_INVENTORY.csv'

$DeterminismInventory |
    Sort-Object DeterminismRisk, RelativePath |
    Export-Csv `
        -LiteralPath $DeterminismInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$Summary = [ordered]@{
    PassID = 'B3-PASS-01'
    Result = 'PASS'
    RuntimeFilesInventoried = $RuntimeInventory.Count
    EntryPointCandidates = @(
        $RuntimeInventory |
            Where-Object IsEntryPointCandidate
    ).Count
    CommandsInventoried = $CommandInventory.Count
    ConfigurationRecords = $ConfigurationInventory.Count
    LoggingRecords = $LoggingInventory.Count
    DeterminismRiskRecords = $DeterminismInventory.Count
    HighDeterminismRisks = @(
        $DeterminismInventory |
            Where-Object DeterminismRisk -eq 'HIGH'
    ).Count
    RuntimeFilesModified = 0
    CompletedAt = (Get-Date).ToString('o')
}

$Summary |
    ConvertTo-Json -Depth 6 |
    Set-Content `
        -LiteralPath (
            Join-Path $ReportRoot 'B3_PASS01_STATUS.json'
        ) `
        -Encoding UTF8

$ExistingManifest = Get-Content `
    -LiteralPath $ManifestPath `
    -Raw |
    ConvertFrom-Json

[ordered]@{
    PassID = 'B3-PASS-01'
    BatchID = 'BATCH-3'
    Purpose = $ExistingManifest.Purpose
    Result = 'PASS'
    Status = 'COMPLETE'
    ScriptPath = $ExistingManifest.ScriptPath
    ReportsRoot = $ExistingManifest.ReportsRoot
    BackupRoot = $ExistingManifest.BackupRoot
    RollbackBoundary = $ExistingManifest.RollbackBoundary
    RuntimeChangesAuthorized = $false
    RuntimeFilesInventoried = $Summary.RuntimeFilesInventoried
    EntryPointCandidates = $Summary.EntryPointCandidates
    CommandsInventoried = $Summary.CommandsInventoried
    ConfigurationRecords = $Summary.ConfigurationRecords
    LoggingRecords = $Summary.LoggingRecords
    DeterminismRiskRecords = $Summary.DeterminismRiskRecords
    HighDeterminismRisks = $Summary.HighDeterminismRisks
    CompletedAt = $Summary.CompletedAt
} |
    ConvertTo-Json -Depth 8 |
    Set-Content `
        -LiteralPath $ManifestPath `
        -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — BATCH 3 PASS 01' -ForegroundColor Cyan
Write-Host 'RUNTIME INVENTORY' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Runtime files inventoried:             $($Summary.RuntimeFilesInventoried)"
Write-Host "Entry-point candidates:                $($Summary.EntryPointCandidates)"
Write-Host "Commands inventoried:                  $($Summary.CommandsInventoried)"
Write-Host "Configuration records:                 $($Summary.ConfigurationRecords)"
Write-Host "Logging records:                       $($Summary.LoggingRecords)"
Write-Host "Determinism risk records:              $($Summary.DeterminismRiskRecords)"
Write-Host "High determinism risks:                $($Summary.HighDeterminismRisks)"
Write-Host "Runtime files modified:                0"
Write-Host ''
Write-Host 'BATCH 3 PASS 01: PASS' -ForegroundColor Green
Write-Host 'THE RUNTIME AND CLI BASELINE IS NOW INVENTORIED.' -ForegroundColor Green
Write-Host 'NO RUNTIME OR CLI FILES WERE MODIFIED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
