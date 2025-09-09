# Daily Rollback Script for Windows/PowerShell
# Rolls back to the last daily checkpoint

param(
    [switch]$Force = $false
)

Write-Host "🔄 Rolling back to last daily checkpoint..." -ForegroundColor Yellow

$ErrorActionPreference = "Stop"

try {
    # Find latest daily checkpoint
    Write-Host "🔍 Finding latest daily checkpoint..." -ForegroundColor Blue
    $latestDaily = git tag -l "checkpoint-daily-*" | Sort-Object | Select-Object -Last 1
    
    if (-not $latestDaily) {
        throw "No daily checkpoint found! Create one with ./daily-checkpoint.ps1"
    }
    
    Write-Host "📍 Latest checkpoint found: $latestDaily" -ForegroundColor Green
    
    if (-not $Force) {
        $confirmation = Read-Host "Are you sure you want to rollback to $latestDaily? (y/N)"
        if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
            Write-Host "❌ Rollback cancelled" -ForegroundColor Yellow
            exit 0
        }
    }
    
    # Create backup branch of current state
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupBranch = "backup-before-rollback-$timestamp"
    
    Write-Host "💾 Creating backup branch: $backupBranch" -ForegroundColor Blue
    git checkout -b $backupBranch
    git push origin $backupBranch
    
    # Rollback to checkpoint
    Write-Host "⏮️  Rolling back to checkpoint..." -ForegroundColor Blue
    git checkout main
    git reset --hard $latestDaily
    
    # Force push (with lease for safety)
    Write-Host "📤 Updating remote main branch..." -ForegroundColor Blue
    git push --force-with-lease origin main
    
    # Clean up workspace
    Write-Host "🧹 Cleaning workspace..." -ForegroundColor Blue
    Remove-Item -Path "node_modules" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path ".svelte-kit" -Recurse -Force -ErrorAction SilentlyContinue
    npm ci
    
    Write-Host "✅ Successfully rolled back to: $latestDaily" -ForegroundColor Green
    Write-Host "💾 Current state backed up to branch: $backupBranch" -ForegroundColor Green
    Write-Host "🔧 Run 'npm run dev' to start development" -ForegroundColor Blue
    
} catch {
    Write-Host "❌ Rollback failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "🆘 Check git status and resolve manually" -ForegroundColor Yellow
    exit 1
}

Write-Host "🎉 Rollback complete!" -ForegroundColor Green