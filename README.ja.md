# PowerZaim

PowerZaim は、Zaim CSVを扱うための PowerShell のツール集です。

## Group-PowzAccountTnx.ps1

Zaim CSVに含まれるトランザクションを口座ごとに集計しカウントします。

### 使い方

```PowerShell
> import-csv .\Zaim.csv | .\Group-PowzAccountTnx.ps1 | Format-Table

Name                        Earliest   Latest     Payment Income TransferFrom TransferTo Balance   Total ForgnCurr
----                        --------   ------     ------- ------ ------------ ---------- -------   ----- ---------
BBB銀行                     2022-06-21 2024-11-06      49     41           21          0       2  741702         0
CCCカード                     2022-04-15 2023-08-04       7      0            0          2       3    1780         0
```

## Split-PowzCsv.ps1

Zaim CSV を分割します。

Zaim には、CSVファイルをアップロードすることで履歴情報を登録する機能があります。長大なCSVファイルはアップロードできない仕様であるため、適度な行数でファイルを分割し、それを一つ一つアップロードする必要があります。その分割を行うスクリプトです。

Zaim には「ファイルを分割（CSV 形式）する」というサービスもあるのですが、そのサービスで分割したファイルがアップロードできないことが何回かあったため、このスクリプトを作成しました。また、一般的なファイル分割ソフトウェアを使うこともできますが、このスクリプトは、可能な限り連続する日付は同じファイルに出力するように区切ります。

### 使い方

```PowerShell
PS > Import-Csv .\Zaim.20241220170821.csv | .\Split-PowzCsv.ps1 -OutputFolder .\splits
```

## Test-PowzUnsafeCharsForUpload.ps1

Zaim のCSVアップロード機能で自動変換される文字を検出します。

Zaim の CSVアップロード機能は、CSVの中に記載されている名称をそのまま登録するのではなく、[一部の文字を自動的に変換して登録します][repl]。一度、意図しない形で登録されてしまうと、Zaim では口座名などの修正が非常に難しいるため、アップロード前にそういった自動的に変換されてしまう文字がファイルに含まれていないかを、このスクリプトを使うことで検出することができます。

[repl]: https://content.zaim.net/questions/show/891

### 使い方

```PowerShell
PS > Import-Csv .\Zaim.20230402092212.csv | .\Test-PowzUnsafeCharsForUpload.ps1 -AsZaimCsv
Property Line UnsafeCharacters Value
-------- ---- ---------------- -----
  :
入金先    3232 {-, -, -}        有頂天 Midy ****-****-****-*787
お店      3590 {　}              ハッピー弁当　中央店
お店      3591 {　}              ハッピー弁当　中央店
支払元    3605 {(, )}           クレジットカード (家計費)
  :
```

### 制約

- セブンイレブンの表記統一ルールには、未対応です。
