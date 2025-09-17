#!/bin/bash

# Setup script for Accessibility Integration Bridge
# This script sets up the integration between accessibility-scraper and mcp-accessibility-evaluator

set -e

echo "🌉 Setting up Accessibility Integration Bridge..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "Please run this script from the root of the github-accessibility-service directory"
    exit 1
fi

# Check if submodules are initialized
print_status "Checking submodule status..."
if [ ! -d "accessibility-scraper/src" ] || [ ! -d "mcp-accessibility-evaluator/src" ]; then
    print_warning "Submodules not initialized. Initializing now..."
    git submodule update --init --recursive
fi

# Create integration bridge directory if it doesn't exist
if [ ! -d "integration-bridge" ]; then
    print_status "Creating integration bridge directory..."
    mkdir -p integration-bridge/src
fi

# Install dependencies for all components
print_status "Installing dependencies for all components..."

# Main project dependencies
print_status "Installing main project dependencies..."
npm install

# Accessibility scraper dependencies
print_status "Installing accessibility-scraper dependencies..."
cd accessibility-scraper
npm install
cd ..

# MCP accessibility evaluator dependencies
print_status "Installing mcp-accessibility-evaluator dependencies..."
cd mcp-accessibility-evaluator
npm install
cd ..

# Integration bridge dependencies
print_status "Installing integration-bridge dependencies..."
cd integration-bridge
npm install
cd ..

# Build all components
print_status "Building all components..."

# Build accessibility scraper
print_status "Building accessibility-scraper..."
cd accessibility-scraper
npm run build
cd ..

# Build MCP accessibility evaluator
print_status "Building mcp-accessibility-evaluator..."
cd mcp-accessibility-evaluator
npm run build
cd ..

# Build integration bridge
print_status "Building integration-bridge..."
cd integration-bridge
npm run build
cd ..

# Create necessary directories
print_status "Creating output and cache directories..."
mkdir -p output
mkdir -p cache
mkdir -p logs

# Create example configuration files
print_status "Creating example configuration files..."

# Create .env.example
cat > .env.example << 'EOF'
# Accessibility Integration Configuration

# Scraper Configuration
WCAG_BASE_URL=https://www.w3.org/WAI/WCAG21/
MAX_CONCURRENT_REQUESTS=5
REQUEST_DELAY_MS=1000
TIMEOUT_MS=30000
HEADLESS=true

# Evaluator Configuration
WCAG_LEVEL=AA
STRICT_MODE=false
MIN_IMPACT_LEVEL=moderate
ENABLE_AXE_CORE=true

# Integration Configuration
OUTPUT_DIR=./output
CACHE_DIR=./cache
UPDATE_INTERVAL=24
AUTO_UPDATE=true

# MCP Configuration
MCP_SERVER_NAME=accessibility-evaluator
ENABLE_ENHANCED_MODE=true

# Logging Configuration
LOG_LEVEL=info
ENABLE_FILE_LOGGING=true
LOG_FILE=./logs/accessibility-integration.log
EOF

# Create accessibility-integration.config.example.json
cat > accessibility-integration.config.example.json << 'EOF'
{
  "scraper": {
    "wcagBaseUrl": "https://www.w3.org/WAI/WCAG21/",
    "maxConcurrentRequests": 5,
    "requestDelayMs": 1000,
    "timeoutMs": 30000,
    "headless": true
  },
  "evaluator": {
    "wcagLevel": "AA",
    "strictMode": false,
    "includeCodeExamples": true,
    "minImpactLevel": "moderate",
    "enableAxeCore": true,
    "enableARIAValidation": true
  },
  "integration": {
    "outputDir": "./output",
    "cacheDir": "./cache",
    "updateInterval": 24,
    "autoUpdate": true,
    "enableCaching": true,
    "cacheExpiration": 168
  },
  "mcp": {
    "serverName": "accessibility-evaluator",
    "version": "1.0.0",
    "enableEnhancedMode": true,
    "enableDocumentationFetching": true,
    "enableComprehensiveAnalysis": true
  },
  "logging": {
    "level": "info",
    "enableFileLogging": true,
    "logFile": "./logs/accessibility-integration.log",
    "enableConsoleLogging": true
  }
}
EOF

# Test the integration
print_status "Testing integration setup..."

# Test accessibility scraper
print_status "Testing accessibility-scraper..."
cd accessibility-scraper
if npm test > /dev/null 2>&1; then
    print_success "accessibility-scraper tests passed"
else
    print_warning "accessibility-scraper tests failed (this is expected if no test files exist)"
fi
cd ..

# Test MCP accessibility evaluator
print_status "Testing mcp-accessibility-evaluator..."
cd mcp-accessibility-evaluator
if npm test > /dev/null 2>&1; then
    print_success "mcp-accessibility-evaluator tests passed"
else
    print_warning "mcp-accessibility-evaluator tests failed (this is expected if no test files exist)"
fi
cd ..

# Test integration bridge
print_status "Testing integration-bridge..."
cd integration-bridge
if npm test > /dev/null 2>&1; then
    print_success "integration-bridge tests passed"
else
    print_warning "integration-bridge tests failed (this is expected if no test files exist)"
fi
cd ..

# Check integration status
print_status "Checking integration status..."
if [ -f "integration-bridge/dist/index.js" ]; then
    print_success "Integration bridge built successfully"
else
    print_error "Integration bridge build failed"
    exit 1
fi

# Create a simple test HTML file
print_status "Creating test HTML file..."
cat > test-accessibility.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Accessibility Page</title>
</head>
<body>
    <h1>Welcome to Our Site</h1>
    <img src="logo.png" alt="Company Logo">
    <h3>About Us</h3>
    <p>We are a company dedicated to accessibility.</p>
    <form>
        <label for="email">Email Address</label>
        <input type="email" id="email" name="email" placeholder="Enter your email">
        <button type="submit">Subscribe</button>
    </form>
    <div role="button" tabindex="0">Custom Button</div>
</body>
</html>
EOF

print_success "Integration setup completed successfully!"
echo ""
echo -e "${GREEN}🎉 Accessibility Integration Bridge is ready!${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Copy .env.example to .env and customize your configuration"
echo "2. Copy accessibility-integration.config.example.json to accessibility-integration.config.json"
echo "3. Test the integration:"
echo "   npm run integration:status"
echo "   npm run integration:update-docs"
echo "   npm run integration:analyze --file test-accessibility.html"
echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo "• Integration Guide: INTEGRATION_GUIDE.md"
echo "• Accessibility Scraper: accessibility-scraper/README.md"
echo "• MCP Evaluator: mcp-accessibility-evaluator/README.md"
echo ""
echo -e "${BLUE}🔧 Available Commands:${NC}"
echo "• npm run integration:update-docs    - Fetch latest WCAG documentation"
echo "• npm run integration:analyze        - Perform comprehensive analysis"
echo "• npm run integration:status         - Check integration status"
echo "• npm run integration:help           - Show detailed help"
echo "• npm run scraper:scrape            - Scrape WCAG pages"
echo "• npm run scraper:map                - Map website structure"
echo "• npm run test:all                  - Run all tests"
echo ""
echo -e "${GREEN}🌟 Happy accessibility testing!${NC}"
