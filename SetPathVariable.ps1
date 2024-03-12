[CmdletBinding()]
param(
    [parameter(Mandatory=$true)]
    [string]$NewLocation
)

Begin
{
    Function GetOldPath()
    {
        $envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        return $envPath
    }
}

Process
{
    $ERROR_SUCCESS = 0
    $ERROR_DUP_NAME = 34
    $ERROR_INVALID_DATA = 13

    $NewLocation = $NewLocation.Trim()

    If ($NewLocation -eq "" -or $NewLocation -eq $null)
    {
        Exit $ERROR_INVALID_DATA
    }

    $oldPath = GetOldPath
    Write-Verbose "Old Path: $oldPath"

    $parts = $oldPath.split(";")
    If ($parts -contains $NewLocation)
    {
        Write-Warning "The new location is already in the path"
        Exit $ERROR_DUP_NAME
    }

    $newPath = $oldPath + ";" + $NewLocation
    $newPath = $newPath -replace ";;",";"

    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    $env:path += ";$NewLocation"

    Write-Output "The operation completed successfully."
    Exit $ERROR_SUCCESS
}