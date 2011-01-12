####################################################################
#ScriptName : update-DNSAddress
#Created by : Chris Federico
#Date Created : 09/09/2008
#Modifications:
###################################################################
param ($forward,$reverse,$dnsaddresslist = (Import-Csv ".\dnsaddresslist.csv"),$help)

function funHelp()

{
$helpText=@”

NAME: Update-DNSAddress.ps1

DESCRIPTION:
Creates DNS entries from a csv file called dnsaddresslist.csv .It
Creates a Forward and Reverse lookup Zone entry in the zone
servers specified.

Prerequisites:
You should have a dnsaddresslist.csv file in the same directory as the script.
When the script starts it reads this file. An error will occur if the file
is not present.

PARAMETERS:
-forward specifies the forward lookup zone Server (required)
-reverse specifies the reverse lookup sone Server (required)
-help Prints Help File

OTHER:
-dnsaddresslist Holds dns entry information in the csv file

SYNTAX:
.\Update-DNSAddress.ps1 -forward ServerName -reverse ServerName

Creates forward and reverse entries from all devices listed
in dnsaddresslist.csv to the servers specified .

“@

$helpText
exit
}

function funCheck-DNSServersStatus ($forward,$Reverse)
{

Write-Host “Verifying if DNS Servers are Reachable…..”

# Create our object
$net = New-Object System.Net.NetworkInformation.Ping

#Check the Forward lookup Server
do {$result =$net.send($forward);}
until ($result.status -eq “Success”)

#Create message that Server is reachable

Write-Host “Forward lookup server ,$forward, is reachable …..”

#Check if the reverese Server is reachable .
do {$result =$net.send($reverse);}
until ($result.status -eq “Success”)

#Create message that the reverse lookup server is reachable

write-host “Reverse lookup server,$reverse,is reachable……”

}

function funUpdate-forward($forward,$dnsaddresslist)
{

# Domain Name
$strDomain =”Microsoft.com”

# create instance of ResourceRecord
$objRR = [WmiClass]“\\$forward\root\MicrosoftDNS:MicrosoftDNS_ResourceRecord”

# We have to read in the txt file split it to get IP address and Name

foreach($a in $dnsaddresslist)
{
Write-Host ” Updating forward lookup zone with $a” -ForegroundColor RED

#create our ip address variable
$address = $a.Address

#create our A name record
$name = $a.Name + “FQDNS_NAME”

# create our String for record creation
$strRR = $name + ” IN A $address”

#Update Record now
$objRR.CreateInstanceFromTextRepresentation($forward,$strDomain,$strRR)

}

}

function funUpdate-Reverse($reverse,$dnsaddresslist)
{

# create instance of ResourceRecord
$objRR = [WmiClass]“\\$reverse\root\MicrosoftDNS:MicrosoftDNS_ResourceRecord”

foreach ($a in $dnsaddresslist)
{

Write-Host “Updating Reverse Lookup zone with $a” -ForegroundColor Blue

#create our ip address variable
$raddress = $a.Address

#Get the name record
$rname = $a.Name

#break the address into octets
$breakaddress = $raddress.split(‘.’)

#create octets
$rFirst = $breakaddress[0] ; $rSecond = $breakaddress[1] ;$rThird = $breakaddress[2] ; $rFourth = $breakaddress[3]

#create the Reverse lookup String
$strReverseRR = “$rFourth”+”.”+”$rThird”+”.”+”$rSecond”+” IN PTR $rname.microsoft.com

$strReverseDomain = “$rFirst”+”.in-addr.arpa.”

#Call Create Method
$objRR.CreateInstanceFromTextRepresentation($reverse,$strReverseDomain,$strReverseRR)

}
}

#Check to see if help text is requested
if($help) { “Printing help now…”;funHelp}

#Check to see if forward and reverse arguments have been entered.
if(!$forward) {“You must Supply a forward lookup zone DNS server” ; funHelp}
if(!$reverse) {“You must Supply a reverse lookup zone DNS server” ; funhelp}

# Show the contents of the txt file and ask the user if they would like to continue
Write-Host “The following IP address/hosts will be entered in DNS.”

#contents file
$dnsaddresslist

#let the user make a descion if they would like to continue.
$decision = Read-Host “Would you like to continue Y or N–”

switch($decision.toupper())
{
Y{continue}
N{exit}
}

#Call to verify DNS Servers .
funCheck-DNSServersStatus $forward $reverse

#now that we have all the information lets update forward zone
funUpdate-forward $forward $dnsaddresslist

#update reverse zone
funUpdate-Reverse $reverse $dnsaddresslist