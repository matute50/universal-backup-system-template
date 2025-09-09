# Performance Monitoring Script
# Tracks build times, file changes, and project health metrics

param(
    [string]$Action = "monitor",
    [string]$MetricType = "all",
    [switch]$SaveReport = $false
)

# Monitoring configuration
$MonitoringConfig = @{
    MaxBuildTimeMinutes = 15
    MaxFilesChanged = 100
    DiskSpaceThresholdGB = 1
    MaxMemoryUsageMB = 2048
    ReportRetentionDays = 30
}

function Get-BuildPerformanceMetrics {
    Write-Host "📊 Analyzing build performance..." -ForegroundColor Cyan
    
    $metrics = @{
        Timestamp = Get-Date
        BuildTimes = @()
        AvgBuildTime = 0
        DiskUsage = 0
        MemoryUsage = 0
    }
    
    # Check if package.json exists for build commands
    if (Test-Path "package.json") {
        $packageJson = Get-Content "package.json" | ConvertFrom-Json
        
        if ($packageJson.scripts.build) {
            Write-Host "🔨 Running build performance test..." -ForegroundColor Yellow
            
            $startTime = Get-Date
            try {
                npm run build 2>$null
                $endTime = Get-Date
                $buildTime = ($endTime - $startTime).TotalSeconds
                $metrics.BuildTimes += $buildTime
                $metrics.AvgBuildTime = $buildTime
                
                if ($buildTime -gt ($MonitoringConfig.MaxBuildTimeMinutes * 60)) {
                    Write-Host "⚠️  WARNING: Build time exceeded threshold ($buildTime seconds)" -ForegroundColor Yellow
                }
                
                Write-Host "✅ Build completed in $buildTime seconds" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ Build failed during performance test" -ForegroundColor Red
            }
        }
    }
    
    return $metrics
}

function Get-DiskUsageMetrics {
    Write-Host "💾 Analyzing disk usage..." -ForegroundColor Cyan
    
    $currentDir = Get-Location
    $totalSize = 0
    $largestFolders = @()
    
    # Get folder sizes
    $folders = @("node_modules", "dist", "build", ".git", "coverage", ".vite", ".next", ".svelte-kit")
    
    foreach ($folder in $folders) {
        if (Test-Path $folder) {
            try {
                $folderSize = (Get-ChildItem $folder -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
                $largestFolders += @{
                    Name = $folder
                    SizeMB = [math]::Round($folderSize, 2)
                }
                $totalSize += $folderSize
            }
            catch {
                # Skip folders we can't access
            }
        }
    }
    
    # Sort by size
    $largestFolders = $largestFolders | Sort-Object SizeMB -Descending
    
    # Display results
    Write-Host "📁 Disk usage summary:" -ForegroundColor White
    foreach ($folder in $largestFolders | Select-Object -First 5) {
        Write-Host "  $($folder.Name): $($folder.SizeMB) MB" -ForegroundColor Gray
    }
    
    $totalSizeGB = [math]::Round($totalSize / 1024, 2)
    Write-Host "📊 Total project size: $totalSizeGB GB" -ForegroundColor White
    
    if ($totalSizeGB -lt $MonitoringConfig.DiskSpaceThresholdGB) {
        Write-Host "⚠️  WARNING: Low disk space available" -ForegroundColor Yellow
    }
    
    return @{
        TotalSizeGB = $totalSizeGB
        LargestFolders = $largestFolders
        Timestamp = Get-Date
    }
}

function Get-GitMetrics {
    Write-Host "📈 Analyzing Git metrics..." -ForegroundColor Cyan
    
    $metrics = @{
        TotalCommits = 0
        RecentActivity = @()
        BranchCount = 0
        UncommittedFiles = 0
        Timestamp = Get-Date
    }
    
    try {
        # Count total commits
        $commitCount = git rev-list --count HEAD 2>$null
        if ($LASTEXITCODE -eq 0) {
            $metrics.TotalCommits = [int]$commitCount
        }
        
        # Get recent activity (last 7 days)
        $recentCommits = git log --oneline --since="7 days ago" 2>$null
        if ($LASTEXITCODE -eq 0 -and $recentCommits) {
            $metrics.RecentActivity = $recentCommits.Count
        }
        
        # Count branches
        $branches = git branch -a 2>$null
        if ($LASTEXITCODE -eq 0 -and $branches) {
            $metrics.BranchCount = $branches.Count
        }
        
        # Count uncommitted files
        $status = git status --porcelain 2>$null
        if ($LASTEXITCODE -eq 0 -and $status) {
            $metrics.UncommittedFiles = $status.Count
            
            if ($status.Count -gt $MonitoringConfig.MaxFilesChanged) {
                Write-Host "⚠️  WARNING: Many uncommitted files ($($status.Count))" -ForegroundColor Yellow
            }
        }
        
        Write-Host "📊 Git metrics:" -ForegroundColor White
        Write-Host "  Total commits: $($metrics.TotalCommits)" -ForegroundColor Gray
        Write-Host "  Recent activity: $($metrics.RecentActivity) commits (7 days)" -ForegroundColor Gray
        Write-Host "  Branches: $($metrics.BranchCount)" -ForegroundColor Gray
        Write-Host "  Uncommitted files: $($metrics.UncommittedFiles)" -ForegroundColor Gray
    }
    catch {
        Write-Host "⚠️  Could not gather Git metrics" -ForegroundColor Yellow
    }
    
    return $metrics
}

function Get-DependencyMetrics {
    Write-Host "📦 Analyzing dependencies..." -ForegroundColor Cyan
    
    $metrics = @{
        TotalDependencies = 0
        Vulnerabilities = 0
        OutdatedPackages = 0
        Timestamp = Get-Date
    }
    
    # NPM/Node.js project
    if (Test-Path "package.json") {
        try {
            $packageJson = Get-Content "package.json" | ConvertFrom-Json
            
            # Count dependencies
            $depCount = 0
            if ($packageJson.dependencies) {
                $depCount += $packageJson.dependencies.PSObject.Properties.Count
            }
            if ($packageJson.devDependencies) {
                $depCount += $packageJson.devDependencies.PSObject.Properties.Count
            }
            $metrics.TotalDependencies = $depCount
            
            # Check for vulnerabilities
            $auditOutput = npm audit --json 2>$null
            if ($LASTEXITCODE -eq 0 -and $auditOutput) {
                try {
                    $auditResult = $auditOutput | ConvertFrom-Json
                    if ($auditResult.vulnerabilities) {
                        $metrics.Vulnerabilities = $auditResult.vulnerabilities.PSObject.Properties.Count
                    }
                }
                catch {
                    # Ignore JSON parsing errors
                }
            }
            
            # Check for outdated packages
            $outdatedOutput = npm outdated --json 2>$null
            if ($LASTEXITCODE -eq 0 -and $outdatedOutput) {
                try {
                    $outdatedResult = $outdatedOutput | ConvertFrom-Json
                    if ($outdatedResult) {
                        $metrics.OutdatedPackages = $outdatedResult.PSObject.Properties.Count
                    }
                }
                catch {
                    # Ignore JSON parsing errors
                }
            }
            
            Write-Host "📦 Dependency metrics:" -ForegroundColor White
            Write-Host "  Total dependencies: $($metrics.TotalDependencies)" -ForegroundColor Gray
            Write-Host "  Vulnerabilities: $($metrics.Vulnerabilities)" -ForegroundColor $(if($metrics.Vulnerabilities -gt 0) {"Red"} else {"Gray"})
            Write-Host "  Outdated packages: $($metrics.OutdatedPackages)" -ForegroundColor Gray
        }
        catch {
            Write-Host "⚠️  Could not analyze NPM dependencies" -ForegroundColor Yellow
        }
    }
    
    # Python project
    if (Test-Path "requirements.txt") {
        try {
            $requirements = Get-Content "requirements.txt" | Where-Object { $_ -notmatch "^#" -and $_.Trim() -ne "" }
            $metrics.TotalDependencies += $requirements.Count
            
            Write-Host "📦 Python dependencies: $($requirements.Count)" -ForegroundColor Gray
        }
        catch {
            Write-Host "⚠️  Could not analyze Python dependencies" -ForegroundColor Yellow
        }
    }
    
    return $metrics
}

function Get-SystemMetrics {
    Write-Host "💻 Analyzing system performance..." -ForegroundColor Cyan
    
    $metrics = @{
        CPUUsage = 0
        MemoryUsageMB = 0
        AvailableMemoryMB = 0
        DiskSpaceGB = 0
        Timestamp = Get-Date
    }
    
    try {
        # Get memory usage
        $memory = Get-CimInstance -ClassName Win32_OperatingSystem
        $totalMemoryMB = [math]::Round($memory.TotalVisibleMemorySize / 1KB, 2)
        $freeMemoryMB = [math]::Round($memory.FreePhysicalMemory / 1KB, 2)
        $usedMemoryMB = $totalMemoryMB - $freeMemoryMB
        
        $metrics.MemoryUsageMB = $usedMemoryMB
        $metrics.AvailableMemoryMB = $freeMemoryMB
        
        # Get disk space for current drive
        $drive = (Get-Location).Drive
        $disk = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $drive.Name }
        if ($disk) {
            $metrics.DiskSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
        }
        
        Write-Host "💻 System metrics:" -ForegroundColor White
        Write-Host "  Memory usage: $usedMemoryMB MB / $totalMemoryMB MB" -ForegroundColor Gray
        Write-Host "  Available disk space: $($metrics.DiskSpaceGB) GB" -ForegroundColor Gray
        
        # Warnings
        if ($usedMemoryMB -gt $MonitoringConfig.MaxMemoryUsageMB) {
            Write-Host "⚠️  WARNING: High memory usage" -ForegroundColor Yellow
        }
        
        if ($metrics.DiskSpaceGB -lt $MonitoringConfig.DiskSpaceThresholdGB) {
            Write-Host "⚠️  WARNING: Low disk space" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "⚠️  Could not gather system metrics" -ForegroundColor Yellow
    }
    
    return $metrics
}

function Save-MonitoringReport {
    param([hashtable]$AllMetrics)
    
    $reportPath = "monitoring-report-$(Get-Date -Format 'yyyyMMdd_HHmm').md"
    
    $report = @"
# Performance Monitoring Report
**Generated:** $(Get-Date)
**Project:** $(Split-Path -Leaf (Get-Location))

## Build Performance
- Average build time: $($AllMetrics.Build.AvgBuildTime) seconds
- Build status: $(if($AllMetrics.Build.AvgBuildTime -lt 300) {"✅ Good"} else {"⚠️ Slow"})

## Disk Usage
- Total project size: $($AllMetrics.Disk.TotalSizeGB) GB
- Largest folders:
$(foreach ($folder in ($AllMetrics.Disk.LargestFolders | Select-Object -First 3)) {
    "  - $($folder.Name): $($folder.SizeMB) MB"
}) -join "`n")

## Git Metrics
- Total commits: $($AllMetrics.Git.TotalCommits)
- Recent activity: $($AllMetrics.Git.RecentActivity) commits (7 days)
- Uncommitted files: $($AllMetrics.Git.UncommittedFiles)

## Dependencies
- Total dependencies: $($AllMetrics.Dependencies.TotalDependencies)
- Vulnerabilities: $($AllMetrics.Dependencies.Vulnerabilities)
- Outdated packages: $($AllMetrics.Dependencies.OutdatedPackages)

## System Performance
- Memory usage: $($AllMetrics.System.MemoryUsageMB) MB
- Available disk space: $($AllMetrics.System.DiskSpaceGB) GB

## Recommendations
$(if ($AllMetrics.Build.AvgBuildTime -gt 300) {"- Optimize build performance (currently slow)"})
$(if ($AllMetrics.Dependencies.Vulnerabilities -gt 0) {"- Update dependencies with vulnerabilities"})
$(if ($AllMetrics.Git.UncommittedFiles -gt 20) {"- Consider committing pending changes"})
$(if ($AllMetrics.System.DiskSpaceGB -lt 2) {"- Free up disk space"})

---
*Report saved to: $reportPath*
"@
    
    $report | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "📄 Monitoring report saved to: $reportPath" -ForegroundColor Green
}

# Main execution
Write-Host "📊 Starting performance monitoring..." -ForegroundColor Cyan

$allMetrics = @{}

switch ($MetricType) {
    "all" {
        $allMetrics.Build = Get-BuildPerformanceMetrics
        $allMetrics.Disk = Get-DiskUsageMetrics
        $allMetrics.Git = Get-GitMetrics
        $allMetrics.Dependencies = Get-DependencyMetrics
        $allMetrics.System = Get-SystemMetrics
    }
    "build" {
        $allMetrics.Build = Get-BuildPerformanceMetrics
    }
    "disk" {
        $allMetrics.Disk = Get-DiskUsageMetrics
    }
    "git" {
        $allMetrics.Git = Get-GitMetrics
    }
    "dependencies" {
        $allMetrics.Dependencies = Get-DependencyMetrics
    }
    "system" {
        $allMetrics.System = Get-SystemMetrics
    }
}

if ($SaveReport -and $allMetrics.Count -gt 0) {
    Save-MonitoringReport -AllMetrics $allMetrics
}

Write-Host "✅ Performance monitoring completed!" -ForegroundColor Green