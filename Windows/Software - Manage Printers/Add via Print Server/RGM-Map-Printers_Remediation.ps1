Param
(
[Parameter(Mandatory=$true)]
[ValidateScript({If($_ -like "*.*"){$true}Else{Throw "$_ is not an FQDN. Please enter a FQDN."}})]
[string]
$PrintServerFQDN
,
[Parameter(Mandatory=$true)]
[string[]]
$PrinterShareNames=@()
,
[Parameter(Mandatory=$False)]
[switch]
$RemoveFirst
,
[Parameter(Mandatory=$False)]
[switch]
$RemoveOnly
)

# normalize the Print server FQDN
If ($PrintServerFQDN -notlike "\\*") {$PrintServerFQDN = "\\" + $PrintServerFQDN}

# Get the non FQDN name of the print server from the FQDN
$PrintServerName = $PrintServerFQDN.Split(".")[0]

# Remove printers
If (($RemoveFirst -eq $true) -Or ($RemoveOnly -eq $true)){
    Try {
        Foreach ($Printer in $PrinterShareNames){
            # Generate printer names
            $PrinterNameFQDN = $PrintServerFQDN + "\" + $Printer
            $PrinterName = $PrintServerName + "\" + $Printer

            # Remove Printer if it exists
            If (get-printer -Name $PrinterNameFQDN -ErrorAction SilentlyContinue) {Remove-Printer -Name $PrinterNameFQDN}
            If (get-printer -Name $PrinterName -ErrorAction SilentlyContinue) {Remove-Printer -Name $PrinterName}
        }
    }
    Catch {
        $ErrorMsg = $_.Exception.Message
        Write-Host "Printer removal error: $ErrorMsg"
    }
}

# (Re)Add printer
If ($RemoveOnly -eq $false){
    Try {
        Foreach ($Printer in $PrinterShareNames){
            # Generate correct printer name for (re)adding
            $PrinterNameFQDN = $PrintServerFQDN + "\" + $Printer

            # (Re)Add printer
            Add-Printer -ConnectionName $PrinterNameFQDN
        }
    }
    Catch {
        $ErrorMsg = $_.Exception.Message
        Write-Host "Printer add error: $ErrorMsg"
    }
}