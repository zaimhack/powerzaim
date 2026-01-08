Describe "Group-PowzAccountTnx" {
    $ScriptPath = Join-Path $PSScriptRoot "../Group-PowzAccountTnx.ps1"

    It "should count and aggregate transactions per account" {
        $count = 0
        Import-Csv (Join-Path $PSScriptRoot "./data/group.csv") | & $ScriptPath | ForEach-Object {
            ++$count
            if ($_.Name -eq "口座 A") {
                $_.Earliest | Should -Be "2023-01-01"
                $_.Latest | Should -Be "2023-01-10"
                $_.Payment | Should -Be 0
                $_.Income | Should -Be 1
                $_.TransferFrom | Should -Be 2
                $_.TransferTo | Should -Be 0
                $_.Balance | Should -Be 1
                $_.Total | Should -Be 1000
                $_.ForgnCurr | Should -Be 0
            }
            if ($_.Name -eq "口座 B") {
                $_.Earliest | Should -Be "2023-01-03"
                $_.Latest | Should -Be "2023-01-11" 
                $_.Payment | Should -Be 2
                $_.Income | Should -Be 0
                $_.TransferFrom | Should -Be 0
                $_.TransferTo | Should -Be 2
                $_.Balance | Should -Be 1
                $_.Total | Should -Be 2500
                $_.ForgnCurr | Should -Be 0
            }
        }
        $count | Should -Be 2
    }
}