

function Correct-PowerReviews ($drive) {
  $pwrzipPath = $drive + 'powerreviews\pwr.zip'

  $prodUpToDate = Prod-Up-To-Date($drive)

  $zipModifiedToday = Zip-Modified-Today($pwrzipPath)

  Write-Host "Everything is up to date in Prod."
}

Function Prod-Up-To-Date($drive){
  $prodAreaFeatPwrPath = $drive + "midwayusa\prod\areas\features\pwr"
  $prodContentPath = $prodAreaFeatPwrPath + "\Content"
  $prodEnginePath = $prodAreaFeatPwrPath + "\Engine"
  $prodM78Path = $prodAreaFeatPwrPath + "\M78z3x93"

  
}

function Was-Modified-Today ($path) {
  if(Test-Path $path){
    $item = Get-Item $path
    $now = Get-Date

    return $item.LastWriteTime.ToShortDateString() -eq $now.ToShortDateString()
  }

  return $false
}

function Zip-Exists($pwrzipPath){
  IF (Test-Path $pwrzipPath){
    Write-Host "The zip file is present."
    return $true
  } Else {
    Write-Host "The zip file isn't present."
    Write-ZipNotFoundInstructions
    return $false
  }
}

function Zip-Modified-Today($path){
  if(Zip-Exists($path)){
    $modifiedToday = Was-Modified-Today($path)
    if ($modifiedToday) {
      return $modifiedToday
    } else {
      Write-Host "Contact a DBA. The pwr.zip file is old."
      return $modifiedToday
    }
  }
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



#//check to see if files on the server are old
#// check to see if the files on c:/ are new
#// if both conditions
#  // turn off iis
#  // delete files from server
#  // move files from c
#  // delete c folder
#  // turn on iis
#// if files are up to date on server and iis is off
#  // turn on iis
#  // clean up c drive
#// if files are not up to date and the files on c: are old
#  // notify user
