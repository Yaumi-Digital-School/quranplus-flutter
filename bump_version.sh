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

# ─── Read Current Version from pubspec.yaml ───────────────────────────────────

CURRENT_VERSION_LINE=$(grep "^version:" "$PUBSPEC" | head -n 1)
if [ -z "$CURRENT_VERSION_LINE" ]; then
    echo -e "${RED}Error: Could not find 'version:' line in $PUBSPEC.${NC}"
    exit 1
fi

# Parse version and build number: version: X.Y.Z+BUILD
CURRENT_VERSION=$(echo "$CURRENT_VERSION_LINE" | sed -E 's/^version:[[:space:]]*([^+]+)\+([0-9]+).*/\1/')
CURRENT_BUILD=$(echo "$CURRENT_VERSION_LINE" | sed -E 's/^version:[[:space:]]*([^+]+)\+([0-9]+).*/\2/')

if [ -z "$CURRENT_VERSION" ] || [ -z "$CURRENT_BUILD" ]; then
    echo -e "${RED}Error: Could not parse version from $PUBSPEC.${NC}"
    echo "Expected format: version: X.Y.Z+BUILD_NUMBER"
    exit 1
fi

echo -e "${YELLOW}Current pubspec version: ${CURRENT_VERSION}+${CURRENT_BUILD}${NC}"

# ─── Determine Next Version with standard-version ─────────────────────────────

# Use standard-version in dry-run mode to get the next version without making changes.
# We create a temporary package.json so standard-version can compute the bump.
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cat > "$TEMP_DIR/package.json" <<EOF
{
  "name": "temp-version-bump",
  "version": "$CURRENT_VERSION"
}
EOF

# Run standard-version dry-run to get the next version
if command -v standard-version &> /dev/null; then
    DRY_RUN_OUTPUT=$(cd "$TEMP_DIR" && standard-version --dry-run 2>&1) || true
else
    DRY_RUN_OUTPUT=$(cd "$TEMP_DIR" && npx standard-version --dry-run 2>&1) || true
fi

# Extract the next version from dry-run output
# Example output line: "✔ bumping version in package.json from 1.8.0 to 1.9.0"
NEW_VERSION=$(echo "$DRY_RUN_OUTPUT" | grep -oE 'bumping version in package\.json from [^ ]+ to ([0-9]+\.[0-9]+\.[0-9]+)' | sed -E 's/.* to ([0-9]+\.[0-9]+\.[0-9]+)$/\1/')

if [ -z "$NEW_VERSION" ]; then
    echo -e "${RED}Error: Could not determine the next version from standard-version.${NC}"
    echo "Dry-run output:"
    echo "$DRY_RUN_OUTPUT"
    exit 1
fi

if [ "$NEW_VERSION" = "$CURRENT_VERSION" ]; then
    echo -e "${YELLOW}No version bump needed (no conventional commits trigger a version change).${NC}"
    exit 0
fi

echo -e "${YELLOW}Next version (from standard-version): ${NEW_VERSION}${NC}"

# ─── Update pubspec.yaml ──────────────────────────────────────────────────────

NEW_VERSION_LINE="version: ${NEW_VERSION}+${CURRENT_BUILD}"

sed -i.bak "s/^version:.*/${NEW_VERSION_LINE}/" "$PUBSPEC"
rm -f "${PUBSPEC}.bak"

echo -e "${GREEN}✔ Updated pubspec.yaml: ${NEW_VERSION_LINE}${NC}"

# ─── Commit, Tag, and Generate Changelog with standard-version ────────────────

# Stage the pubspec.yaml change so standard-version includes it in the release commit
git add "$PUBSPEC"

# Run standard-version for real. It will:
#   1. Generate / update CHANGELOG.md
#   2. Create a version bump commit (including the staged pubspec.yaml)
#   3. Create the git tag
# We skip its own package.json bump since we don't have one in this project.
echo -e "${YELLOW}Running standard-version...${NC}"

if command -v standard-version &> /dev/null; then
    standard-version --skip.bump "$@"
else
    npx standard-version --skip.bump "$@"
fi

TAG_NAME="v${NEW_VERSION}"

# ─── Push to Remote ───────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}Pushing commit and tag to origin...${NC}"
git push origin "$CURRENT_BRANCH"
git push origin "$TAG_NAME"

echo ""
echo -e "${GREEN}✅ Version bump complete!${NC}"
echo -e "${GREEN}   New version: ${NEW_VERSION}+${CURRENT_BUILD}${NC}"
echo -e "${GREEN}   Tag: ${TAG_NAME}${NC}"
