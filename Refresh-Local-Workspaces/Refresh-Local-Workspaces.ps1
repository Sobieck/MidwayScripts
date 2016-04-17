#run in x64 powershell.

Add-PSSnapin Microsoft.TeamFoundation.PowerShell

$workspaceFldr = "c:\WorkSpaces\"

Function Refresh-Local-Workspaces {
  $items = Get-ChildItem $workspaceFldr

  Foreach ($item in $items)
  {
    $folderToUpdate = $workspaceFldr + $item.Name
    Update-TFSWorkspace $folderToUpdate
  }
}

If ($args.length -gt 0 -and $args[0] -eq "run")
{
  Refresh-Local-Workspaces
}
