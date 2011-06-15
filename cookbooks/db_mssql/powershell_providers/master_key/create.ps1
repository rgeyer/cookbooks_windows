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

# http://technet.microsoft.com/en-us/library/ms174382.aspx

. 'C:/powershell_scripts/sql/functions.ps1'

$password = Get-NewResource password
$overwrite = Get-NewResource overwrite
$server_network_name = Get-NewResource server_network_name

$conn_string = "server=$server_network_name;database=master;trusted_connection=true;"
$server = New-Object "System.Data.SqlClient.SqlConnection" $conn_string
$server.Open()

$count = Sql-ExecuteScalar $server "SELECT count(*) FROM sys.key_encryptions"
if($count -gt 0)
{
  if($overwrite)
  {
    Write-Warning "Overwrite was set to true, deleting existing master encryption key..."
    Sql-ExecuteNonQuery $server "DROP MASTER KEY"
  }
  else
  {
    Write-Output "Master encryption key already exists, skipping creation.."
    exit 0
  }
}

# We'll have returned or exitted by now if we weren't supposed to do this.
Sql-ExecuteNonQuery $server "CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$password'"