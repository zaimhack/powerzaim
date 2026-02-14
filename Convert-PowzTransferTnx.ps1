param (
    [parameter(ValueFromPipeline = $True)]
    $p
)

begin {
    Import-Module (Join-Path $PSScriptRoot "ZaimStream.psm1")
}

process {
    if ("transfer" -ne $p.方法) {
        return $_
    }

    $TranId = ($p.日付, [Math]::Abs($p.振替) | Get-Base36Hash)

    [PSCustomObject]@{
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

    [PSCustomObject]@{
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
