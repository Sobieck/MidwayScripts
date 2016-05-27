function Set-LastWriteTime-To-Now ($extension){
  $now = Get-Date

  Foreach ($utem in Get-ChildItem $folder -Recurse $extension)
  {
    $utem.LastWriteTime = $now
  }
}

function Cache-Refresh-Algo ($folder) {
  Set-LastWriteTime-To-Now("*.css")
  Set-LastWriteTime-To-Now("*.js")
}


function Cache-Refresh {
  Write-Host "What is your target path, sir?"
  $target = Read-Host

  Cache-Refresh-Algo $target
}


Cache-Refresh
