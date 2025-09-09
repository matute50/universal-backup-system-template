# AI Safety Check Script for Windows/PowerShell
# Verifies backup status before AI-assisted major changes

param(
    [string]$ChangeDescription = "AI-assisted major change"
)

Write-Host "AI SAFETY PROTOCOL - Backup Verification" -ForegroundColor Cyan
Write-Host "Change Description: $ChangeDescription" -ForegroundColor White

$ErrorActionPreference = "Stop"
$allGood = $true

try {
    # 1. Check if we're in a git repository
    $gitStatus = git status --porcelain 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Not in a git repository" -ForegroundColor Red
        $allGood = $false
    } else {
        Write-Host "SUCCESS: Git repository detected" -ForegroundColor Green
    }

    # 2. Get last checkpoint
    $lastCheckpoint = git tag --list --sort=-version:refname | Select-Object -First 1
    if ($lastCheckpoint) {
        Write-Host "Last checkpoint: $lastCheckpoint" -ForegroundColor Green
        
        # Check age of last checkpoint
        $tagDate = git log -1 --format=%ci $lastCheckpoint 2>$null
        if ($tagDate) {
            $tagDateTime = [DateTime]::Parse($tagDate)
            $age = (Get-Date) - $tagDateTime
            $hoursAgo = [math]::Round($age.TotalHours, 1)
            
            if ($age.TotalHours -lt 4) {
                Write-Host "SUCCESS: Recent checkpoint ($hoursAgo hours ago)" -ForegroundColor Green
            } elseif ($age.TotalDays -lt 1) {
                Write-Host "WARNING: Checkpoint is $hoursAgo hours old" -ForegroundColor Yellow
                Write-Host "  Consider creating a fresh checkpoint before major changes" -ForegroundColor Yellow
            } else {
                $daysAgo = [math]::Round($age.TotalDays, 1)
                Write-Host "CRITICAL: Last checkpoint is $daysAgo days old!" -ForegroundColor Red
                Write-Host "  MUST create fresh checkpoint before proceeding" -ForegroundColor Red
                $allGood = $false
            }
        }
    } else {
        Write-Host "CRITICAL: NO CHECKPOINTS FOUND!" -ForegroundColor Red
        Write-Host "  MUST create initial checkpoint before proceeding" -ForegroundColor Red
        $allGood = $false
    }

    # 3. Check uncommitted changes
    $uncommittedChanges = git status --porcelain | Measure-Object | Select-Object -ExpandProperty Count
    if ($uncommittedChanges -gt 0) {
        Write-Host "WARNING: $uncommittedChanges uncommitted changes detected" -ForegroundColor Yellow
        git status --short
        Write-Host "  These will be included in the next checkpoint" -ForegroundColor Yellow
    } else {
        Write-Host "SUCCESS: Working directory clean" -ForegroundColor Green
    }

    # 4. Check remote connectivity  
    $remoteUrl = git remote get-url origin 2>$null
    if ($remoteUrl) {
        Write-Host "SUCCESS: Remote repository: $remoteUrl" -ForegroundColor Green
        
        # Test if we can reach remote (basic check)
        $remoteReachable = git ls-remote --exit-code origin HEAD 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: Remote repository accessible" -ForegroundColor Green
        } else {
            Write-Host "WARNING: Cannot reach remote repository" -ForegroundColor Yellow
            Write-Host "  Backups will be local-only" -ForegroundColor Yellow
        }
    } else {
        Write-Host "WARNING: No remote repository configured" -ForegroundColor Yellow
        Write-Host "  Backups will be local-only" -ForegroundColor Yellow
    }

    # 5. Summary and recommendations
    Write-Host "`nSAFETY ASSESSMENT:" -ForegroundColor Cyan
    
    if ($allGood) {
        Write-Host "SAFE TO PROCEED" -ForegroundColor Green
        Write-Host "  Backup system is operational and recent" -ForegroundColor Green
        
        if ($uncommittedChanges -gt 0) {
            Write-Host "`nRECOMMENDED ACTION:" -ForegroundColor Cyan
            Write-Host "  Run 'npm run save' to create checkpoint with current changes" -ForegroundColor Yellow
        }
    } else {
        Write-Host "NOT SAFE - CREATE CHECKPOINT FIRST" -ForegroundColor Red
        Write-Host "`nREQUIRED ACTIONS:" -ForegroundColor Cyan
        Write-Host "  1. Run 'npm run checkpoint:feature -Message `"Before $ChangeDescription`"'" -ForegroundColor Red
        Write-Host "  2. Verify checkpoint creation" -ForegroundColor Red
        Write-Host "  3. Re-run this safety check" -ForegroundColor Red
    }

    # 6. Provide rollback plan
    Write-Host "`nROLLBACK PLAN:" -ForegroundColor Cyan
    if ($lastCheckpoint) {
        Write-Host "  If changes fail: git checkout $lastCheckpoint" -ForegroundColor White
    } else {
        Write-Host "  No rollback available - CREATE CHECKPOINT FIRST!" -ForegroundColor Red
    }

    # 7. Quick commands reference
    Write-Host "`nQUICK COMMANDS:" -ForegroundColor Cyan
    Write-Host "  Create checkpoint: npm run save" -ForegroundColor White
    Write-Host "  Feature checkpoint: npm run checkpoint:feature" -ForegroundColor White  
    Write-Host "  View checkpoints: git tag --list" -ForegroundColor White
    Write-Host "  Emergency rollback: git checkout [checkpoint-name]" -ForegroundColor White

    if ($allGood) {
        exit 0
    } else {
        exit 1
    }

} catch {
    Write-Host "Safety check failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}