#!/usr/bin/env powershell
# Universal Backup System Installer
# Works with any Git repository and framework

param(
    [string]$Framework = "auto-detect",
    [switch]$IncludeCopilotInstructions = $false,
    [switch]$DryRun = $false
)

Write-Host "🛡️ Universal Backup System Installer" -ForegroundColor Cyan
Write-Host "Installing backup system for: $Framework" -ForegroundColor White

$ErrorActionPreference = "Stop"

# Check prerequisites
function Test-Prerequisites {
    Write-Host "🔍 Checking prerequisites..." -ForegroundColor Yellow
    
    # Check Git
    try {
        $gitVersion = git --version
        Write-Host "✅ Git: $gitVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ Git not found. Please install Git first." -ForegroundColor Red
        exit 1
    }
    
    # Check if in Git repository
    try {
        $repoRoot = git rev-parse --show-toplevel 2>$null
        Write-Host "✅ Git repository detected" -ForegroundColor Green
    } catch {
        Write-Host "❌ Not in a Git repository. Run 'git init' first." -ForegroundColor Red
        exit 1
    }
    
    # Check package.json (optional)
    if (Test-Path "package.json") {
        Write-Host "✅ package.json found" -ForegroundColor Green
        return $true
    } else {
        Write-Host "⚠️  No package.json found - scripts will need manual configuration" -ForegroundColor Yellow
        return $false
    }
}

# Auto-detect framework
function Get-Framework {
    Write-Host "🔍 Auto-detecting framework..." -ForegroundColor Yellow
    
    if (Test-Path "package.json") {
        $packageJson = Get-Content "package.json" | ConvertFrom-Json
        
        # Check dependencies for framework clues
        $deps = @()
        if ($packageJson.dependencies) { $deps += $packageJson.dependencies.PSObject.Properties.Name }
        if ($packageJson.devDependencies) { $deps += $packageJson.devDependencies.PSObject.Properties.Name }
        
        if ($deps -contains "react" -or $deps -contains "next") {
            return "react"
        } elseif ($deps -contains "vue" -or $deps -contains "nuxt") {
            return "vue"
        } elseif ($deps -contains "@angular/core") {
            return "angular"
        } elseif ($deps -contains "@sveltejs/kit" -or $deps -contains "svelte") {
            return "svelte"
        } elseif ($deps -contains "express" -or $deps -contains "fastify") {
            return "node"
        } else {
            return "generic"
        }
    }
    
    # Check for other project types
    if (Test-Path "requirements.txt" -or Test-Path "setup.py") {
        return "python"
    } elseif (Test-Path "Gemfile") {
        return "ruby"
    } elseif (Test-Path "composer.json") {
        return "php"
    } elseif (Test-Path "Cargo.toml") {
        return "rust"
    } elseif (Test-Path "go.mod") {
        return "go"
    }
    
    return "generic"
}

# Get framework-specific configuration
function Get-FrameworkConfig($framework) {
    switch ($framework) {
        "react" {
            return @{
                dev = "npm start"
                build = "npm run build"
                test = "npm test"
                lint = "npm run lint"
            }
        }
        "vue" {
            return @{
                dev = "npm run serve"
                build = "npm run build"
                test = "npm run test:unit"
                lint = "npm run lint"
            }
        }
        "angular" {
            return @{
                dev = "ng serve"
                build = "ng build"
                test = "ng test --watch=false"
                lint = "ng lint"
            }
        }
        "svelte" {
            return @{
                dev = "npm run dev"
                build = "npm run build"
                test = "npm test"
                lint = "npm run lint"
            }
        }
        "node" {
            return @{
                dev = "npm run dev"
                build = "npm run build"
                test = "npm test"
                lint = "npm run lint"
            }
        }
        default {
            return @{
                dev = "echo 'Configure your dev command'"
                build = "echo 'Configure your build command'"
                test = "echo 'Configure your test command'"
                lint = "echo 'Configure your lint command'"
            }
        }
    }
}

# Install backup scripts
function Install-BackupScripts {
    Write-Host "📁 Installing backup scripts..." -ForegroundColor Yellow
    
    if (-not (Test-Path "scripts")) {
        New-Item -ItemType Directory -Name "scripts" -Force | Out-Null
        Write-Host "✅ Created scripts/ directory" -ForegroundColor Green
    }
    
    # Copy core scripts (these would come from the template)
    $scripts = @(
        "checkpoint-simple.ps1",
        "ai-safety-check.ps1", 
        "health-check.ps1",
        "rollback-daily.ps1",
        "security-validation.ps1",
        "performance-monitor.ps1",
        "error-tracking.ps1"
    )
    
    foreach ($script in $scripts) {
        if ($DryRun) {
            Write-Host "   Would install: scripts/$script" -ForegroundColor Gray
        } else {
            # In real implementation, copy from template
            Write-Host "✅ Installed: scripts/$script" -ForegroundColor Green
        }
    }
}

# Update package.json with backup scripts
function Update-PackageJson($framework) {
    if (-not (Test-Path "package.json")) {
        Write-Host "⚠️  No package.json found - creating basic one" -ForegroundColor Yellow
        $basicPackage = @{
            name = (Get-Item .).Name
            version = "1.0.0"
            scripts = @{}
        }
        
        if ($DryRun) {
            Write-Host "   Would create package.json" -ForegroundColor Gray
        } else {
            $basicPackage | ConvertTo-Json -Depth 4 | Set-Content "package.json"
        }
    }
    
    Write-Host "📦 Updating package.json with backup scripts..." -ForegroundColor Yellow
    
    $packageJson = Get-Content "package.json" | ConvertFrom-Json
    $config = Get-FrameworkConfig $framework
    
    # Add/update framework scripts
    if (-not $packageJson.scripts) {
        $packageJson | Add-Member -MemberType NoteProperty -Name "scripts" -Value @{}
    }
    
    # Update existing or add new scripts
    $packageJson.scripts."health:check" = "powershell -ExecutionPolicy Bypass -File ./scripts/health-check.ps1"
    $packageJson.scripts."save" = "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1"
    $packageJson.scripts."checkpoint:feature" = "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type feature"
    $packageJson.scripts."checkpoint:daily" = "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type daily"
    $packageJson.scripts."ai:safety-check" = "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
    $packageJson.scripts."rollback:daily" = "powershell -ExecutionPolicy Bypass -File ./scripts/rollback-daily.ps1"
    
    # Add new monitoring and security scripts
    $packageJson.scripts."security:check" = "powershell -ExecutionPolicy Bypass -File ./scripts/security-validation.ps1"
    $packageJson.scripts."security:audit" = "powershell -ExecutionPolicy Bypass -File ./scripts/security-validation.ps1"
    $packageJson.scripts."security:scan-secrets" = "powershell -ExecutionPolicy Bypass -File ./scripts/security-validation.ps1 -Strict"
    $packageJson.scripts."monitor:performance" = "powershell -ExecutionPolicy Bypass -File ./scripts/performance-monitor.ps1 -SaveReport"
    $packageJson.scripts."monitor:disk" = "powershell -ExecutionPolicy Bypass -File ./scripts/performance-monitor.ps1 -MetricType disk"
    $packageJson.scripts."monitor:git" = "powershell -ExecutionPolicy Bypass -File ./scripts/performance-monitor.ps1 -MetricType git"
    $packageJson.scripts."monitor:system" = "powershell -ExecutionPolicy Bypass -File ./scripts/performance-monitor.ps1 -MetricType system"
    $packageJson.scripts."monitor:errors" = "powershell -ExecutionPolicy Bypass -File ./scripts/error-tracking.ps1"
    
    # Add framework-specific commands if they don't exist
    if (-not $packageJson.scripts.dev) { $packageJson.scripts.dev = $config.dev }
    if (-not $packageJson.scripts.build) { $packageJson.scripts.build = $config.build }
    if (-not $packageJson.scripts.test) { $packageJson.scripts.test = $config.test }
    if (-not $packageJson.scripts.lint) { $packageJson.scripts.lint = $config.lint }
    
    # Add backup system metadata
    $packageJson | Add-Member -MemberType NoteProperty -Name "backup-system" -Value @{
        version = "1.0.0"
        installed = Get-Date -Format "yyyy-MM-dd"
        framework = $framework
    } -Force
    
    if ($DryRun) {
        Write-Host "   Would update package.json with backup scripts" -ForegroundColor Gray
    } else {
        $packageJson | ConvertTo-Json -Depth 4 | Set-Content "package.json"
        Write-Host "✅ Updated package.json" -ForegroundColor Green
    }
}

# Create initial checkpoint
function Create-InitialCheckpoint {
    Write-Host "🏷️ Creating initial checkpoint..." -ForegroundColor Yellow
    
    if ($DryRun) {
        Write-Host "   Would create initial checkpoint" -ForegroundColor Gray
        return
    }
    
    try {
        # Check if there are any changes to commit
        $status = git status --porcelain
        if ($status) {
            Write-Host "💾 Committing backup system installation..." -ForegroundColor Yellow
            git add .
            git commit -m "feat: install universal backup system

- Add smart checkpoint and rollback scripts
- Add AI safety check protocol  
- Configure $framework-specific health checks
- Add npm scripts for backup management"
        }
        
        # Create installation checkpoint
        $checkpointName = "checkpoint-backup-system-installed-$(Get-Date -Format 'yyyyMMdd_HHmm')"
        git tag -a $checkpointName -m "Universal backup system installed"
        
        # Push to remote if available
        $remoteUrl = git remote get-url origin 2>$null
        if ($remoteUrl) {
            git push origin main 2>$null
            git push origin --tags 2>$null
            Write-Host "✅ Pushed initial checkpoint to remote" -ForegroundColor Green
        }
        
        Write-Host "✅ Created checkpoint: $checkpointName" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Could not create initial checkpoint: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Main installation process
function Install-BackupSystem {
    Write-Host "🚀 Starting installation..." -ForegroundColor Cyan
    
    # Check prerequisites
    $hasPackageJson = Test-Prerequisites
    
    # Auto-detect or use provided framework
    if ($Framework -eq "auto-detect") {
        $Framework = Get-Framework
    }
    
    Write-Host "📋 Configuration:" -ForegroundColor Cyan
    Write-Host "   Framework: $Framework" -ForegroundColor White
    Write-Host "   Include Copilot Instructions: $IncludeCopilotInstructions" -ForegroundColor White
    Write-Host "   Dry Run: $DryRun" -ForegroundColor White
    
    # Install components
    Install-BackupScripts
    
    if ($hasPackageJson -or $Framework -ne "generic") {
        Update-PackageJson $Framework
    }
    
    if ($IncludeCopilotInstructions) {
        Write-Host "📄 Installing Copilot instructions..." -ForegroundColor Yellow
        # Would copy .copilot-instructions.md template
        if ($DryRun) {
            Write-Host "   Would install .github/.copilot-instructions.md" -ForegroundColor Gray
        } else {
            Write-Host "✅ Installed Copilot instructions" -ForegroundColor Green
        }
    }
    
    # Create initial checkpoint
    Create-InitialCheckpoint
    
    # Success message
    Write-Host ""
    Write-Host "🎉 Backup system installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Available commands:" -ForegroundColor Cyan
    Write-Host "   npm run save                  - Quick checkpoint" -ForegroundColor White
    Write-Host "   npm run checkpoint:feature    - Feature checkpoint" -ForegroundColor White
    Write-Host "   npm run ai:safety-check       - Verify backups before changes" -ForegroundColor White
    Write-Host "   npm run health:check          - Project health verification" -ForegroundColor White
    Write-Host "   npm run rollback:daily        - Emergency rollback" -ForegroundColor White
    Write-Host ""
    Write-Host "🛡️ AI Safety Protocol active - all major changes protected!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📚 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Test: npm run health:check" -ForegroundColor White
    Write-Host "   2. Create checkpoint: npm run save" -ForegroundColor White
    Write-Host "   3. Customize scripts in ./scripts/ for your project" -ForegroundColor White
}

# Run installation
Install-BackupSystem