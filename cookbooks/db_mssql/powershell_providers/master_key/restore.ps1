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

# http://technet.microsoft.com/en-us/library/ms186336.aspx

$password = Get-NewResource password
$server_network_name = Get-NewResource server_network_name
$filename = Get-NewResource filename
$overwrite = Get-NewResource overwrite

$conn_string = "Server=$server_network_name; Integrated Security=SSPI; Database=Master"
$server = New-Object "System.Data.SqlClient.SqlConnection" $conn_string
$server.Open()

$query = @"
RESTORE MASTER KEY FROM FILE = '{0}'
  DECRYPTION BY PASSWORD = '{1}'
  ENCRYPTION BY PASSWORD = '{1}'
"@ -f $filename, $password

if($overwrite)
{
  $query += " FORCE"
}

Sql-ExecuteNonQuery $server $query