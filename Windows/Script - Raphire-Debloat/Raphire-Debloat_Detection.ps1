Nee to change to REGKEY detection
if (Test-Path "C:\IntuneDependencies\Raphire-Debloat_Detection.txt") { 
	Write-Output "File exists."
	Exit 0
	} 

else { 
	Write-Output "File does not exist." 
	Exit 1
	}