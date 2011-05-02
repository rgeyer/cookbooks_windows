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

# http://technet.microsoft.com/en-us/library/ms174387.aspx

. 'C:/powershell_scripts/sql/functions.ps1'

$password = Get-NewResource password
$server_network_name = Get-NewResource server_network_name
$filename = Get-NewResource filename

$conn_string = "server=$server_network_name;database=master,trusted_connection=true"
$server = New-Object "System.Data.SqlClient.SqlConnection" $conn_string
$server.Open()

Sql-ExecuteNonQuery $server "DROP MASTER KEY"