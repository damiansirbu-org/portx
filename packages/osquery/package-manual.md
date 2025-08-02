# OSQuery Package Manual

## Package Information
- **Package Name**: osquery
- **Category**: Security Tools
- **Type**: SQL-based Operating System Instrumentation
- **License**: Apache 2.0 / BSD

## Description
SQL-based operating system instrumentation framework for security monitoring and compliance.

OSQuery exposes operating system data as high-performance relational database tables, enabling real-time queries for security monitoring, incident response, and compliance auditing.
Provides comprehensive system visibility through standardized SQL interface across Windows, macOS, and Linux platforms.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| osqueryi.exe | Interactive OSQuery shell | SQL queries against system data |
| osqueryd.exe | OSQuery daemon service | Background monitoring and logging |
| manage-osqueryd.ps1 | Windows service management | Install/configure OSQuery service |
| osquery_utils.ps1 | Utility scripts | Configuration and maintenance helpers |

## System Tables Overview

### Process and Network Monitoring
- **processes** - Running processes with command lines, PIDs, and resource usage
- **listening_ports** - Open network ports and associated processes
- **process_open_sockets** - Network connections by process
- **arp_cache** - ARP table entries for network discovery
- **routes** - System routing table information

### File System and Registry
- **file** - File metadata, hashes, and attributes
- **hash** - File cryptographic hashes (MD5, SHA1, SHA256)
- **registry** - Windows registry keys and values
- **ntfs_journal_events** - NTFS file system change events
- **file_events** - Real-time file system monitoring

### User and Authentication
- **users** - System user accounts and properties
- **logged_in_users** - Currently logged-in users
- **last** - User login/logout history
- **user_groups** - User group memberships
- **logon_sessions** - Active Windows logon sessions

### System Configuration
- **system_info** - Hardware and OS information
- **services** - Windows services status and configuration
- **startup_items** - Programs that start automatically
- **installed_applications** - Installed software inventory
- **patches** - System patches and updates

### Security and Compliance
- **windows_events** - Windows Event Log entries
- **certificates** - Digital certificates on system
- **bitlocker_info** - BitLocker encryption status
- **windows_security_products** - Antivirus and security software
- **process_memory_map** - Process memory mappings for analysis

## Common Usage Examples

### Interactive Security Queries
```sql
-- Find processes listening on network ports
SELECT DISTINCT p.name, p.pid, p.path, lp.port, lp.protocol
FROM processes p 
JOIN listening_ports lp ON p.pid = lp.pid
WHERE lp.port < 1024;

-- Detect unusual network connections
SELECT pos.pid, p.name, pos.remote_address, pos.remote_port
FROM process_open_sockets pos
JOIN processes p ON pos.pid = p.pid
WHERE pos.remote_address NOT LIKE '10.%'
  AND pos.remote_address NOT LIKE '192.168.%'
  AND pos.remote_address NOT LIKE '172.%'
  AND pos.remote_address != '127.0.0.1';

-- Check for unauthorized USB devices
SELECT vendor, model, serial, removable
FROM usb_devices
WHERE removable = 1;
```

### System Inventory and Compliance
```sql
-- Software inventory audit
SELECT name, version, install_date, publisher
FROM programs
WHERE name LIKE '%Adobe%' OR name LIKE '%Java%' OR name LIKE '%Chrome%'
ORDER BY install_date DESC;

-- Check Windows Update status
SELECT title, date_posted, status
FROM windows_updates
WHERE status = 'Available'
ORDER BY date_posted DESC;

-- Verify security product status
SELECT type, name, state, signatures_up_to_date
FROM windows_security_products
WHERE state != 'On';
```

### User Activity Monitoring
```sql
-- Recent user logins
SELECT username, time, type, host
FROM last
WHERE time > (strftime('%s', 'now') - 86400)
ORDER BY time DESC;

-- Check administrative privileges
SELECT u.username, ug.groupname
FROM users u
JOIN user_groups ug ON u.uid = ug.uid
WHERE ug.groupname IN ('Administrators', 'Domain Admins', 'Enterprise Admins');

-- Monitor privileged process execution
SELECT name, pid, uid, gid, cmdline, start_time
FROM processes
WHERE uid = 0 OR gid = 0
ORDER BY start_time DESC;
```

## Advanced Security Monitoring

### Threat Hunting Queries
```sql
-- Detect potential persistence mechanisms
SELECT key, name, data
FROM registry
WHERE key LIKE '%Run%' OR key LIKE '%Service%'
  AND name NOT IN (
    'Windows Security Health Service',
    'Windows Defender',
    'SecurityHealthSystray'
  );

-- Find suspicious process patterns
SELECT name, pid, parent, cmdline, path
FROM processes
WHERE (cmdline LIKE '%powershell%' AND cmdline LIKE '%encoded%')
   OR (cmdline LIKE '%cmd%' AND cmdline LIKE '%/c%')
   OR (path LIKE '%temp%' OR path LIKE '%appdata%')
ORDER BY start_time DESC;

-- Check for unsigned executables
SELECT p.name, p.path, f.size, h.sha256
FROM processes p
JOIN file f ON p.path = f.path
LEFT JOIN hash h ON p.path = h.path
LEFT JOIN authenticode a ON p.path = a.path
WHERE a.result != 'trusted';
```

### Network Security Analysis
```sql
-- Analyze DNS queries for suspicious domains
SELECT name, type, class, rcode, answer
FROM dns_cache
WHERE name LIKE '%.tk' OR name LIKE '%.ml' OR name LIKE '%.ga'
   OR name LIKE '%malware%' OR name LIKE '%suspicious%';

-- Monitor outbound connections to external IPs
SELECT DISTINCT pos.remote_address, 
       COUNT(*) as connection_count,
       GROUP_CONCAT(DISTINCT p.name) as processes
FROM process_open_sockets pos
JOIN processes p ON pos.pid = p.pid
WHERE pos.remote_address NOT LIKE '10.%'
  AND pos.remote_address NOT LIKE '192.168.%'
  AND pos.remote_address NOT LIKE '172.%'
  AND pos.remote_address != '127.0.0.1'
GROUP BY pos.remote_address
HAVING connection_count > 5;

-- Check for proxy or VPN software
SELECT name, publisher, install_date
FROM programs
WHERE name LIKE '%VPN%' OR name LIKE '%proxy%' 
   OR name LIKE '%Tor%' OR name LIKE '%tunnel%';
```

### File System Security
```sql
-- Monitor critical file changes
SELECT target_path, action, time, source, md5, sha256
FROM file_events
WHERE target_path LIKE 'C:\Windows\System32\%'
   OR target_path LIKE 'C:\Program Files\%'
   AND action IN ('CREATED', 'UPDATED', 'MOVED_TO');

-- Find files with suspicious extensions in user directories
SELECT path, size, ctime, mtime, md5
FROM file
WHERE path LIKE 'C:\Users\%\%'
  AND (path LIKE '%.exe' OR path LIKE '%.scr' OR path LIKE '%.bat')
  AND path NOT LIKE '%Program Files%'
  AND path NOT LIKE '%Windows%';

-- Detect hidden files and directories
SELECT path, directory, filename, attributes
FROM file
WHERE attributes LIKE '%hidden%'
  AND path LIKE 'C:\Users\%\%'
  AND filename NOT LIKE 'desktop.ini'
  AND filename NOT LIKE 'thumbs.db';
```

## Configuration Management

### Query Configuration (osquery.conf)
```json
{
  "options": {
    "config_plugin": "filesystem",
    "logger_plugin": "filesystem",
    "logger_path": "C:\\Program Files\\osquery\\log",
    "database_path": "C:\\Program Files\\osquery\\osquery.db",
    "verbose": false,
    "worker_threads": 2,
    "enable_monitor": true,
    "disable_events": false,
    "events_expiry": 3600,
    "schedule_splay_percent": 10
  },
  "schedule": {
    "system_info": {
      "query": "SELECT hostname, cpu_brand, physical_memory FROM system_info;",
      "interval": 3600
    },
    "running_processes": {
      "query": "SELECT pid, name, cmdline, cwd, root FROM processes;",
      "interval": 600
    },
    "listening_ports": {
      "query": "SELECT pid, port, protocol, family, address FROM listening_ports;",
      "interval": 600
    },
    "logged_in_users": {
      "query": "SELECT user, host, time, pid FROM logged_in_users;",
      "interval": 600
    },
    "installed_applications": {
      "query": "SELECT name, version, publisher, install_date FROM programs;",
      "interval": 3600
    }
  },
  "packs": {
    "incident-response": "C:\\Program Files\\osquery\\packs\\incident-response.conf",
    "it-compliance": "C:\\Program Files\\osquery\\packs\\it-compliance.conf",
    "vuln-management": "C:\\Program Files\\osquery\\packs\\vuln-management.conf",
    "windows-hardening": "C:\\Program Files\\osquery\\packs\\windows-hardening.conf"
  }
}
```

### Service Management Scripts
```powershell
# manage-osqueryd.ps1 - Service Management
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("install", "start", "stop", "restart", "uninstall", "status")]
    [string]$Action,
    
    [string]$ConfigPath = "C:\Program Files\osquery\osquery.conf"
)

switch ($Action) {
    "install" {
        Write-Host "Installing OSQuery service..."
        & "C:\Program Files\osquery\osqueryd.exe" --install --config_path=$ConfigPath
    }
    "start" {
        Write-Host "Starting OSQuery service..."
        Start-Service -Name "osqueryd"
    }
    "stop" {
        Write-Host "Stopping OSQuery service..."
        Stop-Service -Name "osqueryd"
    }
    "restart" {
        Write-Host "Restarting OSQuery service..."
        Restart-Service -Name "osqueryd"
    }
    "uninstall" {
        Write-Host "Uninstalling OSQuery service..."
        Stop-Service -Name "osqueryd" -ErrorAction SilentlyContinue
        & "C:\Program Files\osquery\osqueryd.exe" --uninstall
    }
    "status" {
        Get-Service -Name "osqueryd" | Format-Table -AutoSize
        Write-Host "`nService Details:"
        Get-WmiObject Win32_Service | Where-Object {$_.Name -eq "osqueryd"} | 
            Select-Object Name, State, StartMode, ProcessId, PathName
    }
}
```

## Security Pack Configurations

### Incident Response Pack
```json
{
  "queries": {
    "suspicious_processes": {
      "query": "SELECT name, pid, parent, cmdline, cwd, uid, gid FROM processes WHERE name IN ('nc', 'netcat', 'ncat', 'telnet', 'socat') OR cmdline LIKE '%powershell%' AND cmdline LIKE '%invoke%';",
      "interval": 300,
      "description": "Detect potentially suspicious process execution"
    },
    "network_anomalies": {
      "query": "SELECT pos.pid, p.name, pos.local_address, pos.local_port, pos.remote_address, pos.remote_port FROM process_open_sockets pos JOIN processes p ON pos.pid = p.pid WHERE pos.remote_port IN (4444, 5555, 6666, 7777, 8888, 9999);",
      "interval": 300,
      "description": "Monitor connections to common backdoor ports"
    },
    "file_integrity": {
      "query": "SELECT target_path, md5, sha256, action, time FROM file_events WHERE target_path IN ('/etc/passwd', '/etc/shadow', 'C:\\Windows\\System32\\drivers\\etc\\hosts', 'C:\\Windows\\System32\\config\\SAM');",
      "interval": 60,
      "description": "Monitor critical system file changes"
    },
    "login_anomalies": {
      "query": "SELECT username, time, host, pid FROM last WHERE time > (strftime('%s', 'now') - 3600) AND username NOT IN ('admin', 'administrator', 'service_account');",
      "interval": 600,
      "description": "Detect unusual login patterns"
    }
  }
}
```

### Compliance Monitoring Pack
```json
{
  "queries": {
    "patch_compliance": {
      "query": "SELECT title, date_posted, status FROM windows_updates WHERE status = 'Available' AND date_posted < date('now', '-30 days');",
      "interval": 3600,
      "description": "Check for outdated security patches"
    },
    "software_inventory": {
      "query": "SELECT name, version, publisher, install_date FROM programs WHERE name LIKE '%Java%' OR name LIKE '%Adobe%' OR name LIKE '%Flash%';",
      "interval": 86400,
      "description": "Monitor vulnerable software versions"
    },
    "user_privileges": {
      "query": "SELECT u.username, ug.groupname FROM users u JOIN user_groups ug ON u.uid = ug.uid WHERE ug.groupname IN ('Administrators', 'Domain Admins', 'Power Users');",
      "interval": 3600,
      "description": "Audit administrative privileges"
    },
    "encryption_status": {
      "query": "SELECT drive_letter, encryption_method, conversion_status, lock_status FROM bitlocker_info;",
      "interval": 86400,
      "description": "Monitor disk encryption compliance"
    }
  }
}
```

## Enterprise Deployment

### Centralized Logging Setup
```bash
#!/bin/bash
# Deploy OSQuery with centralized logging

# Configure rsyslog for OSQuery
cat > /etc/rsyslog.d/60-osquery.conf << EOF
# OSQuery logging configuration
template(name="OsqueryCsvFormat" type="string" string="%timestamp:::date-rfc3339%,%hostname%,%syslogtag%,%msg%\n")
*.info;mail.none;authpriv.none;cron.none    /var/log/osquery/osquery.log;OsqueryCsvFormat
& stop
EOF

# Restart rsyslog
systemctl restart rsyslog

# Configure log rotation
cat > /etc/logrotate.d/osquery << EOF
/var/log/osquery/*.log {
    daily
    missingok
    rotate 30
    compress
    notifempty
    create 640 root root
    postrotate
        /bin/systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
EOF
```

### SIEM Integration Examples
```sql
-- Generate SIEM-friendly output format
.mode csv
.headers on
.output security_events.csv

SELECT 
    datetime('now') as timestamp,
    'osquery' as source,
    'process_monitoring' as event_type,
    name as process_name,
    pid,
    parent as parent_pid,
    cmdline as command_line,
    path as executable_path,
    uid as user_id
FROM processes 
WHERE start_time > (strftime('%s', 'now') - 3600);

-- Export to JSON for modern SIEM platforms
.mode json
.output network_connections.json

SELECT 
    json_object(
        'timestamp', datetime('now'),
        'event_type', 'network_connection',
        'process_name', p.name,
        'pid', pos.pid,
        'local_address', pos.local_address,
        'local_port', pos.local_port,
        'remote_address', pos.remote_address,
        'remote_port', pos.remote_port,
        'protocol', pos.protocol
    ) as event_data
FROM process_open_sockets pos
JOIN processes p ON pos.pid = p.pid;
```

### Automated Threat Response
```powershell
# PowerShell script for automated incident response
param(
    [string]$ThreatIndicator,
    [string]$ResponseAction = "log"
)

# Query OSQuery for threat indicators
$Query = @"
SELECT pid, name, cmdline, path 
FROM processes 
WHERE cmdline LIKE '%$ThreatIndicator%' 
   OR path LIKE '%$ThreatIndicator%'
   OR name LIKE '%$ThreatIndicator%';
"@

$Results = & "C:\Program Files\osquery\osqueryi.exe" --json $Query | ConvertFrom-Json

foreach ($Process in $Results) {
    $Alert = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ThreatType = "Suspicious Process"
        ProcessName = $Process.name
        ProcessID = $Process.pid
        CommandLine = $Process.cmdline
        ExecutablePath = $Process.path
        Action = $ResponseAction
    }
    
    # Log to security event log
    Write-EventLog -LogName Security -Source "OSQuery-ThreatHunting" -EventId 5001 -EntryType Warning -Message ($Alert | ConvertTo-Json)
    
    # Take response action
    switch ($ResponseAction) {
        "kill" {
            Write-Host "Terminating suspicious process $($Process.name) (PID: $($Process.pid))"
            Stop-Process -Id $Process.pid -Force -ErrorAction SilentlyContinue
        }
        "quarantine" {
            Write-Host "Quarantining executable: $($Process.path)"
            # Move file to quarantine directory
            $QuarantinePath = "C:\Quarantine\$(Get-Date -Format 'yyyyMMdd')"
            New-Item -ItemType Directory -Path $QuarantinePath -Force
            Move-Item -Path $Process.path -Destination $QuarantinePath -Force -ErrorAction SilentlyContinue
        }
        "log" {
            Write-Host "Threat logged: $($Process.name) with indicator: $ThreatIndicator"
        }
    }
}
```

## Performance Optimization

### Query Performance Tuning
```sql
-- Use indexes for better performance
CREATE INDEX idx_processes_name ON processes(name);
CREATE INDEX idx_file_events_time ON file_events(time);

-- Optimize queries with proper WHERE clauses
SELECT name, pid FROM processes 
WHERE name = 'svchost.exe'  -- Exact match is faster
LIMIT 100;  -- Limit results for large tables

-- Use JOINs efficiently
SELECT p.name, f.path, f.size
FROM processes p
JOIN file f ON p.path = f.path
WHERE p.start_time > (strftime('%s', 'now') - 3600);
```

### Resource Management
```json
{
  "options": {
    "worker_threads": 4,
    "enable_numeric_monitoring": true,
    "numeric_monitoring_filesystem": true,
    "numeric_monitoring_pre_aggregation": true,
    "enable_file_events": false,
    "enable_process_events": true,
    "events_max": 1000,
    "events_expiry": 7200,
    "schedule_timeout": 60,
    "schedule_max_drift": 60
  }
}
```

## Use Cases

### Security Operations Center (SOC)
- Real-time threat detection and incident response
- Behavioral analysis and anomaly detection
- Compliance monitoring and audit trail generation
- Forensic investigation and evidence collection

### IT Operations and Management
- Asset inventory and configuration management
- Software license compliance and vulnerability management
- Performance monitoring and capacity planning
- Change detection and configuration drift analysis

### Endpoint Detection and Response (EDR)
- Continuous endpoint monitoring and logging
- Advanced threat hunting and investigation
- Malware detection and analysis
- Network traffic analysis and monitoring

### Compliance and Governance
- Regulatory compliance reporting (SOX, HIPAA, PCI-DSS)
- Security control validation and testing
- Data governance and privacy monitoring
- Risk assessment and management

## Installation
SQL-based operating system instrumentation for comprehensive security monitoring.
Essential tool for threat hunting, compliance auditing, and system visibility.

## Dependencies
- Windows 10/11 or Windows Server 2016+ (for Windows deployment)
- Administrative privileges for system-level monitoring
- Network connectivity for centralized logging (optional)
- Sufficient disk space for database and log storage

## Security Considerations
- Requires elevated privileges for complete system visibility
- Log data may contain sensitive system information
- Database encryption recommended for compliance environments
- Network communications should use TLS/SSL encryption

---
*Part of PORTX Portable Development Environment*