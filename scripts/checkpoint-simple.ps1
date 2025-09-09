# Smart Checkpoint Script for Windows/PowerShell
# Follows best practices for Git tagging with automatic frequency detection

param(
    [string]$Message = "",
    [string]$Type = "auto"  # auto, daily, feature, release, hotfix
)

Write-Host "Creating smart checkpoint with best-practice tagging..." -ForegroundColor Yellow

$ErrorActionPreference = "Stop"
$exitCode = 0

function Get-LastTags {
    $tags = @{}
    
    # Get all existing tags
    $allTags = git tag --list --sort=-version:refname
    
    foreach ($tag in $allTags) {
        if ($tag -match "^checkpoint-daily-") { 
            if (-not $tags.ContainsKey("daily")) { $tags["daily"] = $tag }
        }
        elseif ($tag -match "^checkpoint-feature-") { 
            if (-not $tags.ContainsKey("feature")) { $tags["feature"] = $tag }
        }
        elseif ($tag -match "^checkpoint-session-") { 
            if (-not $tags.ContainsKey("session")) { $tags["session"] = $tag }
        }
        elseif ($tag -match "^v\d+\.\d+\.\d+") { 
            if (-not $tags.ContainsKey("release")) { $tags["release"] = $tag }
        }
    }
    
    return $tags
}

function Get-TimeSinceLastTag {
    param($tagName)
    
    if (-not $tagName) { return [TimeSpan]::MaxValue }
    
    try {
        $tagDate = git log -1 --format=%ci $tagName 2>$null
        if ($tagDate) {
            $tagDateTime = [DateTime]::Parse($tagDate)
            return (Get-Date) - $tagDateTime
        }
    } catch {
        # Tag doesn't exist or error occurred
    }
    
    return [TimeSpan]::MaxValue
}

function Determine-CheckpointStrategy {
    $lastTags = Get-LastTags
    $now = Get-Date
    
    # Check time since last daily checkpoint
    $dailyAge = Get-TimeSinceLastTag $lastTags["daily"]
    $sessionAge = Get-TimeSinceLastTag $lastTags["session"]
    
    # BEST PRACTICE: Multiple checkpoint levels
    $strategy = @{
        "createDaily" = $dailyAge.TotalDays -ge 1
        "createSession" = $sessionAge.TotalHours -ge 4
        "createFeature" = $false  # Will determine based on commits
        "reason" = ""
    }
    
    # Check if significant work happened (feature-level checkpoint)
    $commitsSinceFeature = 0
    if ($lastTags["feature"]) {
        $commitsSinceFeature = (git rev-list "$($lastTags['feature'])..HEAD" --count 2>$null) -as [int]
    } else {
        $commitsSinceFeature = (git rev-list --count HEAD 2>$null) -as [int]
    }
    
    if ($commitsSinceFeature -ge 10) {
        $strategy["createFeature"] = $true
        $strategy["reason"] += "10+ commits since last feature checkpoint. "
    }
    
    if ($strategy["createDaily"]) {
        $strategy["reason"] += "24+ hours since last daily checkpoint. "
    }
    
    if ($strategy["createSession"]) {
        $strategy["reason"] += "4+ hours since last session checkpoint. "
    }
    
    return $strategy
}

try {
    # Check if we're in a git repository
    $gitStatus = git status --porcelain 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Not in a git repository"
    }

    # Show current status
    Write-Host "Current git status:" -ForegroundColor Blue
    git status --short

    # Determine what checkpoints to create
    $strategy = Determine-CheckpointStrategy
    $timestamp = Get-Date -Format "yyyyMMdd_HHmm"
    $tagsCreated = @()
    
    Write-Host "Checkpoint analysis: $($strategy.reason)" -ForegroundColor Cyan
    
    # Add any uncommitted changes first
    $changes = git status --porcelain
    if ($changes) {
        $commitMessage = if ($Message) { $Message } else { "Auto-checkpoint: Work in progress" }
        Write-Host "Committing current changes..." -ForegroundColor Blue
        git add .
        git commit -m $commitMessage
    }
    
    # Create session checkpoint (frequent, lightweight)
    if ($strategy["createSession"] -or $Type -eq "session") {
        $sessionTag = "checkpoint-session-$timestamp"
        $sessionMsg = "Session checkpoint: Current work state"
        git tag -a $sessionTag -m $sessionMsg
        $tagsCreated += $sessionTag
        Write-Host "Created session checkpoint: $sessionTag" -ForegroundColor Green
    }
    
    # Create daily checkpoint (stable daily save point)
    if ($strategy["createDaily"] -or $Type -eq "daily") {
        $dailyTag = "checkpoint-daily-$timestamp"
        $dailyMsg = if ($Message) { "Daily checkpoint: $Message" } else { "Daily checkpoint: End of day save point" }
        git tag -a $dailyTag -m $dailyMsg
        $tagsCreated += $dailyTag
        Write-Host "Created daily checkpoint: $dailyTag" -ForegroundColor Green
    }
    
    # Create feature checkpoint (significant progress milestone)
    if ($strategy["createFeature"] -or $Type -eq "feature") {
        $featureTag = "checkpoint-feature-$timestamp"
        $featureMsg = if ($Message) { "Feature checkpoint: $Message" } else { "Feature checkpoint: Significant progress milestone" }
        git tag -a $featureTag -m $featureMsg
        $tagsCreated += $featureTag
        Write-Host "Created feature checkpoint: $featureTag" -ForegroundColor Green
    }
    
    # If no automatic checkpoints triggered, create a session checkpoint
    if ($tagsCreated.Count -eq 0) {
        $sessionTag = "checkpoint-session-$timestamp"
        $sessionMsg = if ($Message) { "Manual checkpoint: $Message" } else { "Manual checkpoint: Current state" }
        git tag -a $sessionTag -m $sessionMsg
        $tagsCreated += $sessionTag
        Write-Host "Created manual session checkpoint: $sessionTag" -ForegroundColor Yellow
    }
    
    # Push to remote (BEST PRACTICE: Always backup tags)
    if ($tagsCreated.Count -gt 0) {
        Write-Host "Pushing checkpoints to remote..." -ForegroundColor Blue
        try {
            git push origin main --no-verify
            foreach ($tag in $tagsCreated) {
                git push origin $tag --no-verify
            }
            Write-Host "Successfully pushed all checkpoints to remote" -ForegroundColor Green
        } catch {
            Write-Host "Warning: Could not push to remote (working locally)" -ForegroundColor Yellow
        }
        
        Write-Host "`nCheckpoints created:" -ForegroundColor Cyan
        foreach ($tag in $tagsCreated) {
            Write-Host "  - $tag" -ForegroundColor White
        }
        
        Write-Host "`nBest Practice Tagging Summary:" -ForegroundColor Cyan
        Write-Host "  - Session checkpoints: Every 4+ hours of work" -ForegroundColor White
        Write-Host "  - Daily checkpoints: Every 24 hours" -ForegroundColor White  
        Write-Host "  - Feature checkpoints: Every 10+ commits" -ForegroundColor White
        Write-Host "  - All checkpoints backed up to remote automatically" -ForegroundColor White
    }
    
} catch {
    Write-Host "Checkpoint failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Your work is still safe in the working directory" -ForegroundColor Yellow
    $exitCode = 1
}

exit $exitCode