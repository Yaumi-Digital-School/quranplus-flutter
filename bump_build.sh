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
    read -p "Are you sure you want to bump build from this branch? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# ─── Read & Bump Build Number ─────────────────────────────────────────────────

# Extract current version line (e.g., version: 1.8.0+103)
CURRENT_VERSION_LINE=$(grep "^version:" "$PUBSPEC" | head -n 1)
if [ -z "$CURRENT_VERSION_LINE" ]; then
    echo -e "${RED}Error: Could not find 'version:' line in $PUBSPEC.${NC}"
    exit 1
fi

# Parse version and build number
# Format: version: X.Y.Z+BUILD
CURRENT_VERSION=$(echo "$CURRENT_VERSION_LINE" | sed -E 's/^version:[[:space:]]*([^+]+)\+([0-9]+).*/\1/')
CURRENT_BUILD=$(echo "$CURRENT_VERSION_LINE" | sed -E 's/^version:[[:space:]]*([^+]+)\+([0-9]+).*/\2/')

if [ -z "$CURRENT_BUILD" ]; then
    echo -e "${RED}Error: Could not parse build number from $PUBSPEC.${NC}"
    echo "Expected format: version: X.Y.Z+BUILD_NUMBER"
    exit 1
fi

NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_VERSION_LINE="version: ${CURRENT_VERSION}+${NEW_BUILD}"

# ─── Update pubspec.yaml ──────────────────────────────────────────────────────

# Replace the version line in pubspec.yaml
sed -i.bak "s/^version:.*/${NEW_VERSION_LINE}/" "$PUBSPEC"
rm -f "${PUBSPEC}.bak"

echo -e "${GREEN}✔ Bumped build number: ${CURRENT_BUILD} → ${NEW_BUILD}${NC}"
echo -e "${GREEN}  New version line: ${NEW_VERSION_LINE}${NC}"

# ─── Commit & Tag ─────────────────────────────────────────────────────────────

TAG_NAME="build${NEW_BUILD}"
COMMIT_MESSAGE="chore(release): ${TAG_NAME}"

# Stage and commit the pubspec.yaml change
git add "$PUBSPEC"
git commit -m "$COMMIT_MESSAGE"

# Create the tag on the new commit
git tag "$TAG_NAME"

echo -e "${GREEN}✔ Created commit: ${COMMIT_MESSAGE}${NC}"
echo -e "${GREEN}✔ Created tag: ${TAG_NAME}${NC}"

# ─── Push to Remote ───────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}Pushing commit and tag to origin...${NC}"
git push origin "$CURRENT_BRANCH"
git push origin "$TAG_NAME"

echo ""
echo -e "${GREEN}✅ Build bump complete!${NC}"
echo -e "${GREEN}   Version: ${CURRENT_VERSION}+${NEW_BUILD}${NC}"
echo -e "${GREEN}   Tag: ${TAG_NAME}${NC}"
