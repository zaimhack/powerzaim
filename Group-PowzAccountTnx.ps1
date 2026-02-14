<#
    .SYNOPSIS
    Aggregates the number of transactions per account from Zaim CSV data.
#>

param (
    [Parameter(ValueFromPipeline)]
    [object]$p
)
begin {
    $AccountSummary = @{}

    function Add-TransactionCount {
        param (
            [string]$acc,
            [string]$date,
            [string]$txntype,
            [string]$curr,
            [int]$diff
        ) 
        process {
            $a = $AccountSummary[$acc]
            if ($null -eq $a) {
                $a = [ordered]@{
                    Name         = $acc;
                    Earliest     = $date;
                    Latest       = $date;
                    Payment      = 0;
                    Income       = 0;
                    TransferFrom = 0;
                    TransferTo   = 0;
                    BalancePlus  = 0;
                    BalanceMinus = 0;
                    Total        = 0;
                    ForgnCurr    = 0;
                }
            }
            
            if ($date -lt $a.Earliest) {
                $a.Earliest = $date
            }
            elseif ($a.Latest -lt $date) {
                $a.Latest = $date
            }

            if ("JPY" -ne $curr) {
                $a.ForgnCurr += 1
            }

            if ($a.Contains($txntype)) {
                $a.$txntype += 1
            }

            $a.Total += $diff
            $AccountSummary[$acc] = $a
        }
    }
}

process {
    switch ($p.方法) {
        'payment' {
            Add-TransactionCount $p.支払元 $p.日付 'Payment' $p.通貨 (- $p.支出)
        }
        'income' {
            Add-TransactionCount $p.入金先 $p.日付 'Income' $p.通貨 $p.収入
        }
        'transfer' {
            Add-TransactionCount $p.支払元 $p.日付 'TransferFrom' $p.通貨 (- $p.振替)
            Add-TransactionCount $p.入金先 $p.日付 'TransferTo' $p.通貨 $p.振替
        }
        'balance' {
            if ($p.支払元 -ne "-") {
                Add-TransactionCount $p.支払元 $p.日付 'BalancePlus' $p.通貨 (- $p.残高調整)
            }
            else {
                Add-TransactionCount $p.入金先 $p.日付 'BalanceMinus' $p.通貨 $p.残高調整
            }
        }
        Default {}
    }
}

end {
    $AccountSummary.Values | ForEach-Object { [PSCustomObject]$_ }
}
