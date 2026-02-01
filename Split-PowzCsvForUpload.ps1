<# 
    .SYNOPSIS
    Splits a Zaim CSV file into multiple files.

    .DESCRIPTION

    .Parameter MaxLines
    This script plits the Zaim CSV so that each output file stays within the number of rows specified by this parameter. The default is 3000.

    .Parameter OutputFolder
    Specifies the path to the output folder. The split CSV files are saved in this folder as 0000.csv, 0001.csv, 0002.csv, and so on. The default is the current folder.

    .Parameter DateColumn
    Specifies the date column used to detect date-change boundaries. The default is "日付".
#>

[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline = $True)]
    $p,
    [Parameter()]
    [int]$MaxLines = 3000,
    [Parameter()]
    $OutputFolder = ".",
    [Parameter()]
    $DateColumn = "日付"
)

begin {
    $lastDate = $null
    $waterMark = 0
    $buffer = New-Object -Type System.Collections.ArrayList
    $fileIndex = 0

    If ($null -ne $OutputFolder) {
        function Out-CsvFile {
            param ($n)
            process {
                $_ | Export-Csv -Encoding utf8BOM -Path (Join-Path $OutputFolder ("{0:0000}.csv" -f $n))
            }
        }
    }
    else {
        function Out-CsvFile {
            param ($n)
            process {
                , $_
            }
        }
    }
    $DebugPreference = 'Continue'
}

process {
    $date = $p.$DateColumn
    if ($null -eq $lastDate) {
        $lastDate = $date
    }

    if ($lastDate -ne $date) {
        if ($buffer.Count -le $MaxLines) {
            $waterMark = $buffer.Count
        }
        else {
            if (0 -lt $waterMark) {
                , $buffer[0..($waterMark - 1)] | Out-CsvFile $fileIndex
                ++$fileIndex
            }

            for ($i = $waterMark; $i + $MaxLines -le $buffer.Count; $i += $MaxLines) {
                , $buffer[$i..($i + $MaxLines - 1)] | Out-CsvFile $fileIndex
                ++$fileIndex
            }

            $buffer.RemoveRange(0, $i)
            $waterMark = $buffer.Count
        }
    }

    $buffer.Add($p) | Out-Null
    $lastDate = $date
}

end {
    if ($buffer.Count -le $MaxLines) {
        $waterMark = $buffer.Count
    }

    if (0 -lt $waterMark) {
        , $buffer[0..($waterMark - 1)] | Out-CsvFile $fileIndex
        ++$fileIndex
        for ($i = $waterMark; $i -lt $buffer.Count; $i += $MaxLines) {
            , $buffer[$i..($i + $MaxLines - 1)] | Out-CsvFile $fileIndex
            ++$fileIndex
        }
    }
}
