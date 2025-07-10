# GitHub Service - Auto-Running PR Workflows

This repository demonstrates how to set up automated services that run when Pull Requests are created on GitHub. The workflows include comprehensive testing, security scanning, deployment previews, and automated dependency management.

## 🚀 Features

- **Automated PR Checks**: Linting, testing, and build verification
- **Deployment Previews**: Automatic preview deployments for each PR
- **Security Scanning**: Vulnerability detection and license compliance
- **Performance Testing**: Lighthouse CI integration
- **Accessibility Testing**: Automated a11y checks
- **GitHub Copilot Integration**: AI-powered accessibility analysis
- **Dependency Management**: Automated updates and security fixes

## 📁 Workflow Structure

```
.github/workflows/
├── pr-check.yml              # Basic PR checks (lint, test, build)
├── pr-deploy-preview.yml     # Deployment previews and advanced testing
├── dependency-updates.yml    # Automated dependency management
└── copilot-accessibility.yml # GitHub Copilot accessibility analysis
```

## 🛠️ Setup Instructions

### 1. Repository Configuration

1. **Enable GitHub Actions**: Go to your repository Settings → Actions → General and ensure "Allow all actions and reusable workflows" is selected.

2. **Set up Branch Protection** (Recommended):
   - Go to Settings → Branches
   - Add rule for `main` and `develop` branches
   - Enable "Require status checks to pass before merging"
   - Select the required status checks from the workflows below

### 2. Required Secrets

Add these secrets in your repository Settings → Secrets and variables → Actions:

| Secret Name         | Description                         | Required For        |
| ------------------- | ----------------------------------- | ------------------- |
| `GITHUB_TOKEN`      | Automatically provided by GitHub    | All workflows       |
| `SNYK_TOKEN`        | Snyk security scanning              | Security scanning   |
| `VERCEL_TOKEN`      | Vercel deployment (if using Vercel) | Deployment previews |
| `TEST_DATABASE_URL` | Test database connection string     | Integration tests   |

### 3. Package.json Scripts

Ensure your `package.json` includes these scripts:

```json
{
  "scripts": {
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:coverage": "jest --coverage",
    "test:integration": "jest --config jest.integration.config.js",
    "test:a11y": "pa11y-ci",
    "build": "next build",
    "security:check": "npm audit --audit-level=moderate"
  }
}
```

### 4. Configuration Files

#### ESLint Configuration (`.eslintrc.js`)

```javascript
module.exports = {
  extends: ["next/core-web-vitals", "@typescript-eslint/recommended"],
  rules: {
    // Your custom rules
  },
};
```

#### Jest Configuration (`jest.config.js`)

```javascript
module.exports = {
  testEnvironment: "jsdom",
  setupFilesAfterEnv: ["<rootDir>/jest.setup.js"],
  collectCoverageFrom: ["src/**/*.{js,jsx,ts,tsx}", "!src/**/*.d.ts"],
};
```

#### Lighthouse CI Configuration (`.lighthouserc.js`)

```javascript
module.exports = {
  ci: {
    collect: {
      url: ["http://localhost:3000"],
      startServerCommand: "npm run start",
    },
    assert: {
      assertions: {
        "categories:performance": ["warn", { minScore: 0.8 }],
        "categories:accessibility": ["error", { minScore: 0.9 }],
      },
    },
  },
};
```

## 🔄 Workflow Triggers

### PR Check Workflow (`pr-check.yml`)

- **Triggers**: PR opened, synchronized, or reopened
- **Branches**: `main`, `develop`
- **Jobs**:
  - Linting and code quality
  - Unit tests with coverage
  - Build verification
  - Security audit
  - Integration tests (for main branch PRs)

### Deployment Preview Workflow (`pr-deploy-preview.yml`)

- **Triggers**: PR opened, synchronized, or reopened
- **Branches**: `main`, `develop`
- **Jobs**:
  - Docker image build and push
  - Preview deployment
  - Performance testing (Lighthouse CI)
  - Accessibility testing

### Dependency Updates Workflow (`dependency-updates.yml`)

- **Triggers**: PR events + weekly schedule (Sundays 2 AM UTC)
- **Jobs**:
  - Automated dependency updates
  - Security scanning (Snyk + CodeQL)
  - License compliance checking

### Copilot Accessibility Workflow (`copilot-accessibility.yml`)

- **Triggers**: PR opened, synchronized, or reopened
- **Branches**: `main`, `develop`
- **Jobs**:
  - AI-powered accessibility analysis
  - WCAG 2.1 compliance checking
  - WAI-ARIA best practices validation
  - Automated PR comments with findings

## 🤖 GitHub Copilot Integration

### How Copilot Accessibility Analysis Works

The Copilot accessibility workflow automatically analyzes your PR changes for accessibility issues based on WCAG 2.1 guidelines and WAI-ARIA best practices.

#### What It Checks:

1. **Missing Alt Attributes**: Images without descriptive alt text
2. **Form Accessibility**: Form controls without proper labels
3. **Semantic HTML**: Non-semantic elements used for interactive purposes
4. **Heading Structure**: Proper heading hierarchy
5. **Color Contrast**: Basic color contrast validation
6. **ARIA Attributes**: Proper usage of WAI-ARIA attributes

#### How to Use:

1. **Automatic Analysis**: The workflow runs automatically on every PR
2. **PR Comments**: Copilot posts detailed analysis as PR comments
3. **Summary Report**: Quick overview of issues found and recommendations
4. **Artifact Downloads**: Full analysis reports available as workflow artifacts

#### Example Copilot Comment:

```
🤖 GitHub Copilot Accessibility Analysis

PR Information
- PR Number: 123
- Base Branch: origin/main
- Analysis Date: 2024-01-15 10:30:00 UTC

Changed Files Analyzed
- `src/components/Button.tsx`
- `src/pages/Home.tsx`

Accessibility Analysis

Analyzing: src/components/Button.tsx
- ⚠️ Missing alt attributes: Images should have descriptive alt text
- ℹ️ Heading structure: Verify proper heading hierarchy (h1 → h2 → h3)

Analyzing: src/pages/Home.tsx
- ✅ No obvious accessibility issues detected

Recommendations

WCAG 2.1 Guidelines to Follow:
1. Perceivable: Ensure content is perceivable by all users
2. Operable: Make functionality operable via keyboard and other input methods
3. Understandable: Make content and operation understandable
4. Robust: Ensure compatibility with assistive technologies
```

### Customizing Copilot Analysis

You can customize the accessibility checks by modifying the `copilot-accessibility.yml` workflow:

```yaml
# Add custom accessibility rules
- name: Custom accessibility check
  run: |
    # Your custom accessibility validation logic
    echo "Running custom accessibility checks..."
```

## 🎯 Customization

### Adding Custom Checks

1. **Create a new workflow file** in `.github/workflows/`
2. **Define triggers** using the `on` section
3. **Add jobs** with specific steps
4. **Configure permissions** if needed

Example custom workflow:

```yaml
name: Custom PR Check

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  custom-check:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run custom script
        run: |
          echo "Running custom check..."
          # Your custom logic here
```

### Environment-Specific Workflows

Create separate workflows for different environments:

```yaml
# .github/workflows/staging-deploy.yml
name: Deploy to Staging

on:
  pull_request:
    types: [closed]
    branches: [develop]

jobs:
  deploy-staging:
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    steps:
      # Deployment steps for staging
```

## 📊 Monitoring and Notifications

### Status Badges

Add these badges to your README:

```markdown
![PR Checks](https://github.com/{owner}/{repo}/workflows/PR%20Checks/badge.svg)
![Deployment Preview](https://github.com/{owner}/{repo}/workflows/PR%20Deployment%20Preview/badge.svg)
![Dependency Updates](https://github.com/{owner}/{repo}/workflows/Dependency%20Updates%20%26%20Security/badge.svg)
```

### Slack/Discord Notifications

Add notification steps to your workflows:

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    channel: "#deployments"
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 🔧 Troubleshooting

### Common Issues

1. **Workflow not triggering**:

   - Check branch protection rules
   - Verify workflow file syntax
   - Ensure workflows are in `.github/workflows/` directory

2. **Permission errors**:

   - Review workflow permissions
   - Check repository settings
   - Verify secret names and values

3. **Build failures**:
   - Check package.json scripts
   - Verify Node.js version compatibility
   - Review dependency installation

### Debug Mode

Enable debug logging by setting the secret `ACTIONS_STEP_DEBUG` to `true` in your repository settings.

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Examples](https://github.com/actions/starter-workflows)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
