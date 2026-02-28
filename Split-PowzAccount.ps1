param (
    #[string]$OutputFolder = ".",
    [string]$t,
    [Parameter(ValueFromPipeline)]
    $p
)


begin {
    Import-Module (Join-Path $PSScriptRoot "ZaimStream.psm1") -Force

    $acntfn = @{}
    function Add-ToAccountTnxs {
        param ([string]$account)
        process {
            if ($acntfn.Contains($account)) {

            }
            else {
                $acntfn[$account] = ConvertTo-Base36 $account
                return 
            }
        }
    }
}

process {

    $Acnt = $null
    switch ($p.方法) {
        "payment" {
            Add-ToAccountTnxs $p.支払元 $p
        }
        "income" {
            Add-ToAccountTnxs $p.入金先 $p
        }
        "transfer" {
            $TranId = [Guid]::NewGuid().ToString().Replace("-", "")

            Add-ToAccountTnxs $p.支払元 [PSCustomObject]@ {
                日付       = $p.日付;
                方法       = "payment"
                カテゴリ     = "その他";
                カテゴリの内訳  = "未登録口座への振替";
                支払元      = $p.支払元;
                入金先      = "-";
                品目       = "";
                メモ       = ("TRANSFER_SRC:{0}:{1}" -f $TranId, $p.入金先);
                お店       = "";
                通貨       = $p.通貨;
                収入       = 0;
                支出       = $p.振替;
                振替       = 0;
                残高調整     = 0;
                通貨変換前の金額 = $p.通貨変換前の金額;
                集計の設定    = $p.集計の設定;
            }
            Add-ToAccountTnxs $p.入金先 [PSCustomObject]@ {
                日付       = $p.日付;
                方法       = "income"
                カテゴリ     = "その他";
                カテゴリの内訳  = "-";
                支払元      = "-";
                入金先      = $p.入金先;
                品目       = "";
                メモ       = ("TRANSFER_DST:{0}:{1}" -f $TranId, $p.支払元);
                お店       = "";
                通貨       = $p.通貨;
                収入       = $p.振替;
                支出       = 0;
                振替       = 0;
                残高調整     = 0;
                通貨変換前の金額 = $p.通貨変換前の金額;
                集計の設定    = $p.集計の設定;
            }
        }
        "balance" {
            if ("-" -ne $p.支払元) {
                $Acnt = $p.支払元
            }
            else {
                $Acnt = $p.入金先
            }
        }
    }
}

end {

}