param (
    [Parameter(ValueFromPipeline = $True)]
    $p
)

begin {
    Import-Module (Join-Path $PSScriptRoot "ZaimStream.psm1") -Force
    $lastDate = $null
    $buffer = New-Object -Type System.Collections.ArrayList
}

process {
    $p `
    | Convert-PowzStream `
    | ForEach-Object {
        if ($null -eq $lastDate) {
            $lastDate = $p.Date
        }

        if ($lastDate -eq $_.Date) {
            $buffer.Add($_) | Out-Null
        } else {
            $detectedPairs = @{}
            for ($i = 0; $i -lt $buffer.Count - 1; ++$i) {
                for ($j = 1; $j -lt $buffer.Count; ++$j) {
                    if ($detectedPairs.Contains($j)) {
                        break
                    }

                    if (($buffer[$i].Account -eq $buffer[$j].Account) -and `
                        $buffer[$i].Type -eq "balance" -and $buffer[$j].Type -eq "balance" -and `
                        [Math]::Abs($buffer[$i].Amount) -eq [Math]::Abs($buffer[$j].Amount) -and `
                        ([int]$buffer[$i].Amount * [int]$buffer[$j].Amount) -lt 0) {
                        $detectedPairs[$j] = $i
                    }
                }
            }
            $detectedPairs.Keys |% {
                ,@($buffer[$_], $buffer[$detectedPairs[$_]])
            }
            $buffer.Clear()
        }
        $lastDate = $_.Date
    }


}

end {

}
