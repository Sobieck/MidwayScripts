Add-PSSnapin Microsoft.TeamFoundation.PowerShell

$workspaceFldr = "c:\WorkSpaces\"

function Refresh-Local-Workspaces {
  $items = Get-ChildItem $workspaceFldr

  #mocking isn't working for some reason! It is extremely irritating
  $folderToUpdate = $workspaceFldr + $items[0].Name
  Write-Host $folderToUpdate
  Update-TFSWorkspace -Item $folderToUpdate
}
