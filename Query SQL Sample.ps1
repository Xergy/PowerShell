

function sql($sqlText, $database = "master", $server = ".")
{
    $connection = new-object System.Data.SqlClient.SQLConnection("Data Source=$server;Integrated Security=SSPI;Initial Catalog=$database");
    $cmd = new-object System.Data.SqlClient.SqlCommand($sqlText, $connection);

    $connection.Open();
    $reader = $cmd.ExecuteReader()

    $results = @()
    while ($reader.Read())
    {
        $row = @{}
        for ($i = 0; $i -lt $reader.FieldCount; $i++)
        {
            $row[$reader.GetName($i)] = $reader.GetValue($i)
        }
        $results += new-object psobject -property $row            
    }
    $connection.Close();

    $results
}


$SQlResults = sql "SELECT TOP 100 displayName FROM [FimSynchronizationService].[dbo].[mms_metaverse]" FimSynchronizationService "NEDIACAMS0001N\INSTANCE4"

$SQlResults | Export-Csv "SQLResults.csv"