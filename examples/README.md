# 🎨 Framework-Specific Examples

This directory contains ready-to-use package.json configurations for popular frameworks.

## 🚀 React + TypeScript + Vite

**File**: `examples/react-vite-package.json`

```json
{
  "name": "my-react-app",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "lint:fix": "eslint . --ext ts,tsx --fix",
    "type-check": "tsc --noEmit",
    
    "health:check": "npm run lint && npm run type-check && npm run build && npm run test",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1",
    "checkpoint:feature": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type feature",
    "ai:safety-check": "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.15",
    "@types/react-dom": "^18.2.7",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@vitejs/plugin-react": "^4.0.3",
    "eslint": "^8.45.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "typescript": "^5.0.2",
    "vite": "^4.4.5",
    "vitest": "^0.34.0"
  }
}
```

## 🟢 Vue 3 + Composition API + Vite

**File**: `examples/vue-vite-package.json`

```json
{
  "name": "my-vue-app",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vue-tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:e2e": "playwright test",
    "lint": "eslint . --ext .vue,.js,.jsx,.cjs,.mjs,.ts,.tsx,.cts,.mts --fix --ignore-path .gitignore",
    "lint:fix": "eslint . --ext .vue,.js,.ts --fix",
    "type-check": "vue-tsc --noEmit",
    
    "health:check": "npm run lint && npm run type-check && npm run build && npm run test",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1",
    "checkpoint:feature": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type feature",
    "ai:safety-check": "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
  },
  "dependencies": {
    "vue": "^3.3.4"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.2.3",
    "@vue/eslint-config-typescript": "^11.0.3",
    "eslint": "^8.45.0",
    "eslint-plugin-vue": "^9.15.1",
    "typescript": "~5.1.6",
    "vite": "^4.4.6",
    "vitest": "^0.34.0",
    "vue-tsc": "^1.8.5"
  }
}
```

## 🅰️ Angular + TypeScript

**File**: `examples/angular-package.json`

```json
{
  "name": "my-angular-app",
  "version": "1.0.0",
  "scripts": {
    "ng": "ng",
    "start": "ng serve",
    "dev": "ng serve",
    "build": "ng build",
    "watch": "ng build --watch --configuration development",
    "test": "ng test --watch=false --browsers=ChromeHeadless",
    "test:watch": "ng test",
    "lint": "ng lint",
    "e2e": "ng e2e",
    
    "health:check": "npm run lint && npm run test && npm run build",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1",
    "checkpoint:feature": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type feature",
    "ai:safety-check": "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
  },
  "private": true,
  "dependencies": {
    "@angular/animations": "^16.1.0",
    "@angular/common": "^16.1.0",
    "@angular/compiler": "^16.1.0",
    "@angular/core": "^16.1.0",
    "@angular/forms": "^16.1.0",
    "@angular/platform-browser": "^16.1.0",
    "@angular/platform-browser-dynamic": "^16.1.0",
    "@angular/router": "^16.1.0",
    "rxjs": "~7.8.0",
    "tslib": "^2.3.0",
    "zone.js": "~0.13.0"
  },
  "devDependencies": {
    "@angular-devkit/build-angular": "^16.1.0",
    "@angular/cli": "~16.1.0",
    "@angular/compiler-cli": "^16.1.0",
    "@types/jasmine": "~4.3.0",
    "jasmine-core": "~4.6.0",
    "karma": "~6.4.0",
    "karma-chrome-launcher": "~3.2.0",
    "karma-coverage": "~2.2.0",
    "karma-jasmine": "~5.1.0",
    "karma-jasmine-html-reporter": "~2.1.0",
    "typescript": "~5.1.3"
  }
}
```

## 🟠 SvelteKit + TypeScript

**File**: `examples/sveltekit-package.json`

```json
{
  "name": "my-sveltekit-app",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite dev",
    "build": "vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:integration": "playwright test",
    "check": "svelte-kit sync && svelte-check --tsconfig ./tsconfig.json",
    "check:watch": "svelte-kit sync && svelte-check --tsconfig ./tsconfig.json --watch",
    "lint": "prettier --check . && eslint .",
    "format": "prettier --write .",
    
    "health:check": "npm run lint && npm run check && npm run build && npm run test",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1",
    "checkpoint:feature": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type feature",
    "ai:safety-check": "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
  },
  "devDependencies": {
    "@playwright/test": "^1.28.1",
    "@sveltejs/adapter-auto": "^2.0.0",
    "@sveltejs/kit": "^1.20.4",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.28.0",
    "eslint-config-prettier": "^8.5.0",
    "eslint-plugin-svelte": "^2.30.0",
    "prettier": "^2.8.0",
    "prettier-plugin-svelte": "^2.10.1",
    "svelte": "^4.0.5",
    "svelte-check": "^3.4.3",
    "tslib": "^2.4.1",
    "typescript": "^5.0.0",
    "vite": "^4.4.2",
    "vitest": "^0.34.0"
  }
}
```

## 🟢 Node.js + Express + TypeScript

**File**: `examples/node-express-package.json`

```json
{
  "name": "my-express-api",
  "version": "1.0.0",
  "main": "dist/server.js",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src/ --ext .ts",
    "lint:fix": "eslint src/ --ext .ts --fix",
    "type-check": "tsc --noEmit",
    
    "health:check": "npm run lint && npm run type-check && npm run build && npm run test",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1",
    "checkpoint:feature": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type feature",
    "ai:safety-check": "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.13",
    "@types/node": "^20.4.5",
    "@types/jest": "^29.5.3",
    "@typescript-eslint/eslint-plugin": "^6.2.0",
    "@typescript-eslint/parser": "^6.2.0",
    "eslint": "^8.45.0",
    "jest": "^29.6.1",
    "ts-jest": "^29.1.1",
    "tsx": "^3.12.7",
    "typescript": "^5.1.6"
  }
}
```

## 🐍 Python (Django/Flask) - Using npm for tooling

**File**: `examples/python-package.json`

```json
{
  "name": "my-python-app",
  "version": "1.0.0",
  "description": "Python project with backup system",
  "scripts": {
    "dev": "python manage.py runserver",
    "build": "python manage.py collectstatic --noinput",
    "test": "python manage.py test",
    "test:coverage": "coverage run --source='.' manage.py test && coverage report",
    "lint": "flake8 . && black --check .",
    "lint:fix": "black . && isort .",
    "migrate": "python manage.py migrate",
    
    "health:check": "npm run lint && npm run test && python manage.py check",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1",
    "checkpoint:feature": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type feature",
    "ai:safety-check": "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
  },
  "backup-system": {
    "version": "1.0.0",
    "framework": "python",
    "notes": "Python project using npm for backup system tooling"
  }
}
```

## 💎 Ruby on Rails

**File**: `examples/rails-package.json`

```json
{
  "name": "my-rails-app",
  "version": "1.0.0",
  "description": "Rails project with backup system",
  "scripts": {
    "dev": "rails server",
    "build": "rails assets:precompile",
    "test": "rails test",
    "lint": "rubocop",
    "lint:fix": "rubocop -a",
    "db:migrate": "rails db:migrate",
    "db:seed": "rails db:seed",
    
    "health:check": "npm run lint && npm run test && rails runner 'ActiveRecord::Base.connection'",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1",
    "checkpoint:feature": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type feature",
    "ai:safety-check": "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
  },
  "backup-system": {
    "version": "1.0.0", 
    "framework": "ruby",
    "notes": "Ruby on Rails project using npm for backup system tooling"
  }
}
```

## 📱 React Native + Expo

**File**: `examples/react-native-package.json`

```json
{
  "name": "my-react-native-app",
  "version": "1.0.0",
  "main": "node_modules/expo/AppEntry.js",
  "scripts": {
    "start": "expo start",
    "dev": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios", 
    "web": "expo start --web",
    "build": "expo build",
    "test": "jest",
    "lint": "eslint .",
    "type-check": "tsc --noEmit",
    
    "health:check": "npm run lint && npm run type-check && npm run test",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1",
    "checkpoint:feature": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type feature",
    "ai:safety-check": "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
  },
  "dependencies": {
    "expo": "~49.0.0",
    "react": "18.2.0",
    "react-native": "0.72.3"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0",
    "@types/react": "~18.2.14",
    "typescript": "^5.1.3",
    "jest": "^29.6.1"
  }
}
```

## 🔧 Generic/Custom Project

**File**: `examples/generic-package.json`

```json
{
  "name": "my-custom-project",
  "version": "1.0.0",
  "description": "Custom project with backup system",
  "scripts": {
    "dev": "echo 'Replace with your dev command'",
    "build": "echo 'Replace with your build command'",
    "test": "echo 'Replace with your test command'",
    "lint": "echo 'Replace with your lint command'",
    
    "health:check": "echo 'Customize health check in ./scripts/health-check.ps1'",
    "save": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1",
    "checkpoint:auto": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type auto",
    "checkpoint:feature": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type feature", 
    "checkpoint:daily": "powershell -ExecutionPolicy Bypass -File ./scripts/checkpoint-simple.ps1 -Type daily",
    "rollback:daily": "powershell -ExecutionPolicy Bypass -File ./scripts/rollback-daily.ps1",
    "ai:safety-check": "powershell -ExecutionPolicy Bypass -File ./scripts/ai-safety-check.ps1"
  },
  "backup-system": {
    "version": "1.0.0",
    "framework": "custom",
    "notes": "Customize scripts/ directory for your specific project needs"
  }
}
```

## 📝 Usage Instructions

1. **Choose your framework** example above
2. **Copy the relevant package.json** configuration
3. **Customize commands** to match your specific setup
4. **Test the health check**: `npm run health:check`
5. **Create first checkpoint**: `npm run save`

## 🔧 Customization Tips

### Health Check Customization

Edit `scripts/health-check.ps1` to include framework-specific checks:

```powershell
# React/Vue/Angular - Check bundle size
if (Test-Path "dist") {
    $bundleSize = (Get-ChildItem "dist" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    if ($bundleSize -gt 10) {
        Write-Host "⚠️  Large bundle size: $([math]::Round($bundleSize, 1)) MB" -ForegroundColor Yellow
    }
}

# Node.js - Check for security vulnerabilities  
npm audit --audit-level moderate
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Security vulnerabilities detected" -ForegroundColor Yellow
}

# Python - Check requirements
if (Test-Path "requirements.txt") {
    pip check
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Python dependency conflicts" -ForegroundColor Yellow
    }
}
```

### Cross-Platform Scripts

For macOS/Linux, use bash versions:

```bash
# package.json for Unix systems
"save": "./scripts/checkpoint-simple.sh",
"ai:safety-check": "./scripts/ai-safety-check.sh"
```

The backup system adapts to any framework - just customize the commands! 🚀