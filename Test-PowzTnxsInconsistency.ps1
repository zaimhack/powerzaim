param (
    [Parameter(ValueFromPipeline = $True)]
    $p
)

begin {
    $lastDate = $null
    $tnxs = New-Object -Type System.Collections.ArrayList

    function Test-SendAndRecv {
        param ($tnx1, $tnx2)
    
        if (($buffer[$i].Account -eq $buffer[$j].Account) -and `
                $buffer[$i].Type -eq "balance" -and $buffer[$j].Type -eq "balance" -and `
                [Math]::Abs($buffer[$i].Amount) -eq [Math]::Abs($buffer[$j].Amount) -and `
            ([int]$buffer[$i].Amount * [int]$buffer[$j].Amount) -lt 0) {
            $detectedPairs[$j] = $i
        }
    }

    function Test-A {
        param ([object]$tnx1, [object]$tnx2)
        return ([Math]::Abs($tnx1.収入) -eq [Math]::Abs($tnx2.支出) -and $tnx1.方法 -eq "income")
    }

    function Test-B {
        param ($tnx1, $tnx2)
        return ([Math]::Abs($tnx1.収入) -eq [Math]::Abs($tnx2.残高調整) -and $tnx1.方法 -eq "income")
    }

    function Test-C {
        param ($tnx1, $tnx2)
        return ([Math]::Abs($tnx1.残高調整) -eq [Math]::Abs($tnx2.残高調整) -and $tnx1.方法 -eq "balance" -and $tnx2.方法 -eq "balance" -and ($tnx1.支払元 -eq $tnx2.入金先 -or $tnx1.入金先 -eq $tnx2.支払元))
    }
}

process {
    if ($null -eq $lastDate) {
        $lastDate = $p.日付
    }

    if ($lastDate -eq $p.日付) {
        $tnxs.Add($p) | Out-Null
    } else {
        $detectedPairs = New-Object -Type System.Collections.ArrayList
        for ($i = 0; $i -lt $tnxs.Count - 1; ++$i) {
            for ($j = 1; $j -lt $tnxs.Count; ++$j) {

                if (Test-A $tnxs[$i] $tnxs[$j]) {
                    $detectedPairs.Add(@("A", $i, $j)) | Out-Null
                } elseif (Test-C $tnxs[$i] $tnxs[$j]) {
                    $detectedPairs.Add(@("C", $i, $j)) | Out-Null
                }
            }
        }
        $detectedPairs | % {
            [System.ValueTuple]::Create[string, object, object]($_[0], $tnxs[$_[1]], $tnxs[$_[2]])
        }
        $tnxs.Clear()
    }
    $lastDate = $_.日付
}

end {

}
