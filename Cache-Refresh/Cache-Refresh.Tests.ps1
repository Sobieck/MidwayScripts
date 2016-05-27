$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$fileNames = @("Thomas", "Leo", "Sanchez", "Miranda", "Mal", "Corey", "Mal2", "Adam", "Sam")

$testDrive = "TestDrive:\"
$contentFolder = $testDrive + "\Content"

$startTime = Get-Date
$yesterday = $startTime.AddDays(-1)

function Create-Files($extension, $folder){


  Foreach ($fileName in $fileNames)
  {
    $filePath = $folder + "\" + $fileName + $extension
    New-Item $filePath -Type File

      $cssFile = Get-Item $filePath
      $cssFile.LastWriteTime = $yesterday
  }
}

function Create-Folders {
  Foreach ($folder in $fileNames)
  {
    $MOOONMOOON = $contentFolder + "\" + $folder

    New-Item $MOOONMOOON -Type Directory

    Create-Files ".js" $MOOONMOOON
    Create-Files ".css" $MOOONMOOON
    Create-Files ".thomas" $MOOONMOOON
  }
}

Describe "Cache-Refresh" {
    New-Item $contentFolder -Type Directory

    Create-Files ".js" $contentFolder
    Create-Files ".css" $contentFolder
    Create-Files ".thomas" $contentFolder
    Create-Folders

    Cache-Refresh-Algo($contentFolder)

    $afterRun = Get-Date

    It "SHOULD CHANGE ALL THE FILES THAT ARE CSS TO NOW. DID NOT READ!!!!" {
      Foreach ($name in $fileNames)
      {
        $folder = $contentFolder + "\" + $name

        Foreach ($fileName in $fileNames)
        {
          $filePath = $folder + "\" + $fileName + ".css"
          $updatedFile = Get-Item $filePath

          $updatedFile.LastWriteTime -gt $startTime | Should Be $true
          $updatedFile.LastWriteTime -le $afterRun | Should Be $true
        }
      }
    }

    It "SHOULD CHANGE ALL THE FILES THAT ARE JS TO NOW. DID NOT READ!!!!" {
      Foreach ($name in $fileNames)
      {
        $folder = $contentFolder + "\" + $name

        Foreach ($fileName in $fileNames)
        {
          $filePath = $folder + "\" + $fileName + ".js"
          $updatedFile = Get-Item $filePath

          $updatedFile.LastWriteTime -gt $startTime | Should Be $true
          $updatedFile.LastWriteTime -le $afterRun | Should Be $true
        }
      }
    }

    It "SHOULD CHANGE ALL THE FILES THAT ARE THOMAS TO NOW. DID NOT READ!!!!" {
      Foreach ($name in $fileNames)
      {
        $folder = $contentFolder + "\" + $name

        Foreach ($fileName in $fileNames)
        {
          $filePath = $folder + "\" + $fileName + ".thomas"
          $updatedFile = Get-Item $filePath

          $updatedFile.LastWriteTime -eq $yesterday | Should Be $true
        }
      }
    }

    It "Should Change the last write time to now for CSS." {

      Foreach ($fileName in $fileNames)
      {
        $filePath = $contentFolder + "\" + $fileName + ".css"
        $updatedFile = Get-Item $filePath

        $updatedFile.LastWriteTime -gt $startTime | Should Be $true
        $updatedFile.LastWriteTime -le $afterRun | Should Be $true
      }
    }

    It "Should Change the last write time to now for JS." {

      Foreach ($fileName in $fileNames)
      {
        $filePath = $contentFolder + "\" + $fileName + ".js"
        $updatedFile = Get-Item $filePath

        $updatedFile.LastWriteTime -gt $startTime | Should Be $true
        $updatedFile.LastWriteTime -le $afterRun | Should Be $true
      }
    }

    It "Should NOT Change the last write time for .thomas files" {

      Foreach ($fileName in $fileNames)
      {
        $filePath = $contentFolder + "\" + $fileName + ".thomas"
        $updatedFile = Get-Item $filePath

        $updatedFile.LastWriteTime -eq $yesterday | Should Be $true
      }
    }
}
