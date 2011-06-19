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

function Local-Group-Members([String]$groupName, [String]$serverName)
{
  $grp = [ADSI]"WinNT://$serverName/$groupName, group"
  $retVal = @()

  foreach($member in $grp.psbase.Invoke("Members"))
  {
    $retVal += $member.GetType().InvokeMember("Name","GetProperty",$null,$member,$null)
  }
  return $retVal
}

function Create-Local-User([String]$username, [String]$password, [Array]$groups=@())
{
  $hostname = $env:COMPUTERNAME
  Write-Host "Creating or updating user $username"

  $objUser = $null
  if(!([ADSI]::Exists("WinNT://$hostname/$username")))
  {
    $objOu = [ADSI]"WinNT://$hostname"
    $objUser = $objOU.Create("User", $username)
  }
  else
  {
    $objUser = [ADSI]"WinNT://$hostname/$username, user"
  }

  $objUser.SetPassword($password)
  $objUser.SetInfo()
  $objUser.Description = $username
  $objUser.SetInfo()

  $wmiuser = gwmi -class "Win32_UserAccount" -filter "name='$username'"
  $wmiuser.PasswordExpires = $false
  $wmiuser.PasswordChangeable = $false
  $wmiuser.Put()

  foreach($group in $groups)
  {
      if(!([ADSI]::Exists("WinNT://$hostname/$group")))
      {
        Write-Host "The group ($group) did not exist, the user ($username) was not added"
      }
      else
      {
        $groupMembers = Local-Group-Members $group $hostname
        if($groupMembers -notcontains $username)
        {
          $objGroup = [ADSI]("WinNT://$hostname/$group,group")
          $objGroup.add("WinNT://$hostname/$username")
        }
      }
  }
}