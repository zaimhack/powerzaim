param (
    [Parameter(Mandatory = $True)]
    [string]$Account,
    [Parameter(ValueFromPipeline = $True)]
    $p
)

process {
    $p | Where-Object {
        switch ($_.方法) {
            "payment" {
                $Account -eq $p.支払元 
            }
            "income" {
                $Account -eq $p.入金先
            }
            "transfer" {
                $Account -eq $p.支払元 -or $Account -eq $p.入金先
            }
            "balance" {
                $Account -eq $p.支払元 -or $Account -eq $p.入金先
            }
            default {
                Write-Warning ("unknown 方法: {0}" -f $p.方法)
            }
        }
    }
}