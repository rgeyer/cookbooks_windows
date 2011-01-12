Write-Output("***Starting the DCPromo.exe process")
start-process -FilePath "$env:windir\Sysnative\dcpromo.exe" -ArgumentList /answer:C:\answers.txt -Wait
del "C:\answers.txt"