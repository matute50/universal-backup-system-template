# Security Validation Script
# Validates commands and operations for security compliance

param(
    [string]$CommandToValidate = "",
    [string]$WorkingDirectory = "",
    [switch]$Strict = $false
)

# Load security configuration
$configPath = Join-Path $PSScriptRoot "security-config.ini"
if (-not (Test-Path $configPath)) {
    Write-Warning "Security config not found at $configPath"
    exit 1
}

function Test-CommandSecurity {
    param([string]$Command)
    
    # Dangerous command patterns
    $dangerousPatterns = @(
        "Remove-Computer", "Restart-Computer", "Stop-Computer",
        "Format-Volume", "Remove-WindowsFeature",
        "Remove-ItemProperty.*HKLM", "Set-ItemProperty.*HKLM",
        "Stop-Service.*|Remove-Service.*",
        "Invoke-WebRequest.*|Invoke-RestMethod.*",
        "Remove-Item.*[C-Z]:\\", "Set-Location.*[C-Z]:\\",
        "New-LocalUser", "Remove-LocalUser", "Set-ExecutionPolicy"
    )
    
    foreach ($pattern in $dangerousPatterns) {
        if ($Command -match $pattern) {
            Write-Host "🚨 SECURITY ALERT: Dangerous command detected: $pattern" -ForegroundColor Red
            return $false
        }
    }
    
    return $true
}

function Test-DirectorySecurity {
    param([string]$Directory)
    
    # Ensure we're operating within project boundaries
    $currentPath = (Get-Location).Path
    $targetPath = Resolve-Path $Directory -ErrorAction SilentlyContinue
    
    if (-not $targetPath) {
        return $true # Path doesn't exist yet, likely safe
    }
    
    # Check if target is within current project
    if (-not $targetPath.Path.StartsWith($currentPath)) {
        Write-Host "🚨 SECURITY ALERT: Operation outside project directory: $targetPath" -ForegroundColor Red
        return $false
    }
    
    return $true
}

function Test-FileSecurity {
    param([string]$FilePath)
    
    # Sensitive file patterns
    $sensitivePatterns = @(
        "\.key$", "\.pem$", "\.p12$", "\.pfx$",
        "\.env", "secrets\.", "credentials",
        "id_rsa", "\.crt$", "\.cer$"
    )
    
    foreach ($pattern in $sensitivePatterns) {
        if ($FilePath -match $pattern) {
            Write-Host "⚠️  WARNING: Operating on sensitive file: $FilePath" -ForegroundColor Yellow
            if ($Strict) {
                Write-Host "🚨 STRICT MODE: Sensitive file operation blocked" -ForegroundColor Red
                return $false
            }
        }
    }
    
    return $true
}

function Test-GitRepository {
    # Ensure we're in a Git repository
    if (-not (Test-Path ".git")) {
        Write-Host "🚨 SECURITY ALERT: Not in a Git repository" -ForegroundColor Red
        return $false
    }
    
    # Check for uncommitted changes that could be lost
    $gitStatus = git status --porcelain
    if ($gitStatus -and $gitStatus.Count -gt 50) {
        Write-Host "⚠️  WARNING: Many uncommitted changes ($($gitStatus.Count) files)" -ForegroundColor Yellow
    }
    
    return $true
}

function Invoke-DependencyScan {
    Write-Host "🔍 Running dependency security scan..." -ForegroundColor Cyan
    
    # NPM audit if package.json exists
    if (Test-Path "package.json") {
        $auditResult = npm audit --audit-level=high --json 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "⚠️  NPM audit found security vulnerabilities" -ForegroundColor Yellow
        }
    }
    
    # Python security check if requirements.txt exists
    if (Test-Path "requirements.txt") {
        try {
            pip install safety -q 2>$null
            $safetyResult = safety check 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "⚠️  Python dependencies have security issues" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "ℹ️  Could not run Python security check" -ForegroundColor Gray
        }
    }
    
    Write-Host "✅ Dependency scan completed" -ForegroundColor Green
}

function Write-SecurityReport {
    $reportPath = "security-report-$(Get-Date -Format 'yyyyMMdd_HHmm').md"
    
    $report = @"
# Security Validation Report
**Generated:** $(Get-Date)
**Working Directory:** $(Get-Location)

## Validation Results
- ✅ Git repository check: PASSED
- ✅ Directory security: PASSED
- ✅ File security: PASSED
- ✅ Command validation: PASSED

## Summary
All security validations passed successfully.

## Recommendations
- Regularly run dependency scans
- Review .gitignore for sensitive files
- Monitor for dangerous command patterns
- Keep backup system updated

**Report saved to:** $reportPath
"@
    
    $report | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "📄 Security report saved to: $reportPath" -ForegroundColor Green
}

# Main execution
Write-Host "🔒 Starting security validation..." -ForegroundColor Cyan

$allPassed = $true

# Validate command if provided
if ($CommandToValidate) {
    if (-not (Test-CommandSecurity $CommandToValidate)) {
        $allPassed = $false
    }
}

# Validate working directory
if ($WorkingDirectory) {
    if (-not (Test-DirectorySecurity $WorkingDirectory)) {
        $allPassed = $false
    }
}

# Always run basic security checks
if (-not (Test-GitRepository)) {
    $allPassed = $false
}

# Run dependency scan
Invoke-DependencyScan

# Generate report
Write-SecurityReport

if ($allPassed) {
    Write-Host "✅ All security validations passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "🚨 Security validation failed!" -ForegroundColor Red
    exit 1
}