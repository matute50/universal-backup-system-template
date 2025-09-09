# 🚀 Quick Start Guide

## Installation (Choose One Method)

### Method 1: Automatic Installation
```bash
# In your project directory
curl -fsSL https://raw.githubusercontent.com/your-repo/backup-system/main/install.ps1 | powershell

# Or with options
powershell -c "irm https://raw.githubusercontent.com/your-repo/backup-system/main/install.ps1 | iex" -Framework react -IncludeCopilotInstructions
```

### Method 2: Manual Installation
```bash
# 1. Download template
git clone https://github.com/your-repo/backup-system-template temp-backup
cd your-project

# 2. Copy files
cp -r ../temp-backup/scripts ./
cp ../temp-backup/package.json.template ./package-backup.json

# 3. Merge package.json scripts
# Copy the backup scripts from package-backup.json to your package.json

# 4. Test installation
npm run ai:safety-check
```

### Method 3: Individual Files (Minimum Viable)
```bash
# Just copy the core scripts you need
mkdir scripts
cp template/scripts/checkpoint-simple.ps1 scripts/
cp template/scripts/ai-safety-check.ps1 scripts/

# Add to package.json:
"save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1",
"ai:safety-check": "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
```

## First Steps After Installation

### 1. Test the System
```bash
# Verify everything works
npm run health:check

# Create first checkpoint
npm run save

# Test AI safety check
npm run ai:safety-check
```

### 2. Customize for Your Framework
```bash
# Edit health check for your specific needs
notepad scripts/health-check.ps1

# Update package.json scripts to match your build process
# See examples/ directory for framework-specific configurations
```

### 3. Create Team Documentation
```bash
# Add to your README.md:
## Backup System Commands
- `npm run save` - Quick checkpoint with current changes  
- `npm run checkpoint:feature` - Feature checkpoint with description
- `npm run ai:safety-check` - Verify backups before major changes
- `npm run health:check` - Verify project health
```

## Daily Usage

### Before Starting Work
```bash
# Check project health
npm run health:check

# Create session checkpoint
npm run checkpoint:session
```

### During Development
```bash
# Save progress frequently
npm run save

# Before major changes
npm run ai:safety-check
```

### Before Major Refactors
```bash
# Create feature checkpoint
npm run checkpoint:feature -Message "Before user authentication refactor"

# Verify safety
npm run ai:safety-check -ChangeDescription "User auth refactor"
```

### End of Day
```bash
# Save final state
npm run save

# Optional: Create daily checkpoint
npm run checkpoint:daily
```

## Emergency Situations

### Rollback to Last Checkpoint
```bash
# List available checkpoints
git tag --list --sort=-version:refname

# Rollback to specific checkpoint
git checkout checkpoint-feature-20250909_1234

# Create recovery branch
git checkout -b emergency-recovery-$(date +%s)
```

### Complete Project Recovery
```bash
# Use the emergency scripts
./scripts/emergency-procedures/complete-rollback.ps1

# Or manual recovery
git clone https://github.com/your-repo/your-project fresh-copy
cd fresh-copy
git checkout [last-known-good-checkpoint]
```

## Customization Examples

### React Project
```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build", 
    "test": "vitest",
    "lint": "eslint .",
    "health:check": "npm run lint && npm run build && npm run test",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1"
  }
}
```

### Node.js API
```json
{
  "scripts": {
    "dev": "nodemon src/server.ts",
    "build": "tsc",
    "test": "jest", 
    "lint": "eslint src/",
    "health:check": "npm run lint && npm run build && npm run test",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1"
  }
}
```

### Python Project (using npm for tooling)
```json
{
  "scripts": {
    "dev": "python manage.py runserver",
    "build": "python manage.py collectstatic --noinput",
    "test": "python manage.py test",
    "lint": "flake8 .",
    "health:check": "npm run lint && npm run test",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1"
  }
}
```

## Advanced Features

### AI Safety Protocol Integration
Add to your `.github/.copilot-instructions.md`:
```markdown
## AI Safety Protocol
Before making major changes, AI assistants MUST:
1. Run `npm run ai:safety-check`
2. Create checkpoint if needed: `npm run checkpoint:feature`
3. Announce rollback plan to user
```

### Custom Health Checks
Edit `scripts/health-check.ps1`:
```powershell
# Add your specific checks
if (Test-Path "dist") {
    Write-Host "✅ Build artifacts present" -ForegroundColor Green
} else {
    Write-Host "❌ No build artifacts found" -ForegroundColor Red
}

# Database connectivity (example)
try {
    # Your DB connection test
    Write-Host "✅ Database connected" -ForegroundColor Green
} catch {
    Write-Host "❌ Database connection failed" -ForegroundColor Red
}
```

### Automated Daily Checkpoints
Add to your CI/CD or as a scheduled task:
```yaml
# .github/workflows/daily-checkpoint.yml
name: Daily Checkpoint
on:
  schedule:
    - cron: '0 18 * * 1-5'  # 6 PM weekdays
jobs:
  checkpoint:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Create daily checkpoint
        run: npm run checkpoint:daily
```

## Troubleshooting

### PowerShell Execution Policy
```bash
# If scripts won't run:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```

### Git Tags Not Pushing
```bash
# Check remote
git remote -v

# Manual push tags
git push origin --tags
```

### Health Check Failing
```bash
# Check what's failing
npm run lint
npm run build  
npm run test

# Customize health check script for your project
```

## Support

- **Documentation**: See `examples/` directory for framework-specific configs
- **Issues**: Create GitHub issue with your framework and error details
- **Customization**: Edit scripts in `scripts/` directory for your needs

**🛡️ Remember: The backup system is there to enable confident changes, not prevent them!** 🚀