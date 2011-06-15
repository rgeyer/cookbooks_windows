#  Copyright 2011 Ryan J. Geyer
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# http://technet.microsoft.com/en-us/library/ms187798.aspx

. 'C:/powershell_scripts/sql/functions.ps1'

$name = Get-NewResource name
$overwrite = Get-NewResource overwrite
$username = Get-NewResource username
$filename = Get-NewResource filename
$server_network_name = Get-NewResource server_network_name
$import_on_create = Get-NewResource import_on_create

$conn_string = "server=$server_network_name;database=master;trusted_connection=true;"
$server = New-Object "System.Data.SqlClient.SqlConnection" $conn_string
$server.Open()

$count = Sql-ExecuteScalar $server "SELECT count(*) FROM sys.certificates WHERE name = '$name'"
if($count -gt 0)
{
  if($overwrite)
  {
    Write-Warning "Overwrite was set to true, deleting the certificate named ($name)..."
    Sql-ExecuteNonQuery $server "DROP CERTIFICATE [$name]"
  }
  else
  {
    Write-Output "Certificate with the name ($name) already exists, skipping creation.."
    exit 0
  }
}

# We'll have returned or exitted by now if we weren't supposed to do this.
$query = "CREATE CERTIFICATE [$name]"

# Add an authorization
if(![String]::IsNullOrEmpty($username))
{
  $query += " AUTHORIZATION [$username]"
}

# Import an existing certificate
if(![String]::IsNullOrEmpty($filename) -and $import_on_create)
{
  $query += " FROM FILE = '$filename'"
}
else
{
  $query += " WITH SUBJECT = '$name generated from the Chef LWRP db_mssql_certificate'"
}

Sql-ExecuteNonQuery $server $query