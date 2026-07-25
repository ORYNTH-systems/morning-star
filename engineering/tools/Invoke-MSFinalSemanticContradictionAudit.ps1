$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepositoryRoot = (
    Resolve-Path (Join-Path $PSScriptRoot '..\..')
).Path

$ReportRoot = Join-Path `
    $RepositoryRoot `
    'engineering\reports\final-semantic-audit'

$CsvReportPath = Join-Path `
    $ReportRoot `
    'FINAL_SEMANTIC_CONTRADICTION_REGISTER.csv'

$MarkdownReportPath = Join-Path `
    $ReportRoot `
    'FINAL_SEMANTIC_CONTRADICTION_REPORT.md'

$ManifestPath = Join-Path `
    $ReportRoot `
    'FINAL_SEMANTIC_CONTRADICTION_MANIFEST.json'

New-Item `
    -ItemType Directory `
    -Path $ReportRoot `
    -Force |
    Out-Null

# =====================================================================
# Authoritative release identity.
# =====================================================================

$ExpectedArchitectureVersion = '1.0.0-rc.1'
$ExpectedRuntimeVersion = '0.5.0'

$AuthoritativeRootFiles = @(
    'README.md'
    'ARCHITECTURE_CERTIFICATION.md'
    'ARCHITECTURE_CERTIFICATION_READINESS.md'
    'ARCHITECTURE_COMPLETION_CERTIFICATION.md'
    'ARCHITECTURE_MAP.md'
    'CHANGELOG.md'
    'CITATION.cff'
    'CITATION_METADATA.md'
    'FINAL_FREEZE_DECLARATION.md'
    'LICENSE.md'
    'PUBLIC_REFERENCE_MANIFEST.csv'
    'VERSION.md'
)

$AuthoritativeDirectoryPatterns = @(
    '^constitution\\'
    '^governance\\'
    '^registries\\'
    '^architecture\\'
    '^release\\'
    '^runtime\\pyproject\.toml$'
)

$ExcludedPathPattern = (
    '\\(' +
    '\.git|' +
    'Archive|' +
    'archive|' +
    'backups|' +
    'release\\staging|' +
    'engineering\\reports|' +
    'engineering\\backups|' +
    'execution|' +
    'verification|' +
    '\.venv|' +
    'venv|' +
    'build|' +
    'dist|' +
    '_NEXT_VERIFICATION_INTAKE|' +
    'readiness\\BATCH_EXECUTION' +
    ')\\'
)

$AllowedExtensions = @(
    '.md'
    '.txt'
    '.json'
    '.csv'
    '.yaml'
    '.yml'
    '.cff'
    '.toml'
)

# =====================================================================
# Select only active authority documents.
# =====================================================================

$AuthorityFiles = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Recurse `
        -File `
        -ErrorAction Stop |
    Where-Object {
        $RelativePath = $_.FullName.
            Substring($RepositoryRoot.Length).
            TrimStart('\')

        $IsRootAuthority = (
            $RelativePath -notmatch '\\' -and
            $_.Name -in $AuthoritativeRootFiles
        )

        $IsDirectoryAuthority = $false

        foreach ($Pattern in $AuthoritativeDirectoryPatterns) {
            if ($RelativePath -match $Pattern) {
                $IsDirectoryAuthority = $true
                break
            }
        }

        $_.Extension -in $AllowedExtensions -and
        $_.FullName -notmatch $ExcludedPathPattern -and
        (
            $IsRootAuthority -or
            $IsDirectoryAuthority
        )
    } |
    Sort-Object FullName
)

$Findings = [System.Collections.Generic.List[object]]::new()

function Add-SemanticFinding {
    param(
        [Parameter(Mandatory)]
        [string]$FindingID,

        [Parameter(Mandatory)]
        [ValidateSet('BLOCKING', 'REVIEW', 'INFORMATIONAL')]
        [string]$Severity,

        [Parameter(Mandatory)]
        [string]$FindingClass,

        [Parameter(Mandatory)]
        [string]$RelativePath,

        [Parameter(Mandatory)]
        [int]$LineNumber,

        [Parameter(Mandatory)]
        [string]$ObservedAssertion,

        [Parameter(Mandatory)]
        [string]$ExpectedCondition,

        [Parameter(Mandatory)]
        [string]$Disposition
    )

    $Findings.Add(
        [pscustomobject][ordered]@{
            FindingID = $FindingID
            Severity = $Severity
            FindingClass = $FindingClass
            RelativePath = $RelativePath
            LineNumber = $LineNumber
            ObservedAssertion = $ObservedAssertion
            ExpectedCondition = $ExpectedCondition
            Disposition = $Disposition
        }
    )
}

function Get-RelativeRepositoryPath {
    param(
        [Parameter(Mandatory)]
        [string]$FullName
    )

    return $FullName.
        Substring($RepositoryRoot.Length).
        TrimStart('\')
}

# =====================================================================
# Rule 1 — Active architecture-version assertions.
# =====================================================================

$ArchitectureVersionAssertions = @(
    foreach ($File in $AuthorityFiles) {
        $RelativePath = Get-RelativeRepositoryPath -FullName $File.FullName

        Select-String `
            -LiteralPath $File.FullName `
            -Pattern @(
                '(?i)architecture\s+version\s*[:=]?\s*(?<version>\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?)'
                '(?i)constitutional architecture version\s+(?<version>\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?)'
            ) `
            -AllMatches `
            -ErrorAction SilentlyContinue |
        ForEach-Object {
            foreach ($Match in $_.Matches) {
                if ($Match.Groups['version'].Success) {
                    [pscustomobject]@{
                        RelativePath = $RelativePath
                        LineNumber = $_.LineNumber
                        Version = $Match.Groups['version'].Value
                        Line = $_.Line.Trim()
                    }
                }
            }
        }
    }
)

$UnexpectedArchitectureVersions = @(
    $ArchitectureVersionAssertions |
    Where-Object {
        $_.Version -ne $ExpectedArchitectureVersion -and
        $_.RelativePath -ne 'runtime\pyproject.toml' -and
        $_.RelativePath -ne 'CITATION.cff' -and
        $_.Line -notmatch '(?i)^\s*cff-version\s*:' -and
        $_.Line -notmatch '(?i)^\s*Runtime Version\s*:'
    }
)

foreach ($Assertion in $UnexpectedArchitectureVersions) {
    Add-SemanticFinding `
        -FindingID 'MS-FSA-VERSION-001' `
        -Severity 'BLOCKING' `
        -FindingClass 'ARCHITECTURE_VERSION_CONFLICT' `
        -RelativePath $Assertion.RelativePath `
        -LineNumber $Assertion.LineNumber `
        -ObservedAssertion $Assertion.Line `
        -ExpectedCondition (
            "Active constitutional and release authority documents must use architecture version $ExpectedArchitectureVersion."
        ) `
        -Disposition 'UPDATE_OR_CLASSIFY_AS_HISTORICAL'
}

# =====================================================================
# Rule 2 — Runtime version consistency.
# =====================================================================

$RuntimePyprojectPath = Join-Path `
    $RepositoryRoot `
    'runtime\pyproject.toml'

if (Test-Path -LiteralPath $RuntimePyprojectPath -PathType Leaf) {
    $PyprojectText = Get-Content `
        -LiteralPath $RuntimePyprojectPath `
        -Raw

    $RuntimeVersionMatch = [regex]::Match(
        $PyprojectText,
        '(?m)^\s*version\s*=\s*"(?<version>[^"]+)"'
    )

    if (-not $RuntimeVersionMatch.Success) {
        Add-SemanticFinding `
            -FindingID 'MS-FSA-RUNTIME-001' `
            -Severity 'BLOCKING' `
            -FindingClass 'RUNTIME_VERSION_UNREADABLE' `
            -RelativePath 'runtime\pyproject.toml' `
            -LineNumber 0 `
            -ObservedAssertion 'No readable runtime version declaration.' `
            -ExpectedCondition "Runtime version must equal $ExpectedRuntimeVersion." `
            -Disposition 'REPAIR_RUNTIME_VERSION_DECLARATION'
    }
    elseif (
        $RuntimeVersionMatch.Groups['version'].Value -ne
        $ExpectedRuntimeVersion
    ) {
        Add-SemanticFinding `
            -FindingID 'MS-FSA-RUNTIME-002' `
            -Severity 'BLOCKING' `
            -FindingClass 'RUNTIME_VERSION_CONFLICT' `
            -RelativePath 'runtime\pyproject.toml' `
            -LineNumber 0 `
            -ObservedAssertion (
                "Runtime version=$($RuntimeVersionMatch.Groups['version'].Value)"
            ) `
            -ExpectedCondition "Runtime version must equal $ExpectedRuntimeVersion." `
            -Disposition 'SYNCHRONIZE_RUNTIME_VERSION'
    }
}
else {
    Add-SemanticFinding `
        -FindingID 'MS-FSA-RUNTIME-003' `
        -Severity 'BLOCKING' `
        -FindingClass 'RUNTIME_IDENTITY_MISSING' `
        -RelativePath 'runtime\pyproject.toml' `
        -LineNumber 0 `
        -ObservedAssertion 'Runtime identity file is missing.' `
        -ExpectedCondition 'The governed runtime identity file must exist.' `
        -Disposition 'RESTORE_RUNTIME_IDENTITY'
}

# =====================================================================
# Rule 3 — Stale active boundary claims.
# =====================================================================

$StaleRuntimePatterns = @(
    '(?i)software runtime implementation remains a subsequent engineering phase'
    '(?i)runtime implementation has not started'
    '(?i)engineering phase not started'
    '(?i)reference implementation remains future work'
    '(?i)runtime remains to be built'
)

foreach ($File in $AuthorityFiles) {
    $RelativePath = Get-RelativeRepositoryPath -FullName $File.FullName

    Select-String `
        -LiteralPath $File.FullName `
        -Pattern $StaleRuntimePatterns `
        -AllMatches `
        -ErrorAction SilentlyContinue |
    ForEach-Object {
        Add-SemanticFinding `
            -FindingID 'MS-FSA-BOUNDARY-001' `
            -Severity 'BLOCKING' `
            -FindingClass 'STALE_RUNTIME_BOUNDARY' `
            -RelativePath $RelativePath `
            -LineNumber $_.LineNumber `
            -ObservedAssertion $_.Line.Trim() `
            -ExpectedCondition (
                'Active authority documents must acknowledge the governed reference runtime now present in the repository.'
            ) `
            -Disposition 'UPDATE_ACTIVE_BOUNDARY_LANGUAGE'
    }
}

# =====================================================================
# Rule 4 — Mutually exclusive release-state assertions.
# =====================================================================

$ReleaseStateAssertions = @(
    foreach ($File in $AuthorityFiles) {
        $RelativePath = Get-RelativeRepositoryPath -FullName $File.FullName

        Select-String `
            -LiteralPath $File.FullName `
            -Pattern @(
                '(?i)status\s*:\s*(?<state>.+)$'
                '(?i)release state\s*:\s*(?<state>.+)$'
                '(?i)certification status\s*:\s*(?<state>.+)$'
                '(?i)final certification\s*:\s*(?<state>.+)$'
            ) `
            -AllMatches `
            -ErrorAction SilentlyContinue |
        ForEach-Object {
            foreach ($Match in $_.Matches) {
                if ($Match.Groups['state'].Success) {
                    [pscustomobject]@{
                        RelativePath = $RelativePath
                        LineNumber = $_.LineNumber
                        State = $Match.Groups['state'].Value.Trim()
                        Line = $_.Line.Trim()
                    }
                }
            }
        }
    }
)

$ProhibitedActiveStates = @(
    'INCOMPLETE'
    'NOT_STARTED'
    'NOT COLLECTED'
    'NOT_COLLECTED'
    'MISSING'
    'FAILED'
    'BLOCKED'
)

foreach ($Assertion in $ReleaseStateAssertions) {
    $NormalizedState = $Assertion.State.ToUpperInvariant()

    if (
        $ProhibitedActiveStates |
        Where-Object {
            $NormalizedState -match [regex]::Escape($_)
        }
    ) {
        Add-SemanticFinding `
            -FindingID 'MS-FSA-STATE-001' `
            -Severity 'BLOCKING' `
            -FindingClass 'ACTIVE_AUTHORITY_INCOMPLETE_STATE' `
            -RelativePath $Assertion.RelativePath `
            -LineNumber $Assertion.LineNumber `
            -ObservedAssertion $Assertion.Line `
            -ExpectedCondition (
                'Active release-authority documents may not declare the certified architecture incomplete, missing, failed, or blocked.'
            ) `
            -Disposition 'RESOLVE_OR_MOVE_TO_HISTORICAL_EVIDENCE'
    }
}

# =====================================================================
# Rule 5 — Freeze declaration conflicts.
# =====================================================================

$FreezePositivePatterns = @(
    '(?i)architecture.*frozen'
    '(?i)final freeze declared'
    '(?i)canonical constitutional reference state'
    '(?i)future revisions.*governed version progression'
)

$FreezeNegativePatterns = @(
    '(?i)architecture.*not frozen'
    '(?i)freeze.*pending'
    '(?i)freeze.*not complete'
    '(?i)architecture remains mutable'
    '(?i)unrestricted architectural modification'
)

$PositiveFreezeAssertions = @()
$NegativeFreezeAssertions = @()

foreach ($File in $AuthorityFiles) {
    $RelativePath = Get-RelativeRepositoryPath -FullName $File.FullName

    $PositiveFreezeAssertions += @(
        Select-String `
            -LiteralPath $File.FullName `
            -Pattern $FreezePositivePatterns `
            -AllMatches `
            -ErrorAction SilentlyContinue |
        ForEach-Object {
            [pscustomobject]@{
                RelativePath = $RelativePath
                LineNumber = $_.LineNumber
                Line = $_.Line.Trim()
            }
        }
    )

    $NegativeFreezeAssertions += @(
        Select-String `
            -LiteralPath $File.FullName `
            -Pattern $FreezeNegativePatterns `
            -AllMatches `
            -ErrorAction SilentlyContinue |
        ForEach-Object {
            [pscustomobject]@{
                RelativePath = $RelativePath
                LineNumber = $_.LineNumber
                Line = $_.Line.Trim()
            }
        }
    )
}

if (
    $PositiveFreezeAssertions.Count -gt 0 -and
    $NegativeFreezeAssertions.Count -gt 0
) {
    foreach ($Assertion in $NegativeFreezeAssertions) {
        Add-SemanticFinding `
            -FindingID 'MS-FSA-FREEZE-001' `
            -Severity 'BLOCKING' `
            -FindingClass 'FREEZE_STATE_CONFLICT' `
            -RelativePath $Assertion.RelativePath `
            -LineNumber $Assertion.LineNumber `
            -ObservedAssertion $Assertion.Line `
            -ExpectedCondition (
                'No active authority document may deny or defer the declared constitutional freeze.'
            ) `
            -Disposition 'REMOVE_OR_RECLASSIFY_NEGATIVE_FREEZE_ASSERTION'
    }
}

# =====================================================================
# Rule 6 — Certification/frontier contradiction.
# =====================================================================

$CertificationPath = Join-Path `
    $RepositoryRoot `
    'ARCHITECTURE_COMPLETION_CERTIFICATION.md'

if (Test-Path -LiteralPath $CertificationPath -PathType Leaf) {
    $CertificationText = Get-Content `
        -LiteralPath $CertificationPath `
        -Raw

    $FrontierSectionMatch = [regex]::Match(
        $CertificationText,
        '(?s)## 4\. Verification Frontier(?<frontier>.*?)(?=## 5\.)'
    )

    $CompletionSectionMatch = [regex]::Match(
        $CertificationText,
        '(?s)## 5\. Completion Finding(?<completion>.*?)(?=## 6\.)'
    )

    if ($FrontierSectionMatch.Success) {
        $FrontierText = $FrontierSectionMatch.Groups['frontier'].Value

        $FrontierHasOpenStates = (
            $FrontierText -match
            '(?im)\|\s*[^|]+\|\s*(MISSING|OPEN|INCOMPLETE|NOT_STARTED|NOT_COLLECTED)\s*\|'
        )

        if (
            $FrontierHasOpenStates -and
            $CompletionSectionMatch.Success
        ) {
            $CompletionText = $CompletionSectionMatch.Groups['completion'].Value

            $AbsoluteCompletionClaims = @(
                'all currently defined.*complete'
                'all.*theorems.*complete'
                'no unresolved.*OPEN'
                'no unresolved.*MISSING'
                'no unresolved.*INCOMPLETE'
            )

            foreach ($Pattern in $AbsoluteCompletionClaims) {
                if ($CompletionText -match "(?is)$Pattern") {
                    Add-SemanticFinding `
                        -FindingID 'MS-FSA-CERT-001' `
                        -Severity 'BLOCKING' `
                        -FindingClass 'CERTIFICATION_FRONTIER_CONTRADICTION' `
                        -RelativePath 'ARCHITECTURE_COMPLETION_CERTIFICATION.md' `
                        -LineNumber 0 `
                        -ObservedAssertion (
                            'Verification Frontier contains unresolved states while Completion Finding makes an absolute no-unresolved-state claim.'
                        ) `
                        -ExpectedCondition (
                            'Certification language must distinguish architectural completion from the continuing theorem-verification frontier.'
                        ) `
                        -Disposition 'REWRITE_COMPLETION_FINDING_OR_CLOSE_FRONTIER'
                }
            }
        }
    }
}

# =====================================================================
# Rule 7 — Root release artifact presence.
# =====================================================================

$RequiredRootArtifacts = @(
    'README.md'
    'CHANGELOG.md'
    'CITATION.cff'
    'FINAL_FREEZE_DECLARATION.md'
    'LICENSE.md'
    'VERSION.md'
    'ARCHITECTURE_COMPLETION_CERTIFICATION.md'
)

foreach ($RequiredArtifact in $RequiredRootArtifacts) {
    $RequiredPath = Join-Path $RepositoryRoot $RequiredArtifact

    if (-not (Test-Path -LiteralPath $RequiredPath -PathType Leaf)) {
        Add-SemanticFinding `
            -FindingID 'MS-FSA-ARTIFACT-001' `
            -Severity 'BLOCKING' `
            -FindingClass 'REQUIRED_RELEASE_ARTIFACT_MISSING' `
            -RelativePath $RequiredArtifact `
            -LineNumber 0 `
            -ObservedAssertion 'Required root release artifact is absent.' `
            -ExpectedCondition 'Every required release-authority artifact must exist.' `
            -Disposition 'CREATE_OR_RESTORE_ARTIFACT'
    }
}

# =====================================================================
# Rule 8 — Public release candidate wording alignment.
# =====================================================================

$ReadmePath = Join-Path $RepositoryRoot 'README.md'

if (Test-Path -LiteralPath $ReadmePath -PathType Leaf) {
    $ReadmeText = Get-Content -LiteralPath $ReadmePath -Raw

    if (
        $ReadmeText -notmatch
        '(?im)^\s*(?:\*\*)?Status:(?:\*\*)?\s*Public Reference Release Candidate\s*$'
    ) {
        Add-SemanticFinding `
            -FindingID 'MS-FSA-PRESENTATION-001' `
            -Severity 'REVIEW' `
            -FindingClass 'PUBLIC_STATUS_WORDING_MISMATCH' `
            -RelativePath 'README.md' `
            -LineNumber 0 `
            -ObservedAssertion 'README lacks the canonical public release-candidate status line.' `
            -ExpectedCondition (
                'README should identify the repository as the Public Reference Release Candidate.'
            ) `
            -Disposition 'ALIGN_PUBLIC_STATUS_WORDING'
    }
}

# =====================================================================
# Final disposition.
# =====================================================================

$BlockingFindings = @(
    $Findings |
    Where-Object Severity -eq 'BLOCKING'
)

$ReviewFindings = @(
    $Findings |
    Where-Object Severity -eq 'REVIEW'
)

$Result = if ($BlockingFindings.Count -eq 0) {
    'PASS'
}
else {
    'FAIL'
}

$Findings |
    Sort-Object Severity, FindingClass, RelativePath, LineNumber |
    Export-Csv `
        -LiteralPath $CsvReportPath `
        -NoTypeInformation `
        -Encoding UTF8

$FindingRows = if ($Findings.Count -eq 0) {
    '| None | None | None | None |'
}
else {
    (
        $Findings |
        Sort-Object Severity, FindingClass, RelativePath, LineNumber |
        ForEach-Object {
            $Observed = $_.ObservedAssertion -replace '\|', '\|'

            '| {0} | {1} | {2} | {3}:{4} | {5} |' -f `
                $_.FindingID,
                $_.Severity,
                $_.FindingClass,
                $_.RelativePath,
                $_.LineNumber,
                $Observed
        }
    ) -join "`r`n"
}

$MarkdownReport = @"
# Morning Star Final Semantic Contradiction Audit

## Result

**$Result**

## Scope

This audit evaluated only active constitutional and release-authority
documents.

Excluded materials include:

- historical archives;
- verification trials;
- execution evidence;
- readiness workspaces;
- engineering reports and backups;
- staged release packages;
- generated build and virtual-environment artifacts.

## Expected Release Identity

- Architecture version: $ExpectedArchitectureVersion
- Runtime version: $ExpectedRuntimeVersion
- Public status: Public Reference Release Candidate

## Counts

- Authority files scanned: $($AuthorityFiles.Count)
- Total findings: $($Findings.Count)
- Blocking findings: $($BlockingFindings.Count)
- Review findings: $($ReviewFindings.Count)

## Findings

| Finding ID | Severity | Class | Location | Observed assertion |
|---|---|---|---|---|
$FindingRows

## Final Disposition

$(if ($Result -eq 'PASS') {
'No blocking semantic contradictions were detected in the active constitutional or release-authority surface.'
}
else {
'Blocking semantic contradictions remain. Public release authority should not be treated as fully synchronized until these findings are resolved.'
})
"@

Set-Content `
    -LiteralPath $MarkdownReportPath `
    -Value $MarkdownReport `
    -Encoding UTF8

[ordered]@{
    AuditID = 'MS-FINAL-SEMANTIC-CONTRADICTION-AUDIT'
    Result = $Result
    ExpectedArchitectureVersion = $ExpectedArchitectureVersion
    ExpectedRuntimeVersion = $ExpectedRuntimeVersion
    AuthorityFilesScanned = $AuthorityFiles.Count
    TotalFindings = $Findings.Count
    BlockingFindings = $BlockingFindings.Count
    ReviewFindings = $ReviewFindings.Count
    CsvReport = $CsvReportPath
    MarkdownReport = $MarkdownReportPath
    CompletedAt = (Get-Date).ToString('o')
} |
    ConvertTo-Json -Depth 8 |
    Set-Content `
        -LiteralPath $ManifestPath `
        -Encoding UTF8

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host 'MORNING STAR — FINAL SEMANTIC CONTRADICTION AUDIT' -ForegroundColor Cyan
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Authority files scanned:              $($AuthorityFiles.Count)"
Write-Host "Total findings:                       $($Findings.Count)"
Write-Host "Blocking findings:                    $($BlockingFindings.Count)"
Write-Host "Review findings:                      $($ReviewFindings.Count)"
Write-Host ''
Write-Host "CSV report:                            $CsvReportPath"
Write-Host "Markdown report:                       $MarkdownReportPath"
Write-Host "Manifest:                              $ManifestPath"
Write-Host ''

if ($Result -eq 'PASS') {
    Write-Host 'FINAL SEMANTIC AUDIT: PASS' -ForegroundColor Green
    Write-Host 'NO BLOCKING AUTHORITY-LEVEL CONTRADICTIONS WERE DETECTED.' -ForegroundColor Green
}
else {
    Write-Host 'FINAL SEMANTIC AUDIT: FAIL' -ForegroundColor Red
    Write-Host 'BLOCKING AUTHORITY-LEVEL CONTRADICTIONS REQUIRE CORRECTION.' -ForegroundColor Red
}

Write-Host '======================================================================' -ForegroundColor Cyan

if ($BlockingFindings.Count -gt 0) {
    Write-Host ''
    $BlockingFindings |
        Sort-Object FindingClass, RelativePath, LineNumber |
        Format-Table `
            FindingID,
            FindingClass,
            RelativePath,
            LineNumber,
            ObservedAssertion `
            -AutoSize
}


