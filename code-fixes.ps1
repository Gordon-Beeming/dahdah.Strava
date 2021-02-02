[string]$CurrentPath = $PSScriptRoot
Write-Host @"
CurrentPath: $($CurrentPath)
"@

if (-not (Test-Path -LiteralPath "$($CurrentPath)\fixes\src\dahdah.Strava.NetCore\Model"))
{
  New-Item -ItemType Directory -Path "$($CurrentPath)\fixes\src\dahdah.Strava.NetCore\Model"
}

[string]$DetailedActivityContent = Get-Content -LiteralPath "$($CurrentPath)\g\src\dahdah.Strava.NetCore\Model\DetailedActivity.cs" -Encoding utf8 | Out-String
$DetailedActivityContent = $DetailedActivityContent.Replace("ActivityType?","ActivityType");
Set-Content -LiteralPath "$($CurrentPath)\fixes\src\dahdah.Strava.NetCore\Model\DetailedActivity.cs" -Encoding utf8 -Value $DetailedActivityContent -Force

[string]$SummaryActivityContent = Get-Content -LiteralPath "$($CurrentPath)\g\src\dahdah.Strava.NetCore\Model\SummaryActivity.cs" -Encoding utf8 | Out-String
$SummaryActivityContent = @"
#pragma warning disable CS0472
$($SummaryActivityContent)
"@
Set-Content -LiteralPath "$($CurrentPath)\fixes\src\dahdah.Strava.NetCore\Model\SummaryActivity.cs" -Encoding utf8 -Value $SummaryActivityContent -Force
