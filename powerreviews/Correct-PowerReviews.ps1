

function Correct-PowerReviews ($drive) {
  $pwrzipPath = $drive + 'powerreviews\pwr.zip'

  $zipExists = Test-Path $pwrzipPath

  if($zipExists -eq $false){
    Write-Host "The zip file isn't present."
    Write-ZipNotFoundInstructions
  }else{
    Write-Host "The zip file is present."
  }

  $zipModifiedToday = Was-Modified-Today $pwrzipPath

  if($zipModifiedToday -eq $false){
    Write-Host "Contact a DBA. The pwr.zip file is old."
  }

  $prodUpToDate = Prod-Up-To-Date $drive

  Write-Host "IIS is running."

  return $zipModifiedToday
}

Function Prod-Up-To-Date($drive){
  $prodAreaFeatPwrPath = $drive + "midwayusa\prod\areas\features\pwr"
  $prodContentPath = $prodAreaFeatPwrPath + "\Content"
  $prodEnginePath = $prodAreaFeatPwrPath + "\Engine"
  $prodM78Path = $prodAreaFeatPwrPath + "\M78z3x93"

  $contentModified = Was-Modified-Today $prodContentPath
  $engineModified = Was-Modified-Today $prodEnginePath
  $m78Modified = Was-Modified-Today $prodM78Path

  if($contentModified -and $engineModified -and $m78Modified) {
    Write-Host "Everything is up to date in Prod."
  }
}

function Was-Modified-Today ($path) {
  if(Test-Path $path){
    $item = Get-Item $path
    $now = Get-Date

    return $item.LastWriteTime.ToShortDateString() -eq $now.ToShortDateString()
  }

  return $false
}


function Write-ZipNotFoundInstructions {
  Write-Host "Use the Power Reviews FTP Credentials in the third party contact info to download the pwr.zip file."
  Write-Host "Drop this file into '\\a-power1\D\PowerReviews'"
  Write-Host "This will be picked up by the ZipExtractor service"
}

#//log into a-power1
#$now =  Get-Date
#$thisMorning = $now.ToShortDateString()
#$tonight = $now.AddDays(1).ToShortDateString()

#$allItemsInC = Get-ChildItem 'c:\' | Where-Object { $_.CreationTime -ge $thisMorning -and $_.CreationTime -le $tonight }
#http://stackoverflow.com/a/15884384/2740086
#http://stackoverflow.com/a/19774425/2740086
