Add-PSSnapin Microsoft.TeamFoundation.PowerShell

$workspaceFldr = "c:\WorkSpaces\"

Function Refresh-Local-Workspaces {
  $items = Get-ChildItem $workspaceFldr

  #mocking isn't working for some reason! It is extremely irritating

  Foreach ($item in $items)
  {
    $folderToUpdate = $workspaceFldr + $item.Name
    Update-TFSWorkspace -Item $folderToUpdate
  }
}

If ($args.length -gt 0 -and $args[0] -eq "run")
{
  Refresh-Local-Workspaces
}
