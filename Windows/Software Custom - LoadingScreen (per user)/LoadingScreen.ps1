<#
.SYNOPSIS
    Displays full-screen loading screen during device setup

.DESCRIPTION
    Shows a customizable full-screen XAML-based loading screen with company
    logo and progress indicators during device provisioning or enrollment.
    
    Provides visual feedback to users during Autopilot, Intune enrollment,
    or other lengthy setup processes. Screen automatically closes when
    setup is complete.
    
.NOTES
    FileName:    LoadingScreen.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     2.1
    
    Requirements:
    - PowerShell 5.0+
    - Run as: User
    - Context: 64 Bit
    - Windows 10/11
    - .NET Framework (PresentationFramework)
    
    Exit Codes:
    - 0: Screen displayed and closed successfully
    
    Configuration:
    - Customize XAML for branding (logo, colors, text)
    - Registry key controls screen dismissal
    - HKCU:\Software\Intune\LoadingScreen
    
    Impact:
    - Takes over full screen during setup
    - Prevents user interaction until dismissed
    - Used during Autopilot/Intune enrollment
    
    Change Log:
    v2.1 - Updated to use registry key for installation detection
    v1.0 - Initial release
#>

Add-Type -AssemblyName PresentationFramework

# Define the XAML for the window
$xaml = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
        WindowState='Maximized'
        WindowStyle='None'
        ResizeMode='NoResize'
        Topmost='True'
        Background='#0078D7'>
    <Window.Effect>
        <DropShadowEffect Color='Black' BlurRadius='20' ShadowDepth='0' Opacity='0.5'/>
    </Window.Effect>
    <Grid>
        <TextBlock Text='It&#39;s your first time logging in. Just a moment while the device is being configured...'
                   Foreground='White'
                   FontSize='48'
                   FontFamily='Segoe UI'
                   HorizontalAlignment='Center'
                   VerticalAlignment='Center'
                   Margin='0,0,0,150'/>
        <TextBlock Text='This process may take 1.5 hours and will reboot upon completion.'
                   Foreground='White'
                   Opacity='0.7'
                   FontSize='24'
                   FontFamily='Segoe UI'
                   HorizontalAlignment='Center'
                   VerticalAlignment='Bottom'
                   Margin='0,0,0,50'/>
    </Grid>
</Window>
"@

# Parse the XAML
Add-Type -AssemblyName System.IO
Add-Type -AssemblyName System.Xml

$reader = New-Object System.IO.StringReader($xaml)
$xmlReader = [System.Xml.XmlReader]::Create($reader)
$Window = [Windows.Markup.XamlReader]::Load($xmlReader)

# Define the KeyDown event handler function
function HandleWindowKeyDown {
    param ($windowSource, $keyEvent)
    if ($keyEvent.Key -eq [System.Windows.Input.Key]::M -and
        [System.Windows.Input.Keyboard]::Modifiers -eq ([System.Windows.Input.ModifierKeys]::Control -bor [System.Windows.Input.ModifierKeys]::Shift)) {
        $windowSource.Close()
    }
}

# Attach the KeyDown event handler to the Window
$Window.add_KeyDown({
    param ($windowSource, $keyEvent)
    HandleWindowKeyDown -windowSource $windowSource -keyEvent $keyEvent
})

# Schedule a restart after 1 hour and 30 minutes
$script = {
    # Define the registry key and value
    $regPath = "HKCU:\Software\Intune"
    $regName = "DeviceConfigurationComplete"

    # Check if registry path exists and create if not
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Create the registry value
    Set-ItemProperty -Path $regPath -Name $regName -Value $true -Force

    # Wait for 1 hour and 30 minutes (5400 seconds)
    Start-Sleep -Seconds 5400

    # Restart the computer
    Restart-Computer -Force
}

# Start the scheduled script block as a job
Start-Job -ScriptBlock $script

# Show the window
$Window.ShowDialog()
