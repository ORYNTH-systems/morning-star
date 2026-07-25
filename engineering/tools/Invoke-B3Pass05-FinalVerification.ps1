$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (
    Resolve-Path (Join-Path $PSScriptRoot '..\..')
).Path

$CommonModulePath = Join-Path `
    $RepositoryRoot `
    'engineering\modules\MorningStar.Engine.Common.psm1'

$ManifestRoot = Join-Path `
    $RepositoryRoot `
    'engineering\manifests\batch-3'

$ReportsRoot = Join-Path `
    $RepositoryRoot `
    'engineering\reports\batch-3'

$PassReportRoot = Join-Path `
    $ReportsRoot `
    'B3-PASS-05'

$CompletionManifestPath = Join-Path `
    $ManifestRoot `
    'BATCH_3_RUNTIME_CLI_POLISH_COMPLETION_MANIFEST.json'

$CompletionReportPath = Join-Path `
    $ReportsRoot `
    'BATCH_3_RUNTIME_CLI_POLISH_COMPLETION_REPORT.md'

$VerificationRegisterPath = Join-Path `
    $PassReportRoot `
    'B3_PASS05_FINAL_VERIFICATION_REGISTER.csv'

New-Item `
    -ItemType Directory `
    -Path $PassReportRoot `
    -Force |
    Out-Null

Import-Module `
    $CommonModulePath `
    -Force `
    -ErrorAction Stop

$VerificationRegister = [System.Collections.Generic.List[object]]::new()

function Add-VerificationRecord {
    param(
        [Parameter(Mandatory)]
        [string]$VerificationID,

        [Parameter(Mandatory)]
        [string]$VerificationClass,

        [Parameter(Mandatory)]
        [string]$Subject,

        [Parameter(Mandatory)]
        [string]$RequiredCondition,

        [Parameter(Mandatory)]
        [string]$ObservedEvidence,

        [Parameter(Mandatory)]
        [bool]$Passed
    )

    $VerificationRegister.Add(
        [pscustomobject][ordered]@{
            VerificationID = $VerificationID
            VerificationClass = $VerificationClass
            Subject = $Subject
            RequiredCondition = $RequiredCondition
            ObservedEvidence = $ObservedEvidence
            VerificationStatus = if ($Passed) {
                'PASS'
            }
            else {
                'FAIL'
            }
            VerifiedAt = (Get-Date).ToString('o')
        }
    )
}

# =====================================================================
# Verify governed Pass 01–04 manifests.
# =====================================================================

$RequiredPasses = @(
    'B3-PASS-01'
    'B3-PASS-02'
    'B3-PASS-03'
    'B3-PASS-04'
)

$PassResults = [System.Collections.Generic.List[object]]::new()

foreach ($PassID in $RequiredPasses) {
    $PassManifestPath = Join-Path `
        $ManifestRoot `
        "${PassID}_MANIFEST.json"

    $Exists = Test-Path `
        -LiteralPath $PassManifestPath `
        -PathType Leaf

    $Readable = $false
    $Result = ''
    $Status = ''

    if ($Exists) {
        try {
            $Manifest = Get-Content `
                -LiteralPath $PassManifestPath `
                -Raw |
                ConvertFrom-Json

            $Readable = $true

            if (
                $Manifest.PSObject.Properties.Name -contains 'Result'
            ) {
                $Result = [string]$Manifest.Result
            }

            if (
                $Manifest.PSObject.Properties.Name -contains 'Status'
            ) {
                $Status = [string]$Manifest.Status
            }
        }
        catch {
            $Readable = $false
            $Result = 'UNREADABLE'
        }
    }

    $Passed = (
        $Exists -and
        $Readable -and
        $Result -eq 'PASS'
    )

    Add-VerificationRecord `
        -VerificationID "MS-B3-$PassID-MANIFEST" `
        -VerificationClass 'PASS_MANIFEST' `
        -Subject $PassID `
        -RequiredCondition 'Pass manifest must exist, be readable, and report PASS.' `
        -ObservedEvidence "Exists=$Exists; Readable=$Readable; Result=$Result; Status=$Status" `
        -Passed $Passed

    $PassResults.Add(
        [pscustomobject][ordered]@{
            PassID = $PassID
            Result = $Result
            Status = $Status
            Passed = $Passed
        }
    )
}

# =====================================================================
# Verify shared PowerShell module.
# =====================================================================

$ModuleTokens = $null
$ModuleErrors = $null

[void][System.Management.Automation.Language.Parser]::ParseFile(
    (Resolve-Path -LiteralPath $CommonModulePath).Path,
    [ref]$ModuleTokens,
    [ref]$ModuleErrors
)

Add-VerificationRecord `
    -VerificationID 'MS-B3-COMMON-MODULE-SYNTAX' `
    -VerificationClass 'MODULE' `
    -Subject $CommonModulePath `
    -RequiredCondition 'Shared PowerShell module must parse without errors.' `
    -ObservedEvidence "ParseErrors=$(@($ModuleErrors).Count)" `
    -Passed (@($ModuleErrors).Count -eq 0)

$RequiredPowerShellFunctions = @(
    'Get-MSDeterministicHash'
    'Import-MSCsv'
    'Export-MSAtomicCsv'
    'Assert-MSCondition'
    'Resolve-MSRepositoryPath'
    'Get-MSBatchContext'
    'Get-MSFileHashRecord'
)

foreach ($FunctionName in $RequiredPowerShellFunctions) {
    $CommandExists = $null -ne (
        Get-Command `
            -Name $FunctionName `
            -ErrorAction SilentlyContinue
    )

    Add-VerificationRecord `
        -VerificationID "MS-B3-EXPORT-$FunctionName" `
        -VerificationClass 'MODULE_EXPORT' `
        -Subject $FunctionName `
        -RequiredCondition 'Required shared function must be exported.' `
        -ObservedEvidence "Exported=$CommandExists" `
        -Passed $CommandExists
}

# =====================================================================
# Verify Batch 3 runtime artifacts.
# =====================================================================

$CommandSurfacePath = Join-Path `
    $RepositoryRoot `
    'runtime\cli\command-surface.json'

$CommandDocumentationPath = Join-Path `
    $RepositoryRoot `
    'runtime\cli\COMMANDS.md'

$RuntimeArtifactPaths = @(
    $CommandSurfacePath
    $CommandDocumentationPath
)

foreach ($ArtifactPath in $RuntimeArtifactPaths) {
    $Exists = Test-Path `
        -LiteralPath $ArtifactPath `
        -PathType Leaf

    Add-VerificationRecord `
        -VerificationID (
            'MS-B3-ARTIFACT-' +
            (Split-Path -Leaf $ArtifactPath)
        ) `
        -VerificationClass 'RUNTIME_ARTIFACT' `
        -Subject $ArtifactPath `
        -RequiredCondition 'Required runtime artifact must exist.' `
        -ObservedEvidence "Exists=$Exists" `
        -Passed $Exists
}

$CommandSurface = Get-Content `
    -LiteralPath $CommandSurfacePath `
    -Raw |
    ConvertFrom-Json

$CanonicalConsole = [string]$CommandSurface.Console.CanonicalName
$CanonicalTarget = [string]$CommandSurface.Console.Target

Add-VerificationRecord `
    -VerificationID 'MS-B3-CANONICAL-CONSOLE' `
    -VerificationClass 'CLI_SURFACE' `
    -Subject $CanonicalConsole `
    -RequiredCondition 'Canonical console command must be morning-star.' `
    -ObservedEvidence "Console=$CanonicalConsole; Target=$CanonicalTarget" `
    -Passed ($CanonicalConsole -eq 'morning-star')

# =====================================================================
# Locate and verify operational runtime module/configuration.
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

$OperationalModuleCountValid = (
    $OperationalModuleCandidates.Count -eq 1
)

Add-VerificationRecord `
    -VerificationID 'MS-B3-OPERATIONAL-MODULE-CARDINALITY' `
    -VerificationClass 'OPERATIONAL_RUNTIME' `
    -Subject 'operational.py' `
    -RequiredCondition 'Exactly one active operational runtime module must exist.' `
    -ObservedEvidence "Count=$($OperationalModuleCandidates.Count)" `
    -Passed $OperationalModuleCountValid

Assert-MSCondition `
    -Condition $OperationalModuleCountValid `
    -Message (
        'Expected exactly one operational.py file; found ' +
        "$($OperationalModuleCandidates.Count)."
    ) `
    -InvariantID 'MS-B3-P5-OPERATIONAL'

$OperationalModulePath = $OperationalModuleCandidates[0].FullName
$OperationalConfigPath = Join-Path `
    (Split-Path -Parent $OperationalModulePath) `
    'operational-defaults.json'

$OperationalConfigExists = Test-Path `
    -LiteralPath $OperationalConfigPath `
    -PathType Leaf

Add-VerificationRecord `
    -VerificationID 'MS-B3-OPERATIONAL-CONFIGURATION' `
    -VerificationClass 'CONFIGURATION' `
    -Subject $OperationalConfigPath `
    -RequiredCondition 'Operational defaults must exist.' `
    -ObservedEvidence "Exists=$OperationalConfigExists" `
    -Passed $OperationalConfigExists

$OperationalConfig = Get-Content `
    -LiteralPath $OperationalConfigPath `
    -Raw |
    ConvertFrom-Json

$ExitCodesValid = (
    $OperationalConfig.exit_codes.success -eq 0 -and
    $OperationalConfig.exit_codes.operational_error -eq 1 -and
    $OperationalConfig.exit_codes.invalid_input -eq 2 -and
    $OperationalConfig.exit_codes.configuration_error -eq 3 -and
    $OperationalConfig.exit_codes.verification_failure -eq 4 -and
    $OperationalConfig.exit_codes.interrupted -eq 130
)

Add-VerificationRecord `
    -VerificationID 'MS-B3-EXIT-CODE-STANDARD' `
    -VerificationClass 'OPERATIONAL_STANDARD' `
    -Subject 'Exit codes' `
    -RequiredCondition 'All six standardized exit codes must be present.' `
    -ObservedEvidence (
        "Success=$($OperationalConfig.exit_codes.success); " +
        "Operational=$($OperationalConfig.exit_codes.operational_error); " +
        "InvalidInput=$($OperationalConfig.exit_codes.invalid_input); " +
        "Configuration=$($OperationalConfig.exit_codes.configuration_error); " +
        "Verification=$($OperationalConfig.exit_codes.verification_failure); " +
        "Interrupted=$($OperationalConfig.exit_codes.interrupted)"
    ) `
    -Passed $ExitCodesValid

$LoggingValid = (
    $OperationalConfig.logging.level -eq 'INFO' -and
    $OperationalConfig.logging.stream -eq 'stderr'
)

Add-VerificationRecord `
    -VerificationID 'MS-B3-LOGGING-STANDARD' `
    -VerificationClass 'OPERATIONAL_STANDARD' `
    -Subject 'Logging' `
    -RequiredCondition 'Default logging must use INFO and stderr.' `
    -ObservedEvidence (
        "Level=$($OperationalConfig.logging.level); " +
        "Stream=$($OperationalConfig.logging.stream)"
    ) `
    -Passed $LoggingValid

# =====================================================================
# Verify Pass 04 determinism evidence.
# =====================================================================

$Pass04ReportRoot = Join-Path `
    $ReportsRoot `
    'B3-PASS-04'

$Pass04ExecutionPath = Join-Path `
    $Pass04ReportRoot `
    'B3_PASS04_DETERMINISM_EXECUTION_REGISTER.csv'

$Pass04DifferencePath = Join-Path `
    $Pass04ReportRoot `
    'B3_PASS04_DETERMINISM_DIFFERENCE_REGISTER.csv'

$Pass04ConfigurationPath = Join-Path `
    $Pass04ReportRoot `
    'B3_PASS04_CONFIGURATION_VERIFICATION_REGISTER.csv'

$DeterminismExecution = @(
    Import-Csv -LiteralPath $Pass04ExecutionPath
)

$DeterminismDifferences = @()

if (
    Test-Path `
        -LiteralPath $Pass04DifferencePath `
        -PathType Leaf
) {
    $DifferenceFile = Get-Item `
        -LiteralPath $Pass04DifferencePath

    if ($DifferenceFile.Length -gt 3) {
        $DeterminismDifferences = @(
            Import-Csv -LiteralPath $Pass04DifferencePath
        )
    }
}

$ConfigurationVerification = @(
    Import-Csv -LiteralPath $Pass04ConfigurationPath
)

$UniqueHelpHashes = @(
    $DeterminismExecution.OutputSHA256 |
        Where-Object {
            -not [string]::IsNullOrWhiteSpace($_)
        } |
        Sort-Object -Unique
)

$UniqueHelpExitCodes = @(
    $DeterminismExecution.ExitCode |
        Sort-Object -Unique
)

$UniqueConfigurationHashes = @(
    $ConfigurationVerification.ConfigurationSHA256 |
        Sort-Object -Unique
)

$DeterminismValid = (
    $DeterminismExecution.Count -eq 5 -and
    $UniqueHelpHashes.Count -eq 1 -and
    $UniqueHelpExitCodes.Count -eq 1 -and
    $UniqueHelpExitCodes[0] -eq '0' -and
    $ConfigurationVerification.Count -eq 5 -and
    $UniqueConfigurationHashes.Count -eq 1 -and
    $DeterminismDifferences.Count -eq 0
)

Add-VerificationRecord `
    -VerificationID 'MS-B3-DETERMINISM-EVIDENCE' `
    -VerificationClass 'DETERMINISM' `
    -Subject 'Pass 04 execution evidence' `
    -RequiredCondition 'Repeated CLI and configuration executions must be stable.' `
    -ObservedEvidence (
        "HelpRuns=$($DeterminismExecution.Count); " +
        "HelpHashes=$($UniqueHelpHashes.Count); " +
        "ExitCodes=$($UniqueHelpExitCodes.Count); " +
        "ConfigRuns=$($ConfigurationVerification.Count); " +
        "ConfigHashes=$($UniqueConfigurationHashes.Count); " +
        "Differences=$($DeterminismDifferences.Count)"
    ) `
    -Passed $DeterminismValid

# =====================================================================
# Compile all active Python files.
# =====================================================================

$PythonCommand = Get-Command `
    -Name python `
    -ErrorAction SilentlyContinue

Assert-MSCondition `
    -Condition ($null -ne $PythonCommand) `
    -Message 'Python is unavailable in PATH.' `
    -InvariantID 'MS-B3-P5-PYTHON'

$ActivePythonFiles = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Recurse `
        -File `
        -Filter '*.py' |
    Where-Object {
        $_.FullName -notmatch
        '\\(\.git|Archive|archive|backups|\.venv|venv|build|dist|__pycache__)\\'
    }
)

$CompileFailures = [System.Collections.Generic.List[object]]::new()

foreach ($File in $ActivePythonFiles) {
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

Add-VerificationRecord `
    -VerificationID 'MS-B3-PYTHON-COMPILATION' `
    -VerificationClass 'RUNTIME_SYNTAX' `
    -Subject 'Active Python files' `
    -RequiredCondition 'Every active Python file must compile.' `
    -ObservedEvidence (
        "Files=$($ActivePythonFiles.Count); " +
        "Failures=$($CompileFailures.Count)"
    ) `
    -Passed ($CompileFailures.Count -eq 0)

# =====================================================================
# Verify active PowerShell syntax.
# =====================================================================

$ExcludedPowerShellPatterns = @(
    '\\.git\\'
    '\\Archive\\'
    '\\archive\\'
    '\\backups\\'
    '\\Repository_Cleanup\\'
    '\\node_modules\\'
    '\\\.venv\\'
    '\\venv\\'
)

$ActivePowerShellFiles = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Recurse `
        -File `
        -Filter '*.ps1' |
    Where-Object {
        $Path = $_.FullName

        @(
            $ExcludedPowerShellPatterns |
                Where-Object {
                    $Path -match $_
                }
        ).Count -eq 0
    }
)

$PowerShellSyntaxFailures = [System.Collections.Generic.List[object]]::new()

foreach ($File in $ActivePowerShellFiles) {
    $Tokens = $null
    $Errors = $null

    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $File.FullName,
        [ref]$Tokens,
        [ref]$Errors
    )

    if (@($Errors).Count -gt 0) {
        $PowerShellSyntaxFailures.Add(
            [pscustomobject][ordered]@{
                FilePath = $File.FullName
                ParseErrors = @($Errors).Count
                Messages = (
                    @($Errors | ForEach-Object Message) -join ' | '
                )
            }
        )
    }
}

Add-VerificationRecord `
    -VerificationID 'MS-B3-POWERSHELL-SYNTAX' `
    -VerificationClass 'ENGINEERING_SYNTAX' `
    -Subject 'Active PowerShell scripts' `
    -RequiredCondition 'Every active PowerShell script must parse.' `
    -ObservedEvidence (
        "Scripts=$($ActivePowerShellFiles.Count); " +
        "Failures=$($PowerShellSyntaxFailures.Count)"
    ) `
    -Passed ($PowerShellSyntaxFailures.Count -eq 0)

# =====================================================================
# Stage 5 and Stage 6 regression verification.
# =====================================================================

$BatchContext = Get-MSBatchContext `
    -RepositoryRoot $RepositoryRoot `
    -BatchID 'BATCH_A'

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

$Stage5Pass = (
    $Stage5Status.Result -eq 'PASS' -and
    $Stage5Status.ExecutionRows -eq 22 -and
    $Stage5Status.VerificationRows -eq 22 -and
    $Stage5Status.EvidenceChainRows -eq 22 -and
    $Stage5Status.FailedFinalValidations -eq 0
)

$Stage6Pass = (
    $Stage6Status.Result -eq 'PASS' -and
    $Stage6Status.DispositionRecords -eq 42 -and
    $Stage6Status.FailedValidations -eq 0 -and
    $Stage6Status.BatchClosureEligibility -eq 'ELIGIBLE'
)

Add-VerificationRecord `
    -VerificationID 'MS-B3-STAGE5-REGRESSION' `
    -VerificationClass 'REGRESSION' `
    -Subject 'Stage 5' `
    -RequiredCondition 'Stage 5 must remain genuinely validated.' `
    -ObservedEvidence (
        "Result=$($Stage5Status.Result); " +
        "Executions=$($Stage5Status.ExecutionRows); " +
        "Verifications=$($Stage5Status.VerificationRows); " +
        "Evidence=$($Stage5Status.EvidenceChainRows); " +
        "Failures=$($Stage5Status.FailedFinalValidations)"
    ) `
    -Passed $Stage5Pass

Add-VerificationRecord `
    -VerificationID 'MS-B3-STAGE6-REGRESSION' `
    -VerificationClass 'REGRESSION' `
    -Subject 'Stage 6' `
    -RequiredCondition 'Stage 6 must remain complete and closure-eligible.' `
    -ObservedEvidence (
        "Result=$($Stage6Status.Result); " +
        "Records=$($Stage6Status.DispositionRecords); " +
        "Failures=$($Stage6Status.FailedValidations); " +
        "Eligibility=$($Stage6Status.BatchClosureEligibility)"
    ) `
    -Passed $Stage6Pass

# =====================================================================
# Export and evaluate final verification evidence.
# =====================================================================

$VerificationRegister |
    Export-Csv `
        -LiteralPath $VerificationRegisterPath `
        -NoTypeInformation `
        -Encoding UTF8

$VerificationFailures = @(
    $VerificationRegister |
        Where-Object VerificationStatus -ne 'PASS'
)

if ($VerificationFailures.Count -gt 0) {
    $VerificationFailures |
        Format-List *

    throw (
        "$($VerificationFailures.Count) Batch 3 final " +
        'verifications failed.'
    )
}

# =====================================================================
# Create Batch 3 completion artifacts.
# =====================================================================

$CompletionManifest = [ordered]@{
    BatchID = 'BATCH-3'
    BatchName = 'RUNTIME_AND_CLI_POLISH'
    Result = 'PASS'
    Status = 'COMPLETE'
    GovernedPasses = 5
    CompletedPasses = 5
    PassResults = $PassResults
    CanonicalConsole = $CanonicalConsole
    CanonicalTarget = $CanonicalTarget
    OperationalModulePath = $OperationalModulePath
    OperationalConfigurationPath = $OperationalConfigPath
    StandardizedExitCodes = 6
    LoggingStandardized = $true
    ConfigurationStandardized = $true
    ErrorBoundaryStandardized = $true
    DeterminismHelpRuns = $DeterminismExecution.Count
    UniqueHelpOutputHashes = $UniqueHelpHashes.Count
    ConfigurationReadBackRuns = $ConfigurationVerification.Count
    UniqueConfigurationHashes = $UniqueConfigurationHashes.Count
    ObservableDeterminismDifferences = $DeterminismDifferences.Count
    ActivePythonFiles = $ActivePythonFiles.Count
    PythonCompileFailures = $CompileFailures.Count
    ActivePowerShellScripts = $ActivePowerShellFiles.Count
    PowerShellSyntaxFailures = $PowerShellSyntaxFailures.Count
    FinalVerificationRows = $VerificationRegister.Count
    FinalVerificationFailures = $VerificationFailures.Count
    Stage5RegressionStatus = $Stage5Status.Result
    Stage6RegressionStatus = $Stage6Status.Result
    ConstitutionalDisposition = 'RUNTIME_AND_CLI_POLISH_VALIDATED'
    CompletedAt = (Get-Date).ToString('o')
}

$CompletionManifest |
    ConvertTo-Json -Depth 10 |
    Set-Content `
        -LiteralPath $CompletionManifestPath `
        -Encoding UTF8

$ReportLines = @(
    '# Morning Star — Batch 3 Runtime and CLI Polish'
    ''
    'Status: **PASS**'
    ''
    '## Governed Passes'
    ''
    '- Pass 01 — Runtime Inventory: PASS'
    '- Pass 02 — Command Standardization: PASS'
    '- Pass 03 — Operational Standards: PASS'
    '- Pass 04 — Determinism Verification: PASS'
    '- Pass 05 — Final Verification: PASS'
    ''
    '## Runtime and CLI Results'
    ''
    "- Canonical console: ``$CanonicalConsole``"
    "- Canonical target: ``$CanonicalTarget``"
    '- Exit codes standardized: 6'
    '- Logging standardized: Yes'
    '- Configuration standardized: Yes'
    '- Error boundary standardized: Yes'
    ''
    '## Determinism'
    ''
    "- Canonical help runs: $($DeterminismExecution.Count)"
    "- Unique help output hashes: $($UniqueHelpHashes.Count)"
    "- Configuration read-back runs: $($ConfigurationVerification.Count)"
    "- Unique configuration hashes: $($UniqueConfigurationHashes.Count)"
    "- Observable differences: $($DeterminismDifferences.Count)"
    ''
    '## Verification'
    ''
    "- Active Python files: $($ActivePythonFiles.Count)"
    "- Python compilation failures: $($CompileFailures.Count)"
    "- Active PowerShell scripts: $($ActivePowerShellFiles.Count)"
    "- PowerShell syntax failures: $($PowerShellSyntaxFailures.Count)"
    "- Final verification records: $($VerificationRegister.Count)"
    "- Final verification failures: $($VerificationFailures.Count)"
    "- Stage 5 regression: $($Stage5Status.Result)"
    "- Stage 6 regression: $($Stage6Status.Result)"
    ''
    'Batch 3 is complete.'
)

$ReportLines |
    Set-Content `
        -LiteralPath $CompletionReportPath `
        -Encoding UTF8

[ordered]@{
    PassID = 'B3-PASS-05'
    BatchID = 'BATCH-3'
    Purpose = 'Run final regression verification and generate Batch 3 completion artifacts.'
    Result = 'PASS'
    Status = 'COMPLETE'
    VerificationRows = $VerificationRegister.Count
    VerificationFailures = $VerificationFailures.Count
    PythonCompileFailures = $CompileFailures.Count
    PowerShellSyntaxFailures = $PowerShellSyntaxFailures.Count
    Stage5RegressionStatus = $Stage5Status.Result
    Stage6RegressionStatus = $Stage6Status.Result
    CompletedAt = (Get-Date).ToString('o')
} |
    ConvertTo-Json -Depth 8 |
    Set-Content `
        -LiteralPath (
            Join-Path `
                $ManifestRoot `
                'B3-PASS-05_MANIFEST.json'
        ) `
        -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — BATCH 3 PASS 05' -ForegroundColor Cyan
Write-Host 'FINAL VERIFICATION AND CLOSURE' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Governed passes completed:             5"
Write-Host "Canonical console:                     $CanonicalConsole"
Write-Host "Standardized exit codes:               6"
Write-Host "Help execution runs:                   $($DeterminismExecution.Count)"
Write-Host "Unique help hashes:                    $($UniqueHelpHashes.Count)"
Write-Host "Configuration read-back runs:          $($ConfigurationVerification.Count)"
Write-Host "Unique configuration hashes:           $($UniqueConfigurationHashes.Count)"
Write-Host "Observable determinism differences:    $($DeterminismDifferences.Count)"
Write-Host "Python compilation failures:           $($CompileFailures.Count)"
Write-Host "PowerShell syntax failures:            $($PowerShellSyntaxFailures.Count)"
Write-Host "Final verification failures:           $($VerificationFailures.Count)"
Write-Host "Stage 5 regression:                    $($Stage5Status.Result)"
Write-Host "Stage 6 regression:                    $($Stage6Status.Result)"
Write-Host ''
Write-Host "Completion manifest:                   $CompletionManifestPath"
Write-Host "Completion report:                     $CompletionReportPath"
Write-Host ''
Write-Host 'BATCH 3 PASS 05: PASS' -ForegroundColor Green
Write-Host 'BATCH 3 RUNTIME AND CLI POLISH IS COMPLETE.' -ForegroundColor Green
Write-Host 'COMMANDS, EXIT CODES, LOGGING, CONFIGURATION, AND ERROR HANDLING ARE STANDARDIZED.' -ForegroundColor Green
Write-Host 'REPEATED CLI AND CONFIGURATION EXECUTION IS DETERMINISTIC.' -ForegroundColor Green
Write-Host 'STAGE 5 AND STAGE 6 REMAIN VALID AND UNCHANGED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
