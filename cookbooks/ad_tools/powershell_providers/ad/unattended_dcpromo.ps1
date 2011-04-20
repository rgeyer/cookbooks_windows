$answers_file = Get-NewResource answers_file
$binpath = Get-ChefNode mnt_utils, system32_dir

Write-Output("***Starting the DCPromo.exe process with answers file $answers_file")
start-process -FilePath "$binpath\dcpromo.exe" -ArgumentList /answer:C:\answers.txt -Wait
del "C:\answers.txt"