# GitHub Copilot & MCP Accessibility Analysis Setup

## 🎯 Overview

This guide explains how to set up automated accessibility analysis for your projects using:

1. **GitHub Actions** - Automated PR analysis with GitHub Copilot
2. **MCP Accessibility Evaluator** - Advanced local analysis with AI assistants (Claude, Copilot, etc.)

Both approaches analyze code against WCAG 2.1 guidelines, WAI-ARIA best practices, and MDN accessibility standards.

## 🚀 Quick Setup Options

### Option 1: GitHub Actions (Automated PR Analysis)

Automatically runs accessibility checks when Pull Requests are created.

#### 1. Enable GitHub Actions

1. Go to your repository Settings → Actions → General
2. Select "Allow all actions and reusable workflows"
3. Save the changes

#### 2. Add Required Secrets

In your repository Settings → Secrets and variables → Actions, add:

| Secret | Description | Required |
|--------|-------------|----------|
| `GITHUB_TOKEN` | Automatically provided | ✅ Yes |
| `COPILOT_ACCESS_TOKEN` | GitHub Copilot API token | ⚠️ Optional |

#### 3. Configure Branch Protection

1. Go to Settings → Branches
2. Add rule for `main` and `develop` branches
3. Enable "Require status checks to pass before merging"
4. Add the Copilot accessibility check to required status checks

### Option 2: MCP Accessibility Evaluator (Local AI Analysis)

Use with AI assistants like Claude Desktop or GitHub Copilot for real-time accessibility evaluation.

#### 1. Install MCP Server

```bash
# Clone or copy the MCP accessibility evaluator
cd mcp-accessibility-evaluator
npm install
npm run build
```

#### 2. Configure Your AI Assistant

**For Claude Desktop:**

Edit your Claude configuration file (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "accessibility-evaluator": {
      "command": "node",
      "args": ["/path/to/mcp-accessibility-evaluator/dist/index.js"]
    }
  }
}
```

**For GitHub Copilot (via VS Code):**

Install the MCP extension and configure in VS Code settings:

```json
{
  "mcp.servers": {
    "accessibility-evaluator": {
      "command": "node",
      "args": ["/path/to/mcp-accessibility-evaluator/dist/index.js"]
    }
  }
}
```

#### 3. Use MCP Tools

Once configured, you can use these commands with your AI assistant:

```
# Evaluate HTML content
Use evaluate_accessibility to check this HTML: <html>...</html>

# Check WCAG compliance
Check WCAG AA compliance for https://example.com

# Validate ARIA usage
Validate ARIA attributes in my component file

# Fetch latest documentation
Fetch accessibility documentation from W3C and MDN
```

## 🔧 How It Works

### GitHub Actions Workflow

The `copilot-accessibility.yml` workflow automatically runs when:

- ✅ PR is opened
- ✅ PR is updated with new commits
- ✅ PR is reopened
- ✅ Target branches: `main`, `develop`

### MCP Server Tools

The MCP accessibility evaluator provides four main tools:

1. **`evaluate_accessibility`** - Comprehensive accessibility evaluation
   - Checks images for alt text
   - Validates heading structure
   - Ensures form controls have labels
   - Runs axe-core checks

2. **`check_wcag_compliance`** - WCAG 2.1 compliance checking
   - Determines compliance level (A, AA, AAA)
   - Provides detailed compliance report
   - Generates specific recommendations

3. **`validate_aria`** - ARIA usage validation
   - Validates ARIA roles and attributes
   - Checks parent-child relationships
   - Detects redundant or invalid ARIA

4. **`fetch_accessibility_docs`** - Documentation retrieval
   - Fetches latest W3C WCAG guidelines
   - Retrieves ARIA specifications
   - Gets MDN accessibility guides

### What Gets Checked

#### ⚠️ Critical Issues (Will Block PR)

- Missing `alt` attributes on images
- Form controls without labels
- Non-semantic HTML for interactive elements
- Missing ARIA attributes where required
- Invalid ARIA roles or properties
- Skipped heading levels
- Hidden focusable elements

#### ℹ️ Recommendations (Warnings)

- Heading hierarchy issues
- Color contrast concerns
- Keyboard navigation improvements
- Screen reader compatibility
- Redundant ARIA roles
- Empty ARIA attributes

#### ✅ Best Practices

- Semantic HTML usage
- Proper ARIA implementation
- WCAG 2.1 compliance
- WAI-ARIA guidelines

## 📋 Example Analysis Output

### GitHub Actions PR Comment

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
...
```

### MCP Analysis Output

```json
{
  "issues": [
    {
      "type": "error",
      "rule": "WCAG 1.1.1",
      "message": "Images must have alternative text",
      "element": "<img src=\"logo.png\">",
      "selector": "img",
      "standard": "WCAG",
      "level": "A",
      "impact": "critical"
    }
  ],
  "summary": {
    "totalIssues": 1,
    "errors": 1,
    "warnings": 0,
    "byStandard": { "WCAG": 1 },
    "byImpact": { "critical": 1 }
  },
  "passedChecks": ["WCAG: headings-structure", "WCAG: form-labels"]
}
```

## 🛠️ Customization

### Adding Custom Rules to MCP

Create custom accessibility rules by extending the evaluator:

```typescript
// custom-rules.ts
export function checkCustomRule($: CheerioAPI): AccessibilityIssue[] {
  const issues: AccessibilityIssue[] = [];
  
  // Your custom logic here
  $('button').each((_, element) => {
    // Check for specific patterns
  });
  
  return issues;
}
```

### Modifying GitHub Actions Workflow

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

### Using MCP with Different File Types

```bash
# Evaluate local HTML file
Use evaluate_accessibility with the HTML from ./src/components/MyComponent.html

# Check built application
Check WCAG compliance for http://localhost:3000

# Validate multiple files
Validate ARIA usage in all files in ./src/components/
```

## 🔍 Testing the Setup

### Testing GitHub Actions

1. Create a test PR with accessibility issues
2. Verify workflow runs automatically
3. Check PR comment for analysis results
4. Download artifacts for full report

### Testing MCP Server

```bash
# 1. Run tests
cd mcp-accessibility-evaluator
npm test

# 2. Test with example HTML
Use evaluate_accessibility with the HTML from ./examples/test-page.html

# 3. Verify all tools work
- Evaluate a sample page
- Check WCAG compliance 
- Validate ARIA usage
- Fetch documentation
```

## 🚨 Troubleshooting

### GitHub Actions Issues

| Problem | Solution |
|---------|----------|
| Workflow not running | Check branch protection and permissions |
| No comments posted | Verify `pull-requests: write` permission |
| False positives | Customize grep patterns and rules |

### MCP Server Issues

| Problem | Solution |
|---------|----------|
| Server not connecting | Check path in configuration |
| Tools not available | Verify server is running |
| Type errors | Run `npm install` to get dependencies |
| No results | Check HTML format and content |

## 📚 Resources

### Documentation

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/standards-guidelines/wcag/docs/)
- [WAI-ARIA Best Practices](https://www.w3.org/TR/wai-aria/)
- [MDN Accessibility Guide](https://developer.mozilla.org/en-US/docs/Web/Accessibility/Guides)
- [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)

### Tools

- [MCP SDK Documentation](https://github.com/anthropics/model-context-protocol)
- [axe-core](https://github.com/dequelabs/axe-core) - Accessibility testing library
- [pa11y](https://pa11y.org/) - Automated accessibility testing
- [Lighthouse](https://developers.google.com/web/tools/lighthouse) - Performance and accessibility auditing

### MCP Accessibility Evaluator

- Location: `./mcp-accessibility-evaluator/`
- Tests: Run `npm test` for comprehensive test suite
- Documentation: See `./mcp-accessibility-evaluator/README.md`

## 🤝 Contributing

To improve the accessibility analysis tools:

1. Fork the repository
2. Create a feature branch
3. Add new accessibility checks
4. Write tests for new features
5. Submit a pull request

### Contributing to MCP Server

```bash
cd mcp-accessibility-evaluator
npm install
npm test
# Make your changes
npm run test:coverage
```

## 📄 License

This setup is provided under the MIT License. Feel free to modify and adapt for your needs.
