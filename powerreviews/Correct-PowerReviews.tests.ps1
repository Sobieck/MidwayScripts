Import-Module Pester

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

$testDrive = "TestDrive:\"
$powerReviewsZip = $testDrive + "powerreviews\pwr.zip"
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
  }

  Context "pwr.zip does exist and pwr.zip doesn't have todays date as modified" {
    Mock Test-Path {return $true} -ParameterFilter {$Path -eq $powerReviewsZip }
    Mock Get-Item {return @{LastWriteTime = $yesterdayAtThisTime }} -ParameterFilter {$Path -eq $powerReviewsZip}
    Mock Write-Host { }

    Correct-PowerReviews($testDrive)

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
  }
}

Describe "Was-Modified-Today" {
  $path = $testDrive + "asdfasfd"

  Context "It Was Modified Today"{
    Mock Get-Item {return @{LastWriteTime = $date }} -ParameterFilter {$Path -eq $path}

    $actual = Was-Modified-Today($path)

    It "Should return true" {
      $actual | Should Be $true
    }
  }

  Context "It Was Modified Yesterday"{
    Mock Get-Item {return @{LastWriteTime = $yesterdayAtThisTime }} -ParameterFilter {$Path -eq $path}

    $actual = Was-Modified-Today($path)

    It "Should return false" {
      $actual | Should Be $false
    }
  }
}
