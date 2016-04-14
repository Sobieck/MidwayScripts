# cd c:\github\midwayscripts\powerreviews
# .\Correct-PowerReviews.Tests.ps1
# Invoke-Pester

#Invoke-Pester .\Correct-PowerReviews.Tests.ps1 -CodeCoverage .\Correct-PowerReviews.ps1

Import-Module Pester

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

$testDrive = "TestDrive:\"
$powerReviewsZip = $testDrive + "powerreviews\pwr.zip"

$prodAreaFeatPwrPath = $testDrive + "midwayusa\prod\areas\features\pwr"
$prodContentPath = $prodAreaFeatPwrPath + "\Content"
$prodEnginePath = $prodAreaFeatPwrPath + "\Engine"
$prodM78Path = $prodAreaFeatPwrPath + "\M78z3x93"

$date = Get-Date
$yesterdayAtThisTime = $date.AddDays(-1)

Describe "Correct-PowerReviews" {
  Context "pwr.zip doesn't exist" {
    Mock Test-Path {return $false} -ParameterFilter {$Path -eq $powerReviewsZip}
    Mock Write-Host { }
    Mock Get-Item { }

    Correct-PowerReviews($testDrive)

    It "Should check to see if the pwr.zip file exists" {
      Assert-MockCalled Test-Path -Times 1 -ParameterFilter {$path -eq $powerReviewsZip}
    }

    It "Should notify the user of that the file doesn't exist" {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "The zip file isn't present."}
    }

    It "Should then describe the actions needed to fix this problem" {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "Use the Power Reviews FTP Credentials in the third party contact info to download the pwr.zip file."}
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "Drop this file into '\\a-power1\D\PowerReviews'"}
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "This will be picked up by the ZipExtractor service"}
    }

    It "Should not call Get-Item" {
      Assert-MockCalled Get-Item -Times 0
    }

    It "Should Not Notify the User that everything is ok" {
      Assert-MockCalled Write-Host -Times 0 -ParameterFilter {$Object -eq "The zip file is present."}
    }

    It "Should Not Notify the User that the zip file is present." {
      Assert-MockCalled Write-Host -Times 0 -ParameterFilter {$Object -eq "Everything is up to date in Prod."}
    }
  }

  Context "pwr.zip does exist and pwr.zip doesn't have todays date as modified" {
    Mock Test-Path {return $true} -ParameterFilter {$Path -eq $powerReviewsZip }
    Mock Get-Item {return @{LastWriteTime = $yesterdayAtThisTime }} -ParameterFilter {$Path -eq $powerReviewsZip}
    Mock Write-Host { }

    $reuslt = Correct-PowerReviews($testDrive)
    Write-Host $reuslt

    It "Should check to see if the pwr.zip file exists" {
      Assert-MockCalled Test-Path -Times 1 -ParameterFilter {$path -eq $powerReviewsZip}
    }

    It "Should call Get-Item on the zip file."{
      Assert-MockCalled Get-Item -Times 1 -ParameterFilter {$Path -eq $powerReviewsZip}
    }

    It "Should notify the user of that the pwr.zip file exist" {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "The zip file is present."}
    }

    It "Should notify the user that they should contact a DBA." {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "Contact a DBA. The pwr.zip file is old."}
    }

    It "Should Not Notify the User that everything is ok" {
      Assert-MockCalled Write-Host -Times 0 -ParameterFilter {$Object -eq "Everything is up to date in Prod."}
    }

    It "Should Not Notify the User that IIS is running" {
      Assert-MockCalled Write-Host -Times 0 -ParameterFilter {$Object -eq "Everything is up to date in Prod."}
    }
  }

  Context "pwr.zip does exist, it has today's date as modified, the production folders are from today and IIS is running" {
    Mock Test-Path {return $true} -ParameterFilter {$Path -eq $pwrzipPath }
    Mock Get-Item {return @{LastWriteTime = $date }} -ParameterFilter {$Path -eq $pwrzipPath}

    Mock Test-Path {return $true} -ParameterFilter {$Path -eq $prodContentPath }
    Mock Get-Item {return @{LastWriteTime = $date }} -ParameterFilter {$Path -eq $prodContentPath}

    Mock Test-Path {return $true} -ParameterFilter {$Path -eq $prodEnginePath }
    Mock Get-Item {return @{LastWriteTime = $date }} -ParameterFilter {$Path -eq $prodEnginePath}

    Mock Test-Path {return $true} -ParameterFilter {$Path -eq $prodM78Path }
    Mock Get-Item {return @{LastWriteTime = $date }} -ParameterFilter {$Path -eq $prodM78Path}

    Mock Write-Host { }

    Mock Get-Service {return @{Status = "Running"}} -ParameterFilter {$Name -eq "W3SVC"}

    Correct-PowerReviews($testDrive)

    It "Should notify the user of that the pwr.zip file exist" {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "The zip file is present."}
    }

    It "Should Notify the User that everything is ok" {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "Everything is up to date in Prod."}
    }

    It "Should Notify the user that IIS is running" {
      Assert-MockCalled Write-Host -Times 1 -ParameterFilter {$Object -eq "IIS is running."}
    }
  }
}

Describe "Was-Modified-Today" {
  $path = $testDrive + "asdfasfd"

  Context "It Was Modified Today"{
    Mock Get-Item {return @{LastWriteTime = $date }} -ParameterFilter {$Path -eq $path}
    Mock Test-Path {return $true } -ParameterFilter {$Path -eq $path }

    $actual = Was-Modified-Today($path)

    It "Should return true" {
      $actual | Should Be $true
    }
  }

  Context "It Was Modified Yesterday"{
    Mock Get-Item {return @{LastWriteTime = $yesterdayAtThisTime }} -ParameterFilter {$Path -eq $path}
    Mock Test-Path {return $true } -ParameterFilter {$Path -eq $path }

    $actual = Was-Modified-Today($path)

    It "Should return false" {
      $actual | Should Be $false
    }
  }

  Context "It doesn't exist"{
    Mock Test-Path {return $false } -ParameterFilter {$Path -eq $path }
    Mock Get-Item { return $false }

    $actual = Was-Modified-Today($path)

    It "Should return false" {
      $actual | Should Be $false
    }

    It "Should not call Get Item"{
      Assert-MockCalled Get-Item -Times 0
    }
  }
}
