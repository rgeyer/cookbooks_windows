[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

# For debugging/local testing purposes
#$env:SERVER = "localhost"
#$env:ENDPOINT_NAME = "mirror"
#$env:LISTEN_PORT = 5022
#$env:LISTEN_IP = "ALL"

# TODO: We're not really doing any error handling... And that's bad...

$conn_string = "Server=$env:SERVER; Integrated Security=SSPI; Database=Master"
$server = New-Object "System.Data.SqlClient.SqlConnection" $conn_string
$server.Open()
$cmd = New-Object "System.Data.SqlClient.SqlCommand"
$cmd.CommandType = [System.Data.CommandType]::Text
$cmd.CommandText = "SELECT COUNT(*) FROM master.sys.database_mirroring_endpoints"
$cmd.Connection = $server
$count = $cmd.ExecuteScalar()

if($count -gt 0)
{
    # Assuming that there's only one, since there should be only one per server
    # TODO: need to check for the other parameters (authentication, listen port/ip, encryption, etc) before deciding to overwrite
    $cmd.CommandText = "SELECT name FROM master.sys.database_mirroring_endpoints"
    $endpoint_name = $cmd.ExecuteScalar()
    if($endpoint_name -ne $env:ENDPOINT_NAME)
    {
        Write-Warning "Deleting all existing mirroring endpoints!"
        $cmd.CommandText = "TRUNCATE TABLE master.sys.database_mirroring_endpoints"
        $cmd.ExecuteNonQuery()
    }
    else
    {
        Write-Output "The endpoint ($env:ENDPOINT_NAME) already exists, skipping creation"
        Return 0
    }
}

# We'll only arrive here if there are were no endpoints, or the endpoint(s) that existed weren't the one requested

# TODO: Be more specific about authentication and encryption options. Probably want to create a mirroring service account
$server.Close()
$server.Open()
$create_cmd = New-Object "System.Data.SqlClient.SqlCommand"
$create_cmd.CommandType = [System.Data.CommandType]::Text
$create_cmd.Connection = $server
$create_cmd.CommandText = @"
CREATE ENDPOINT {0}
    STATE=STARTED
    AS TCP(LISTENER_PORT={1}, LISTENER_IP={2})
    FOR DATA_MIRRORING(ROLE=PARTNER, AUTHENTICATION=WINDOWS NEGOTIATE, ENCRYPTION=REQUIRED ALGORITHM RC4)
"@ -f $env:ENDPOINT_NAME, $env:LISTEN_PORT, $env:LISTEN_IP
$create_cmd.ExecuteNonQuery()