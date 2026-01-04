Describe "Test-PowzUnsafeCharsForUploade" {
    $ScriptPath = Join-Path $PSScriptRoot "../Test-PowzUnsafeCharsForUpload.ps1"

    Context "Reading a CSV file containing full-width symbol characters" {
        BeforeAll {
            $Results = @{}
            Import-Csv (Join-Path $PSScriptRoot "./data/unsafe_fullwidth.csv") | & $ScriptPath -AsZaimCsv | ForEach-Object {
                $Results["{0}_{1}" -f $_.Line, $_.Property] = $_.Value
            }
        }

        It "should detect unsafe characters in 支払元 entities on lines 1-22" {
            $Results.Keys | Should -HaveCount 22
            1..22 | ForEach-Object {
                $Results.Keys | Should -Contain ("{0}_支払元" -f $_)
            }
        }

        It "should not detect any unsafe characters in 支払元 entities on lines 23-25" {
            $Results.keys | ForEach-Object { Should -Not -Match "23_.*" }
            $Results.keys | ForEach-Object { Should -Not -Match "24_.*" }
            $Results.keys | ForEach-Object { Should -Not -Match "25_.*" }
        }
    }

    Context "Reading a CSV file containing half-width symbol characters" {
        BeforeAll {
            $Results = @{}
            Import-Csv (Join-Path $PSScriptRoot "./data/unsafe_halfwidth.csv") | & $ScriptPath -AsZaimCsv | ForEach-Object {
                $Results["{0}_{1}" -f $_.Line, $_.Property] = $_.Value
            }
        }

        It "should detect unsafe characters in 支払元 entities on lines 1-12" {
            $Results.Keys | Should -HaveCount 12
            1..12 | ForEach-Object {
                $Results.Keys | Should -Contain ("{0}_支払元" -f $_)
            }
        }

        It "should not detect any unsafe characters in 支払元 entities on lines 13-33" {
            13..33 | ForEach-Object {
                $n = $_
                $Results.keys | ForEach-Object { $_ | Should -Not -Match ("{0:00}_.*" -f $n) }
            }
        }
    }

    Context "Reading a CSV file containing katakana with separated dakuten and handakuten" {
        BeforeAll {
            $Results = @{}
            Import-Csv (Join-Path $PSScriptRoot "./data/unsafe_kana.csv") | & $ScriptPath -AsZaimCsv | ForEach-Object {
                $Results["{0}_{1}" -f $_.Line, $_.Property] = $_.Value
            }
        }

        It "should detect unsafe characters in 支払元 entities on lines 1-25" {
            $Results.Keys | Should -HaveCount 25
            1..25 | ForEach-Object {
                $Results.Keys | Should -Contain ("{0}_支払元" -f $_)
            }
        }

        It "should not detect any unsafe characters in 支払元 entities on lines 26-50" {
            26..50 | ForEach-Object {
                $n = $_
                $Results.keys | ForEach-Object { $_ | Should -Not -Match ("{0:00}_.*" -f $n) }
            }
        }
    }
}
