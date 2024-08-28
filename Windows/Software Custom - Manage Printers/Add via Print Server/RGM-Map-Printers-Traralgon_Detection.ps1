# Set variable with printer names
$Printers = @("\\RGM-TGN1\Traralgon_Back_BW","\\RGM-TGN1\Traralgon_Back_Colour","\\RGM-TGN1\Traralgon_Front_BW","\\RGM-TGN1\Traralgon_Front_Colour")

# Check if printers are installed
Try{
    Foreach($Printer in $Printers){
        # Throw error is printer doesn't exist
        If (!(Get-Printer -Name $Printer -ErrorAction SilentlyContinue)){
            Write-Host "$Printer not found"
            Exit 1
        }
    }
    # If no errors exit with success message and exit code
    Write-Host "All printers detected"
    Exit 0
}
Catch {
    $ErrorMsg = $_.Exception.Message
    Write-Host "Printer detection error: $ErrorMsg"
    Exit 1
}