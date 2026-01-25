function Convert-PowzStream {
    param (
        [Parameter(ValueFromPipeline = $True)]
        $p
    )

    begin {
        $idx = 0
    }

    process {
        ++$idx

        switch ($p.方法) {
            "payment" {
                $amount = - $p.支出;
                $account = $p.支払元;
                $counterParty = $null;

            }
            "income" {
                $amount = $p.収入;
                $account = $p.入金先;
                $counterParty = $null;
            }
            "transfer" {
                if ("-" -ne $p.支払元) {
                    $amount = - $p.振替;
                    $account = $p.支払元;
                    $counterParty = $p.入金先;
                } else {
                    $amount = $p.振替;
                    $account = $p.入金先;
                    $counterParty = $p.支払元;
                }
            } 
            "balance" {
                if ("-" -ne $p.支払元) {
                    $amount = - $p.残高調整;
                    $account = $p.支払元;
                    $counterParty = $null;
                } else {
                    
                    $amount = $p.残高調整;
                    $account = $p.入金先;
                }
            }
        }

        [PSCustomObject]@{
            Date        = $p.日付;
            Type        = $p.方法;
            Account     = $account;
            Amount      = $amount;
            Currency    = $p.通貨;
            CounterParty = $counterParty;
            Data = $p
        }
    }

    end {
    }
}

Export-ModuleMember -Function Convert-PowzStream
