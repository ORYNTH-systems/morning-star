$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (
    Resolve-Path (Join-Path $PSScriptRoot '..\..')
).Path

$ModulePath = Join-Path `
    $RepositoryRoot `
    'engineering\modules\MorningStar.Engine.Common.psm1'

$ReportRoot = Join-Path `
    $RepositoryRoot `
    'engineering\reports\batch-3\B3-PASS-04'

$ManifestPath = Join-Path `
    $RepositoryRoot `
    'engineering\manifests\batch-3\B3-PASS-04_MANIFEST.json'

$CommandSurfacePath = Join-Path `
    $RepositoryRoot `
    'runtime\cli\command-surface.json'

New-Item `
    -ItemType Directory `
    -Path $ReportRoot `
    -Force |
    Out-Null

Import-Module $ModulePath -Force -ErrorAction Stop

Assert-MSCondition `
    -Condition (
        Test-Path -LiteralPath $CommandSurfacePath -PathType Leaf
    ) `
    -Message "Command surface is missing: $CommandSurfacePath" `
    -InvariantID 'MS-B3-P4-COMMAND-SURFACE'

$PythonCommand = Get-Command `
    -Name python `
    -ErrorAction SilentlyContinue

Assert-MSCondition `
    -Condition ($null -ne $PythonCommand) `
    -Message 'Python is unavailable in PATH.' `
    -InvariantID 'MS-B3-P4-PYTHON'

$CommandSurface = Get-Content `
    -LiteralPath $CommandSurfacePath `
    -Raw |
    ConvertFrom-Json

$CanonicalConsole = [string]$CommandSurface.Console.CanonicalName
$TargetModule = [string]$CommandSurface.Console.Module

# Pass 03 routes the public console through this module.
$OperationalModule = (
    ($TargetModule -split '\.')[0..(
        ($TargetModule -split '\.').Count - 2
    )] -join '.'
) + '.operational'

# =====================================================================
# Preserve Stage 5 and Stage 6 authoritative artifacts.
# =====================================================================

$BatchContext = Get-MSBatchContext `
    -RepositoryRoot $RepositoryRoot `
    -BatchID 'BATCH_A'

$ProtectedPaths = @(
    (Join-Path $BatchContext.Stage5Root 'Reports\BATCH_A_STAGE_5_COMPLETION_STATUS.json')
    (Join-Path $BatchContext.Stage5Root 'Evidence\BATCH_A_STAGE_5_EVIDENCE_CHAIN.csv')
    (Join-Path $BatchContext.Stage5Root 'Evidence\BATCH_A_STAGE_5_FINAL_VALIDATION_REGISTER.csv')
    (Join-Path $BatchContext.Stage6Root 'Reports\BATCH_A_STAGE_6_COMPLETION_STATUS.json')
    (Join-Path $BatchContext.Stage6Root 'Evidence\BATCH_A_STAGE_6_GOVERNANCE_DISPOSITION_REGISTER.csv')
    (Join-Path $BatchContext.Stage6Root 'Governance_Packets\BATCH_A_STAGE_6_GOVERNANCE_PACKET.csv')
)

$ProtectedBefore = @(
    foreach ($Path in $ProtectedPaths) {
        Get-MSFileHashRecord -LiteralPath $Path
    }
)

# =====================================================================
# Locate the runtime project root and operational configuration.
# =====================================================================

$OperationalModuleCandidates = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Recurse `
        -File `
        -Filter 'operational.py' |
    Where-Object {
        $_.FullName -notmatch
        '\\(\.git|Archive|archive|backups|\.venv|venv|build|dist)\\'
    }
)

Assert-MSCondition `
    -Condition ($OperationalModuleCandidates.Count -eq 1) `
    -Message (
        'Expected one operational.py file; found ' +
        "$($OperationalModuleCandidates.Count)."
    ) `
    -InvariantID 'MS-B3-P4-OPERATIONAL-MODULE'

$OperationalModulePath = $OperationalModuleCandidates[0].FullName
$PackageDirectory = Split-Path -Parent $OperationalModulePath
$ProjectRoot = Split-Path -Parent $PackageDirectory

$OperationalConfigPath = Join-Path `
    $PackageDirectory `
    'operational-defaults.json'

Assert-MSCondition `
    -Condition (
        Test-Path -LiteralPath $OperationalConfigPath -PathType Leaf
    ) `
    -Message "Operational configuration is missing: $OperationalConfigPath" `
    -InvariantID 'MS-B3-P4-CONFIG'

# =====================================================================
# Record the controlled runtime environment.
# =====================================================================

$EnvironmentRegisterPath = Join-Path `
    $ReportRoot `
    'B3_PASS04_RUNTIME_ENVIRONMENT.json'

$EnvironmentRecord = [ordered]@{
    RepositoryRoot = $RepositoryRoot
    ProjectRoot = $ProjectRoot
    CanonicalConsole = $CanonicalConsole
    OperationalModule = $OperationalModule
    PythonPath = $PythonCommand.Source
    PythonVersion = (& python --version 2>&1 | Out-String).Trim()
    PowerShellVersion = $PSVersionTable.PSVersion.ToString()
    OperatingSystem = [Environment]::OSVersion.VersionString
    ProcessorCount = [Environment]::ProcessorCount
    CurrentCulture = [System.Globalization.CultureInfo]::CurrentCulture.Name
    CurrentUICulture = [System.Globalization.CultureInfo]::CurrentUICulture.Name
    TimeZone = [System.TimeZoneInfo]::Local.Id
    LogLevelOverride = $env:MORNING_STAR_LOG_LEVEL
    RecordedAt = (Get-Date).ToString('o')
}

$EnvironmentRecord |
    ConvertTo-Json -Depth 6 |
    Set-Content `
        -LiteralPath $EnvironmentRegisterPath `
        -Encoding UTF8

# =====================================================================
# Execute canonical help repeatedly under identical conditions.
# =====================================================================

$ExecutionRegister = [System.Collections.Generic.List[object]]::new()
$DifferenceRegister = [System.Collections.Generic.List[object]]::new()

$PreviousPythonPath = $env:PYTHONPATH
$PreviousLogLevel = $env:MORNING_STAR_LOG_LEVEL

try {
    $env:PYTHONPATH = if (
        [string]::IsNullOrWhiteSpace($PreviousPythonPath)
    ) {
        $ProjectRoot
    }
    else {
        "$ProjectRoot;$PreviousPythonPath"
    }

    $env:MORNING_STAR_LOG_LEVEL = 'INFO'

    for ($RunNumber = 1; $RunNumber -le 5; $RunNumber++) {
        $OutputPath = Join-Path `
            $ReportRoot `
            ("B3_PASS04_HELP_RUN_{0}.txt" -f $RunNumber)

        $StartedAt = Get-Date

        $Output = @(
            & python -c (
                "import sys; " +
                "from $OperationalModule import main; " +
                "sys.argv=['$CanonicalConsole','--help']; " +
                "raise SystemExit(main())"
            ) 2>&1
        )

        $ExitCode = $LASTEXITCODE
        $CompletedAt = Get-Date
        $ElapsedMilliseconds = [int](
            $CompletedAt - $StartedAt
        ).TotalMilliseconds

        $Output |
            Set-Content `
                -LiteralPath $OutputPath `
                -Encoding UTF8

        $OutputHash = (
            Get-FileHash `
                -LiteralPath $OutputPath `
                -Algorithm SHA256
        ).Hash

        $ExecutionRegister.Add(
            [pscustomobject][ordered]@{
                RunID = "HELP-$RunNumber"
                Operation = 'CANONICAL_HELP'
                RunNumber = $RunNumber
                ExitCode = $ExitCode
                OutputPath = $OutputPath
                OutputSHA256 = $OutputHash
                ElapsedMilliseconds = $ElapsedMilliseconds
                Status = if ($ExitCode -eq 0) {
                    'PASS'
                }
                else {
                    'FAIL'
                }
            }
        )
    }
}
finally {
    $env:PYTHONPATH = $PreviousPythonPath
    $env:MORNING_STAR_LOG_LEVEL = $PreviousLogLevel
}

$HelpRows = @(
    $ExecutionRegister |
        Where-Object Operation -eq 'CANONICAL_HELP'
)

$ReferenceHelp = $HelpRows |
    Sort-Object RunNumber |
    Select-Object -First 1

foreach ($HelpRow in $HelpRows) {
    if (
        $HelpRow.ExitCode -ne $ReferenceHelp.ExitCode -or
        $HelpRow.OutputSHA256 -ne $ReferenceHelp.OutputSHA256
    ) {
        $DifferenceRegister.Add(
            [pscustomobject][ordered]@{
                DifferenceID = "HELP-DIFF-$($HelpRow.RunNumber)"
                Operation = 'CANONICAL_HELP'
                ReferenceRun = $ReferenceHelp.RunNumber
                ComparedRun = $HelpRow.RunNumber
                ReferenceExitCode = $ReferenceHelp.ExitCode
                ComparedExitCode = $HelpRow.ExitCode
                ReferenceSHA256 = $ReferenceHelp.OutputSHA256
                ComparedSHA256 = $HelpRow.OutputSHA256
                DifferenceClass = 'OBSERVABLE_OUTPUT_OR_EXIT_VARIATION'
                AuthorizedVariation = $false
            }
        )
    }
}

# =====================================================================
# Repeated configuration read-back verification.
# =====================================================================

$ConfigProbePath = Join-Path `
    $ReportRoot `
    'Probe-ConfigurationDeterminism.py'

@(
    'import importlib'
    'import json'
    'import pathlib'
    'import sys'
    ''
    'module = importlib.import_module(sys.argv[1])'
    'output = pathlib.Path(sys.argv[2])'
    'config = module.load_runtime_config()'
    'output.write_text('
    '    json.dumps(config, sort_keys=True, separators=(",", ":")),'
    '    encoding="utf-8",'
    ')'
) |
    Set-Content `
        -LiteralPath $ConfigProbePath `
        -Encoding UTF8

$ConfigurationRegister = [System.Collections.Generic.List[object]]::new()

$PreviousPythonPath = $env:PYTHONPATH

try {
    $env:PYTHONPATH = if (
        [string]::IsNullOrWhiteSpace($PreviousPythonPath)
    ) {
        $ProjectRoot
    }
    else {
        "$ProjectRoot;$PreviousPythonPath"
    }

    for ($RunNumber = 1; $RunNumber -le 5; $RunNumber++) {
        $OutputPath = Join-Path `
            $ReportRoot `
            ("B3_PASS04_CONFIG_RUN_{0}.json" -f $RunNumber)

        & python `
            $ConfigProbePath `
            $OperationalModule `
            $OutputPath

        $ExitCode = $LASTEXITCODE

        Assert-MSCondition `
            -Condition ($ExitCode -eq 0) `
            -Message "Configuration probe $RunNumber failed." `
            -InvariantID 'MS-B3-P4-CONFIG-PROBE'

        $Hash = (
            Get-FileHash `
                -LiteralPath $OutputPath `
                -Algorithm SHA256
        ).Hash

        $ConfigurationRegister.Add(
            [pscustomobject][ordered]@{
                RunNumber = $RunNumber
                ExitCode = $ExitCode
                OutputPath = $OutputPath
                ConfigurationSHA256 = $Hash
                SourceConfigurationSHA256 = (
                    Get-FileHash `
                        -LiteralPath $OperationalConfigPath `
                        -Algorithm SHA256
                ).Hash
                Status = 'PASS'
            }
        )
    }
}
finally {
    $env:PYTHONPATH = $PreviousPythonPath
}

$ReferenceConfiguration = $ConfigurationRegister |
    Sort-Object RunNumber |
    Select-Object -First 1

foreach ($ConfigRow in $ConfigurationRegister) {
    if (
        $ConfigRow.ConfigurationSHA256 -ne
        $ReferenceConfiguration.ConfigurationSHA256
    ) {
        $DifferenceRegister.Add(
            [pscustomobject][ordered]@{
                DifferenceID = "CONFIG-DIFF-$($ConfigRow.RunNumber)"
                Operation = 'CONFIGURATION_READBACK'
                ReferenceRun = $ReferenceConfiguration.RunNumber
                ComparedRun = $ConfigRow.RunNumber
                ReferenceExitCode = $ReferenceConfiguration.ExitCode
                ComparedExitCode = $ConfigRow.ExitCode
                ReferenceSHA256 = $ReferenceConfiguration.ConfigurationSHA256
                ComparedSHA256 = $ConfigRow.ConfigurationSHA256
                DifferenceClass = 'CONFIGURATION_VARIATION'
                AuthorizedVariation = $false
            }
        )
    }
}

# =====================================================================
# Static nondeterminism inspection.
# =====================================================================

$RuntimePythonFiles = @(
    Get-ChildItem `
        -LiteralPath $ProjectRoot `
        -Recurse `
        -File `
        -Filter '*.py' |
    Where-Object {
        $_.FullName -notmatch
        '\\(\.git|Archive|archive|backups|\.venv|venv|build|dist|__pycache__)\\'
    }
)

$RiskPatterns = @(
    [pscustomobject]@{
        RiskClass = 'CURRENT_TIMESTAMP'
        Pattern = '(?i)datetime\.now|datetime\.utcnow|time\.time\(|date\.today\('
        Severity = 'MODERATE'
    }
    [pscustomobject]@{
        RiskClass = 'UUID_GENERATION'
        Pattern = '(?i)uuid4\(|uuid1\(|uuid\.uuid'
        Severity = 'HIGH'
    }
    [pscustomobject]@{
        RiskClass = 'RANDOMNESS'
        Pattern = '(?i)\brandom\.|\bsecrets\.|SystemRandom'
        Severity = 'HIGH'
    }
    [pscustomobject]@{
        RiskClass = 'UNSORTED_FILESYSTEM_ENUMERATION'
        Pattern = '(?i)os\.listdir\(|\.iterdir\(|glob\(|rglob\('
        Severity = 'MODERATE'
    }
    [pscustomobject]@{
        RiskClass = 'CULTURE_OR_LOCALE'
        Pattern = '(?i)\blocale\.|setlocale\(|strftime\('
        Severity = 'MODERATE'
    }
    [pscustomobject]@{
        RiskClass = 'TEMPORARY_NAME'
        Pattern = '(?i)NamedTemporaryFile|mkstemp|TemporaryDirectory'
        Severity = 'MODERATE'
    }
    [pscustomobject]@{
        RiskClass = 'PROCESS_OR_THREAD_IDENTIFIER'
        Pattern = '(?i)os\.getpid\(|threading\.get_ident\('
        Severity = 'MODERATE'
    }
)

$StaticRiskRegister = [System.Collections.Generic.List[object]]::new()

foreach ($File in $RuntimePythonFiles) {
    $Lines = @(Get-Content -LiteralPath $File.FullName)

    for ($Index = 0; $Index -lt $Lines.Count; $Index++) {
        foreach ($RiskPattern in $RiskPatterns) {
            if ($Lines[$Index] -match $RiskPattern.Pattern) {
                $StaticRiskRegister.Add(
                    [pscustomobject][ordered]@{
                        RiskID = "MS-B3-P4-RISK-$($StaticRiskRegister.Count + 1)"
                        RiskClass = $RiskPattern.RiskClass
                        Severity = $RiskPattern.Severity
                        RelativePath = $File.FullName.
                            Substring($RepositoryRoot.Length).
                            TrimStart('\')
                        LineNumber = $Index + 1
                        SourceLine = $Lines[$Index].Trim()
                        ObservableVariationDetected = $false
                        Disposition = 'REGISTERED_FOR_REVIEW'
                    }
                )
            }
        }
    }
}

# Static risks are not automatic failures unless observable variation occurs.
$HighStaticRisks = @(
    $StaticRiskRegister |
        Where-Object Severity -eq 'HIGH'
)

# =====================================================================
# Compile all active Python runtime files.
# =====================================================================

$CompileFailures = [System.Collections.Generic.List[object]]::new()

foreach ($File in $RuntimePythonFiles) {
    & python -m py_compile $File.FullName

    if ($LASTEXITCODE -ne 0) {
        $CompileFailures.Add(
            [pscustomobject][ordered]@{
                FilePath = $File.FullName
                ExitCode = $LASTEXITCODE
            }
        )
    }
}

# =====================================================================
# Regression verification.
# =====================================================================

$RegressionFailures = [System.Collections.Generic.List[object]]::new()

foreach ($Before in $ProtectedBefore) {
    $After = Get-MSFileHashRecord -LiteralPath $Before.Path

    if ($Before.SHA256 -ne $After.SHA256) {
        $RegressionFailures.Add(
            [pscustomobject][ordered]@{
                ArtifactPath = $Before.Path
                SHA256Before = $Before.SHA256
                SHA256After = $After.SHA256
            }
        )
    }
}

$Stage5Status = Get-Content `
    -LiteralPath (
        Join-Path `
            $BatchContext.Stage5Root `
            'Reports\BATCH_A_STAGE_5_COMPLETION_STATUS.json'
    ) `
    -Raw |
    ConvertFrom-Json

$Stage6Status = Get-Content `
    -LiteralPath (
        Join-Path `
            $BatchContext.Stage6Root `
            'Reports\BATCH_A_STAGE_6_COMPLETION_STATUS.json'
    ) `
    -Raw |
    ConvertFrom-Json

# =====================================================================
# Export evidence.
# =====================================================================

$ExecutionRegisterPath = Join-Path `
    $ReportRoot `
    'B3_PASS04_DETERMINISM_EXECUTION_REGISTER.csv'

$DifferenceRegisterPath = Join-Path `
    $ReportRoot `
    'B3_PASS04_DETERMINISM_DIFFERENCE_REGISTER.csv'

$ConfigurationRegisterPath = Join-Path `
    $ReportRoot `
    'B3_PASS04_CONFIGURATION_VERIFICATION_REGISTER.csv'

$StaticRiskRegisterPath = Join-Path `
    $ReportRoot `
    'B3_PASS04_STATIC_RISK_REGISTER.csv'

$ExecutionRegister |
    Export-Csv `
        -LiteralPath $ExecutionRegisterPath `
        -NoTypeInformation `
        -Encoding UTF8

$DifferenceRegister |
    Export-Csv `
        -LiteralPath $DifferenceRegisterPath `
        -NoTypeInformation `
        -Encoding UTF8

$ConfigurationRegister |
    Export-Csv `
        -LiteralPath $ConfigurationRegisterPath `
        -NoTypeInformation `
        -Encoding UTF8

$StaticRiskRegister |
    Export-Csv `
        -LiteralPath $StaticRiskRegisterPath `
        -NoTypeInformation `
        -Encoding UTF8

# =====================================================================
# Final constitutional verification.
# =====================================================================

$FailedExecutionRows = @(
    $ExecutionRegister |
        Where-Object Status -ne 'PASS'
)

$UnstableExitCodes = @(
    $HelpRows |
        Group-Object ExitCode |
        Where-Object {
            $_.Count -ne $HelpRows.Count
        }
)

$Pass04Result = (
    $FailedExecutionRows.Count -eq 0 -and
    $DifferenceRegister.Count -eq 0 -and
    $UnstableExitCodes.Count -eq 0 -and
    $CompileFailures.Count -eq 0 -and
    $RegressionFailures.Count -eq 0 -and
    $Stage5Status.Result -eq 'PASS' -and
    $Stage5Status.FailedFinalValidations -eq 0 -and
    $Stage6Status.Result -eq 'PASS' -and
    $Stage6Status.BatchClosureEligibility -eq 'ELIGIBLE'
)

if (-not $Pass04Result) {
    throw (
        'Pass 04 failed: ' +
        "ExecutionFailures=$($FailedExecutionRows.Count); " +
        "Differences=$($DifferenceRegister.Count); " +
        "CompileFailures=$($CompileFailures.Count); " +
        "RegressionFailures=$($RegressionFailures.Count)"
    )
}

# =====================================================================
# Completion manifest and report.
# =====================================================================

$ExistingManifest = Get-Content `
    -LiteralPath $ManifestPath `
    -Raw |
    ConvertFrom-Json

[ordered]@{
    PassID = 'B3-PASS-04'
    BatchID = 'BATCH-3'
    Purpose = $ExistingManifest.Purpose
    Result = 'PASS'
    Status = 'COMPLETE'
    CanonicalHelpRuns = $HelpRows.Count
    StableHelpExitCode = $ReferenceHelp.ExitCode
    UniqueHelpOutputHashes = @(
        $HelpRows.OutputSHA256 |
            Sort-Object -Unique
    ).Count
    ConfigurationReadBackRuns = $ConfigurationRegister.Count
    UniqueConfigurationHashes = @(
        $ConfigurationRegister.ConfigurationSHA256 |
            Sort-Object -Unique
    ).Count
    ObservableDifferences = $DifferenceRegister.Count
    StaticRiskRecords = $StaticRiskRegister.Count
    HighStaticRiskRecords = $HighStaticRisks.Count
    PythonFilesCompiled = $RuntimePythonFiles.Count
    PythonCompileFailures = $CompileFailures.Count
    RegressionFailures = $RegressionFailures.Count
    Stage5RegressionStatus = $Stage5Status.Result
    Stage6RegressionStatus = $Stage6Status.Result
    RuntimeFilesModified = 0
    CompletedAt = (Get-Date).ToString('o')
} |
    ConvertTo-Json -Depth 8 |
    Set-Content `
        -LiteralPath $ManifestPath `
        -Encoding UTF8

$SummaryReportPath = Join-Path `
    $ReportRoot `
    'B3_PASS04_DETERMINISM_SUMMARY.md'

@(
    '# Morning Star — Batch 3 Pass 04'
    ''
    'Status: **PASS**'
    ''
    '## Repeated Runtime Verification'
    ''
    "- Canonical help runs: $($HelpRows.Count)"
    "- Stable help exit code: $($ReferenceHelp.ExitCode)"
    "- Unique help output hashes: $(@($HelpRows.OutputSHA256 | Sort-Object -Unique).Count)"
    "- Configuration read-back runs: $($ConfigurationRegister.Count)"
    "- Unique configuration hashes: $(@($ConfigurationRegister.ConfigurationSHA256 | Sort-Object -Unique).Count)"
    "- Observable differences: $($DifferenceRegister.Count)"
    ''
    '## Static Determinism Review'
    ''
    "- Static risk records: $($StaticRiskRegister.Count)"
    "- High static risk records: $($HighStaticRisks.Count)"
    ''
    'Static risk records are review findings, not automatic failures, unless'
    'they produce observable variation during controlled repeated execution.'
    ''
    '## Regression'
    ''
    "- Python compile failures: $($CompileFailures.Count)"
    "- Protected-artifact regression failures: $($RegressionFailures.Count)"
    "- Stage 5 regression: $($Stage5Status.Result)"
    "- Stage 6 regression: $($Stage6Status.Result)"
) |
    Set-Content `
        -LiteralPath $SummaryReportPath `
        -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — BATCH 3 PASS 04' -ForegroundColor Cyan
Write-Host 'DETERMINISM VERIFICATION' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Canonical help runs:                  $($HelpRows.Count)"
Write-Host "Stable help exit code:                $($ReferenceHelp.ExitCode)"
Write-Host "Unique help output hashes:            $(@($HelpRows.OutputSHA256 | Sort-Object -Unique).Count)"
Write-Host "Configuration read-back runs:         $($ConfigurationRegister.Count)"
Write-Host "Unique configuration hashes:          $(@($ConfigurationRegister.ConfigurationSHA256 | Sort-Object -Unique).Count)"
Write-Host "Observable differences:               $($DifferenceRegister.Count)"
Write-Host "Static risk records:                  $($StaticRiskRegister.Count)"
Write-Host "High static risk records:             $($HighStaticRisks.Count)"
Write-Host "Python compile failures:              $($CompileFailures.Count)"
Write-Host "Regression failures:                  $($RegressionFailures.Count)"
Write-Host "Stage 5 regression:                   $($Stage5Status.Result)"
Write-Host "Stage 6 regression:                   $($Stage6Status.Result)"
Write-Host "Runtime files modified:               0"
Write-Host ''
Write-Host 'BATCH 3 PASS 04: PASS' -ForegroundColor Green
Write-Host 'REPEATED CLI OUTPUT AND EXIT CODES ARE STABLE.' -ForegroundColor Green
Write-Host 'CONFIGURATION READ-BACK IS DETERMINISTIC.' -ForegroundColor Green
Write-Host 'STATIC NONDETERMINISM RISKS ARE FORMALLY REGISTERED.' -ForegroundColor Green
Write-Host 'STAGE 5 AND STAGE 6 REGRESSION CHECKS PASSED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
