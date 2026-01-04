Describe "Split-PowzCsv" {
    $ScriptPath = Join-Path $PSScriptRoot "../Split-PowzCsv.ps1"

    BeforeAll {
        $ResultsFolder = New-Item -ItemType Directory (Join-Path $PSScriptRoot ("results_{0}" -f (Get-Date -format "yyyyMMddHHmmss")))
        $ErrorCount = 0
        $Error.Clear()
    }

    BeforeEach {
        $OutputFolder = New-Item -ItemType Directory (Join-Path $ResultsFolder ( -join (1..8 | % { '{0:X}' -f (Get-Random -Max 16) })))
        Write-Information ("output folder is created at {0}" -f $OutputFolder)
    }

    It "should generate nothing for an empty CSV file" { 
        Import-Csv (Join-Path $PSScriptRoot "./data/empty.csv") | & $ScriptPath -MaxLines 5 -OutputFolder $OutputFolder

        Get-ChildItem $OutputFolder | Should -HaveCount 0
    }

    It "does not split a CSV file whose number of rows is below the maximum row count" {
        Import-Csv (Join-Path $PSScriptRoot "./data/split_01.csv") | & $ScriptPath -MaxLines 5 -OutputFolder $OutputFolder

        $expected = Import-Csv (Join-Path $PSScriptRoot "./data/split_01.csv")

        Get-ChildItem $OutputFolder | Should -HaveCount 1

        $actual = Import-Csv (Get-ChildItem $OutputFolder | Select-Object -First 1)
        $actual | Should -HaveCount ($expected.Count)
        # ToBeFixed: it doest not seem that `$actual | Should -Be $expected` works
        0..($actual.Count - 1) | ForEach-Object {
            $actual[$_].日付 | Should -BeExactly $expected[$_].日付
        }
    }

    It "splits a CSV file exceeding the maximum rows at rows where the date changes" {
        Import-Csv (Join-Path $PSScriptRoot "./data/split_02.csv") | & $ScriptPath -MaxLines 5 -OutputFolder $OutputFolder

        Get-ChildItem $OutputFolder | Should -HaveCount 3

        @(
            @{file = "0000.csv"; count = 4; first = "01"; last = "02" },
            @{file = "0001.csv"; count = 4; first = "03"; last = "04" },
            @{file = "0002.csv"; count = 3; first = "05"; last = "05" }
        ) | ForEach-Object {
            $actual = Import-Csv (Join-Path $OutputFolder $_.file)
            $actual | Should -HaveCount $_.count
            $actual[0].日付 | Should -BeExactly $_.first
            $actual[-1].日付 | Should -BeExactly $_.last
        }
    }

    It "splits at the last date‑change line before reaching the max rows when dates repeat" {
        Import-Csv (Join-Path $PSScriptRoot "./data/split_03.csv") | & $ScriptPath -MaxLines 5 -OutputFolder $OutputFolder

        Get-ChildItem $OutputFolder | Should -HaveCount 3

        @(
            @{file = "0000.csv"; count = 5; first = "01"; last = "01" },
            @{file = "0001.csv"; count = 1; first = "02"; last = "02" },
            @{file = "0002.csv"; count = 5; first = "03"; last = "03" }
        ) | ForEach-Object {
            $actual = Import-Csv (Join-Path $OutputFolder $_.file)
            $actual | Should -HaveCount $_.count
            $actual[0].日付 | Should -BeExactly $_.first
            $actual[-1].日付 | Should -BeExactly $_.last
        }
    }

    It "splits when the same date repeats beyond the maximum length" {
        Import-Csv (Join-Path $PSScriptRoot "./data/split_04.csv") | & $ScriptPath -MaxLines 5 -OutputFolder $OutputFolder

        Get-ChildItem $OutputFolder | Should -HaveCount 8

        @(
            @{file = "0000.csv"; count = 5; first = "01"; last = "01" },
            @{file = "0001.csv"; count = 5; first = "01"; last = "01" },
            @{file = "0002.csv"; count = 4; first = "02"; last = "02" },
            @{file = "0003.csv"; count = 5; first = "03"; last = "03" },
            @{file = "0004.csv"; count = 5; first = "03"; last = "03" },
            @{file = "0005.csv"; count = 3; first = "03"; last = "03" },
            @{file = "0006.csv"; count = 5; first = "04"; last = "05" },
            @{file = "0007.csv"; count = 3; first = "06"; last = "06" }
        ) | ForEach-Object {
            $actual = Import-Csv (Join-Path $OutputFolder $_.file)
            $actual | Should -HaveCount $_.count
            $actual[0].日付 | Should -BeExactly $_.first
            $actual[-1].日付 | Should -BeExactly $_.last
        }
    }

    It "splits a CSV file based on the column specified by DateColumn parameter" {
        Import-Csv (Join-Path $PSScriptRoot "./data/split_05.csv") | & $ScriptPath -MaxLines 5 -OutputFolder $OutputFolder -DateCOlumn 本当の日付

        Get-ChildItem $OutputFolder | Should -HaveCount 2

        @(
            @{file = "0000.csv"; count = 2; first = "01"; last = "01" },
            @{file = "0001.csv"; count = 5; first = "01"; last = "02" }
        ) | ForEach-Object {
            $actual = Import-Csv (Join-Path $OutputFolder $_.file)
            $actual | Should -HaveCount $_.count
            $actual[0].日付 | Should -BeExactly $_.first
            $actual[-1].日付 | Should -BeExactly $_.last
        }
    }

    It "returns the split CSV content as an array of objects when OutputFolder is set to $null" {
        #$results = New-Object -Type System.Collections.ArrayList
        $results = Import-Csv (Join-Path $PSScriptRoot "./data/split_02.csv") | & $ScriptPath -MaxLines 5 -OutputFolder $null

        $results | Should -HaveCount 3
        $results[0] | Should -HaveCount 4
        $results[0][0].日付 | Should -BeExactly "01"
        $results[0][-1].日付 | Should -BeExactly "02"
        $results[1] | Should -HaveCount 4
        $results[1][0].日付 | Should -BeExactly "03"
        $results[1][-1].日付 | Should -BeExactly "04"
        $results[2] | Should -HaveCount 3
        $results[2][0].日付 | Should -BeExactly "05"
        $results[2][-1].日付 | Should -BeExactly "05"
    }

    AfterEach {
        if ($Error.Count -eq 0) {
            Remove-Item -Recurse ($OutputFolder)
        }
        else {
            Write-Host "The test has failed"
            Write-Host ("  output folder: {0}" -f $OutputFolder)
            Write-Host ("  error: {0}" -f $Error[0])
            ++$ErrorCount
        }
        $Error.Clear()
    }

    AfterAll {
        if (0 -eq (Get-ChildItem $ResultsFolder | Measure-Object).Count) {
            Remove-Item -Recurse $ResultsFolder
        }
    }
}