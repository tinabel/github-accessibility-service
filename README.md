# GitHub Accessibility Service

**Automated accessibility evaluation for GitHub repositories with MCP server integration and AI assistant support**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)](https://nodejs.org/)
[![WCAG 2.1](https://img.shields.io/badge/WCAG-2.1%20AA-green.svg)](https://www.w3.org/WAI/WCAG21/)

## 🎯 Overview

This repository provides a complete accessibility evaluation solution that integrates with your existing GitHub workflow and AI assistants. Get automated WCAG 2.1 compliance checking, educational feedback, and actionable recommendations for every pull request.

## ✨ Key Features

- **🤖 Automated PR Analysis**: GitHub Actions workflow that analyzes every pull request
- **🧠 AI Assistant Integration**: Works with Claude Desktop, VS Code, Cursor, and other MCP-compatible tools
- **📚 Educational Feedback**: Not just issue detection—learn why accessibility matters
- **🎯 WCAG 2.1 Compliance**: Comprehensive A, AA, AAA level checking
- **⚡ One-Command Setup**: Get everything running in minutes
- **🔧 Highly Customizable**: Adapt to your team's needs and standards

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

```bash
# Clone the repository
git clone https://github.com/your-org/github-accessibility-service.git
cd github-accessibility-service

# One-command setup
./setup.sh

# Verify installation
./verify-installation.sh
```

### Option 2: Download Release Package

```bash
# Download latest release
curl -L -o github-accessibility-service.tar.gz \
  https://github.com/your-org/github-accessibility-service/releases/latest/download/github-accessibility-service.tar.gz

# Extract and setup
tar -xzf github-accessibility-service.tar.gz
cd github-accessibility-service
./setup.sh
```

## 🛠️ What Gets Set Up

### GitHub Actions Integration
- **Automated PR analysis** with accessibility evaluation
- **Educational comments** on pull requests with detailed explanations
- **WCAG compliance scoring** and recommendations
- **Artifact storage** for detailed analysis reports

### MCP Accessibility Evaluator
- **Real-time analysis** for AI assistants
- **4 powerful tools**: `evaluate_accessibility`, `check_wcag_compliance`, `validate_aria`, `fetch_accessibility_docs`
- **Educational explanations** for every accessibility issue found
- **Live documentation** from W3C and MDN standards

### AI Assistant Support
- **Claude Desktop**: Full MCP integration with enhanced explanations
- **VS Code/Cursor**: Real-time accessibility checking during development
- **GitHub Copilot**: Integration for automated accessibility analysis
- **Custom AI tools**: Works with any MCP-compatible assistant

## 📊 Example Analysis Output

When you create a PR with accessibility issues, you'll get feedback like this:

```markdown
🤖 Accessibility Analysis Report

## 📄 Button.tsx

🚨 **Missing Alt Text** (WCAG 1.1.1)
   Images must have alternative text for screen readers
   **Impact**: Critical - Blocks access for vision-impaired users
   **Fix**: Add descriptive alt="..." attributes to all images

⚠️ **Non-semantic Interactive Elements** (WCAG 2.1.1)
   Use semantic HTML elements for interactive content
   **Impact**: Moderate - Affects keyboard navigation and screen readers
   **Fix**: Use <button> or <a> elements instead of div/span with click handlers

## 🎓 Accessibility Education

### Why Accessibility Matters
- **1 in 4 adults** in the US has a disability that impacts daily activities
- **Web accessibility benefits everyone**, not just users with disabilities
- **Legal compliance** is required in many jurisdictions
```

## 🧪 Testing Your Setup

### Test GitHub Actions
Create a test PR with accessibility issues:

```bash
echo '<img src="test.jpg"><button><i class="icon"></i></button>' > test.html
git add test.html
git commit -m "Test accessibility analysis"
git push origin feature-branch
# Create PR and check for accessibility analysis comment
```

### Test MCP Server
Ask your configured AI assistant:

```
Use evaluate_accessibility to check this HTML:
<html><body><img src="logo.png"><button><i class="icon"></i></button></body></html>
```

## 📚 Documentation

- **[Setup Guide](SETUP_GUIDE.md)**: Detailed installation and configuration
- **[Distribution Guide](docs/distribution/DISTRIBUTOR_GUIDE.md)**: For organizations and teams
- **[MCP Evaluator Documentation](mcp-accessibility-evaluator/README.md)**: Technical details and API
- **[GitHub Copilot Setup](COPILOT_SETUP.md)**: Advanced GitHub integration

## 🏢 For Organizations

### Easy Distribution
This package is designed for easy distribution across teams and organizations:

- **One-command installation** for any repository
- **Customizable templates** for your organization's standards
- **Automated setup scripts** for enterprise deployment
- **Comprehensive documentation** for different audiences

### Enterprise Features
- **Custom accessibility rules** for your brand guidelines
- **WCAG compliance reporting** for auditing
- **Multi-repository deployment** scripts
- **Training and educational content** for development teams

See the [Distribution Guide](docs/distribution/DISTRIBUTOR_GUIDE.md) for details.

## 🔧 Customization

### Workflow Configuration
Customize the GitHub Actions workflow for your needs:

```yaml
# .github/workflows/copilot-accessibility.yml
env:
  WCAG_TARGET_LEVEL: 'AA'  # A, AA, or AAA
  FAIL_ON_ERRORS: 'false'  # Set to 'true' to fail CI on errors
  ANALYSIS_PATTERNS: '\.(jsx?|tsx?|vue|html|svelte)$'
```

### MCP Server Configuration
Customize the MCP server for your AI assistant:

```json
{
  "mcpServers": {
    "accessibility-evaluator": {
      "command": "node",
      "args": ["/path/to/mcp-accessibility-evaluator/dist/index.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

## 🔄 Updates and Releases

### Stay Updated
```bash
# For git-based installations
git pull origin main
./setup.sh

# For package-based installations
# Download latest release and re-extract
```

### Create Custom Releases
```bash
# For organizations distributing internally
npm run distribution:package
# Creates github-accessibility-service.tar.gz
```

## 📈 Benefits

### For Developers
- **Learn while coding**: Educational feedback helps improve accessibility knowledge
- **Catch issues early**: Problems identified before production
- **Consistent standards**: Automated checking ensures compliance
- **AI assistance**: Get help with accessibility during development

### For Teams
- **Standardized process**: Same accessibility checking across all projects
- **Reduced review time**: Automated analysis catches common issues
- **Knowledge sharing**: Educational content helps entire team learn
- **Compliance tracking**: Monitor WCAG compliance across projects

### For Organizations
- **Scale expertise**: Accessibility knowledge available to all teams
- **Risk reduction**: Catch accessibility issues before release
- **Compliance assurance**: Meet legal and regulatory requirements
- **Cost savings**: Automated checking reduces manual review needs

## 🎯 Standards Compliance

- **WCAG 2.1**: Full support for A, AA, AAA levels
- **WAI-ARIA**: Complete validation and best practices
- **Section 508**: US federal accessibility standards
- **EN 301 549**: European accessibility standards

## 🤝 Contributing

We welcome contributions! Please see our [contribution guidelines](CONTRIBUTING.md) for details.

### Ways to Contribute
- **Bug reports** and feature requests
- **New accessibility rules** and checks
- **Documentation** improvements
- **Platform support** enhancements
- **Educational content** and examples

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Acknowledgments

- **W3C Web Accessibility Initiative** for WCAG guidelines
- **axe-core team** for accessibility testing engine
- **MCP Protocol** for AI assistant integration
- **Open source accessibility community** for inspiration and guidance

## 📞 Support

- **Documentation**: [Setup Guide](SETUP_GUIDE.md) and [Wiki](https://github.com/your-org/github-accessibility-service/wiki)
- **Issues**: [GitHub Issues](https://github.com/your-org/github-accessibility-service/issues) for bug reports
- **Discussions**: [GitHub Discussions](https://github.com/your-org/github-accessibility-service/discussions) for questions
- **Community**: Join our accessibility-focused development community

---

**Building a more accessible web, one repository at a time.** 🌟

*Ready to make your projects more accessible? [Get started now](#-quick-start) with our one-command setup!*
