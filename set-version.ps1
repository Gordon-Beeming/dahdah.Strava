$RunTime = (Get-Date).ToUniversalTime()
$VersionDay = "$($RunTime.Year).$($RunTime.Month).$($RunTime.Day)"
$RunId = $env:GITHUB_RUN_NUMBER
if ([string]::IsNullOrEmpty($RunId))
{
  $RunId = "0"
}
$VersionNumber = "$($VersionDay).$($RunId)"
$VersionTag = "$($env:GITHUB_REF)"
if ([string]::IsNullOrEmpty($VersionTag))
{
  $VersionTag = "local"
}
if ($VersionTag.Contains("refs/heads/"))
{
  $VersionTag = $VersionTag.Replace("refs/heads/","")
}
if ($VersionTag -eq "main")
{
  $VersionTag = ""
}
else
{
  $VersionTag = "-$($VersionTag)"
}
$VersionNumberWithTag = "$($VersionNumber)$($VersionTag)"

[string]$CurrentPath = $PSScriptRoot
Write-Host @"
CurrentPath: $($CurrentPath)
VersionNumberWithTag: $($VersionNumberWithTag)
"@

function FindAndReplace([string]$PathIn, [string]$PathOut, [string]$Find, [string]$Replace)
{
  Write-Host "Reading '$($PathIn)'."
  [string]$Content = Get-Content -LiteralPath "$($CurrentPath)\$($PathIn)" -Encoding utf8 | Out-String  
  Write-Host "Replacing '$($Find)' with '$($Replace)'."
  $Content = $Content.Replace($Find,$Replace)
  Write-Host "Writing '$($PathOut)'."
  Set-Content -LiteralPath "$($CurrentPath)\$($PathOut)" -Encoding utf8 -Value $Content
}

FindAndReplace  -PathIn "config.json" `
                -PathOut "out-config.json" `
                -Find "0.0.1" `
                -Replace $VersionNumberWithTag
               
FindAndReplace  -PathIn "dahdah.Strava.NetCore.csproj" `
                -PathOut "out-dahdah.Strava.NetCore.csproj" `
                -Find "0.0.1" `
                -Replace $VersionNumberWithTag
