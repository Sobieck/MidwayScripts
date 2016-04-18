# cd c:\github\midwayscripts\Correct-PowerReviews
# .\Correct-PowerReviews.Tests.ps1
# Invoke-Pester
# requires PSCX

#Invoke-Pester .\Correct-PowerReviews.Tests.ps1 -CodeCoverage .\Correct-PowerReviews.ps1

Import-Module Pester

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

$testDrive = "TestDrive:\"
$powerReviewsZipFileName = "pwr.zip"
$powerReviewsZipFileFolderPath = $testDrive + "powerreviews\"

$currentFile = "current.txt"

$powerReviewsZipPath = $powerReviewsZipFileFolderPath + $powerReviewsZipFileName

$prodAreaFeatPwrPath = $testDrive + "midwayusa\prod\areas\features\pwr"
$prodContentPath = $prodAreaFeatPwrPath + "\Content"
$prodEnginePath = $prodAreaFeatPwrPath + "\Engine"
$prodM78Path = $prodAreaFeatPwrPath + "\M78z3x93"

$now = Get-Date
$yesterdayAtThisTime = $now.AddDays(-1)

Describe "Correct-PowerReviews" {
  New-Item $powerReviewsZipFileFolderPath -Type Directory
  New-Item $prodContentPath -Type Directory
  New-Item $prodEnginePath -Type Directory
  New-Item $prodM78Path -Type Directory

  New-Item $currentFile -Type File
  Copy-Item $currentFile $prodContentPath
  Copy-Item $currentFile $prodEnginePath
  Move-Item $currentFile $prodM78Path

  Context "pwr.zip doesn't exist" {
    Mock Write-Host { }

    Mock Get-Service {return @{Status = "Running"}} -ParameterFilter {$Name -eq "W3SVC"}

    $content = Get-Item $prodContentPath
    $content.LastWriteTime = $yesterdayAtThisTime

    Correct-PowerReviews($testDrive)

    It "Should notify the user of that the file doesn't exist" {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "The zip file isn't present."}
    }

    It "Should then describe the actions needed to fix this problem" {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "Use the Power Reviews FTP Credentials in the third party contact info to download the pwr.zip file."}
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "Drop this file into '\\a-power1\D\PowerReviews'"}
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "This will be picked up by the ZipExtractor service"}
    }

    It "Should Not Notify the User that everything is ok" {
      Assert-MockCalled Write-Host -Times 0 -ParameterFilter {$Object -eq "The zip file is present."}
    }

    It "Should Not Notify the User that the zip file is present." {
      Assert-MockCalled Write-Host -Times 0 -ParameterFilter {$Object -eq "Everything is up to date in Prod."}
    }
  }

  Context "pwr.zip does exist and pwr.zip doesn't have todays date as modified" {
    Write-Zip ".\" $powerReviewsZipFileName
    Move-Item $powerReviewsZipFileName $powerReviewsZipPath

    $zip = Get-Item $powerReviewsZipPath
    $zip.LastWriteTime = $yesterdayAtThisTime

    Mock Write-Host { }
    Mock Get-Service {return @{Status = "Running"}} -ParameterFilter {$Name -eq "W3SVC"}

    Correct-PowerReviews($testDrive)

    It "Should notify the user of that the pwr.zip file exist" {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "The zip file is present."}
    }

    It "Should notify the user that they should contact a DBA." {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "Contact a DBA. The pwr.zip file is old."}
    }

    It "Should Not Notify the User that everything is ok" {
      Assert-MockCalled Write-Host -Times 0 -ParameterFilter {$Object -eq "Everything is up to date in Prod."}
    }

    It "Should Notify the User that IIS is running" {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "IIS is running."}
    }
  }

  Context "pwr.zip does exist, it has today's date as modified, the production folders are from today" {
    Write-Zip ".\" $powerReviewsZipFileName
    Move-Item $powerReviewsZipFileName $powerReviewsZipPath

    $zip = Get-Item $powerReviewsZipPath
    $zip.LastWriteTime = $now

    $content = Get-Item $prodContentPath
    $content.LastWriteTime = $now

    Mock Write-Host { }
    Mock Start-Service { }

    Mock Get-Service {return @{Status = "Running"}} -ParameterFilter {$Name -eq "W3SVC"}

    It "Should notify the user of that the pwr.zip file exist" {
      Correct-PowerReviews($testDrive)
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "The zip file is present."}
    }

    It "Should Notify the User that everything is ok" {
      Correct-PowerReviews($testDrive)
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "Everything is up to date in Prod."}
    }

    It "when IIS is running it Should Notify the user that IIS is running" {
      Correct-PowerReviews($testDrive)
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "IIS is running."}
    }

    It "when IIS is not running should notify the user that IIS is not running and start IIS" {
      Mock Get-Service {return @{Status = "Not running"}} -ParameterFilter {$Name -eq "W3SVC"}
      Correct-PowerReviews($testDrive)
      Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter {$Object -eq "IIS is not running."}
      Assert-MockCalled Start-Service -Exactly 1 -ParameterFilter {$DisplayName -eq "World Wide Web Publishing Service"}
    }
  }

  Context "pwr.zip does exist, it has today's date as modified, the at least one of the production folders are old, and the temp folders are current" {
    $content = Get-Item $prodContentPath
    $content.LastWriteTime = $yesterdayAtThisTime

    It "IIS is running" {

    }

    IT "IIS is not running" {

    }

    Mock Write-Host { }
    Mock Start-Service { }
  }
}

Describe "Was-Modified-Today" {
  $wasModifiedPath = $testDrive + "asdfasfd"

  Context "It Was Modified Today"{
    New-Item $wasModifiedPath -Type Directory

    $actual = Was-Modified-Today($wasModifiedPath)

    It "Should return TRUE" {
      $actual | Should Be $TRUE
    }
  }

  Context "It Was Modified Yesterday"{
    New-Item $wasModifiedPath -Type Directory

    $modifiedFolder = Get-Item $wasModifiedPath
    $modifiedFolder.LastWriteTime = $yesterdayAtThisTime

    $actual = Was-Modified-Today($wasModifiedPath)

    It "Should return FALSE" {
      $actual | Should Be $FALSE
    }
  }

  Context "It doesn't exist"{
    Mock Get-Item { return $FALSE }

    $actual = Was-Modified-Today($wasModifiedPath)

    It "Should return FALSE" {
      $actual | Should Be $FALSE
    }

    It "Should not call Get Item"{
      Assert-MockCalled Get-Item -Times 0
    }
  }
}
