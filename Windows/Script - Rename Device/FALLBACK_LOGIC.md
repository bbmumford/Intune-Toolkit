# Device Identifier Fallback Logic

## Overview

All three scripts (standalone, detection, remediation) use the same fallback hierarchy to ensure devices can always be renamed, even if they lack a valid BIOS serial number.

## Fallback Hierarchy

### 1️⃣ **Primary: BIOS Serial Number** (Default)

**Source:** `Win32_BIOS.SerialNumber`

**Best for:**
- Physical devices
- Most Dell, HP, Lenovo, Microsoft Surface devices
- Any device with proper BIOS/UEFI serial

**Example:**
```
BIOS Serial: ABC12345678
Result: ACME-ABC12345678
```

---

### 2️⃣ **Fallback 1: UUID** (Computer System Product)

**Source:** `Win32_ComputerSystemProduct.UUID` (last 12 characters)

**Triggered when:** BIOS serial is empty or invalid

**Best for:**
- Virtual machines (VMware, Hyper-V)
- Devices with missing BIOS serial
- Cloud instances (Azure VMs, AWS EC2)

**Example:**
```
UUID: 12345678-90AB-CDEF-1234-567890ABCDEF
Extracted: 567890ABCDEF
Result: ACME-567890ABCDEF
```

**Note:** UUIDs are guaranteed unique per VM/device

---

### 3️⃣ **Fallback 2: MAC Address** (Network Adapter)

**Source:** `Win32_NetworkAdapterConfiguration.MACAddress` (first enabled adapter)

**Triggered when:** BIOS serial AND UUID are unavailable

**Best for:**
- Network-connected devices
- VMs without proper UUID
- Devices with network adapters

**Example:**
```
MAC Address: 00:15:5D:01:02:03
Sanitized: 00155D010203
Result: ACME-00155D010203
```

**Note:** Uses first enabled network adapter with IP

---

### 4️⃣ **Fallback 3: Random Identifier** (Last Resort)

**Source:** Random 8-character alphanumeric string with "UN" prefix

**Triggered when:** All hardware identifiers fail

**Best for:**
- Edge cases with minimal hardware info
- Temporary/disposable systems
- Unusual device configurations

**Example:**
```
Generated: UN + 8 random characters
Possible Results: UN1A2B3C4D, UNEF5678AB, UN9Z4K7M2P
Final Name: ACME-UN1A2B3C4D
```

**UN Meaning:** "Unknown" - indicates device lacks standard hardware identifiers

**⚠️ Important Notes:**
- Each script run generates a **NEW** random identifier
- Not suitable for production environments (name changes on each detection)
- **Use only when hardware identifiers cannot be obtained**
- Indicates the device needs investigation/configuration
- Consider manually setting proper UUID/serial in BIOS/hypervisor

---

## Script Output Examples

### Successful Primary Method
```
[2025-10-16 14:30:15] [Info] Retrieving device serial number...
[2025-10-16 14:30:15] [Info] Retrieved serial number: ABC12345678
[2025-10-16 14:30:15] [Info] Proposed new computer name: ACME-ABC12345678
```

### Fallback to UUID
```
[2025-10-16 14:30:15] [Info] Retrieving device serial number...
[2025-10-16 14:30:15] [Warning] BIOS serial number is empty or invalid, trying fallback methods...
[2025-10-16 14:30:15] [Info] Using UUID-based identifier: 567890ABCDEF
[2025-10-16 14:30:15] [Info] Proposed new computer name: ACME-567890ABCDEF
```

### Fallback to MAC Address
```
[2025-10-16 14:30:15] [Info] Retrieving device serial number...
[2025-10-16 14:30:15] [Warning] BIOS serial number is empty or invalid, trying fallback methods...
[2025-10-16 14:30:15] [Info] Using MAC address-based identifier: 00155D010203
[2025-10-16 14:30:15] [Info] Proposed new computer name: ACME-00155D010203
```

### Fallback to Generated Random ID
```
[2025-10-16 14:30:15] [Info] Retrieving device serial number...
[2025-10-16 14:30:15] [Warning] BIOS serial number is empty or invalid, trying fallback methods...
[2025-10-16 14:30:15] [Warning] All hardware identifiers unavailable, generating random identifier
[2025-10-16 14:30:15] [Warning] Using generated identifier: UN1A2B3C4D (UN = Unknown device)
[2025-10-16 14:30:15] [Info] Proposed new computer name: ACME-UN1A2B3C4D
```

**⚠️ Note:** Random identifiers change on each script run, so devices using this fallback will be detected as non-compliant repeatedly until proper hardware identifiers are configured.

---

## Testing Fallback Methods

### Test on Physical Device (Should Use Serial)
```powershell
.\Rename-Device.ps1 -OrgShort "TEST"
# Expected: Uses BIOS serial number
```

### Test on Virtual Machine (May Use UUID or MAC)
```powershell
# On Hyper-V/VMware VM
.\Rename-Device.ps1 -OrgShort "TEST"
# Expected: Uses UUID (fallback 1) or MAC (fallback 2)
```

### Check Current Identifier Type
```powershell
# Run this to see what identifier your device has
$bios = (Get-CimInstance Win32_BIOS).SerialNumber
$uuid = (Get-CimInstance Win32_ComputerSystemProduct).UUID
$mac = (Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled} | Select-Object -First 1).MACAddress

Write-Host "BIOS Serial: $bios"
Write-Host "UUID: $uuid"
Write-Host "MAC: $mac"
```

---

## Consistency Guarantee

**All three scripts use identical fallback logic:**
- ✅ `Rename-Device.ps1` (standalone)
- ✅ `DeviceRename_Detection.ps1` (remediation detection)
- ✅ `DeviceRename_Remediation.ps1` (remediation action)

This ensures:
- Detection script calculates the same expected name
- Remediation script renames to the same name
- No conflicts between detection and remediation
- Devices renamed once stay compliant

---

## Device Type Recommendations

| Device Type | Primary Method | Typical Fallback | Notes |
|------------|----------------|------------------|-------|
| **Dell/HP/Lenovo Desktop** | BIOS Serial | N/A | Works with serial 99% of time |
| **Microsoft Surface** | BIOS Serial | N/A | Has valid serial number |
| **Hyper-V VM** | UUID | MAC if no UUID | Hyper-V provides UUID |
| **VMware VM** | UUID | MAC if no UUID | VMware provides UUID |
| **VirtualBox VM** | UUID | MAC if no UUID | VirtualBox provides UUID |
| **Azure VM** | UUID | MAC | Azure VMs have UUID |
| **AWS EC2** | UUID | MAC | EC2 instances have UUID |
| **Generic VM** | MAC Address | Generated Hash | If UUID not configured |
| **Custom Build PC** | BIOS Serial | UUID/MAC | Depends on motherboard |

---

## Troubleshooting

### Device keeps getting renamed on every run

**Cause:** Detection and remediation may be using different fallback methods

**Solution:**
1. Check logs to see which identifier is being used
2. Ensure all scripts are version 1.1+
3. Verify scripts have identical fallback logic

### Different VMs getting the same name

**Cause:** Only possible with Fallback 3 (random identifier) if scripts run simultaneously

**Solution:**
- Ensure VMs have proper UUID configured in hypervisor
- VMs should automatically use UUID (Fallback 1) which is unique
- Random identifiers are generated fresh each time, so collision is extremely unlikely

### Device name keeps changing

**Cause:** Device is using Fallback 3 (random identifier) which generates a new ID on each run

**Solution:**
- **This indicates a problem** - device lacks proper hardware identifiers
- Check device logs to see "UN" prefix in name (e.g., `ACME-UN1A2B3C4D`)
- Configure proper UUID or serial number in BIOS/hypervisor settings
- For VMs: Ensure UUID is enabled in hypervisor configuration
- For physical devices: Update BIOS firmware or contact manufacturer

### Name changes after network adapter replacement

**Cause:** Device was using MAC address (Fallback 2) as identifier

**Solution:**
- This is expected behavior if MAC was the identifier
- Device will be renamed to new MAC-based name
- Consider configuring proper UUID in BIOS/hypervisor settings

---

## Security Considerations

**Identifier Predictability:**

| Method | Predictable? | Unique? | Persistent? |
|--------|--------------|---------|-------------|
| BIOS Serial | ❌ No | ✅ Yes | ✅ Yes |
| UUID | ❌ No | ✅ Yes | ✅ Yes |
| MAC Address | ⚠️ Somewhat | ✅ Yes* | ⚠️ No** |
| Random (UN prefix) | ✅ Yes*** | ❌ No**** | ❌ No***** |

*Unique per network adapter  
**Changes if NIC is replaced  
***Random = always different on each run  
****Different every time = not unique to device  
*****Changes on every detection/remediation run

**Recommendation:** Configure proper BIOS serial or UUID for production devices. Random identifiers should trigger investigation.
