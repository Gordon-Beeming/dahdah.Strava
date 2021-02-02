[string]$CurrentPath = $PSScriptRoot
$github_ref = "$($env:GITHUB_REF)"
if ([string]::IsNullOrEmpty($github_ref))
{
  $github_ref = "local"
}
function Hash-Folder([string]$FolderPath, [string]$SaveTo)
{
  $FileHashes = ""
  $FilesInFolder = Get-ChildItem -LiteralPath $FolderPath -Filter "*.cs"  
  foreach($File in $FilesInFolder)
  {
    if (-not ($File.FullName.Contains("Client\Configuration.cs")))
    {
      $FileHash = (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA1).Hash
      $FileHashes += "$($FileHash)|$($File.Name)`n"
    }
  }
  $FileHashes += $github_ref
  $FileHashes = $FileHashes.Trim()
  $CurrentSaveToHash = ""
  if (Test-Path -LiteralPath $SaveTo)
  {
    $CurrentSaveToHash = (Get-FileHash -LiteralPath $SaveTo -Algorithm SHA1).Hash
  }
  Set-Content -LiteralPath $SaveTo -Encoding utf8 -Value $FileHashes
  $UpdatedSaveToHash = (Get-FileHash -LiteralPath $SaveTo -Algorithm SHA1).Hash
  if($CurrentSaveToHash -ne $UpdatedSaveToHash)
  {    
    return $true
  }
  else 
  {
    return $false
  }
}
$publishPackage = $false
if (-not (Test-Path -LiteralPath "$($CurrentPath)\api"))
{
  New-Item "$($CurrentPath)\api" -ItemType Directory
}
if (Hash-Folder -FolderPath "$($CurrentPath)\g\src\dahdah.Strava.NetCore\Api" -SaveTo "$($CurrentPath)\api\api.state")
{
  $publishPackage = $true
}
if (Hash-Folder -FolderPath "$($CurrentPath)\g\src\dahdah.Strava.NetCore\Client" -SaveTo "$($CurrentPath)\api\Client.state")
{
  $publishPackage = $true
}
if (Hash-Folder -FolderPath "$($CurrentPath)\g\src\dahdah.Strava.NetCore\Model" -SaveTo "$($CurrentPath)\api\Model.state")
{
  $publishPackage = $true
}
Write-Host "publishPackage=$($publishPackage)"
Write-Host "::set-output name=publishPackage::$($publishPackage)"
if ($publishPackage -and $github_ref -ne "local")
{
  git add api/*
  git config --global user.name "CI System" 
  git commit -m "[skip ci] api state change"
  git push
}
