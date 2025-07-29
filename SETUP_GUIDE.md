# GitHub Service + MCP Accessibility Evaluator Setup Guide

## 🎯 Overview

This guide shows you how to connect your GitHub service to the MCP accessibility evaluator for comprehensive PR accessibility analysis.

## ✅ What's Already Set Up

1. **GitHub Actions Workflow**: Enhanced `copilot-accessibility.yml` with MCP integration
2. **MCP Server**: Built and ready at `/Users/tvance/Sites/github-service/mcp-accessibility-evaluator/dist/index.js`
3. **Configuration**: Generated MCP config for AI assistants

## 🚀 Quick Start

### For Automated PR Analysis (GitHub Actions)

**This is already working!** Your enhanced workflow will automatically:

- Run on every PR (opened/updated/reopened)
- Build and use the MCP accessibility evaluator
- Analyze changed files for accessibility issues
- Post detailed feedback with WCAG compliance info
- Provide actionable recommendations

**Test it**: Create a PR with an image missing alt text, and you'll see the analysis!

### For Local AI Assistant Integration

#### Option 1: Claude Desktop

1. **Copy the configuration**:
   ```bash
   cat mcp-accessibility-evaluator/mcp-config.json
   ```

2. **Open Claude's config file**:
   ```bash
   # On macOS:
   open ~/Library/Application\ Support/Claude/claude_desktop_config.json
   
   # On Linux:
   open ~/.config/Claude/claude_desktop_config.json
   ```

3. **Add the MCP server configuration**:
   ```json
   {
     "mcpServers": {
       "accessibility-evaluator": {
         "command": "node",
         "args": ["/Users/tvance/Sites/github-service/mcp-accessibility-evaluator/dist/index.js"],
         "env": {
           "NODE_ENV": "production"
         }
       }
     }
   }
   ```

4. **Restart Claude Desktop**

#### Option 2: Cursor/VS Code with MCP Extension

1. **Install the MCP extension** in your editor

2. **Add to VS Code settings.json**:
   ```json
   {
     "mcp.servers": {
       "accessibility-evaluator": {
         "command": "node",
         "args": ["/Users/tvance/Sites/github-service/mcp-accessibility-evaluator/dist/index.js"]
       }
     }
   }
   ```

## 🧪 Testing Your Setup

### Test GitHub Actions

1. **Create a test branch**:
   ```bash
   git checkout -b test-accessibility
   ```

2. **Add a file with accessibility issues**:
   ```bash
   echo '<html><body><img src="test.jpg"><button><i class="icon"></i></button></body></html>' > test.html
   git add test.html
   git commit -m "Add test file with accessibility issues"
   git push origin test-accessibility
   ```

3. **Create a PR** and watch for the accessibility analysis comment!

### Test Local AI Assistant

Ask your AI assistant:

```
Use evaluate_accessibility to check this HTML:
<html>
  <body>
    <img src="logo.png">
    <button><i class="icon-close"></i></button>
    <form>
      <input type="email" placeholder="Enter email">
    </form>
  </body>
</html>
```

**Expected response**: Detailed accessibility analysis with explanations, user impact, and fix recommendations.

## 🛠️ Available MCP Tools

Once connected, your AI assistant can use these tools:

### `evaluate_accessibility`
**Usage**: `"Evaluate accessibility of this HTML: <html>...</html>"`
**Purpose**: Comprehensive accessibility evaluation with detailed explanations

### `check_wcag_compliance`
**Usage**: `"Check WCAG AA compliance for https://example.com"`
**Purpose**: WCAG 2.1 compliance analysis with scoring

### `validate_aria`
**Usage**: `"Validate ARIA usage in this component: <div role='button'>..."`
**Purpose**: ARIA best practices validation

### `fetch_accessibility_docs`
**Usage**: `"Fetch the latest accessibility documentation"`
**Purpose**: Get current W3C/MDN accessibility standards

## 🔍 How It All Works Together

### GitHub Actions Flow
```
PR Created/Updated
    ↓
GitHub Actions Triggered
    ↓
MCP Server Built & Installed
    ↓
Changed Files Extracted
    ↓
HTML Content Analyzed
    ↓
MCP Accessibility Tools Run
    ↓
Results Posted to PR
```

### Local AI Assistant Flow
```
You Ask AI Assistant
    ↓
AI Uses MCP Tools
    ↓
MCP Server Processes Request
    ↓
Advanced Analysis Performed
    ↓
Educational Response Generated
```

## 📋 Troubleshooting

### GitHub Actions Not Running?

1. **Check repository settings**:
   - Go to Settings → Actions → General
   - Ensure "Allow all actions" is enabled

2. **Verify workflow file**:
   ```bash
   cat .github/workflows/copilot-accessibility.yml
   ```

3. **Check branch protection rules** (optional but recommended)

### MCP Server Not Connecting?

1. **Verify the server is built**:
   ```bash
   ls -la mcp-accessibility-evaluator/dist/index.js
   ```

2. **Test the server manually**:
   ```bash
   cd mcp-accessibility-evaluator
   node dist/index.js
   ```

3. **Check the configuration path** in your AI assistant config

### No Analysis Results?

1. **Ensure you're changing relevant files** (`.html`, `.jsx`, `.tsx`, `.vue`)
2. **Check the PR targets** `main` or `develop` branches
3. **Look at the Actions tab** in GitHub for detailed logs

## 🎉 Success Indicators

### GitHub Actions Working:
- ✅ PR comments with accessibility analysis
- ✅ Actionable recommendations
- ✅ WCAG compliance information
- ✅ MCP-powered detailed explanations

### Local AI Assistant Working:
- ✅ AI can evaluate HTML for accessibility
- ✅ Detailed explanations with user impact
- ✅ Code examples and fix recommendations
- ✅ Educational content about accessibility

## 📚 Next Steps

1. **Create a test PR** to see the automation in action
2. **Configure your AI assistant** for local development help
3. **Review the accessibility feedback** and implement suggestions
4. **Share with your team** how to use the MCP tools

## 🔗 Resources

- **MCP Server Docs**: [mcp-accessibility-evaluator/README.md](mcp-accessibility-evaluator/README.md)
- **GitHub Copilot Setup**: [COPILOT_SETUP.md](COPILOT_SETUP.md)
- **Testing Guide**: [mcp-accessibility-evaluator/TESTING.md](mcp-accessibility-evaluator/TESTING.md)

---

**You're all set!** 🚀 Your GitHub service is now connected to the MCP accessibility evaluator for both automated PR analysis and local AI-assisted development. 