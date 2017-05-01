
$PrimaryData = Import-Csv "SQLResults.csv"
$SecondaryData =Import-Csv "SQLResults2.csv"

#Sample
#compare-object -referenceobject $(get-content C:\test\testfile1.txt) -differenceobject $(get-content C:\test\testfile2.txt

$CompareResults = compare-object -referenceobject $PrimaryData.displayname -differenceobject $SecondaryData.displayname

$CompareResults | select-object -Property @{N='Displayname';E={($_.InputObject)}}  | export-csv "CompareResults.csv"

    