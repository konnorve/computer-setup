# Preview by default; -Delete permanently removes matching files.
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string[]]$Directories,
    [switch]$Delete
)

$ErrorActionPreference = 'Stop'
$cutoff = (Get-Date).AddYears(-1)
$files = @(
    Get-ChildItem -LiteralPath $Directories -File -Recurse |
        Where-Object {
            $_.Extension -in '.tif', '.tiff', '.pos' -and
            $_.LastWriteTime -lt $cutoff
        } |
        Sort-Object FullName -Unique
)
$files | Select-Object LastWriteTime, FullName | Format-Table -AutoSize -Wrap
"Matching files: $($files.Count)"
if ($Delete) {
    $files | ForEach-Object { Remove-Item -LiteralPath $_.FullName }
}
