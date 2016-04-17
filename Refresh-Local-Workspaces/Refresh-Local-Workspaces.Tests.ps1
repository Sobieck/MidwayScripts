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
$path2 = $workspacesFolder + $folder2
$path3 = $workspacesFolder + $folder3

Describe "Refresh-Local-Workspaces" {
  Context "when there are local workspaces" {
    Mock Get-ChildItem {
                [PSCustomObject]@{ Name = $folder1 },
                [PSCustomObject]@{ Name = $folder2 },
                [PSCustomObject]@{ Name = $folder3 }
            } -ParameterFilter {$Path -eq $workspacesFolder}

    Mock Update-TFSWorkspace { } #Used return Item as a return object to figure out what the heck the paramaters where. I Write-Hosted that object until I was able to see what was going on with the paramaters. Get-Member then gave me the properties of that object.

    Refresh-Local-Workspaces

    It "should call Get-ChildItem" {
      Assert-MockCalled Get-ChildItem -Times 1 -ParameterFilter {$Path -eq $workspacesFolder}
    }

    It 'should call Update-TFSWorkspace with sadpanda folder.' {
      Assert-MockCalled Update-TFSWorkspace -times 1 -parameterFilter {$Item[0].FileNames -eq $path1}
    }

    It 'should call Update-TFSWorkspace with banana folder.' {
      Assert-MockCalled Update-TFSWorkspace -Times 1 -ParameterFilter {$Item[0].FileNames -eq $path2}
    }

    It 'should call Update-TFSWorkspace with fred folder.' {
      Assert-MockCalled Update-TFSWorkspace -Times 1 -ParameterFilter {$Item[0].FileNames -eq $path2}
    }

    It 'shouuld call Update-TFSWorkspace three times' {
      Assert-MockCalled Update-TFSWorkspace -Exactly 3
    }

  }
}
