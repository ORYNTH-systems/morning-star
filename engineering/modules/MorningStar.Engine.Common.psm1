Set-StrictMode -Version Latest

function Get-MSDeterministicHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$InputText,

        [ValidateSet('SHA256', 'SHA384', 'SHA512')]
        [string]$Algorithm = 'SHA256',

        [ValidateRange(1, 128)]
        [int]$Length = 64
    )

    $Hasher = [System.Security.Cryptography.HashAlgorithm]::Create(
        $Algorithm
    )

    if ($null -eq $Hasher) {
        throw "Unable to create hashing algorithm: $Algorithm"
    }

    try {
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($InputText)
        $HashBytes = $Hasher.ComputeHash($Bytes)

        $Hash = (
            [System.BitConverter]::ToString($HashBytes) -replace '-', ''
        )

        $RequestedLength = [Math]::Min(
            $Length,
            $Hash.Length
        )

        return $Hash.Substring(0, $RequestedLength)
    }
    finally {
        $Hasher.Dispose()
    }
}

function Import-MSCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$LiteralPath,

        [switch]$AllowEmpty
    )

    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) {
        throw "CSV file does not exist: $LiteralPath"
    }

    $Rows = @(Import-Csv -LiteralPath $LiteralPath)

    if (-not $AllowEmpty -and $Rows.Count -eq 0) {
        throw "CSV file contains no data rows: $LiteralPath"
    }

    return $Rows
}

function Export-MSAtomicCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$InputObject,

        [Parameter(Mandatory)]
        [string]$LiteralPath,

        [ValidateSet('utf8', 'utf8BOM', 'unicode', 'ascii')]
        [string]$Encoding = 'utf8'
    )

    $Parent = Split-Path -Parent $LiteralPath

    if (-not [string]::IsNullOrWhiteSpace($Parent)) {
        New-Item `
            -ItemType Directory `
            -Path $Parent `
            -Force |
            Out-Null
    }

    $TemporaryPath = (
        '{0}.tmp.{1}' -f
        $LiteralPath,
        [guid]::NewGuid().ToString('N')
    )

    try {
        @($InputObject) |
            Export-Csv `
                -LiteralPath $TemporaryPath `
                -NoTypeInformation `
                -Encoding $Encoding

        if (-not (Test-Path -LiteralPath $TemporaryPath -PathType Leaf)) {
            throw "Temporary CSV output was not created: $TemporaryPath"
        }

        Move-Item `
            -LiteralPath $TemporaryPath `
            -Destination $LiteralPath `
            -Force

        if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) {
            throw "CSV destination was not created: $LiteralPath"
        }
    }
    finally {
        if (Test-Path -LiteralPath $TemporaryPath -PathType Leaf) {
            Remove-Item -LiteralPath $TemporaryPath -Force
        }
    }
}

function Assert-MSCondition {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [bool]$Condition,

        [Parameter(Mandatory)]
        [string]$Message,

        [string]$InvariantID = ''
    )

    if (-not $Condition) {
        if ([string]::IsNullOrWhiteSpace($InvariantID)) {
            throw $Message
        }

        throw "[$InvariantID] $Message"
    }
}

function Resolve-MSRepositoryPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory)]
        [string]$RelativePath,

        [switch]$RequireExisting
    )

    $RepositoryFullPath = [System.IO.Path]::GetFullPath(
        $RepositoryRoot
    ).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )

    $ResolvedPath = [System.IO.Path]::GetFullPath(
        (Join-Path $RepositoryFullPath $RelativePath)
    )

    if (-not $ResolvedPath.StartsWith(
        $RepositoryFullPath,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        throw "Resolved path escapes repository root: $RelativePath"
    }

    if (
        $RequireExisting -and
        -not (Test-Path -LiteralPath $ResolvedPath)
    ) {
        throw "Required repository path does not exist: $ResolvedPath"
    }

    return $ResolvedPath
}

function Get-MSBatchContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RepositoryRoot,

        [string]$Volume = 'VOLUME_I_FOUNDATION',

        [string]$BatchID = 'BATCH_A'
    )

    $BatchRelativePath = (
        'volumes\{0}\verification\readiness\BATCH_EXECUTION\{1}' -f
        $Volume,
        $BatchID
    )

    $BatchRoot = Resolve-MSRepositoryPath `
        -RepositoryRoot $RepositoryRoot `
        -RelativePath $BatchRelativePath

    [pscustomobject][ordered]@{
        RepositoryRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
        Volume = $Volume
        BatchID = $BatchID
        BatchRoot = $BatchRoot
        Stage4Root = Join-Path $BatchRoot 'Stage_4_Synchronization'
        Stage5Root = Join-Path $BatchRoot 'Stage_5_Constitutional_Validation'
        Stage6Root = Join-Path $BatchRoot 'Stage_6_Governance_Disposition'
    }
}

function Get-MSFileHashRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$LiteralPath
    )

    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) {
        throw "File does not exist: $LiteralPath"
    }

    $Item = Get-Item -LiteralPath $LiteralPath

    [pscustomobject][ordered]@{
        Path = $Item.FullName
        LengthBytes = $Item.Length
        SHA256 = (
            Get-FileHash `
                -LiteralPath $Item.FullName `
                -Algorithm SHA256
        ).Hash
    }
}

Export-ModuleMember -Function @(
    'Get-MSDeterministicHash'
    'Import-MSCsv'
    'Export-MSAtomicCsv'
    'Assert-MSCondition'
    'Resolve-MSRepositoryPath'
    'Get-MSBatchContext'
    'Get-MSFileHashRecord'
)
