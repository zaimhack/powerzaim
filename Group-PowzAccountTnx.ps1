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
            [string]$txnype,
            [string]$curr,
            [int]$diff
        ) 
        process {
            $a = $AccountSummary[$acc]
            if ($null -eq $a) {
                $a = @{
                    Name         = $acc;
                    Latest       = $date;
                    Earliest     = $date;
                    Payment      = 0;
                    Income       = 0;
                    TransferFrom = 0;
                    TransferTo   = 0;
                    Balance      = 0;
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

            switch ($txnype) {
                'payment' { $a.Payment += 1; }
                'income' { $a.Income += 1; }
                'transfer_from' { $a.TransferFrom += 1; }
                'transfer_to' { $a.TransferTo += 1; }
                'balance' { $a.Balance += 1; }
                Default {}
            }

            $a.Total += $diff
            $AccountSummary[$acc] = $a
        }
    }
}

process {
    switch ($p.方法) {
        'payment' {
            Add-TransactionCount $p.支払元 $p.日付 $p.方法 $p.通貨 (- $p.支出)
        }
        'income' {
            Add-TransactionCount $p.入金先 $p.日付 $p.方法 $p.通貨 $p.収入
        }
        'transfer' {
            Add-TransactionCount $p.支払元 $p.日付 'transfer_from' $p.通貨 (- $p.振替)
            Add-TransactionCount $p.入金先 $p.日付 'transfer_to' $p.通貨 $p.振替
        }
        'balance' {
            if ($p.支払元 -ne "-") {
                Add-TransactionCount $p.支払元 $p.日付 $p.方法 $p.通貨 (- $p.残高調整)
            }
            else {
                Add-TransactionCount $p.入金先 $p.日付 $p.方法 $p.通貨 $p.残高調整
            }
        }
        Default {}
    }
}

end {
    $AccountSummary.Values | ForEach-Object {
        [pscustomobject]@{
            Name         = $_.Name;
            Earliest     = $_.Earliest;
            Latest       = $_.Latest;
            Payment      = $_.Payment;
            Income       = $_.Income;
            TransferFrom = $_.TransferFrom;
            TransferTo   = $_.TransferTo;
            Balance      = $_.Balance;
            Total        = $_.Total;
            ForgnCurr = $_.ForgnCurr;
        }
    }
}
