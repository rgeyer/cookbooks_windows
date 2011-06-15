$filename = 'C:/powershell_scripts/sql/functions.ps1'

if(!(Test-Path $filename))
{
  Write-Error "The db_mssql Powershell script library was not installed.  Try running the db_mssql::default recipe then try again"
  exit 100
}
else
{
  . $filename
}

# For debugging/local testing purposes
#$env:SERVER = "localhost"
#$env:ENDPOINT_NAME = "mirror"
#$env:LISTEN_PORT = 5022
#$env:LISTEN_IP = "ALL"

# TODO: We're not really doing any error handling... And that's bad...

$conn_string = "server=$env:SERVER;database=master;trusted_connection=true;"
$server = New-Object "System.Data.SqlClient.SqlConnection" $conn_string
$server.Open()
$count = Sql-ExecuteScalar $server "SELECT COUNT(*) FROM master.sys.database_mirroring_endpoints"

if($count -gt 0)
{
    # Assuming that there's only one, since there should be only one per server
    # TODO: need to check for the other parameters (authentication, listen port/ip, encryption, etc) before deciding to overwrite
    $endpoint_name = Sql-ExecuteScalar "SELECT name FROM master.sys.database_mirroring_endpoints"
    if($endpoint_name -ne $env:ENDPOINT_NAME)
    {
        Write-Warning "Deleting all existing mirroring endpoints!"
        Sql-ExecuteNonQuery $server "DROP ENDPOINT $endpoint_name"
    }
    else
    {
        Write-Output "The endpoint ($env:ENDPOINT_NAME) already exists, skipping creation"
        Return 0
    }
}

# We'll only arrive here if there are were no endpoints, or the endpoint(s) that existed weren't the one requested

# TODO: Be more specific about authentication and encryption options. Probably want to create a mirroring service account
$query = @"
CREATE ENDPOINT {0}
    STATE=STARTED
    AS TCP(LISTENER_PORT={1}, LISTENER_IP={2})
    FOR DATABASE_MIRRORING(ROLE=PARTNER, AUTHENTICATION=CERTIFICATE {3})
"@ -f $env:ENDPOINT_NAME, $env:LISTEN_PORT, $env:LISTEN_IP, $env:CERT_NAME
Write-Output "Executing the following query to create a mirroring endpoint..."
Write-Output $query
Sql-ExecuteNonQuery $server $query

Return 0