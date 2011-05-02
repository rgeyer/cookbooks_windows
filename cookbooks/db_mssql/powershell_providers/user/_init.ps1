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

$filename = 'C:/powershell_scripts/sql/functions.ps1'

if(!(Test-Path $filename))
{
  Write-Error "The db_mssql Powershell script library was not installed.  Try running the db_mssql::default recipe then try again"
  exit 100
}
else
{
  Include $filename
}