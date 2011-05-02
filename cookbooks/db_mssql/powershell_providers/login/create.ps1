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

# http://msdn.microsoft.com/en-us/library/ms189751.aspx

. 'C:/powershell_scripts/sql/functions.ps1'

$login = Get-NewResource name
$password = Get-NewResource password
$overwrite = Get-NewResource overwrite
$server_network_name = Get-NewResource server_network_name

$conn_string = "server=$server_network_name;database=master,trusted_connection=true;"
$server = New-Object "System.Data.SqlClient.SqlConnection" $conn_string
$server.Open()

$count = Sql-ExecuteScalar $server "SELECT count(*) FROM sys.server_principals WHERE name = '$login'"
if($count -gt 0)
{
  if($overwrite)
  {
    Write-Warning "Overwrite was set to true, deleting the login named ($name)..."
    Sql-ExecuteNonQuery $server "DROP LOGIN [$name]"
  }
  else
  {
    Write-Output "Login with the name ($name) already exists, skipping creation.."
    exit 0
  }
}

Sql-ExecuteNonQuery $server "CREATE LOGIN [$login] WITH PASSWORD = '$password'"