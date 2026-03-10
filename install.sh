#!/bin/bash
set -e

# claude-wizard installer
# Installs the wizard skill into your project's .claude/skills/ directory

SKILL_DIR=".claude/skills/wizard"
REPO_URL="https://raw.githubusercontent.com/vlad-ko/claude-wizard/main/skill"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo "  claude-wizard installer"
echo "  ======================"
echo ""

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not inside a git repository.${NC}"
    echo "Run this from the root of your project."
    exit 1
fi

# Get repo root
REPO_ROOT=$(git rev-parse --show-toplevel)
TARGET="${REPO_ROOT}/${SKILL_DIR}"

# Check if already installed
if [ -d "$TARGET" ]; then
    echo -e "${YELLOW}Wizard skill already exists at ${SKILL_DIR}/${NC}"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Create directory
mkdir -p "$TARGET"

# Download files
echo "Downloading skill files..."

for file in SKILL.md CHECKLISTS.md PATTERNS.md; do
    if command -v curl > /dev/null 2>&1; then
        curl -sL "${REPO_URL}/${file}" -o "${TARGET}/${file}"
    elif command -v wget > /dev/null 2>&1; then
        wget -q "${REPO_URL}/${file}" -O "${TARGET}/${file}"
    else
        echo -e "${RED}Error: Neither curl nor wget found.${NC}"
        exit 1
    fi
    echo "  + ${SKILL_DIR}/${file}"
done

echo ""
echo -e "${GREEN}Installed successfully!${NC}"
echo ""
echo "Usage:"
echo "  Type /wizard in Claude Code to activate architect mode."
echo ""
echo "Optional: Add to .gitignore if you don't want to commit the skill:"
echo "  echo '.claude/skills/wizard/' >> .gitignore"
echo ""
echo "Tip: Customize SKILL.md to add your project-specific patterns,"
echo "     framework conventions, and tooling preferences."
echo ""
