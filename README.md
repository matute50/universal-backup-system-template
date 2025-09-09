# 🛡️ Universal Backup & Checkpoint System

**A framework-agnostic Git-based backup and checkpoint system for any development project.**

[![GitHub Template](https://img.shields.io/badge/GitHub-Use%20This%20Template-brightgreen?logo=github)](https://github.com/HalbonLabs/universal-backup-system-template/generate)
[![Framework Agnostic](https://img.shields.io/badge/Framework-Agnostic-blue)](#framework-support)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](#requirements)
[![License](https://img.shields.io/badge/License-MIT-green)](#license)

## ⚡ **Quick Start**

### 1️⃣ Use This Template
Click **"Use this template"** above or visit: https://github.com/HalbonLabs/universal-backup-system-template/generate

### 2️⃣ Clone Your New Repo
```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME
cd YOUR_REPO_NAME
```

### 3️⃣ Install in Your Project
```bash
# Automatic installation
powershell -ExecutionPolicy Bypass -File ./install.ps1 -Framework auto-detect

# Or copy files manually
cp -r scripts/ ../your-existing-project/
cp package.json.template ../your-existing-project/package-backup.json
```

### 4️⃣ Test Installation
```bash
npm run ai:safety-check
npm run save
```

**🎉 Done! Your project now has enterprise-grade backup protection.**

---

## 🎯 Framework Support

### ✅ **Fully Supported:**
- **Frontend**: React, Vue, Angular, SvelteKit, Next.js, Nuxt, Vite projects
- **Backend**: Node.js, Express, NestJS, Python (Django/Flask), PHP, Ruby on Rails
- **Mobile**: React Native, Flutter, Ionic
- **Desktop**: Electron, Tauri
- **Static**: Jekyll, Hugo, Gatsby, 11ty
- **Any Git Repository**: Documentation, configs, dotfiles, etc.

### 🔧 **Works With:**
- **Package Managers**: npm, yarn, pnpm, pip, composer, gem, cargo, etc.
- **Git Hosts**: GitHub, GitLab, Bitbucket, Azure DevOps
- **Operating Systems**: Windows (PowerShell), macOS/Linux (bash versions available)

## 🛡️ Security Features

### 🔒 **Built-in Security:**
- **Secret Scanning**: Detects API keys, passwords, tokens in commits
- **Pre-commit Hooks**: Validates security before each commit
- **Dependency Scanning**: NPM audit, Python safety checks
- **AI Safety Protocol**: Validates AI-assisted changes
- **File Validation**: Prevents sensitive files from being committed

### 📋 **Security Tools:**
```bash
# Run security validation
npm run security:check

# Validate all dependencies  
npm run security:audit

# Check for secrets in codebase
npm run security:scan-secrets
```

## 📊 Monitoring & Analytics

### 🎯 **Performance Monitoring:**
- **Build Time Tracking**: Monitor compilation performance
- **Disk Usage Analysis**: Track project size and folder growth
- **Git Metrics**: Commit frequency, branch health, repository stats
- **System Resources**: Memory usage, disk space, CPU monitoring
- **Error Tracking**: Centralized logging with structured data

### 📈 **Analytics Commands:**
```bash
# Full performance analysis
npm run monitor:performance

# Disk usage breakdown
npm run monitor:disk

# Git repository analytics  
npm run monitor:git

# System resource monitoring
npm run monitor:system

# Error log analysis
npm run monitor:errors
```

## 🔔 Notification System

### 📢 **Supported Platforms:**
- **Slack**: Webhook integration with rich formatting
- **Discord**: Bot notifications with embed support
- **Microsoft Teams**: Adaptive card notifications
- **Email**: SMTP with HTML formatting
- **Custom Webhooks**: Any REST API endpoint

### ⚙️ **Configuration:**
```bash
# Copy notification template
cp notification-config.json.example notification-config.json

# Edit configuration
# Enable desired notification platforms
# Add webhook URLs and credentials
```

### 🚨 **Alert Types:**
- **Security Alerts**: Dangerous operations, secrets detected
- **Performance Alerts**: Slow builds, high resource usage  
- **Error Alerts**: Build failures, critical errors
- **Health Alerts**: Repository issues, dependency problems

## 🏃‍♂️ Usage Examples

### Basic Checkpointing
```bash
# Quick save with current changes
npm run save

# Feature checkpoint with description
npm run checkpoint:feature -Message "Add user authentication"

# Daily checkpoint
npm run checkpoint:daily
```

### AI Safety Protocol
```bash
# Before major AI-assisted changes
npm run ai:safety-check

# With custom description
npm run ai:safety-check -ChangeDescription "Database migration"
```

### Security & Monitoring
```bash
# Run security validation
npm run security:check

# Performance monitoring
npm run monitor:performance

# Error tracking analysis
npm run monitor:errors

# Full health check
npm run health:check
```

### Emergency Recovery
```bash
# List all checkpoints
git tag --list --sort=-version:refname

# Rollback to specific checkpoint
git checkout checkpoint-feature-20250909_1234

# Emergency procedures
npm run rollback:daily
```

## 📋 Configuration

### 1. Framework-Specific Commands

Edit `package.json` scripts section to match your framework:

**React/Next.js:**
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "test": "jest",
    "lint": "eslint .",
    "health:check": "npm run lint && npm run build && npm run test"
  }
}
```

**Vue/Nuxt:**
```json
{
  "scripts": {
    "dev": "nuxt dev", 
    "build": "nuxt build",
    "test": "vitest",
    "lint": "eslint .",
    "health:check": "npm run lint && npm run build && npm run test"
  }
}
```

**Angular:**
```json
{
  "scripts": {
    "dev": "ng serve",
    "build": "ng build",
    "test": "ng test --watch=false",
    "lint": "ng lint",
    "health:check": "npm run lint && npm run build && npm run test"
  }
}
```

**Python (Django/Flask):**
```json
{
  "scripts": {
    "dev": "python manage.py runserver",
    "build": "python manage.py collectstatic --noinput",
    "test": "python manage.py test",
    "lint": "flake8 .",
    "health:check": "npm run lint && npm run test && npm run build"
  }
}
```

### 2. Customize Checkpoint Triggers

Edit `scripts/checkpoint-simple.ps1` to adjust:
- **Session interval**: Change from 4 hours to your preference
- **Daily timing**: Adjust when daily checkpoints are created
- **Feature threshold**: Change from 10+ commits to your preference

### 3. Health Check Configuration

Edit `scripts/health-check.ps1` to include your project's specific health checks:
- Database connectivity
- API endpoint tests
- Build verification
- Dependency vulnerability checks

## 🎨 Framework-Specific Examples

### React + TypeScript + Vite
```bash
# Install backup system
cp -r backup-system-template/* my-react-app/

# Customize package.json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "test": "vitest",
    "lint": "eslint . --ext ts,tsx",
    "health:check": "npm run lint && npm run build && npm run test",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1",
    "checkpoint:feature": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type feature",
    "ai:safety-check": "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
  }
}
```

### Vue 3 + Composition API + Vite  
```bash
# Same scripts, different dev commands
{
  "scripts": {
    "dev": "vite",
    "build": "vue-tsc && vite build", 
    "test": "vitest",
    "lint": "eslint . --ext .vue,.ts,.js",
    "health:check": "npm run lint && npm run build && npm run test",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1"
  }
}
```

### Node.js + Express API
```bash
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

## 🔧 Advanced Configuration

### Custom Health Checks
```powershell
# In scripts/health-check.ps1, add your checks:

# Database connectivity
$dbResult = Invoke-Command { npm run db:ping }
if ($LASTEXITCODE -ne 0) { Write-Host "❌ Database connection failed" }

# API endpoints  
$apiResult = Invoke-RestMethod "http://localhost:3000/health"
if ($apiResult.status -ne "ok") { Write-Host "❌ API health check failed" }

# Custom build validation
npm run build:validate
if ($LASTEXITCODE -ne 0) { Write-Host "❌ Build validation failed" }
```

### Integration with CI/CD
```yaml
# .github/workflows/backup-validation.yml
name: Validate Backup System
on: [push, pull_request]
jobs:
  validate:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate checkpoints
        run: |
          git tag --list | grep checkpoint
          npm run health:check
```

## 🆘 Troubleshooting

### Common Issues:

**"PowerShell execution policy"**
```bash
# Fix: Update execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```

**"Git tags not pushing"**
```bash
# Fix: Check remote configuration
git remote -v
git push origin --tags
```

**"Health check failing"**
```bash
# Fix: Customize health check for your framework
# Edit scripts/health-check.ps1 with your specific commands
```

### Cross-Platform Support

**macOS/Linux versions:**
```bash
# Bash versions of scripts available in:
scripts/
├── checkpoint-simple.sh      # Bash version
├── ai-safety-check.sh        # Bash version  
└── health-check.sh           # Bash version
```

## 📚 Documentation

- **[Installation Guide](./docs/INSTALLATION.md)** - Step-by-step setup
- **[Framework Integration](./docs/FRAMEWORKS.md)** - Specific framework configurations
- **[AI Safety Protocol](./docs/AI-SAFETY.md)** - AI assistant integration
- **[Emergency Procedures](./docs/EMERGENCY.md)** - Disaster recovery
- **[Customization](./docs/CUSTOMIZATION.md)** - Advanced configuration

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/improvement`
3. Test on multiple frameworks
4. Submit pull request

## 📄 License

MIT License - Use in any project, commercial or personal.

---

**🚀 Start protecting your projects today!**