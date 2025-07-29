#!/bin/bash

# GitHub Accessibility Service - Release Creation Script
# Automates version tagging, package creation, and distribution preparation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGE_NAME="github-accessibility-service"
DIST_DIR="$PROJECT_ROOT/dist-release"

# Helper functions
print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Parse command line arguments
VERSION=""
RELEASE_TYPE=""
SKIP_TESTS=false
CREATE_TAG=true
UPLOAD_RELEASE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --release-type)
      RELEASE_TYPE="$2"  # major, minor, patch
      shift 2
      ;;
    --skip-tests)
      SKIP_TESTS=true
      shift
      ;;
    --no-tag)
      CREATE_TAG=false
      shift
      ;;
    --upload)
      UPLOAD_RELEASE=true
      shift
      ;;
    -h|--help)
      echo "GitHub Accessibility Service Release Creator"
      echo ""
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --version VERSION        Specify version number (e.g., 1.2.3)"
      echo "  --release-type TYPE      Auto-increment version (major|minor|patch)"
      echo "  --skip-tests            Skip test execution"
      echo "  --no-tag               Don't create git tag"
      echo "  --upload               Upload release to GitHub"
      echo "  -h, --help             Show this help"
      echo ""
      echo "Examples:"
      echo "  $0 --version 1.2.3"
      echo "  $0 --release-type minor"
      echo "  $0 --release-type patch --upload"
      exit 0
      ;;
    *)
      print_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}🚀 GitHub Accessibility Service Release Creator${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

cd "$PROJECT_ROOT"

# Determine version
if [ -n "$RELEASE_TYPE" ]; then
  print_info "Auto-incrementing version ($RELEASE_TYPE)..."
  
  # Get current version from package.json
  CURRENT_VERSION=$(node -p "require('./package.json').version")
  print_info "Current version: $CURRENT_VERSION"
  
  # Parse version numbers
  IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
  MAJOR=${VERSION_PARTS[0]}
  MINOR=${VERSION_PARTS[1]}
  PATCH=${VERSION_PARTS[2]}
  
  # Increment based on release type
  case $RELEASE_TYPE in
    major)
      MAJOR=$((MAJOR + 1))
      MINOR=0
      PATCH=0
      ;;
    minor)
      MINOR=$((MINOR + 1))
      PATCH=0
      ;;
    patch)
      PATCH=$((PATCH + 1))
      ;;
    *)
      print_error "Invalid release type: $RELEASE_TYPE (use: major, minor, patch)"
      exit 1
      ;;
  esac
  
  VERSION="$MAJOR.$MINOR.$PATCH"
fi

if [ -z "$VERSION" ]; then
  print_error "Version not specified. Use --version or --release-type"
  exit 1
fi

print_info "Creating release version: $VERSION"

# Pre-release checks
print_info "Running pre-release checks..."

# Check git status
if [ -n "$(git status --porcelain)" ]; then
  print_warning "Working directory is not clean"
  read -p "Continue anyway? (y/n): " continue_dirty
  if [ "$continue_dirty" != "y" ]; then
    exit 1
  fi
fi

# Check if on main/master branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
  print_warning "Not on main/master branch (currently on: $CURRENT_BRANCH)"
  read -p "Continue anyway? (y/n): " continue_branch
  if [ "$continue_branch" != "y" ]; then
    exit 1
  fi
fi

# Run tests
if [ "$SKIP_TESTS" = false ]; then
  print_info "Running tests..."
  
  # Build MCP server
  cd mcp-accessibility-evaluator
  npm install
  npm run build
  npm test
  cd ..
  
  # Verify installation
  ./verify-installation.sh
  
  print_status "All tests passed"
else
  print_warning "Skipping tests (--skip-tests specified)"
fi

# Update version in package.json
print_info "Updating package.json version to $VERSION..."
npm version "$VERSION" --no-git-tag-version

# Update version in MCP package.json
print_info "Updating MCP evaluator version..."
cd mcp-accessibility-evaluator
npm version "$VERSION" --no-git-tag-version
cd ..

print_status "Version updated to $VERSION"

# Create distribution directory
print_info "Preparing distribution package..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Create clean distribution package
PACKAGE_FILE="$DIST_DIR/$PACKAGE_NAME-v$VERSION.tar.gz"

# Files to include in distribution
DIST_FILES=(
  "mcp-accessibility-evaluator/"
  ".github/workflows/"
  "config/"
  "templates/"
  "docs/"
  "scripts/"
  "setup.sh"
  "verify-installation.sh"
  "package.json"
  "README.md"
  "SETUP_GUIDE.md"
  "DISTRIBUTION.md"
  "COPILOT_SETUP.md"
  "LICENSE"
)

# Create package
print_info "Creating distribution package..."
tar -czf "$PACKAGE_FILE" \
  --exclude=node_modules \
  --exclude=.git \
  --exclude=dist-release \
  --exclude=*.log \
  --exclude=.DS_Store \
  "${DIST_FILES[@]}"

print_status "Distribution package created: $PACKAGE_FILE"

# Create checksums
print_info "Creating checksums..."
cd "$DIST_DIR"
sha256sum "$(basename "$PACKAGE_FILE")" > "$(basename "$PACKAGE_FILE").sha256"
md5sum "$(basename "$PACKAGE_FILE")" > "$(basename "$PACKAGE_FILE").md5"
cd "$PROJECT_ROOT"

# Create release notes
RELEASE_NOTES_FILE="$DIST_DIR/RELEASE_NOTES_v$VERSION.md"
print_info "Generating release notes..."

cat > "$RELEASE_NOTES_FILE" << EOF
# GitHub Accessibility Service v$VERSION

## 🎉 Release Highlights

This release provides automated accessibility evaluation for GitHub repositories with enhanced MCP integration and AI assistant support.

## 📦 What's Included

- **MCP Accessibility Evaluator**: Advanced accessibility analysis server
- **GitHub Actions Workflows**: Automated PR accessibility analysis  
- **AI Assistant Integration**: Claude Desktop, VS Code, Cursor support
- **WCAG 2.1 Compliance**: Comprehensive A, AA, AAA level checking
- **Educational Content**: Detailed explanations and learning materials

## 🚀 Quick Start

\`\`\`bash
# Download and extract
curl -L -o github-accessibility-service-v$VERSION.tar.gz \\
  https://github.com/your-org/github-accessibility-service/releases/download/v$VERSION/github-accessibility-service-v$VERSION.tar.gz

tar -xzf github-accessibility-service-v$VERSION.tar.gz
cd github-accessibility-service

# One-command setup
./setup.sh
\`\`\`

## 🛠️ Available Tools

- \`evaluate_accessibility\`: Comprehensive HTML accessibility evaluation
- \`check_wcag_compliance\`: WCAG 2.1 compliance analysis with scoring
- \`validate_aria\`: ARIA usage validation and best practices
- \`fetch_accessibility_docs\`: Live W3C/MDN documentation retrieval

## 📋 System Requirements

- **Node.js**: 18.0.0 or higher
- **npm**: 8.0.0 or higher
- **Git**: For repository management
- **Operating Systems**: macOS, Linux, Windows

## 🧪 Verification

After installation, verify everything works:

\`\`\`bash
./verify-installation.sh
\`\`\`

## 📚 Documentation

- [Setup Guide](SETUP_GUIDE.md) - Detailed installation instructions
- [Distribution Guide](docs/distribution/DISTRIBUTOR_GUIDE.md) - For organizations
- [MCP Evaluator Documentation](mcp-accessibility-evaluator/README.md) - Technical details

## 🔒 Security

- **SHA256**: \`$(cat "$DIST_DIR/$(basename "$PACKAGE_FILE").sha256" | cut -d' ' -f1)\`
- **MD5**: \`$(cat "$DIST_DIR/$(basename "$PACKAGE_FILE").md5" | cut -d' ' -f1)\`

## 🤝 Support

- **Issues**: [GitHub Issues](https://github.com/your-org/github-accessibility-service/issues)
- **Documentation**: [Project Wiki](https://github.com/your-org/github-accessibility-service/wiki)
- **Community**: [Discussions](https://github.com/your-org/github-accessibility-service/discussions)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Building a more accessible web, one repository at a time.* 🌟
EOF

print_status "Release notes created: $RELEASE_NOTES_FILE"

# Create git tag
if [ "$CREATE_TAG" = true ]; then
  print_info "Creating git tag..."
  
  # Commit version changes
  git add package.json mcp-accessibility-evaluator/package.json
  git commit -m "chore: bump version to $VERSION"
  
  # Create tag
  git tag -a "v$VERSION" -m "Release version $VERSION"
  
  print_status "Git tag v$VERSION created"
  
  print_info "To push the tag, run: git push origin v$VERSION"
else
  print_warning "Skipping git tag creation (--no-tag specified)"
fi

# GitHub release upload (if requested)
if [ "$UPLOAD_RELEASE" = true ]; then
  print_info "Uploading release to GitHub..."
  
  # Check if GitHub CLI is installed
  if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) not found. Install it to upload releases automatically."
    print_info "Manual upload instructions:"
    print_info "1. Go to https://github.com/your-org/github-accessibility-service/releases/new"
    print_info "2. Tag: v$VERSION"
    print_info "3. Upload: $PACKAGE_FILE"
    print_info "4. Copy release notes from: $RELEASE_NOTES_FILE"
  else
    # Create GitHub release
    gh release create "v$VERSION" \
      "$PACKAGE_FILE" \
      "$PACKAGE_FILE.sha256" \
      "$PACKAGE_FILE.md5" \
      --title "GitHub Accessibility Service v$VERSION" \
      --notes-file "$RELEASE_NOTES_FILE"
    
    print_status "Release uploaded to GitHub"
  fi
else
  print_info "Skipping GitHub release upload (use --upload to enable)"
fi

# Summary
echo ""
echo -e "${GREEN}🎉 Release v$VERSION Created Successfully!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${BLUE}📦 Distribution Package:${NC}"
echo "  File: $PACKAGE_FILE"
echo "  Size: $(du -h "$PACKAGE_FILE" | cut -f1)"
echo ""
echo -e "${BLUE}📋 Files Created:${NC}"
echo "  - Distribution package"
echo "  - SHA256 checksum"
echo "  - MD5 checksum"
echo "  - Release notes"
if [ "$CREATE_TAG" = true ]; then
  echo "  - Git tag: v$VERSION"
fi
echo ""
echo -e "${BLUE}🚀 Next Steps:${NC}"
echo "  1. Test the distribution package"
echo "  2. Push git tag: git push origin v$VERSION"
echo "  3. Upload to distribution channels"
echo "  4. Update documentation"
echo "  5. Announce to community"
echo ""
echo -e "${YELLOW}⚠️  Remember:${NC}"
echo "  - Test installation on different platforms"
echo "  - Update changelog and documentation"
echo "  - Notify users of the new release"
echo ""
print_status "Release process complete!" 