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
                }
                else {
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
                }
                else {
                    
                    $amount = $p.残高調整;
                    $account = $p.入金先;
                }
            }
        }

        [PSCustomObject]@{
            Date         = $p.日付;
            Type         = $p.方法;
            Account      = $account;
            Amount       = $amount;
            Currency     = $p.通貨;
            CounterParty = $counterParty;
            Data         = $p
        }
    }

    end {
    }
}

function Get-Base36Hash {
    param (
        [Parameter(ValueFromPipeline = $True)]
        $p
    )

    begin {
        $chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        $l = 12
        $state = 0
    }

    process {
        [Text.Encoding]::UTF8.GetBytes($p) | ForEach-Object {
            $state = (($state -bxor $_) + ($state * 31)) % 0x7FFFFFFF
        }
    }

    end {
        $result = ""
        for ($i = 0; $i -lt $l; $i++) {
            $state = ($state * 1315423911 + 12345) % 0x7FFFFFFF
            $result += $chars[$state % $chars.Length]
        }
        return $result
    }
}

function Group-PowzTnxsByDate {
    param (
        [Parameter(ValueFromPipeline = $True)]
        $p
    )

    begin {
        $lastDate = $null
        $tnxBufferByDate = New-Object -Type System.Collections.ArrayList
        Write-Warning("begin")
    }

    process {
        if ($null -eq $lastDate) {
            $lastDate = $p.日付
        }

        if ($lastDate -eq $p.日付) {
            $tnxBufferByDate.Add($p) | Out-Null
        }
        else {
            Write-Warning(">{0}" -f $lastDate)
            , $TnxBufferByDate.ToArray()
            $TnxBufferByDate.Clear()
        }
        $lastDate = $p.日付
    }
    end {
        if (0 -lt $buffer.Count) {
            , $TnxBufferByDate.ToArray()
        }
    }
}

Export-ModuleMember -Function Convert-PowzStream
Export-ModuleMember -Function Get-Base36Hash
Export-ModuleMember -Function Group-PowzTnxsByDate
