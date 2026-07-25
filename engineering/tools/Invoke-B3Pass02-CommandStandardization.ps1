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
    'engineering\reports\batch-3\B3-PASS-02'

$BackupRoot = Join-Path `
    $RepositoryRoot `
    'engineering\backups\batch-3\B3-PASS-02'

$ManifestPath = Join-Path `
    $RepositoryRoot `
    'engineering\manifests\batch-3\B3-PASS-02_MANIFEST.json'

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

if ($PyprojectCandidates.Count -eq 0) {
    throw "No pyproject.toml was found below $RepositoryRoot"
}

$PyprojectWithConsoleEntry = @(
    foreach ($Candidate in $PyprojectCandidates) {
        $CandidateText = Get-Content `
            -LiteralPath $Candidate.FullName `
            -Raw

        if ($CandidateText -match '(?m)^\s*\[project\.scripts\]\s*$') {
            $Candidate
        }
    }
)

if ($PyprojectWithConsoleEntry.Count -eq 1) {
    $PyprojectPath = $PyprojectWithConsoleEntry[0].FullName
}
elseif ($PyprojectWithConsoleEntry.Count -gt 1) {
    Write-Host ''
    Write-Host 'Multiple pyproject.toml files define [project.scripts]:' -ForegroundColor Yellow

    $PyprojectWithConsoleEntry |
        Select-Object FullName |
        Format-Table -AutoSize

    throw 'The public runtime project is ambiguous.'
}
elseif ($PyprojectCandidates.Count -eq 1) {
    $PyprojectPath = $PyprojectCandidates[0].FullName
}
else {
    Write-Host ''
    Write-Host 'pyproject.toml candidates:' -ForegroundColor Yellow

    $PyprojectCandidates |
        Select-Object FullName |
        Format-Table -AutoSize

    throw 'No unique pyproject.toml with [project.scripts] could be identified.'
}

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

Import-Module $ModulePath -Force -ErrorAction Stop

Assert-MSCondition `
    -Condition (
        Test-Path -LiteralPath $PyprojectPath -PathType Leaf
    ) `
    -Message "pyproject.toml is missing: $PyprojectPath" `
    -InvariantID 'MS-B3-P2-PYPROJECT'

$PythonCommand = Get-Command `
    -Name python `
    -ErrorAction SilentlyContinue

Assert-MSCondition `
    -Condition ($null -ne $PythonCommand) `
    -Message 'Python is not available in PATH.' `
    -InvariantID 'MS-B3-P2-PYTHON'

# =====================================================================
# Preserve authoritative Stage 5 and Stage 6 state.
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
# Read [project.scripts] from pyproject.toml through Python tomllib.
# =====================================================================

$TomlProbePath = Join-Path `
    $ReportRoot `
    'Read-PyprojectScripts.py'

@(
    'import json'
    'import pathlib'
    'import sys'
    'import tomllib'
    ''
    'path = pathlib.Path(sys.argv[1])'
    'with path.open("rb") as stream:'
    '    data = tomllib.load(stream)'
    ''
    'project = data.get("project", {})'
    'scripts = project.get("scripts", {})'
    'print(json.dumps(scripts, sort_keys=True))'
) |
    Set-Content `
        -LiteralPath $TomlProbePath `
        -Encoding UTF8

$ScriptsJson = & python `
    $TomlProbePath `
    $PyprojectPath

if ($LASTEXITCODE -ne 0) {
    throw 'Unable to read [project.scripts] from pyproject.toml.'
}

$ProjectScripts = $ScriptsJson | ConvertFrom-Json

$ScriptProperties = @(
    $ProjectScripts.PSObject.Properties
)

Assert-MSCondition `
    -Condition ($ScriptProperties.Count -gt 0) `
    -Message 'pyproject.toml contains no [project.scripts] entries.' `
    -InvariantID 'MS-B3-P2-SCRIPTS'

$CanonicalConsoleName = 'morning-star'

$CanonicalProperty = @(
    $ScriptProperties |
        Where-Object Name -eq $CanonicalConsoleName
)

$PyprojectModified = $false
$OriginalPyprojectHash = (
    Get-FileHash `
        -LiteralPath $PyprojectPath `
        -Algorithm SHA256
).Hash

if ($CanonicalProperty.Count -eq 0) {
    $UniqueTargets = @(
        $ScriptProperties.Value |
            Sort-Object -Unique
    )

    Assert-MSCondition `
        -Condition ($UniqueTargets.Count -eq 1) `
        -Message (
            'Cannot infer a canonical Morning Star entry point because ' +
            "$($UniqueTargets.Count) distinct console targets exist."
        ) `
        -InvariantID 'MS-B3-P2-ENTRYPOINT'

    $BackupPath = Join-Path $BackupRoot 'pyproject.toml'

    Copy-Item `
        -LiteralPath $PyprojectPath `
        -Destination $BackupPath `
        -Force

    $PyprojectLines = @(
        Get-Content -LiteralPath $PyprojectPath
    )

    $ProjectScriptsHeaderIndex = -1

    for ($Index = 0; $Index -lt $PyprojectLines.Count; $Index++) {
        if (
            $PyprojectLines[$Index].Trim() -eq
            '[project.scripts]'
        ) {
            $ProjectScriptsHeaderIndex = $Index
            break
        }
    }

    Assert-MSCondition `
        -Condition ($ProjectScriptsHeaderIndex -ge 0) `
        -Message '[project.scripts] section was not found.' `
        -InvariantID 'MS-B3-P2-SCRIPT-SECTION'

    $InsertionIndex = $ProjectScriptsHeaderIndex + 1

    while (
        $InsertionIndex -lt $PyprojectLines.Count -and
        $PyprojectLines[$InsertionIndex] -notmatch '^\s*\['
    ) {
        $InsertionIndex++
    }

    $CanonicalLine = (
        '{0} = "{1}"' -f
        $CanonicalConsoleName,
        $UniqueTargets[0]
    )

    $BeforeLines = if ($InsertionIndex -gt 0) {
        @($PyprojectLines[0..($InsertionIndex - 1)])
    }
    else {
        @()
    }

    $AfterLines = if ($InsertionIndex -lt $PyprojectLines.Count) {
        @($PyprojectLines[$InsertionIndex..($PyprojectLines.Count - 1)])
    }
    else {
        @()
    }

    @(
        $BeforeLines
        $CanonicalLine
        $AfterLines
    ) |
        Set-Content `
            -LiteralPath $PyprojectPath `
            -Encoding UTF8

    $PyprojectModified = $true

    $ScriptsJson = & python `
        $TomlProbePath `
        $PyprojectPath

    if ($LASTEXITCODE -ne 0) {
        Copy-Item `
            -LiteralPath $BackupPath `
            -Destination $PyprojectPath `
            -Force

        throw 'Modified pyproject.toml failed TOML validation and was restored.'
    }

    $ProjectScripts = $ScriptsJson | ConvertFrom-Json
    $ScriptProperties = @(
        $ProjectScripts.PSObject.Properties
    )

    $CanonicalProperty = @(
        $ScriptProperties |
            Where-Object Name -eq $CanonicalConsoleName
    )
}

Assert-MSCondition `
    -Condition ($CanonicalProperty.Count -eq 1) `
    -Message 'Exactly one canonical morning-star entry point is required.' `
    -InvariantID 'MS-B3-P2-CANONICAL-ENTRY'

$CanonicalTarget = [string]$CanonicalProperty[0].Value

Assert-MSCondition `
    -Condition (
        $CanonicalTarget -match
        '^[A-Za-z_][A-Za-z0-9_.]*:[A-Za-z_][A-Za-z0-9_]*$'
    ) `
    -Message "Invalid console target syntax: $CanonicalTarget" `
    -InvariantID 'MS-B3-P2-TARGET-SYNTAX'

$TargetParts = $CanonicalTarget -split ':', 2
$TargetModule = $TargetParts[0]
$TargetFunction = $TargetParts[1]

# =====================================================================
# Locate the public entry-point module.
# =====================================================================

$TargetRelativePath = (
    $TargetModule -replace '\.', '\'
) + '.py'

$EntryPointCandidates = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Recurse `
        -File `
        -Filter '*.py' |
        Where-Object {
            $_.FullName.EndsWith(
                $TargetRelativePath,
                [System.StringComparison]::OrdinalIgnoreCase
            )
        }
)

Assert-MSCondition `
    -Condition ($EntryPointCandidates.Count -eq 1) `
    -Message (
        "Expected one file for $TargetModule; found " +
        "$($EntryPointCandidates.Count)."
    ) `
    -InvariantID 'MS-B3-P2-TARGET-FILE'

$EntryPointPath = $EntryPointCandidates[0].FullName
$EntryPointText = Get-Content `
    -LiteralPath $EntryPointPath `
    -Raw

Assert-MSCondition `
    -Condition (
        $EntryPointText -match
        ("(?m)^\s*def\s+{0}\s*\(" -f [regex]::Escape($TargetFunction))
    ) `
    -Message (
        "Target function '$TargetFunction' was not found in " +
        $EntryPointPath
    ) `
    -InvariantID 'MS-B3-P2-TARGET-FUNCTION'

# =====================================================================
# Inventory the actual command surface.
# =====================================================================

$CommandRecords = [System.Collections.Generic.List[object]]::new()

$PythonFiles = @(
    Get-ChildItem `
        -LiteralPath (
            Split-Path -Parent $EntryPointPath
        ) `
        -Recurse `
        -File `
        -Filter '*.py'
)

foreach ($File in $PythonFiles) {
    $Content = Get-Content `
        -LiteralPath $File.FullName `
        -Raw

    $RelativePath = $File.FullName.
        Substring($RepositoryRoot.Length).
        TrimStart('\')

    $TyperMatches = @(
        [regex]::Matches(
            $Content,
            '(?ms)@(?:app|cli)\.command\((?<args>[^\)]*)\)\s*' +
            'def\s+(?<function>[A-Za-z_][A-Za-z0-9_]*)\s*\('
        )
    )

    foreach ($Match in $TyperMatches) {
        $Arguments = $Match.Groups['args'].Value
        $FunctionName = $Match.Groups['function'].Value
        $ExplicitName = ''

        if (
            $Arguments -match
            '[''"](?<name>[A-Za-z0-9_-]+)[''"]'
        ) {
            $ExplicitName = $Matches['name']
        }

        $CommandName = if (
            [string]::IsNullOrWhiteSpace($ExplicitName)
        ) {
            $FunctionName -replace '_', '-'
        }
        else {
            $ExplicitName
        }

        $CommandRecords.Add(
            [pscustomobject][ordered]@{
                CommandName = $CommandName
                FunctionName = $FunctionName
                Framework = 'TYPER'
                RelativePath = $RelativePath
                IsCanonicalConsole = $false
                IsAlias = $false
            }
        )
    }

    $ArgparseMatches = @(
        [regex]::Matches(
            $Content,
            '\.add_parser\(\s*[''"](?<name>[A-Za-z0-9_-]+)[''"]'
        )
    )

    foreach ($Match in $ArgparseMatches) {
        $CommandRecords.Add(
            [pscustomobject][ordered]@{
                CommandName = $Match.Groups['name'].Value
                FunctionName = ''
                Framework = 'ARGPARSE'
                RelativePath = $RelativePath
                IsCanonicalConsole = $false
                IsAlias = $false
            }
        )
    }

    $ClickMatches = @(
        [regex]::Matches(
            $Content,
            '(?ms)@(?:click\.)?command\((?<args>[^\)]*)\)\s*' +
            'def\s+(?<function>[A-Za-z_][A-Za-z0-9_]*)\s*\('
        )
    )

    foreach ($Match in $ClickMatches) {
        $FunctionName = $Match.Groups['function'].Value
        $Arguments = $Match.Groups['args'].Value
        $CommandName = $FunctionName -replace '_', '-'

        if (
            $Arguments -match
            '[''"](?<name>[A-Za-z0-9_-]+)[''"]'
        ) {
            $CommandName = $Matches['name']
        }

        $CommandRecords.Add(
            [pscustomobject][ordered]@{
                CommandName = $CommandName
                FunctionName = $FunctionName
                Framework = 'CLICK'
                RelativePath = $RelativePath
                IsCanonicalConsole = $false
                IsAlias = $false
            }
        )
    }
}

$UniqueCommands = @(
    $CommandRecords |
        Sort-Object CommandName, RelativePath -Unique
)

$ConsoleEntries = @(
    foreach ($Property in $ScriptProperties) {
        [pscustomobject][ordered]@{
            ConsoleName = $Property.Name
            Target = [string]$Property.Value
            IsCanonical = (
                $Property.Name -eq $CanonicalConsoleName
            )
            IsAlias = (
                $Property.Name -ne $CanonicalConsoleName -and
                [string]$Property.Value -eq $CanonicalTarget
            )
        }
    }
)

# =====================================================================
# Verify public help behavior twice.
# =====================================================================

$EnvironmentBackup = $env:PYTHONPATH

try {
    $env:PYTHONPATH = if (
        [string]::IsNullOrWhiteSpace($EnvironmentBackup)
    ) {
        $RepositoryRoot
    }
    else {
        "$RepositoryRoot;$EnvironmentBackup"
    }

    $HelpRun1Path = Join-Path `
        $ReportRoot `
        'B3_PASS02_HELP_RUN_1.txt'

    $HelpRun2Path = Join-Path `
        $ReportRoot `
        'B3_PASS02_HELP_RUN_2.txt'

    $HelpRun1 = @(
        & python -c (
            "import sys; " +
            "from $TargetModule import $TargetFunction; " +
            "sys.argv=['$CanonicalConsoleName','--help']; " +
            "$TargetFunction()"
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
            "from $TargetModule import $TargetFunction; " +
            "sys.argv=['$CanonicalConsoleName','--help']; " +
            "$TargetFunction()"
        ) 2>&1
    )

    $HelpExit2 = $LASTEXITCODE

    $HelpRun2 |
        Set-Content `
            -LiteralPath $HelpRun2Path `
            -Encoding UTF8
}
finally {
    $env:PYTHONPATH = $EnvironmentBackup
}

$HelpText1 = (
    Get-Content -LiteralPath $HelpRun1Path -Raw
).Trim()

$HelpText2 = (
    Get-Content -LiteralPath $HelpRun2Path -Raw
).Trim()

$HelpDeterministic = (
    $HelpText1 -eq $HelpText2
)

$HelpSuccessful = (
    $HelpExit1 -eq 0 -and
    $HelpExit2 -eq 0 -and
    -not [string]::IsNullOrWhiteSpace($HelpText1)
)

Assert-MSCondition `
    -Condition $HelpSuccessful `
    -Message (
        "Public help failed. Exit1=$HelpExit1; Exit2=$HelpExit2"
    ) `
    -InvariantID 'MS-B3-P2-HELP'

Assert-MSCondition `
    -Condition $HelpDeterministic `
    -Message 'Repeated public help output was not deterministic.' `
    -InvariantID 'MS-B3-P2-HELP-DETERMINISM'

# =====================================================================
# Generate the canonical command-surface registry.
# =====================================================================

$CommandSurfaceRoot = Join-Path `
    $RepositoryRoot `
    'runtime\cli'

New-Item `
    -ItemType Directory `
    -Path $CommandSurfaceRoot `
    -Force |
    Out-Null

$CommandSurfacePath = Join-Path `
    $CommandSurfaceRoot `
    'command-surface.json'

$CommandDocumentationPath = Join-Path `
    $CommandSurfaceRoot `
    'COMMANDS.md'

$CommandSurface = [ordered]@{
    SchemaVersion = '1.0.0'
    Console = [ordered]@{
        CanonicalName = $CanonicalConsoleName
        Target = $CanonicalTarget
        Module = $TargetModule
        Function = $TargetFunction
        EntryPointPath = $EntryPointPath.
            Substring($RepositoryRoot.Length).
            TrimStart('\')
    }
    ConsoleEntries = $ConsoleEntries
    Commands = @(
        $UniqueCommands |
            Select-Object `
                CommandName,
                FunctionName,
                Framework,
                RelativePath
    )
    Help = [ordered]@{
        ExitCode = $HelpExit1
        Deterministic = $HelpDeterministic
        Artifact = $HelpRun1Path.
            Substring($RepositoryRoot.Length).
            TrimStart('\')
    }
    GeneratedAt = (Get-Date).ToString('o')
}

$CommandSurface |
    ConvertTo-Json -Depth 10 |
    Set-Content `
        -LiteralPath $CommandSurfacePath `
        -Encoding UTF8

$DocumentationLines = @(
    '# Morning Star CLI Commands'
    ''
    '## Public executable'
    ''
    "- Canonical command: ``$CanonicalConsoleName``"
    "- Python target: ``$CanonicalTarget``"
    ''
    '## Supported command surface'
    ''
)

if ($UniqueCommands.Count -eq 0) {
    $DocumentationLines += (
        '- No subordinate commands were statically discoverable. ' +
        'The public executable remains the canonical runtime interface.'
    )
}
else {
    foreach ($Command in $UniqueCommands) {
        $DocumentationLines += (
            '- ``{0}`` — {1} in ``{2}``' -f
            $Command.CommandName,
            $Command.Framework,
            $Command.RelativePath
        )
    }
}

$DocumentationLines += @(
    ''
    '## Compatibility aliases'
    ''
)

$Aliases = @(
    $ConsoleEntries |
        Where-Object IsAlias
)

if ($Aliases.Count -eq 0) {
    $DocumentationLines += '- None.'
}
else {
    foreach ($Alias in $Aliases) {
        $DocumentationLines += (
            '- ``{0}`` → ``{1}``' -f
            $Alias.ConsoleName,
            $CanonicalConsoleName
        )
    }
}

$DocumentationLines += @(
    ''
    '## Help behavior'
    ''
    '- ``morning-star --help`` exits successfully.'
    '- Repeated help output is deterministic.'
)

$DocumentationLines |
    Set-Content `
        -LiteralPath $CommandDocumentationPath `
        -Encoding UTF8

# =====================================================================
# Python syntax and import verification.
# =====================================================================

$PythonRuntimeFiles = @(
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

foreach ($File in $PythonRuntimeFiles) {
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
    -InvariantID 'MS-B3-P2-COMPILE'

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

Assert-MSCondition `
    -Condition ($RegressionFailures.Count -eq 0) `
    -Message (
        "$($RegressionFailures.Count) protected artifacts changed."
    ) `
    -InvariantID 'MS-B3-P2-REGRESSION'

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
    -InvariantID 'MS-B3-P2-STAGE5'

Assert-MSCondition `
    -Condition (
        $Stage6Status.Result -eq 'PASS' -and
        $Stage6Status.BatchClosureEligibility -eq 'ELIGIBLE'
    ) `
    -Message 'Stage 6 regression failed.' `
    -InvariantID 'MS-B3-P2-STAGE6'

# =====================================================================
# Evidence and manifest.
# =====================================================================

$CommandInventoryPath = Join-Path `
    $ReportRoot `
    'B3_PASS02_COMMAND_SURFACE.csv'

$ConsoleInventoryPath = Join-Path `
    $ReportRoot `
    'B3_PASS02_CONSOLE_ENTRYPOINTS.csv'

$UniqueCommands |
    Export-Csv `
        -LiteralPath $CommandInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$ConsoleEntries |
    Export-Csv `
        -LiteralPath $ConsoleInventoryPath `
        -NoTypeInformation `
        -Encoding UTF8

$PyprojectHashAfter = (
    Get-FileHash `
        -LiteralPath $PyprojectPath `
        -Algorithm SHA256
).Hash

$ExistingManifest = Get-Content `
    -LiteralPath $ManifestPath `
    -Raw |
    ConvertFrom-Json

[ordered]@{
    PassID = 'B3-PASS-02'
    BatchID = 'BATCH-3'
    Purpose = $ExistingManifest.Purpose
    Result = 'PASS'
    Status = 'COMPLETE'
    CanonicalConsoleName = $CanonicalConsoleName
    CanonicalTarget = $CanonicalTarget
    EntryPointPath = $EntryPointPath
    ConsoleEntries = $ConsoleEntries.Count
    CompatibilityAliases = $Aliases.Count
    CommandsDiscovered = $UniqueCommands.Count
    HelpExitCode = $HelpExit1
    HelpDeterministic = $HelpDeterministic
    PythonFilesCompiled = $PythonRuntimeFiles.Count
    PythonCompileFailures = $CompileFailures.Count
    PyprojectModified = $PyprojectModified
    PyprojectSHA256Before = $OriginalPyprojectHash
    PyprojectSHA256After = $PyprojectHashAfter
    RegressionFailures = $RegressionFailures.Count
    Stage5RegressionStatus = $Stage5Status.Result
    Stage6RegressionStatus = $Stage6Status.Result
    BackupRoot = $BackupRoot
    CommandSurfacePath = $CommandSurfacePath
    CommandDocumentationPath = $CommandDocumentationPath
    CompletedAt = (Get-Date).ToString('o')
} |
    ConvertTo-Json -Depth 10 |
    Set-Content `
        -LiteralPath $ManifestPath `
        -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — BATCH 3 PASS 02' -ForegroundColor Cyan
Write-Host 'COMMAND STANDARDIZATION' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Canonical console:                    $CanonicalConsoleName"
Write-Host "Canonical target:                     $CanonicalTarget"
Write-Host "Entry-point file:                     $EntryPointPath"
Write-Host "Console entries:                      $($ConsoleEntries.Count)"
Write-Host "Compatibility aliases:                $($Aliases.Count)"
Write-Host "Commands discovered:                  $($UniqueCommands.Count)"
Write-Host "Help exit code:                       $HelpExit1"
Write-Host "Help deterministic:                   $HelpDeterministic"
Write-Host "Python files compiled:                $($PythonRuntimeFiles.Count)"
Write-Host "Python compile failures:              $($CompileFailures.Count)"
Write-Host "pyproject.toml modified:              $PyprojectModified"
Write-Host "Regression failures:                  $($RegressionFailures.Count)"
Write-Host "Stage 5 regression:                   $($Stage5Status.Result)"
Write-Host "Stage 6 regression:                   $($Stage6Status.Result)"
Write-Host ''
Write-Host "Command surface:                      $CommandSurfacePath"
Write-Host "Command documentation:                $CommandDocumentationPath"
Write-Host ''
Write-Host 'BATCH 3 PASS 02: PASS' -ForegroundColor Green
Write-Host 'THE PUBLIC CLI ENTRY POINT IS CANONICALLY DEFINED.' -ForegroundColor Green
Write-Host 'COMMAND AND ALIAS SURFACES ARE EXPLICITLY REGISTERED.' -ForegroundColor Green
Write-Host 'PUBLIC HELP BEHAVIOR IS SUCCESSFUL AND DETERMINISTIC.' -ForegroundColor Green
Write-Host 'STAGE 5 AND STAGE 6 REGRESSION CHECKS PASSED.' -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan

