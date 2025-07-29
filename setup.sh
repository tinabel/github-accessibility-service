#!/bin/bash

# GitHub Accessibility Service - Universal Setup Script
# This script sets up the complete accessibility evaluation system for any repository

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="github-accessibility-service"
MCP_DIR="mcp-accessibility-evaluator"

echo -e "${BLUE}🚀 GitHub Accessibility Service Setup${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js 18+ and try again."
        exit 1
    fi
    
    NODE_VERSION=$(node --version | cut -d 'v' -f 2 | cut -d '.' -f 1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        print_error "Node.js version 18+ is required. Current version: $(node --version)"
        exit 1
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed. Please install npm and try again."
        exit 1
    fi
    
    # Check git
    if ! command -v git &> /dev/null; then
        print_error "git is not installed. Please install git and try again."
        exit 1
    fi
    
    print_status "Prerequisites check passed"
}

# Detect OS for configuration
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macOS"
            CLAUDE_CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
            ;;
        Linux*)
            OS="Linux"
            CLAUDE_CONFIG_PATH="$HOME/.config/Claude/claude_desktop_config.json"
            ;;
        MINGW*|CYGWIN*|MSYS*)
            OS="Windows"
            CLAUDE_CONFIG_PATH="$APPDATA/Claude/claude_desktop_config.json"
            ;;
        *)
            OS="Unknown"
            CLAUDE_CONFIG_PATH=""
            ;;
    esac
    
    print_info "Detected OS: $OS"
}

# Setup project structure
setup_project_structure() {
    print_info "Setting up project structure..."
    
    # Ensure we're in a git repository
    if [ ! -d ".git" ]; then
        print_warning "Not in a git repository. Initializing..."
        git init
        print_status "Git repository initialized"
    fi
    
    # Create .github/workflows directory if it doesn't exist
    mkdir -p .github/workflows
    
    # Create package.json if it doesn't exist
    if [ ! -f "package.json" ]; then
        print_info "Creating package.json..."
        cat > package.json << EOF
{
  "name": "$(basename "$PWD")",
  "version": "1.0.0",
  "description": "Project with GitHub Accessibility Service integration",
  "main": "index.js",
  "scripts": {
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:coverage": "jest --coverage",
    "test:a11y": "pa11y-ci",
    "build": "next build || npm run build:custom",
    "build:custom": "echo 'Add your build command here'",
    "accessibility:setup": "cd mcp-accessibility-evaluator && npm install && npm run build",
    "accessibility:test": "cd mcp-accessibility-evaluator && npm test"
  },
  "keywords": ["accessibility", "a11y", "wcag", "aria"],
  "license": "MIT",
  "devDependencies": {
    "@types/node": "^20.0.0",
    "eslint": "^9.0.0",
    "typescript": "^5.0.0",
    "jest": "^30.0.0",
    "pa11y-ci": "^2.4.2"
  }
}
EOF
        print_status "package.json created"
    fi
    
    print_status "Project structure ready"
}

# Install MCP Accessibility Evaluator
install_mcp_evaluator() {
    print_info "Installing MCP Accessibility Evaluator..."
    
    if [ ! -d "$MCP_DIR" ]; then
        print_error "MCP Accessibility Evaluator directory not found. Please ensure the complete package is present."
        exit 1
    fi
    
    cd "$MCP_DIR"
    
    # Install dependencies
    print_info "Installing MCP dependencies..."
    npm install
    
    # Build the project
    print_info "Building MCP server..."
    npm run build
    
    # Run tests to verify installation
    print_info "Running MCP tests..."
    npm test
    
    cd ..
    print_status "MCP Accessibility Evaluator installed and tested"
}

# Setup GitHub Actions workflows
setup_github_workflows() {
    print_info "Setting up GitHub Actions workflows..."
    
    # Copy workflow files if they don't exist
    workflows=(
        "copilot-accessibility.yml"
        "pr-check.yml"
        "pr-deploy-preview.yml"
        "dependency-updates.yml"
    )
    
    for workflow in "${workflows[@]}"; do
        if [ ! -f ".github/workflows/$workflow" ]; then
            if [ -f ".github/workflows/$workflow" ]; then
                print_status "Workflow $workflow already exists"
            else
                print_warning "Workflow template $workflow not found in package"
            fi
        else
            print_status "Workflow $workflow ready"
        fi
    done
}

# Generate portable configurations
generate_configurations() {
    print_info "Generating portable configurations..."
    
    # Get absolute path to MCP server
    MCP_ABSOLUTE_PATH="$(cd "$MCP_DIR" && pwd)"
    
    # Create configuration templates
    mkdir -p config/templates
    
    # Claude Desktop config template
    cat > config/templates/claude_desktop_config.json << EOF
{
  "mcpServers": {
    "accessibility-evaluator": {
      "command": "node",
      "args": ["$MCP_ABSOLUTE_PATH/dist/index.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
    
    # VS Code settings template
    cat > config/templates/vscode_settings.json << EOF
{
  "mcp.servers": {
    "accessibility-evaluator": {
      "command": "node",
      "args": ["$MCP_ABSOLUTE_PATH/dist/index.js"]
    }
  }
}
EOF
    
    # Environment-specific config
    cat > config/accessibility-config.sh << EOF
#!/bin/bash
# Accessibility Service Configuration

# MCP Server Path
export MCP_SERVER_PATH="$MCP_ABSOLUTE_PATH/dist/index.js"

# OS Detection
case "\$(uname -s)" in
    Darwin*)
        export CLAUDE_CONFIG_PATH="\$HOME/Library/Application Support/Claude/claude_desktop_config.json"
        ;;
    Linux*)
        export CLAUDE_CONFIG_PATH="\$HOME/.config/Claude/claude_desktop_config.json"
        ;;
    *)
        export CLAUDE_CONFIG_PATH=""
        ;;
esac

# Helper functions
setup_claude() {
    if [ -n "\$CLAUDE_CONFIG_PATH" ]; then
        mkdir -p "\$(dirname "\$CLAUDE_CONFIG_PATH")"
        cp config/templates/claude_desktop_config.json "\$CLAUDE_CONFIG_PATH"
        echo "Claude Desktop configured at \$CLAUDE_CONFIG_PATH"
    else
        echo "Unsupported OS for automatic Claude configuration"
    fi
}

setup_vscode() {
    echo "Add the following to your VS Code settings.json:"
    cat config/templates/vscode_settings.json
}
EOF
    
    chmod +x config/accessibility-config.sh
    
    print_status "Configuration templates generated"
}

# Configure AI assistants
configure_ai_assistants() {
    print_info "Configuring AI assistants..."
    
    echo ""
    echo -e "${YELLOW}🤖 AI Assistant Configuration${NC}"
    echo -e "${YELLOW}=============================${NC}"
    
    read -p "Would you like to configure Claude Desktop automatically? (y/n): " configure_claude
    
    if [ "$configure_claude" = "y" ] || [ "$configure_claude" = "Y" ]; then
        if [ -n "$CLAUDE_CONFIG_PATH" ]; then
            mkdir -p "$(dirname "$CLAUDE_CONFIG_PATH")"
            
            # Backup existing config
            if [ -f "$CLAUDE_CONFIG_PATH" ]; then
                cp "$CLAUDE_CONFIG_PATH" "$CLAUDE_CONFIG_PATH.backup.$(date +%Y%m%d_%H%M%S)"
                print_status "Backed up existing Claude config"
            fi
            
            # Install new config
            cp config/templates/claude_desktop_config.json "$CLAUDE_CONFIG_PATH"
            print_status "Claude Desktop configured at: $CLAUDE_CONFIG_PATH"
            print_warning "Please restart Claude Desktop to apply changes"
        else
            print_warning "Automatic Claude configuration not supported on this OS"
        fi
    fi
    
    echo ""
    echo -e "${BLUE}📋 Manual Configuration Instructions:${NC}"
    echo ""
    echo "For VS Code/Cursor with MCP extension:"
    echo "  1. Install MCP extension from marketplace"
    echo "  2. Add configuration from: config/templates/vscode_settings.json"
    echo ""
    echo "For other AI assistants:"
    echo "  Use MCP server path: $(cd "$MCP_DIR" && pwd)/dist/index.js"
}

# Create distribution package
create_distribution_info() {
    print_info "Creating distribution information..."
    
    # Create distribution README
    cat > DISTRIBUTION.md << 'EOF'
# GitHub Accessibility Service - Distribution Package

## 🎯 What's Included

This package provides automated accessibility evaluation for GitHub repositories with:

- **GitHub Actions Workflows**: Automated PR accessibility analysis
- **MCP Accessibility Evaluator**: AI assistant integration for local development
- **WCAG 2.1 Compliance**: Comprehensive accessibility checking
- **Educational Feedback**: Detailed explanations and fix recommendations

## 📦 Quick Setup

### 1. Automated Setup (Recommended)

```bash
# Clone or download this package to your repository
# Run the setup script
./setup.sh
```

### 2. Manual Setup

```bash
# Install MCP server
cd mcp-accessibility-evaluator
npm install
npm run build

# Configure your AI assistant
# Use the configuration templates in config/templates/
```

## 🧪 Verify Installation

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

## 🛠️ Available Tools

- `evaluate_accessibility`: Comprehensive HTML accessibility evaluation
- `check_wcag_compliance`: WCAG 2.1 compliance analysis with scoring
- `validate_aria`: ARIA usage validation and best practices
- `fetch_accessibility_docs`: Live W3C/MDN documentation retrieval

## 📚 Documentation

- `SETUP_GUIDE.md`: Detailed setup instructions
- `mcp-accessibility-evaluator/README.md`: MCP server documentation
- `COPILOT_SETUP.md`: GitHub Copilot integration guide

## 🤝 Support

For issues, questions, or contributions, please refer to the project repository.

## 📄 License

This package is distributed under the MIT License.
EOF

    # Create installation verification script
    cat > verify-installation.sh << 'EOF'
#!/bin/bash

# Installation Verification Script

echo "🔍 Verifying GitHub Accessibility Service Installation"
echo "=================================================="

# Check MCP server
if [ -f "mcp-accessibility-evaluator/dist/index.js" ]; then
    echo "✅ MCP server built successfully"
else
    echo "❌ MCP server not found or not built"
    exit 1
fi

# Check GitHub workflows
if [ -f ".github/workflows/copilot-accessibility.yml" ]; then
    echo "✅ GitHub Actions workflows present"
else
    echo "❌ GitHub Actions workflows missing"
fi

# Check configuration templates
if [ -d "config/templates" ]; then
    echo "✅ Configuration templates available"
else
    echo "❌ Configuration templates missing"
fi

# Test MCP server
echo ""
echo "🧪 Testing MCP server..."
cd mcp-accessibility-evaluator
if npm test --silent; then
    echo "✅ MCP server tests passed"
else
    echo "❌ MCP server tests failed"
    exit 1
fi

cd ..
echo ""
echo "🎉 Installation verification completed successfully!"
echo ""
echo "Next steps:"
echo "1. Configure your AI assistant using templates in config/templates/"
echo "2. Test with a PR containing accessibility issues"
echo "3. Ask your AI assistant to evaluate HTML content"
EOF

    chmod +x verify-installation.sh
    
    print_status "Distribution information created"
}

# Main setup function
main() {
    echo -e "${BLUE}Starting setup for: $(basename "$PWD")${NC}"
    echo ""
    
    # Run setup steps
    check_prerequisites
    detect_os
    setup_project_structure
    install_mcp_evaluator
    setup_github_workflows
    generate_configurations
    configure_ai_assistants
    create_distribution_info
    
    echo ""
    echo -e "${GREEN}🎉 Setup Complete!${NC}"
    echo -e "${GREEN}==================${NC}"
    echo ""
    echo -e "${BLUE}📋 What's been set up:${NC}"
    echo "  ✅ MCP Accessibility Evaluator server"
    echo "  ✅ GitHub Actions workflows"
    echo "  ✅ Configuration templates"
    echo "  ✅ AI assistant integration"
    echo "  ✅ Distribution documentation"
    echo ""
    echo -e "${BLUE}🧪 Verify installation:${NC}"
    echo "  ./verify-installation.sh"
    echo ""
    echo -e "${BLUE}📖 Next steps:${NC}"
    echo "  1. Review SETUP_GUIDE.md for detailed instructions"
    echo "  2. Test with a PR containing accessibility issues"
    echo "  3. Ask your AI assistant to evaluate HTML content"
    echo ""
    echo -e "${YELLOW}⚠️  Remember to:${NC}"
    echo "  - Restart Claude Desktop if configured"
    echo "  - Enable GitHub Actions in repository settings"
    echo "  - Add team members to accessibility review process"
    echo ""
    echo -e "${GREEN}Happy accessible coding! 🚀${NC}"
}

# Run main function
main "$@" 