# cd c:\github\midwayscripts\Refresh-Local-Workspaces
# .\Refresh-Local-Workspaces.Tests.ps1
# Invoke-Pester

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$workspacesFolder = "c:\WorkSpaces\"

$folder1 = "sadpanda"
$folder2 = "banana"
$folder3 = "fred"

$path1 = $workspacesFolder + $folder1

Describe "Refresh-Local-Workspaces" {
  Context "when there are local workspaces" {
    Mock Get-ChildItem {
                [PSCustomObject]@{ Name = $folder1 },
                [PSCustomObject]@{ Name = $folder2 },
                [PSCustomObject]@{ Name = $folder3 }
            } -ParameterFilter {$Path -eq $workspacesFolder}

    Mock Update-TFSWorkspace { }

    Refresh-Local-Workspaces

    It "should call Get-ChildItem" {
      Assert-MockCalled Get-ChildItem -Times 1 -ParameterFilter {$Path -eq $workspacesFolder}
    }

    It 'should call Update-TFSWorkspace with sadpanda folder.' {
      Write-Host $path1
      Assert-MockCalled Update-TFSWorkspace -ParameterFilter {$Item -contains  $path1}
    }

    It 'should call Update-TFSWorkspace with banana folder.' {
      $path3 = $workspacesFolder + $folder2
      Assert-MockCalled Update-TFSWorkspace -Times 1 -ParameterFilter {$Item -eq $path3}
    }

    It 'should call Update-TFSWorkspace with fred folder.' {
      $path4 = $workspacesFolder + $folder3
      Write-Host Update-TFSWorkspace
      Assert-MockCalled Update-TFSWorkspace -Times 1 -ParameterFilter {$Item -eq $path4}
    }

    It 'shouuld call Update-TFSWorkspace three times' {
      Assert-MockCalled Update-TFSWorkspace -Times 3
    }

  }
}
