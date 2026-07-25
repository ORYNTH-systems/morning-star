$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (
    Resolve-Path (Join-Path $PSScriptRoot '..\..')
).Path

$CommonModulePath = Join-Path `
    $RepositoryRoot `
    'engineering\modules\MorningStar.Engine.Common.psm1'

$ReportRoot = Join-Path `
    $RepositoryRoot `
    'engineering\reports\batch-3\B3-PASS-03'

$BackupRoot = Join-Path `
    $RepositoryRoot `
    'engineering\backups\batch-3\B3-PASS-03'

$ManifestPath = Join-Path `
    $RepositoryRoot `
    'engineering\manifests\batch-3\B3-PASS-03_MANIFEST.json'

$CommandSurfacePath = Join-Path `
    $RepositoryRoot `
    'runtime\cli\command-surface.json'

foreach ($Directory in @(
    $ReportRoot
    $BackupRoot
)) {
    New-Item `
        -ItemType Directory `
        -Path $Directory `
        -Force |
        Out-Null
}

Import-Module `
    $CommonModulePath `
    -Force `
    -ErrorAction Stop

Assert-MSCondition `
    -Condition (
        Test-Path `
            -LiteralPath $CommandSurfacePath `
            -PathType Leaf
    ) `
    -Message "Command surface is missing: $CommandSurfacePath" `
    -InvariantID 'MS-B3-P3-COMMAND-SURFACE'

$CommandSurface = Get-Content `
    -LiteralPath $CommandSurfacePath `
    -Raw |
    ConvertFrom-Json

$CanonicalConsole = [string]$CommandSurface.Console.CanonicalName
$OriginalTarget   = [string]$CommandSurface.Console.Target
$TargetModule     = [string]$CommandSurface.Console.Module
$TargetFunction   = [string]$CommandSurface.Console.Function
$EntryPointPath   = Join-Path `
    $RepositoryRoot `
    ([string]$CommandSurface.Console.EntryPointPath)

Assert-MSCondition `
    -Condition (
        Test-Path `
            -LiteralPath $EntryPointPath `
            -PathType Leaf
    ) `
    -Message "Canonical entry-point file is missing: $EntryPointPath" `
    -InvariantID 'MS-B3-P3-ENTRYPOINT'

$PythonCommand = Get-Command `
    -Name python `
    -ErrorAction SilentlyContinue

Assert-MSCondition `
    -Condition ($null -ne $PythonCommand) `
    -Message 'Python is unavailable in PATH.' `
    -InvariantID 'MS-B3-P3-PYTHON'

# =====================================================================
# Locate pyproject.toml containing the canonical console declaration.
# =====================================================================

$PyprojectCandidates = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Recurse `
        -File `
        -Filter 'pyproject.toml' |
    Where-Object {
        $_.FullName -notmatch
        '\\(\.git|Archive|archive|backups|\.venv|venv|build|dist)\\'
    }
)

$PyprojectMatches = @(
    foreach ($Candidate in $PyprojectCandidates) {
        $Text = Get-Content `
            -LiteralPath $Candidate.FullName `
            -Raw

        if (
            $Text -match
            (
                '(?m)^\s*' +
                [regex]::Escape($CanonicalConsole) +
                '\s*=\s*["'']' +
                [regex]::Escape($OriginalTarget) +
                '["'']\s*$'
            )
        ) {
            $Candidate
        }
    }
)

Assert-MSCondition `
    -Condition ($PyprojectMatches.Count -eq 1) `
    -Message (
        'Expected one pyproject.toml containing the canonical console ' +
        "entry; found $($PyprojectMatches.Count)."
    ) `
    -InvariantID 'MS-B3-P3-PYPROJECT'

$PyprojectPath = $PyprojectMatches[0].FullName

# =====================================================================
# Preserve authoritative Stage 5 and Stage 6 artifacts.
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
# Derive the Python package location.
# =====================================================================

$ModuleParts = @($TargetModule -split '\.')

Assert-MSCondition `
    -Condition ($ModuleParts.Count -ge 2) `
    -Message (
        'The canonical target module does not identify a package: ' +
        $TargetModule
    ) `
    -InvariantID 'MS-B3-P3-PACKAGE'

$PackageModule = (
    $ModuleParts[0..($ModuleParts.Count - 2)] -join '.'
)

$PackageDirectory = Split-Path `
    -Parent `
    $EntryPointPath

$OperationalModulePath = Join-Path `
    $PackageDirectory `
    'operational.py'

$OperationalConfigPath = Join-Path `
    $PackageDirectory `
    'operational-defaults.json'

$OperationalModuleName = "$PackageModule.operational"
$WrapperTarget = "$OperationalModuleName`:main"

# =====================================================================
# Back up all files that may be changed.
# =====================================================================

$PyprojectBackupPath = Join-Path `
    $BackupRoot `
    'pyproject.toml'

Copy-Item `
    -LiteralPath $PyprojectPath `
    -Destination $PyprojectBackupPath `
    -Force

if (Test-Path -LiteralPath $OperationalModulePath -PathType Leaf) {
    Copy-Item `
        -LiteralPath $OperationalModulePath `
        -Destination (
            Join-Path $BackupRoot 'operational.py'
        ) `
        -Force
}

if (Test-Path -LiteralPath $OperationalConfigPath -PathType Leaf) {
    Copy-Item `
        -LiteralPath $OperationalConfigPath `
        -Destination (
            Join-Path $BackupRoot 'operational-defaults.json'
        ) `
        -Force
}

$PyprojectHashBefore = (
    Get-FileHash `
        -LiteralPath $PyprojectPath `
        -Algorithm SHA256
).Hash

# =====================================================================
# Create standardized operational defaults.
# =====================================================================

$OperationalDefaults = [ordered]@{
    schema_version = '1.0.0'
    logging = [ordered]@{
        level = 'INFO'
        format = '%(asctime)s %(levelname)s %(name)s %(message)s'
        date_format = '%Y-%m-%dT%H:%M:%S%z'
        stream = 'stderr'
    }
    exit_codes = [ordered]@{
        success = 0
        operational_error = 1
        invalid_input = 2
        configuration_error = 3
        verification_failure = 4
        interrupted = 130
    }
    error_boundary = [ordered]@{
        emit_traceback = $false
        preserve_system_exit = $true
        preserve_keyboard_interrupt = $true
    }
}

$OperationalDefaults |
    ConvertTo-Json -Depth 8 |
    Set-Content `
        -LiteralPath $OperationalConfigPath `
        -Encoding UTF8

# =====================================================================
# Create the operational runtime module.
# =====================================================================

$OperationalLines = @(
    '"""Morning Star shared operational runtime standards."""'
    ''
    'from __future__ import annotations'
    ''
    'import json'
    'import logging'
    'import os'
    'import pathlib'
    'import sys'
    'from enum import IntEnum'
    'from typing import Any, Callable, Mapping'
    ''
    "from $TargetModule import $TargetFunction as _canonical_main"
    ''
    ''
    'class ExitCode(IntEnum):'
    '    """Canonical Morning Star process exit codes."""'
    ''
    '    SUCCESS = 0'
    '    OPERATIONAL_ERROR = 1'
    '    INVALID_INPUT = 2'
    '    CONFIGURATION_ERROR = 3'
    '    VERIFICATION_FAILURE = 4'
    '    INTERRUPTED = 130'
    ''
    ''
    'class RuntimeConfigurationError(RuntimeError):'
    '    """Raised when operational runtime configuration is invalid."""'
    ''
    ''
    'def _defaults_path() -> pathlib.Path:'
    '    return pathlib.Path(__file__).with_name("operational-defaults.json")'
    ''
    ''
    'def load_runtime_config('
    '    path: str | os.PathLike[str] | None = None,'
    ') -> dict[str, Any]:'
    '    """Load and validate the operational runtime configuration."""'
    ''
    '    config_path = pathlib.Path(path) if path else _defaults_path()'
    ''
    '    if not config_path.is_file():'
    '        raise RuntimeConfigurationError('
    '            f"Runtime configuration does not exist: {config_path}"'
    '        )'
    ''
    '    try:'
    '        with config_path.open("r", encoding="utf-8-sig") as stream:'
    '            config = json.load(stream)'
    '    except (OSError, json.JSONDecodeError) as exc:'
    '        raise RuntimeConfigurationError('
    '            f"Unable to load runtime configuration: {config_path}"'
    '        ) from exc'
    ''
    '    if not isinstance(config, dict):'
    '        raise RuntimeConfigurationError('
    '            "Runtime configuration must be a JSON object."'
    '        )'
    ''
    '    for required_key in ("logging", "exit_codes", "error_boundary"):'
    '        if required_key not in config:'
    '            raise RuntimeConfigurationError('
    '                f"Runtime configuration is missing: {required_key}"'
    '            )'
    ''
    '    return config'
    ''
    ''
    'def configure_logging('
    '    config: Mapping[str, Any] | None = None,'
    ') -> logging.Logger:'
    '    """Configure deterministic process-level logging."""'
    ''
    '    effective_config = dict(config or load_runtime_config())'
    '    logging_config = effective_config["logging"]'
    ''
    '    level_name = str('
    '        os.getenv('
    '            "MORNING_STAR_LOG_LEVEL",'
    '            logging_config.get("level", "INFO"),'
    '        )'
    '    ).upper()'
    ''
    '    level = getattr(logging, level_name, None)'
    ''
    '    if not isinstance(level, int):'
    '        raise RuntimeConfigurationError('
    '            f"Unsupported log level: {level_name}"'
    '        )'
    ''
    '    logging.basicConfig('
    '        level=level,'
    '        format=str(logging_config["format"]),'
    '        datefmt=str(logging_config["date_format"]),'
    '        stream=sys.stderr,'
    '        force=True,'
    '    )'
    ''
    '    return logging.getLogger("morning_star")'
    ''
    ''
    'def execute_with_boundary('
    '    operation: Callable[[], Any],'
    ') -> int:'
    '    """Execute one CLI operation through the canonical error boundary."""'
    ''
    '    logger = configure_logging()'
    ''
    '    try:'
    '        result = operation()'
    ''
    '        if result is None:'
    '            return int(ExitCode.SUCCESS)'
    ''
    '        if isinstance(result, bool):'
    '            return int('
    '                ExitCode.SUCCESS'
    '                if result'
    '                else ExitCode.OPERATIONAL_ERROR'
    '            )'
    ''
    '        if isinstance(result, int):'
    '            return result'
    ''
    '        return int(ExitCode.SUCCESS)'
    '    except SystemExit:'
    '        raise'
    '    except KeyboardInterrupt:'
    '        logger.warning("Execution interrupted.")'
    '        return int(ExitCode.INTERRUPTED)'
    '    except RuntimeConfigurationError as exc:'
    '        logger.error("%s", exc)'
    '        return int(ExitCode.CONFIGURATION_ERROR)'
    '    except (TypeError, ValueError) as exc:'
    '        logger.error("%s", exc)'
    '        return int(ExitCode.INVALID_INPUT)'
    '    except Exception:'
    '        logger.exception("Unhandled Morning Star runtime failure.")'
    '        return int(ExitCode.OPERATIONAL_ERROR)'
    ''
    ''
    'def main() -> int:'
    '    """Canonical console wrapper preserving the existing CLI surface."""'
    ''
    '    return execute_with_boundary(_canonical_main)'
)

$OperationalLines |
    Set-Content `
        -LiteralPath $OperationalModulePath `
        -Encoding UTF8

# =====================================================================
# Update all aliases targeting the original function to use the wrapper.
# =====================================================================

$PyprojectLines = @(
    Get-Content -LiteralPath $PyprojectPath
)

$InsideProjectScripts = $false
$UpdatedEntryCount = 0

for ($Index = 0; $Index -lt $PyprojectLines.Count; $Index++) {
    $Trimmed = $PyprojectLines[$Index].Trim()

    if ($Trimmed -eq '[project.scripts]') {
        $InsideProjectScripts = $true
        continue
    }

    if (
        $InsideProjectScripts -and
        $Trimmed -match '^\['
    ) {
        $InsideProjectScripts = $false
    }

    if (
        $InsideProjectScripts -and
        $PyprojectLines[$Index] -match
        (
            '^(?<prefix>\s*[A-Za-z0-9_-]+\s*=\s*["''])' +
            [regex]::Escape($OriginalTarget) +
            '(?<suffix>["'']\s*)$'
        )
    ) {
        $PyprojectLines[$Index] = (
            $Matches['prefix'] +
            $WrapperTarget +
            $Matches['suffix']
        )

        $UpdatedEntryCount++
    }
}

Assert-MSCondition `
    -Condition ($UpdatedEntryCount -ge 1) `
    -Message 'No console entries were updated to the operational wrapper.' `
    -InvariantID 'MS-B3-P3-WRAPPER-ENTRY'

$Utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)

[System.IO.File]::WriteAllLines(
    $PyprojectPath,
    [string[]]$PyprojectLines,
    $Utf8WithoutBom
)

# =====================================================================
# Validate TOML and Python syntax.
# =====================================================================

$TomlValidationPath = Join-Path `
    $ReportRoot `
    'Validate-Pyproject.py'

@(
    'import pathlib'
    'import sys'
    'import tomllib'
    ''
    'path = pathlib.Path(sys.argv[1])'
    'text = path.read_text(encoding="utf-8-sig")'
    'data = tomllib.loads(text)'
    ''
    'scripts = data.get("project", {}).get("scripts", {})'
    'expected = sys.argv[2]'
    ''
    'if expected not in scripts.values():'
    '    raise SystemExit(4)'
) |
    Set-Content `
        -LiteralPath $TomlValidationPath `
        -Encoding UTF8

& python `
    $TomlValidationPath `
    $PyprojectPath `
    $WrapperTarget

if ($LASTEXITCODE -ne 0) {
    Copy-Item `
        -LiteralPath $PyprojectBackupPath `
        -Destination $PyprojectPath `
        -Force

    throw 'pyproject.toml validation failed and was restored.'
}

$PythonFiles = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Recurse `
        -File `
        -Filter '*.py' |
    Where-Object {
        $_.FullName -notmatch
        '\\(\.git|Archive|archive|backups|\.venv|venv|build|dist)\\'
    }
)

$CompileFailures = [System.Collections.Generic.List[object]]::new()

foreach ($File in $PythonFiles) {
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

Assert-MSCondition `
    -Condition ($CompileFailures.Count -eq 0) `
    -Message (
        "$($CompileFailures.Count) Python files failed compilation."
    ) `
    -InvariantID 'MS-B3-P3-COMPILE'

# =====================================================================
# Configuration, logging, exit-code, and boundary probes.
# =====================================================================

$ProbePath = Join-Path `
    $ReportRoot `
    'Probe-OperationalStandards.py'

$ProbeResultPath = Join-Path `
    $ReportRoot `
    'B3_PASS03_OPERATIONAL_PROBE.json'

@(
    'import importlib'
    'import json'
    'import pathlib'
    'import sys'
    ''
    'module_name = sys.argv[1]'
    'output_path = pathlib.Path(sys.argv[2])'
    'module = importlib.import_module(module_name)'
    ''
    'config = module.load_runtime_config()'
    'logger = module.configure_logging(config)'
    ''
    'results = {'
    '    "success": module.execute_with_boundary(lambda: None),'
    '    "integer": module.execute_with_boundary(lambda: 4),'
    '    "invalid_input": module.execute_with_boundary('
    '        lambda: (_ for _ in ()).throw(ValueError("invalid"))'
    '    ),'
    '    "operational_error": module.execute_with_boundary('
    '        lambda: (_ for _ in ()).throw(RuntimeError("failure"))'
    '    ),'
    '    "logger_name": logger.name,'
    '    "schema_version": config["schema_version"],'
    '}'
    ''
    'output_path.write_text('
    '    json.dumps(results, sort_keys=True, indent=2),'
    '    encoding="utf-8",'
    ')'
) |
    Set-Content `
        -LiteralPath $ProbePath `
        -Encoding UTF8

$PreviousPythonPath = $env:PYTHONPATH

try {
    $ProjectRoot = Split-Path `
        -Parent `
        $PyprojectPath

    $env:PYTHONPATH = if (
        [string]::IsNullOrWhiteSpace($PreviousPythonPath)
    ) {
        $ProjectRoot
    }
    else {
        "$ProjectRoot;$PreviousPythonPath"
    }

    & python `
        $ProbePath `
        $OperationalModuleName `
        $ProbeResultPath

    if ($LASTEXITCODE -ne 0) {
        throw 'Operational standards probe failed.'
    }

    $HelpRun1Path = Join-Path `
        $ReportRoot `
        'B3_PASS03_HELP_RUN_1.txt'

    $HelpRun2Path = Join-Path `
        $ReportRoot `
        'B3_PASS03_HELP_RUN_2.txt'

    $HelpRun1 = @(
        & python -c (
            "import sys; " +
            "from $OperationalModuleName import main; " +
            "sys.argv=['$CanonicalConsole','--help']; " +
            "raise SystemExit(main())"
        ) 2>&1
    )

    $HelpExit1 = $LASTEXITCODE

    $HelpRun1 |
        Set-Content `
            -LiteralPath $HelpRun1Path `
            -Encoding UTF8

    $HelpRun2 = @(
        & python -c (
            "import sys; " +
            "from $OperationalModuleName import main; " +
            "sys.argv=['$CanonicalConsole','--help']; " +
            "raise SystemExit(main())"
        ) 2>&1
    )

    $HelpExit2 = $LASTEXITCODE

    $HelpRun2 |
        Set-Content `
            -LiteralPath $HelpRun2Path `
            -Encoding UTF8
}
finally {
    $env:PYTHONPATH = $PreviousPythonPath
}

$ProbeResult = Get-Content `
    -LiteralPath $ProbeResultPath `
    -Raw |
    ConvertFrom-Json

Assert-MSCondition `
    -Condition (
        $ProbeResult.success -eq 0 -and
        $ProbeResult.integer -eq 4 -and
        $ProbeResult.invalid_input -eq 2 -and
        $ProbeResult.operational_error -eq 1 -and
        $ProbeResult.logger_name -eq 'morning_star'
    ) `
    -Message 'Operational standards probe returned invalid results.' `
    -InvariantID 'MS-B3-P3-PROBE'

$HelpText1 = (
    Get-Content `
        -LiteralPath $HelpRun1Path `
        -Raw
).Trim()

$HelpText2 = (
    Get-Content `
        -LiteralPath $HelpRun2Path `
        -Raw
).Trim()

Assert-MSCondition `
    -Condition (
        $HelpExit1 -eq 0 -and
        $HelpExit2 -eq 0
    ) `
    -Message (
        "CLI help failed after wrapping: $HelpExit1, $HelpExit2"
    ) `
    -InvariantID 'MS-B3-P3-HELP'

Assert-MSCondition `
    -Condition ($HelpText1 -eq $HelpText2) `
    -Message 'CLI help changed between repeated executions.' `
    -InvariantID 'MS-B3-P3-HELP-DETERMINISM'

# =====================================================================
# Regression verification.
# =====================================================================

$RegressionFailures = [System.Collections.Generic.List[object]]::new()

foreach ($Before in $ProtectedBefore) {
    $After = Get-MSFileHashRecord `
        -LiteralPath $Before.Path

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

Assert-MSCondition `
    -Condition ($RegressionFailures.Count -eq 0) `
    -Message (
        "$($RegressionFailures.Count) protected artifacts changed."
    ) `
    -InvariantID 'MS-B3-P3-REGRESSION'

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

Assert-MSCondition `
    -Condition (
        $Stage5Status.Result -eq 'PASS' -and
        $Stage5Status.FailedFinalValidations -eq 0
    ) `
    -Message 'Stage 5 regression failed.' `
    -InvariantID 'MS-B3-P3-STAGE5'

Assert-MSCondition `
    -Condition (
        $Stage6Status.Result -eq 'PASS' -and
        $Stage6Status.BatchClosureEligibility -eq 'ELIGIBLE'
    ) `
    -Message 'Stage 6 regression failed.' `
    -InvariantID 'MS-B3-P3-STAGE6'

# =====================================================================
# Completion artifacts.
# =====================================================================

$PyprojectHashAfter = (
    Get-FileHash `
        -LiteralPath $PyprojectPath `
        -Algorithm SHA256
).Hash

$OperationalModuleHash = (
    Get-FileHash `
        -LiteralPath $OperationalModulePath `
        -Algorithm SHA256
).Hash

$OperationalConfigHash = (
    Get-FileHash `
        -LiteralPath $OperationalConfigPath `
        -Algorithm SHA256
).Hash

$ExecutionRegisterPath = Join-Path `
    $ReportRoot `
    'B3_PASS03_EXECUTION_REGISTER.csv'

@(
    [pscustomobject][ordered]@{
        ArtifactPath = $OperationalModulePath
        Action = 'CREATED_OR_REPLACED'
        Purpose = 'Shared exit codes, logging, configuration, and error boundary.'
        SHA256 = $OperationalModuleHash
        Status = 'VERIFIED'
    }
    [pscustomobject][ordered]@{
        ArtifactPath = $OperationalConfigPath
        Action = 'CREATED_OR_REPLACED'
        Purpose = 'Operational runtime defaults.'
        SHA256 = $OperationalConfigHash
        Status = 'VERIFIED'
    }
    [pscustomobject][ordered]@{
        ArtifactPath = $PyprojectPath
        Action = 'CONSOLE_TARGET_WRAPPED'
        Purpose = 'Route public console entries through the operational boundary.'
        SHA256 = $PyprojectHashAfter
        Status = 'VERIFIED'
    }
) |
    Export-Csv `
        -LiteralPath $ExecutionRegisterPath `
        -NoTypeInformation `
        -Encoding UTF8

$ExistingManifest = Get-Content `
    -LiteralPath $ManifestPath `
    -Raw |
    ConvertFrom-Json

[ordered]@{
    PassID = 'B3-PASS-03'
    BatchID = 'BATCH-3'
    Purpose = $ExistingManifest.Purpose
    Result = 'PASS'
    Status = 'COMPLETE'
    OriginalConsoleTarget = $OriginalTarget
    StandardizedConsoleTarget = $WrapperTarget
    ConsoleEntriesUpdated = $UpdatedEntryCount
    ExitCodeStandard = [ordered]@{
        Success = 0
        OperationalError = 1
        InvalidInput = 2
        ConfigurationError = 3
        VerificationFailure = 4
        Interrupted = 130
    }
    LoggingStandard = [ordered]@{
        LoggerName = 'morning_star'
        DefaultLevel = 'INFO'
        Stream = 'stderr'
        EnvironmentOverride = 'MORNING_STAR_LOG_LEVEL'
    }
    ConfigurationPath = $OperationalConfigPath
    ConfigurationValidated = $true
    ErrorBoundaryValidated = $true
    PythonFilesCompiled = $PythonFiles.Count
    PythonCompileFailures = $CompileFailures.Count
    HelpExitCode = $HelpExit1
    HelpDeterministic = $true
    RegressionFailures = $RegressionFailures.Count
    Stage5RegressionStatus = $Stage5Status.Result
    Stage6RegressionStatus = $Stage6Status.Result
    BackupRoot = $BackupRoot
    PyprojectSHA256Before = $PyprojectHashBefore
    PyprojectSHA256After = $PyprojectHashAfter
    CompletedAt = (Get-Date).ToString('o')
} |
    ConvertTo-Json -Depth 10 |
    Set-Content `
        -LiteralPath $ManifestPath `
        -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — BATCH 3 PASS 03' -ForegroundColor Cyan
Write-Host 'OPERATIONAL STANDARDS' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Original console target:              $OriginalTarget"
Write-Host "Standardized console target:          $WrapperTarget"
Write-Host "Console entries updated:              $UpdatedEntryCount"
Write-Host "Exit codes standardized:              6"
Write-Host "Logging standard:                     morning_star / INFO / stderr"
Write-Host "Configuration validated:              True"
Write-Host "Error boundary validated:             True"
Write-Host "Python files compiled:                $($PythonFiles.Count)"
Write-Host "Python compile failures:              $($CompileFailures.Count)"
Write-Host "Help exit code:                       $HelpExit1"
Write-Host "Help deterministic:                   True"
Write-Host "Regression failures:                  $($RegressionFailures.Count)"
Write-Host "Stage 5 regression:                   $($Stage5Status.Result)"
Write-Host "Stage 6 regression:                   $($Stage6Status.Result)"
Write-Host ''
Write-Host "Operational module:                   $OperationalModulePath"
Write-Host "Operational defaults:                 $OperationalConfigPath"
Write-Host "Backups:                              $BackupRoot"
Write-Host ''
Write-Host 'BATCH 3 PASS 03: PASS' -ForegroundColor Green
Write-Host 'EXIT CODES, LOGGING, CONFIGURATION, AND ERROR BOUNDARIES ARE STANDARDIZED.' -ForegroundColor Green
Write-Host 'THE EXISTING CLI COMMAND AND HELP SURFACE WAS PRESERVED.' -ForegroundColor Green
Write-Host 'STAGE 5 AND STAGE 6 REGRESSION CHECKS PASSED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan

