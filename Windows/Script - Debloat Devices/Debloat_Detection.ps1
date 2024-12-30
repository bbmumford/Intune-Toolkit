# Detection script to check if the DWORD registry value exists and is set to $true
$regPath = "HKLM:\Software\IntuneDependencies"
$regName = "RaphireDebloatCompleted"

if ((Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName -eq $true) {
    Write-Output "RaphireDebloatCompleted is set to $true."
    Exit 0
} else {
    Write-Output "RaphireDebloatCompleted is not set to $true or does not exist."
    Exit 1
}
