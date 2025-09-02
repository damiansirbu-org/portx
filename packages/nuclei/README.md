# Nuclei - Vulnerability Scanner

YAML-driven vulnerability scanner with 9000+ community templates for modern threat detection.

## Windows Defender Integration

**IMPORTANT:** Nuclei is often flagged as malware by Windows Defender due to its vulnerability scanning capabilities.

### Windows Defender Bypass

Run these commands in **PowerShell as Administrator**:

```powershell
# Exclude nuclei directory from scanning
Add-MpPreference -ExclusionPath "C:\App\Git\home\portx\packages\nuclei"

# Exclude nuclei executable from process monitoring
Add-MpPreference -ExclusionProcess "c:\App\Git\home\portx\packages\nuclei\nuclei.exe"
```

### Verification

After adding exclusions, verify they were applied:

```powershell
Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess
```

## Python Integration

Nuclei may require Python for certain templates and scripts:

### PORTX Python Runtime (Available)

Python is available in PORTX at: `/home/portx/packages/python-runtime/python`

```bash
# Verify Python is available  
/home/portx/packages/python-runtime/python --version

# Run nuclei with Python support
nuclei.exe -version
```

### Alternative: Micromamba Integration  

If using micromamba for additional packages:

```bash
# Activate Python environment
micromamba activate base

# Verify Python is available
python --version
```

## Usage Examples

```bash
# Basic vulnerability scan
nuclei.exe -target https://example.com

# Scan with specific templates
nuclei.exe -target https://example.com -t technologies/

# List available templates
nuclei.exe -tl
```

## Security Note

This tool is for **authorized security testing only**. Ensure you have proper permission before scanning any targets.

## Templates Location

Templates are downloaded to: `C:\Users\%USERNAME%\AppData\Roaming\nuclei\`