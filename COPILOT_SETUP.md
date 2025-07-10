# GitHub Copilot Accessibility Analysis Setup

## 🎯 Overview

This guide explains how to set up GitHub Copilot to automatically run accessibility analysis when Pull Requests are created. The system analyzes code changes against WCAG 2.1 guidelines and WAI-ARIA best practices.

## 🚀 Quick Setup

### 1. Enable GitHub Actions

1. Go to your repository Settings → Actions → General
2. Select "Allow all actions and reusable workflows"
3. Save the changes

### 2. Add Required Secrets

In your repository Settings → Secrets and variables → Actions, add:

| Secret | Description | Required |
|--------|-------------|----------|
| `GITHUB_TOKEN` | Automatically provided | ✅ Yes |
| `COPILOT_ACCESS_TOKEN` | GitHub Copilot API token | ⚠️ Optional |

### 3. Configure Branch Protection

1. Go to Settings → Branches
2. Add rule for `main` and `develop` branches
3. Enable "Require status checks to pass before merging"
4. Add the Copilot accessibility check to required status checks

## 🔧 How It Works

### Workflow Triggers

The `copilot-accessibility.yml` workflow automatically runs when:

- ✅ PR is opened
- ✅ PR is updated with new commits
- ✅ PR is reopened
- ✅ Target branches: `main`, `develop`

### Analysis Process

1. **File Detection**: Identifies changed files in the PR
2. **Content Analysis**: Scans for accessibility issues
3. **Report Generation**: Creates detailed analysis report
4. **PR Comment**: Posts findings as PR comment
5. **Artifact Upload**: Saves full report for download

### What Copilot Checks

#### ⚠️ Critical Issues (Will Block PR)
- Missing `alt` attributes on images
- Form controls without labels
- Non-semantic HTML for interactive elements
- Missing ARIA attributes where required

#### ℹ️ Recommendations (Warnings)
- Heading hierarchy issues
- Color contrast concerns
- Keyboard navigation improvements
- Screen reader compatibility

#### ✅ Best Practices
- Semantic HTML usage
- Proper ARIA implementation
- WCAG 2.1 compliance
- WAI-ARIA guidelines

## 📋 Example Analysis Output

When you create a PR, Copilot will post a comment like this:

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

Testing Checklist:
- [ ] Keyboard navigation works
- [ ] Screen reader compatibility
- [ ] Color contrast meets WCAG standards
- [ ] Focus indicators are visible
- [ ] Form labels are properly associated
- [ ] Images have descriptive alt text
- [ ] Headings follow logical hierarchy
```

## 🛠️ Customization

### Adding Custom Rules

Edit the `copilot-accessibility.yml` workflow to add custom checks:

```yaml
- name: Custom accessibility check
  run: |
    # Add your custom accessibility validation
    echo "Running custom checks..."
    
    # Example: Check for specific patterns
    if grep -r "dangerouslySetInnerHTML" src/; then
      echo "- ⚠️ **Security**: Avoid dangerouslySetInnerHTML for accessibility"
    fi
```

### Modifying File Types

Change which files are analyzed by modifying the grep pattern:

```bash
# Current: Only JS/TS/React files
grep -E '\.(jsx?|tsx?|vue|html)$' changed_files.txt

# Custom: Add more file types
grep -E '\.(jsx?|tsx?|vue|html|css|scss)$' changed_files.txt
```

### Custom Severity Levels

Modify the analysis to use different severity levels:

```bash
# Critical issues (block PR)
echo "- 🚨 **Critical**: $issue" >> accessibility_analysis.md

# Warnings (allow PR)
echo "- ⚠️ **Warning**: $issue" >> accessibility_analysis.md

# Info (suggestions)
echo "- ℹ️ **Info**: $issue" >> accessibility_analysis.md
```

## 🔍 Testing the Setup

### 1. Create a Test PR

1. Create a new branch: `git checkout -b test-accessibility`
2. Make some changes to trigger accessibility issues
3. Push and create a PR
4. Check the Actions tab for the Copilot workflow

### 2. Verify Analysis

Look for:
- ✅ Workflow runs automatically
- ✅ PR comment is posted
- ✅ Analysis artifacts are uploaded
- ✅ Issues are correctly identified

### 3. Test Different Scenarios

- **Good code**: Should show ✅ passes
- **Missing alt text**: Should show ⚠️ warning
- **Form without labels**: Should show ⚠️ warning
- **Non-semantic HTML**: Should show ⚠️ warning

## 🚨 Troubleshooting

### Workflow Not Running

1. **Check branch protection**: Ensure workflows can run
2. **Verify file location**: Workflow must be in `.github/workflows/`
3. **Check syntax**: Validate YAML syntax
4. **Review permissions**: Ensure proper permissions are set

### No Comments Posted

1. **Check permissions**: Workflow needs `pull-requests: write`
2. **Verify token**: Ensure `GITHUB_TOKEN` is available
3. **Check logs**: Review workflow logs for errors

### False Positives

1. **Customize rules**: Modify the grep patterns
2. **Add exceptions**: Create allowlist for specific cases
3. **Adjust severity**: Change warning levels as needed

## 📚 Resources

### Documentation
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/standards-guidelines/wcag/docs/)
- [WAI-ARIA Best Practices](https://www.w3.org/TR/wai-aria/)
- [MDN Accessibility Guide](https://developer.mozilla.org/en-US/docs/Web/Accessibility/Guides)
- [Material-UI Accessibility](https://mui.com/material-ui/getting-started/)

### Tools
- [axe-core](https://github.com/dequelabs/axe-core) - Accessibility testing library
- [pa11y](https://pa11y.org/) - Automated accessibility testing
- [Lighthouse](https://developers.google.com/web/tools/lighthouse) - Performance and accessibility auditing

## 🤝 Contributing

To improve the Copilot accessibility analysis:

1. Fork the repository
2. Create a feature branch
3. Add new accessibility checks
4. Test with various scenarios
5. Submit a pull request

## 📄 License

This setup is provided under the MIT License. Feel free to modify and adapt for your needs. 