<#
  .SYNOPSIS
  Detects characters that are automatically converted by the CSV upload feature.

  .PARAMETER AsZaimCsv
  Assumes that the input is a Zaim CSV and adds information about which column contains the detected characters to the results.
  It also limits the check to specific columns, such as 支払元 or 入金先, where unintended character conversion would be difficult to correct.
  If this option is not specified, the input is checked as a plain string rather than as a CSV.
#>

param (
    [parameter(ValueFromPipeline)]
    $p,
    [switch]$AsZaimCsv
)

begin {
    $REGEX = "([　．！`”＃＄％&'\(\)\[\]｛｝＜＞？＿，／＊＋＝｜＾＠¥￥\-]|[カ-コサ-ソタ-トハ-ホ]゛|[ハ-ホ]゜|\\|`r(`n)?)"

    function Test-UnsafeChars {
        param (
            $val
        )

        process {
            if ("-" -eq $val) {
                return
            }
            $m = [regex]::Matches($val, $REGEX)
            $unsafeChars = New-Object System.Collections.ArrayList
            if ($m.Success) {
                $m | ForEach-Object {
                    $unsafeChars.Add($_.Value) | Out-Null
                }
                return @{
                    Value            = $val;
                    UnsafeCharacters = $unsafeChars;
                }
            }
        }
    }

    if ($AsZaimCsv) {
        $UnsafeCharacterChecker = {
            param (
                $ln
            )

            begin {
                $columns = @("カテゴリ", "カテゴリの内訳", "支払元", "入金先", "お店", "品目", "メモ")
            }

            process {
                $obj = $_
                $columns | % {
                    $result = Test-UnsafeChars $obj.$_
                    if ($null -ne $result) {
                        $result["Line"] = $ln
                        $result["Property"] = $_
                        return [PSCustomObject]$result
                    }
                }
            }
        }
    }
    else {
        $UnsafeCharacterChecker = {
            param (
                $ln
            )

            process {
                $result = Test-UnsafeChars $_
                if ($null -ne $result) {
                    $result["Line"] = $ln
                    return [PSCustomObject]$result
                }
            }
        }
    }
    $LineNumber = 1
}

process {
    $p | & $UnsafeCharacterChecker $LineNumber
    ++$LineNumber
}

end {

}

