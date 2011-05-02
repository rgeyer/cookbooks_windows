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

function Sql-ExecuteScalar([System.Data.SqlClient.SqlConnection]$server, [System.String]$query)
{
  if($server.State -ne [System.Data.ConnectionState]::Open)
  {
    $server.Open()
  }
  $cmd = New-Object "System.Data.SqlClient.SqlCommand"
  $cmd.Connection = $server
  $cmd.CommandType = [System.Data.CommandType]::Text
  $cmd.CommandText = $query
  $result = $cmd.ExecuteScalar()
  return $result
}

function Sql-ExecuteNonQuery([System.Data.SqlClient.SqlConnection]$server, [System.String]$query)
{
  if($server.State -ne [System.Data.ConnectionState]::Open)
  {
    $server.Open()
  }
  $cmd = New-Object "System.Data.SqlClient.SqlCommand"
  $cmd.Connection = $server
  $cmd.CommandType = [System.Data.CommandType]::Text
  $cmd.CommandText = $query
  $result = $cmd.ExecuteNonQuery()
  return $result
}