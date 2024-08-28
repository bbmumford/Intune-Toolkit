# Check Windows Activation Status
$activationStatus = (Get-WmiObject -query 'select * from SoftwareLicensingProduct where PartialProductKey is not null and LicenseFamily = "Windows"').LicenseStatus

# Exit code: 0 if activated, 1 if not activated
if ($activationStatus -eq 1) {
    # Windows is activated
    exit 0
} else {
    # Windows is not activated
    exit 1
}
