#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print a message, interpreting the color escape sequences above (no `echo -e`).
say() { printf '%b\n' "$*"; }

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PUBSPEC="pubspec.yaml"
CHANGELOG="CHANGELOG.md"

# ─── Parse Arguments ──────────────────────────────────────────────────────────

DRY_RUN=false
BUMP_BUILD=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --bump-build) BUMP_BUILD=true ;;
        -h|--help)
            printf 'Usage: %s [--dry-run] [--bump-build]\n' "$(basename "$0")"
            printf '  --dry-run      Show what would happen; change nothing.\n'
            printf '  --bump-build   Increment the +BUILD number by 1 (default: keep it).\n'
            exit 0
            ;;
        *)
            say "${RED}Error: unknown argument: ${arg}${NC}" >&2
            exit 1
            ;;
    esac
done

# ─── Safety Checks ────────────────────────────────────────────────────────────

# Check if pubspec.yaml exists
if [ ! -f "$PUBSPEC" ]; then
    say "${RED}Error: $PUBSPEC not found in current directory.${NC}"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    say "${RED}Error: Not a git repository.${NC}"
    exit 1
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# --dry-run changes nothing, so it deliberately skips the clean-tree and branch
# guards (which would otherwise refuse to run on a dirty tree / feature branch).
if [ "$DRY_RUN" = false ]; then
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        say "${RED}Error: You have uncommitted changes. Please commit or stash them first.${NC}"
        git status --short
        exit 1
    fi

    # Check current branch
    if [ "$CURRENT_BRANCH" != "master" ] && [ "$CURRENT_BRANCH" != "main" ]; then
        say "${YELLOW}Warning: You are on branch '$CURRENT_BRANCH'.${NC}"
        read -r -p "Are you sure you want to bump version from this branch? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    fi
fi

# ─── Read Current Version from pubspec.yaml ───────────────────────────────────

CURRENT_VERSION_LINE=$(grep "^version:" "$PUBSPEC" | head -n 1 || true)
if [ -z "$CURRENT_VERSION_LINE" ]; then
    say "${RED}Error: Could not find 'version:' line in $PUBSPEC.${NC}"
    exit 1
fi

# Parse version and build number: version: X.Y.Z+BUILD
CURRENT_VERSION=$(printf '%s\n' "$CURRENT_VERSION_LINE" | sed -E 's/^version:[[:space:]]*([^+]+)\+([0-9]+).*/\1/')
CURRENT_BUILD=$(printf '%s\n' "$CURRENT_VERSION_LINE" | sed -E 's/^version:[[:space:]]*([^+]+)\+([0-9]+).*/\2/')

if [ -z "$CURRENT_VERSION" ] || [ -z "$CURRENT_BUILD" ]; then
    say "${RED}Error: Could not parse version from $PUBSPEC.${NC}"
    say "Expected format: version: X.Y.Z+BUILD_NUMBER"
    exit 1
fi

VMAJOR=$(printf '%s' "$CURRENT_VERSION" | cut -d. -f1)
VMINOR=$(printf '%s' "$CURRENT_VERSION" | cut -d. -f2)
VPATCH=$(printf '%s' "$CURRENT_VERSION" | cut -d. -f3)
case "${VMAJOR}.${VMINOR}.${VPATCH}" in
    *[!0-9.]*|.*|*.|*..*)
        say "${RED}Error: version '${CURRENT_VERSION}' is not in X.Y.Z form.${NC}"
        exit 1
        ;;
esac

say "${YELLOW}Current pubspec version: ${CURRENT_VERSION}+${CURRENT_BUILD}${NC}"

# ─── Determine Commit Range Since Last Version Tag ────────────────────────────

LAST_TAG=$(git describe --tags --abbrev=0 --match 'v*' 2>/dev/null || true)
if [ -n "$LAST_TAG" ]; then
    RANGE="${LAST_TAG}..HEAD"
    say "${YELLOW}Analyzing conventional commits in ${RANGE}${NC}"
else
    RANGE="HEAD"
    say "${YELLOW}No version tag found; analyzing all commits.${NC}"
fi

# ─── Scan Conventional Commits (pure bash) ────────────────────────────────────

# POSIX ERE patterns (bash 3.2 compatible). `!?` allows the optional bang form.
RE_BANG='^[a-zA-Z]+(\([^)]*\))?!:'
RE_FEAT='^feat(\([^)]*\))?!?:'
RE_FIX='^fix(\([^)]*\))?!?:'
RE_PERF='^perf(\([^)]*\))?!?:'

BREAKING_ENTRIES=''
FEAT_ENTRIES=''
FIX_ENTRIES=''
PERF_ENTRIES=''

# Bump level: 0 none, 1 patch, 2 minor, 3 major.
LEVEL=0
COMMIT_COUNT=0

COMMITS=$(git log --format='%H' "$RANGE" || true)

if [ -n "$COMMITS" ]; then
    while IFS= read -r HASH; do
        [ -z "$HASH" ] && continue
        SUBJECT=$(git log -1 --format='%s' "$HASH")
        BODY=$(git log -1 --format='%b' "$HASH")
        SHORT=$(git log -1 --format='%h' "$HASH")

        IS_BREAKING=false
        if [[ "$SUBJECT" =~ $RE_BANG ]]; then
            IS_BREAKING=true
        fi
        case "$BODY" in
            *"BREAKING CHANGE"*|*"BREAKING-CHANGE"*) IS_BREAKING=true ;;
        esac

        ENTRY="- ${SUBJECT} (${SHORT})"

        if [ "$IS_BREAKING" = true ]; then
            BREAKING_ENTRIES="${BREAKING_ENTRIES}${ENTRY}"$'\n'
            LEVEL=3
            COMMIT_COUNT=$((COMMIT_COUNT + 1))
        elif [[ "$SUBJECT" =~ $RE_FEAT ]]; then
            FEAT_ENTRIES="${FEAT_ENTRIES}${ENTRY}"$'\n'
            if [ "$LEVEL" -lt 2 ]; then LEVEL=2; fi
            COMMIT_COUNT=$((COMMIT_COUNT + 1))
        elif [[ "$SUBJECT" =~ $RE_FIX ]]; then
            FIX_ENTRIES="${FIX_ENTRIES}${ENTRY}"$'\n'
            if [ "$LEVEL" -lt 1 ]; then LEVEL=1; fi
            COMMIT_COUNT=$((COMMIT_COUNT + 1))
        elif [[ "$SUBJECT" =~ $RE_PERF ]]; then
            PERF_ENTRIES="${PERF_ENTRIES}${ENTRY}"$'\n'
            if [ "$LEVEL" -lt 1 ]; then LEVEL=1; fi
            COMMIT_COUNT=$((COMMIT_COUNT + 1))
        fi
    done <<< "$COMMITS"
fi

if [ "$LEVEL" -eq 0 ]; then
    say "${YELLOW}No version bump needed (no conventional commits trigger a version change).${NC}"
    exit 0
fi

# ─── Compute Next Version ─────────────────────────────────────────────────────

case "$LEVEL" in
    3) NEW_VERSION="$((VMAJOR + 1)).0.0"; BUMP_LABEL="major" ;;
    2) NEW_VERSION="${VMAJOR}.$((VMINOR + 1)).0"; BUMP_LABEL="minor" ;;
    1) NEW_VERSION="${VMAJOR}.${VMINOR}.$((VPATCH + 1))"; BUMP_LABEL="patch" ;;
esac

if [ "$BUMP_BUILD" = true ]; then
    NEW_BUILD=$((CURRENT_BUILD + 1))
else
    NEW_BUILD="$CURRENT_BUILD"
fi

DATE=$(date +%Y-%m-%d)

# ─── Build the Changelog Section (standard-version-like) ──────────────────────

NEW_SECTION="## ${NEW_VERSION} (${DATE})"$'\n'

append_group() {
    # $1 = subsection title, $2 = accumulated "- subject (sha)\n" entries.
    if [ -n "$2" ]; then
        NEW_SECTION="${NEW_SECTION}"$'\n'"### $1"$'\n'$'\n'"$2"
    fi
}

append_group "⚠ BREAKING CHANGES" "$BREAKING_ENTRIES"
append_group "Features" "$FEAT_ENTRIES"
append_group "Bug Fixes" "$FIX_ENTRIES"
append_group "Performance" "$PERF_ENTRIES"

# ─── Dry Run: report and exit without changing anything ───────────────────────

if [ "$DRY_RUN" = true ]; then
    say "${YELLOW}──────────────── DRY RUN (no changes made) ────────────────${NC}"
    say "Current version: ${CURRENT_VERSION}+${CURRENT_BUILD}"
    say "Bump level:      ${BUMP_LABEL} (${COMMIT_COUNT} triggering commit(s))"
    say "Next version:    ${NEW_VERSION}+${NEW_BUILD}"
    printf '\n'
    say "${YELLOW}Changelog section that would be written:${NC}"
    printf '%s\n' "$NEW_SECTION"
    exit 0
fi

# ─── Fail Fast on Tag Collision ───────────────────────────────────────────────

TAG_NAME="v${NEW_VERSION}"
if git rev-parse -q --verify "refs/tags/${TAG_NAME}" > /dev/null 2>&1; then
    say "${RED}Error: tag ${TAG_NAME} already exists.${NC}"
    exit 1
fi

say "${YELLOW}Next version: ${NEW_VERSION}+${NEW_BUILD} (${BUMP_LABEL})${NC}"

# ─── Prepend the Changelog Section ────────────────────────────────────────────

if [ -f "$CHANGELOG" ]; then
    INSERT_LINE=$(grep -nE '^## ' "$CHANGELOG" | head -n 1 | cut -d: -f1 || true)
    if [ -n "$INSERT_LINE" ]; then
        # Insert above the newest existing release (keeps any top-level header).
        {
            head -n "$((INSERT_LINE - 1))" "$CHANGELOG"
            printf '%s\n' "$NEW_SECTION"
            tail -n "+${INSERT_LINE}" "$CHANGELOG"
        } > "${CHANGELOG}.tmp"
        mv "${CHANGELOG}.tmp" "$CHANGELOG"
    else
        # No existing release heading: append after whatever header is there.
        printf '\n%s\n' "$NEW_SECTION" >> "$CHANGELOG"
    fi
else
    {
        printf '# Changelog\n\n'
        printf '%s\n' "$NEW_SECTION"
    } > "$CHANGELOG"
fi

say "${GREEN}✔ Updated ${CHANGELOG}${NC}"

# ─── Update pubspec.yaml ──────────────────────────────────────────────────────

NEW_VERSION_LINE="version: ${NEW_VERSION}+${NEW_BUILD}"
sed -i.bak "s/^version:.*/${NEW_VERSION_LINE}/" "$PUBSPEC"
rm -f "${PUBSPEC}.bak"

say "${GREEN}✔ Updated pubspec.yaml: ${NEW_VERSION_LINE}${NC}"

# ─── Commit and Tag ───────────────────────────────────────────────────────────

git add "$PUBSPEC" "$CHANGELOG"
git commit -m "chore(release): ${NEW_VERSION}"
git tag "$TAG_NAME"

say "${GREEN}✔ Committed and tagged ${TAG_NAME}${NC}"

# ─── Push to Remote ───────────────────────────────────────────────────────────

printf '\n'
say "${YELLOW}Pushing commit and tag to origin...${NC}"
git push origin "$CURRENT_BRANCH"
git push origin "$TAG_NAME"

printf '\n'
say "${GREEN}✅ Version bump complete!${NC}"
say "${GREEN}   New version: ${NEW_VERSION}+${NEW_BUILD}${NC}"
say "${GREEN}   Tag: ${TAG_NAME}${NC}"
