#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PUBSPEC="pubspec.yaml"

# ─── Safety Checks ────────────────────────────────────────────────────────────

# Check if pubspec.yaml exists
if [ ! -f "$PUBSPEC" ]; then
    echo -e "${RED}Error: $PUBSPEC not found in current directory.${NC}"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not a git repository.${NC}"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Error: You have uncommitted changes. Please commit or stash them first.${NC}"
    git status --short
    exit 1
fi

# Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "master" ] && [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}Warning: You are on branch '$CURRENT_BRANCH'.${NC}"
    read -p "Are you sure you want to bump version from this branch? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Check if standard-version is available
if ! command -v standard-version &> /dev/null && ! npx standard-version --version &> /dev/null 2>&1; then
    echo -e "${RED}Error: standard-version is not installed.${NC}"
    echo "Install it with: npm install -g standard-version"
    exit 1
fi

# ─── Run standard-version ─────────────────────────────────────────────────────

# standard-version will:
# 1. Determine next version from conventional commits
# 2. Update CHANGELOG.md
# 3. Bump version in pubspec.yaml (if configured) and package.json
# 4. Create a version bump commit

echo -e "${YELLOW}Running standard-version...${NC}"

# Check if .versionrc or package.json has bumpFiles configured for pubspec.yaml
# If not, we'll handle pubspec.yaml manually after standard-version runs

if command -v standard-version &> /dev/null; then
    standard-version --skip.tag "$@" || true
else
    npx standard-version --skip.tag "$@" || true
fi

# ─── Verify & Fix pubspec.yaml Version ────────────────────────────────────────

# standard-version might not update pubspec.yaml if not configured.
# Let's ensure pubspec.yaml reflects the new version.

# Read the version from package.json (created/updated by standard-version)
if [ -f "package.json" ]; then
    NEW_VERSION=$(node -p "require('./package.json').version" 2>/dev/null || echo "")
fi

# If package.json doesn't exist or has no version, read from the latest git tag
if [ -z "$NEW_VERSION" ]; then
    NEW_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "")
fi

# If still no version, read from pubspec.yaml directly
if [ -z "$NEW_VERSION" ]; then
    NEW_VERSION=$(grep "^version:" "$PUBSPEC" | sed -E 's/^version:[[:space:]]*([^+]+).*/\1/')
fi

if [ -z "$NEW_VERSION" ]; then
    echo -e "${RED}Error: Could not determine the new version.${NC}"
    exit 1
fi

# Update pubspec.yaml version (preserve build number)
CURRENT_BUILD=$(grep "^version:" "$PUBSPEC" | sed -E 's/^version:[[:space:]]*([^+]+)\+([0-9]+).*/\2/')
if [ -n "$CURRENT_BUILD" ]; then
    NEW_VERSION_LINE="version: ${NEW_VERSION}+${CURRENT_BUILD}"
else
    NEW_VERSION_LINE="version: ${NEW_VERSION}+1"
fi

sed -i.bak "s/^version:.*/${NEW_VERSION_LINE}/" "$PUBSPEC"
rm -f "${PUBSPEC}.bak"

# Amend the standard-version commit to include pubspec.yaml change
git add "$PUBSPEC"
if git diff-index --quiet --cached HEAD --; then
    echo -e "${GREEN}✔ pubspec.yaml already up to date.${NC}"
else
    git commit --amend --no-edit
    echo -e "${GREEN}✔ Updated pubspec.yaml version to ${NEW_VERSION_LINE}${NC}"
fi

# ─── Create Tag ───────────────────────────────────────────────────────────────

TAG_NAME="v${NEW_VERSION}"

# Check if tag already exists
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Tag ${TAG_NAME} already exists. Skipping tag creation.${NC}"
else
    git tag "$TAG_NAME"
    echo -e "${GREEN}✔ Created tag: ${TAG_NAME}${NC}"
fi

# ─── Push to Remote ───────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}Pushing commit and tag to origin...${NC}"
git push origin "$CURRENT_BRANCH"
git push origin "$TAG_NAME"

echo ""
echo -e "${GREEN}✅ Version bump complete!${NC}"
echo -e "${GREEN}   New version: ${NEW_VERSION}${NC}"
echo -e "${GREEN}   Tag: ${TAG_NAME}${NC}"
