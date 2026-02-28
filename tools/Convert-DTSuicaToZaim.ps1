param (
    [parameter(ValueFromPipeline = $True)]
    $p,
    [parameter(Mandatory = $True, HelpMessage = "Zaimでの支払元、入金先として設定されるカード名")]
    [string]$CardName,
    [parameter(Mandatory = $False, HelpMessage = "運賃に対し、Zaimで設定されるカテゴリ")]
    [string]$ZaimFareCategory = "交通",
    [parameter(Mandatory = $False, HelpMessage = "運賃に対し、Zaimで設定されるサブカテゴリ")]
    [string]$ZaimFareSubCategory = "電車",
    [parameter(Mandatory = $False, HelpMessage = "チャージに対し、Zaimで設定されるカテゴリ")]
    [string]$ZaimTopupCategory = "電子マネーチャージ",
    [parameter(Mandatory = $False, HelpMessage = "チャージに対し、Zaimで設定されるサブカテゴリ")]
    [string]$ZaimTopupSubCategory = "-",
    [parameter(Mandatory = $False, HelpMessage = "支払に対し、Zaimで設定されるカテゴリ")]
    [string]$ZaimPaymentCategory = "その他",
    [parameter(Mandatory = $False, HelpMessage = "支払に対し、Zaimで設定されるサブカテゴリ")]
    [string]$ZaimPaymentSubCategory = "未分類",
    [string]$ZaimShukei = "常に集計に含める"
)

process {
    $d = [datetime]::ParseExact($p.Date, "yyyy/MM/dd", $null).ToString("yyyy-MM-dd")

    switch ($p.Title) {
        "運賃" {
            [PSCustomObject]@{
                日付       = $d
                方法       = "payment";
                カテゴリ     = $ZaimFareCategory;
                カテゴリの内訳  = $ZaimFareSubCategory;
                支払元      = $CardName;
                入金先      = "-";
                品目       = "";
                メモ       = ("{0} - {1}" -f $p."In Station", $p."Out Station");
                お店       = $p."Company Name";
                通貨       = "JPY";
                収入       = 0;
                支出       = $p."Out Value";
                振替       = 0;
                残高調整     = 0;
                通貨変換前の金額 = $p."Out Value";
                集計の設定    = $ZaimShukei;
            }
        }
        "チャージ" {
            [PSCustomObject]@{
                日付       = $d;
                方法       = "income";
                カテゴリ     = $ZaimTopupCategory;
                カテゴリの内訳  = $ZaimTopupSubCategory;
                支払元      = "-";
                入金先      = $CardName;
                品物       = "";
                メモ       = "";
                お店       = "";
                通貨       = "JPY";
                収入       = $p."In Value";
                支出       = 0;
                振替       = 0;
                残高調整     = 0;
                通貨変換前の金額 = $p."In Value";
                集計の設定    = $ZaimShukei;
            }
        }
        "支払" {
            [PSCustomObject]@{
                日付       = $d;
                方法       = "payment";
                カテゴリ     = $ZaimPaymentCategory;
                カテゴリの内訳  = $ZaimPaymentSubCategory;
                支払元      = $p."Card Name";
                入金先      = "-";
                品物       = "";
                メモ       = "";
                お店       = "物販";
                通貨       = "JPY";
                収入       = 0;
                支出       = $p."Out Value";
                振替       = 0;
                残高調整     = 0;
                通貨変換前の金額 = $p."Out Value";
                集計の設定    = $ZaimShukei;
            }
        }
    }
}
