# Preview by default; -Delete removes matching files and empty subfolders.
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

# Track planned removals so preview also finds folders that would become empty.
$roots = @(Get-Item -LiteralPath $Directories -Force |
    ForEach-Object { $_.FullName.TrimEnd('\') })
$removed = @{}
if (-not $Delete) {
    foreach ($file in $files) { $removed[$file.FullName] = $true }
}
$folders = Get-ChildItem -LiteralPath $Directories -Directory -Recurse |
    Sort-Object FullName -Descending -Unique

foreach ($folder in $folders) {
    if ($folder.FullName.TrimEnd('\') -in $roots -or
        ($folder.Attributes -band [IO.FileAttributes]::ReparsePoint)) { continue }
    if (Get-ChildItem -LiteralPath $folder.FullName -Force |
        Where-Object { -not $removed.ContainsKey($_.FullName) } |
        Select-Object -First 1) { continue }
    if ($Delete) { $folder.Delete() }
    else { $removed[$folder.FullName] = $true }
    "Empty directory: $($folder.FullName)"
}
