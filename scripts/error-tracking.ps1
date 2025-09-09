# Error Tracking and Logging System
# Centralized error logging and alert system for the backup system

param(
    [string]$LogLevel = "INFO",
    [string]$Message = "",
    [string]$Component = "BackupSystem",
    [switch]$Alert = $false
)

# Logging configuration
$LogConfig = @{
    LogDirectory = ".backup-logs"
    MaxLogFiles = 10
    MaxLogSizeMB = 5
    LogFormat = "JSON"
    AlertThresholds = @{
        ErrorsPerHour = 10
        CriticalErrors = 1
        WarningsPerHour = 50
    }
}

# Ensure log directory exists
if (-not (Test-Path $LogConfig.LogDirectory)) {
    New-Item -ItemType Directory -Path $LogConfig.LogDirectory -Force | Out-Null
}

function Write-StructuredLog {
    param(
        [string]$Level,
        [string]$Message,
        [string]$Component,
        [hashtable]$Metadata = @{}
    )
    
    $logEntry = @{
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        level = $Level.ToUpper()
        component = $Component
        message = $Message
        metadata = $Metadata
        machine = $env:COMPUTERNAME
        user = $env:USERNAME
        pid = $PID
    }
    
    # Add Git context if in a Git repository
    if (Test-Path ".git") {
        try {
            $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
            $gitCommit = git rev-parse --short HEAD 2>$null
            if ($LASTEXITCODE -eq 0) {
                $logEntry.git = @{
                    branch = $gitBranch
                    commit = $gitCommit
                }
            }
        }
        catch {
            # Ignore Git errors
        }
    }
    
    # Convert to JSON
    $jsonLog = $logEntry | ConvertTo-Json -Compress
    
    # Write to current log file
    $logFile = Join-Path $LogConfig.LogDirectory "backup-system-$(Get-Date -Format 'yyyy-MM-dd').log"
    $jsonLog | Add-Content -Path $logFile -Encoding UTF8
    
    # Also display to console with color coding
    $color = switch ($Level.ToUpper()) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" } 
        "INFO" { "Green" }
        "DEBUG" { "Gray" }
        default { "White" }
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Level - $Component: $Message" -ForegroundColor $color
    
    return $logEntry
}

function Get-LogAnalytics {
    Write-Host "📊 Analyzing logs..." -ForegroundColor Cyan
    
    $logFiles = Get-ChildItem -Path $LogConfig.LogDirectory -Filter "*.log" | Sort-Object LastWriteTime -Descending
    $analytics = @{
        TotalEntries = 0
        ErrorCount = 0
        WarningCount = 0
        InfoCount = 0
        RecentErrors = @()
        TopComponents = @{}
        HourlyStats = @{}
    }
    
    $cutoffTime = (Get-Date).AddHours(-24)
    
    foreach ($logFile in $logFiles | Select-Object -First 5) {
        try {
            $logContent = Get-Content $logFile.FullName | ForEach-Object {
                try {
                    $_ | ConvertFrom-Json
                }
                catch {
                    # Skip invalid JSON lines
                }
            }
            
            foreach ($entry in $logContent) {
                if (-not $entry.timestamp) { continue }
                
                $entryTime = [DateTime]::Parse($entry.timestamp)
                if ($entryTime -lt $cutoffTime) { continue }
                
                $analytics.TotalEntries++
                
                # Count by level
                switch ($entry.level) {
                    "ERROR" { 
                        $analytics.ErrorCount++
                        $analytics.RecentErrors += $entry
                    }
                    "WARN" { $analytics.WarningCount++ }
                    "INFO" { $analytics.InfoCount++ }
                }
                
                # Count by component
                if ($analytics.TopComponents.ContainsKey($entry.component)) {
                    $analytics.TopComponents[$entry.component]++
                } else {
                    $analytics.TopComponents[$entry.component] = 1
                }
                
                # Hourly stats
                $hour = $entryTime.ToString("yyyy-MM-dd-HH")
                if ($analytics.HourlyStats.ContainsKey($hour)) {
                    $analytics.HourlyStats[$hour]++
                } else {
                    $analytics.HourlyStats[$hour] = 1
                }
            }
        }
        catch {
            Write-Host "⚠️  Could not parse log file: $($logFile.Name)" -ForegroundColor Yellow
        }
    }
    
    # Display analytics
    Write-Host "📈 Log Analytics (Last 24 hours):" -ForegroundColor White
    Write-Host "  Total entries: $($analytics.TotalEntries)" -ForegroundColor Gray
    Write-Host "  Errors: $($analytics.ErrorCount)" -ForegroundColor $(if($analytics.ErrorCount -gt 0) {"Red"} else {"Gray"})
    Write-Host "  Warnings: $($analytics.WarningCount)" -ForegroundColor $(if($analytics.WarningCount -gt 0) {"Yellow"} else {"Gray"})
    Write-Host "  Info: $($analytics.InfoCount)" -ForegroundColor Gray
    
    # Show top components
    if ($analytics.TopComponents.Count -gt 0) {
        Write-Host "🔝 Top Components:" -ForegroundColor White
        $analytics.TopComponents.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 3 | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value) entries" -ForegroundColor Gray
        }
    }
    
    # Show recent errors
    if ($analytics.RecentErrors.Count -gt 0) {
        Write-Host "🚨 Recent Errors:" -ForegroundColor Red
        $analytics.RecentErrors | Select-Object -First 3 | ForEach-Object {
            Write-Host "  [$($_.timestamp)] $($_.component): $($_.message)" -ForegroundColor Red
        }
    }
    
    return $analytics
}

function Test-AlertThresholds {
    param([hashtable]$Analytics)
    
    $alerts = @()
    
    # Check error thresholds
    if ($Analytics.ErrorCount -gt $LogConfig.AlertThresholds.ErrorsPerHour) {
        $alerts += "High error rate: $($Analytics.ErrorCount) errors in last hour (threshold: $($LogConfig.AlertThresholds.ErrorsPerHour))"
    }
    
    if ($Analytics.WarningCount -gt $LogConfig.AlertThresholds.WarningsPerHour) {
        $alerts += "High warning rate: $($Analytics.WarningCount) warnings in last hour (threshold: $($LogConfig.AlertThresholds.WarningsPerHour))"
    }
    
    # Check for critical patterns
    $criticalPatterns = @("CRITICAL", "FATAL", "SECURITY", "CORRUPTION")
    foreach ($error in $Analytics.RecentErrors) {
        foreach ($pattern in $criticalPatterns) {
            if ($error.message -match $pattern) {
                $alerts += "Critical error detected: $($error.message)"
                break
            }
        }
    }
    
    if ($alerts.Count -gt 0) {
        Write-Host "🚨 ALERTS TRIGGERED:" -ForegroundColor Red -BackgroundColor Yellow
        foreach ($alert in $alerts) {
            Write-Host "  ⚠️  $alert" -ForegroundColor Red
        }
        
        # Send notifications if configured
        Send-AlertNotifications -Alerts $alerts
    }
    
    return $alerts
}

function Send-AlertNotifications {
    param([array]$Alerts)
    
    # Check for notification configuration
    $configFile = "notification-config.json"
    if (Test-Path $configFile) {
        try {
            $config = Get-Content $configFile | ConvertFrom-Json
            
            # Send Slack notification if configured
            if ($config.slack.enabled -and $config.slack.webhook) {
                Send-SlackAlert -WebhookUrl $config.slack.webhook -Alerts $Alerts
            }
            
            # Send email if configured  
            if ($config.email.enabled -and $config.email.smtpServer) {
                Send-EmailAlert -SmtpConfig $config.email -Alerts $Alerts
            }
        }
        catch {
            Write-Host "⚠️  Could not load notification config" -ForegroundColor Yellow
        }
    }
}

function Send-SlackAlert {
    param(
        [string]$WebhookUrl,
        [array]$Alerts
    )
    
    $message = @{
        text = "🚨 Backup System Alerts"
        attachments = @(
            @{
                color = "danger"
                title = "Alert Summary"
                text = ($Alerts -join "`n")
                footer = "Backup System Monitor"
                ts = [int][double]::Parse((Get-Date -UFormat %s))
            }
        )
    }
    
    try {
        $body = $message | ConvertTo-Json -Depth 3
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body -ContentType "application/json" | Out-Null
        Write-Host "✅ Slack alert sent" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to send Slack alert: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Invoke-LogMaintenance {
    Write-Host "🧹 Performing log maintenance..." -ForegroundColor Cyan
    
    # Remove old log files
    $logFiles = Get-ChildItem -Path $LogConfig.LogDirectory -Filter "*.log" | Sort-Object LastWriteTime -Descending
    
    if ($logFiles.Count -gt $LogConfig.MaxLogFiles) {
        $filesToRemove = $logFiles | Select-Object -Skip $LogConfig.MaxLogFiles
        foreach ($file in $filesToRemove) {
            Remove-Item $file.FullName -Force
            Write-Host "  Removed old log: $($file.Name)" -ForegroundColor Gray
        }
    }
    
    # Check file sizes and rotate if needed
    foreach ($file in $logFiles | Select-Object -First $LogConfig.MaxLogFiles) {
        $sizeMB = [math]::Round($file.Length / 1MB, 2)
        if ($sizeMB -gt $LogConfig.MaxLogSizeMB) {
            $newName = $file.Name -replace "\.log$", "-$(Get-Date -Format 'HHmmss').log"
            Rename-Item $file.FullName -NewName $newName
            Write-Host "  Rotated large log: $($file.Name) -> $newName" -ForegroundColor Gray
        }
    }
    
    Write-Host "✅ Log maintenance completed" -ForegroundColor Green
}

# Main execution
if ($Message) {
    # Log a specific message
    $metadata = @{
        script = $MyInvocation.ScriptName
        command = $MyInvocation.MyCommand.Name
    }
    
    $logEntry = Write-StructuredLog -Level $LogLevel -Message $Message -Component $Component -Metadata $metadata
    
    if ($Alert) {
        $analytics = Get-LogAnalytics
        Test-AlertThresholds -Analytics $analytics | Out-Null
    }
} else {
    # Run log analysis and maintenance
    $analytics = Get-LogAnalytics
    Test-AlertThresholds -Analytics $analytics | Out-Null
    Invoke-LogMaintenance
}

Write-Host "✅ Error tracking completed!" -ForegroundColor Green