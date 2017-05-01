$ResultsArray = @()
foreach ($displayname in $CompareResults2) {
    $UserObject = New-Object System.Object
    $UserObject | Add-Member -membertype NoteProperty -Name "DisplayName" -Value $displayname
    $resultsarray += $UserObject
}

$ResultsArray | Export-Csv "CompareResults.csv"