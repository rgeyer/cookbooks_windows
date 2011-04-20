$answers_file = Get-NewResource answers_file
Write-Output("***Starting the DCPromo.exe process with answers file $answers_file")
start-process -FilePath "$env:windir\Sysnative\dcpromo.exe" -ArgumentList /answer:C:\answers.txt -Wait
del "C:\answers.txt"