function On-Farm{
  $wc = New-Object System.Net.WebClient
  $result = $wc.downloadString("http://p-weblb1.tpgi.us:82/currentfarm.html")

  return $result
}

function Set-LastWriteTime-To-Now ($extension){
  $now = Get-Date

  Foreach ($utem in Get-ChildItem $folder -Recurse $extension)
  {
    Write-Host "Changing " $utem.name " LastWriteTime to now."
    $utem.LastWriteTime = $now
  }
}

function Cache-Refresh-Algo ($folder) {
  Set-LastWriteTime-To-Now("*.css")
  Set-LastWriteTime-To-Now("*.js")
}


function Cache-Refresh {
  $onFarmDirectory = "\\wptest1-vvdm\midwayusa\prod117\Content"
  $offFarmDirectory = "\\wptest1-vvdm\midwayusa\prod118\Content"

  $onFarm = ON-FARM
  Write-Host "The on farm is" + $onFarm
  Write-Host "Which server do you want to refresh (111 for test111), OnFarm(ON), OffFarm(OFF), a path of your choosing (C)"
  Write-Host "What is your target path, sir?"
  $target = Read-Host

  if($target -eq "ON"){
    Write-Host "Are you sure?"
    $confirmation = Read-Host
    if($confirmation -eq "y" -or $confirmation -eq "Y"){
      Cache-Refresh-Algo $onFarmDirectory
    }
  } elseif($target -eq "OFF"){
    Cache-Refresh-Algo $offFarmDirectory
  } elseif(($target -as [int]) -ne $null){
    $folder = "\\wptest1-vvdm\midwayusa\prod" + $target + "\Content"
    Cache-Refresh-Algo $folder
  } else{
    Cache-Refresh-Algo $target
  }
}


Cache-Refresh
