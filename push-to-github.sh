#!/bin/bash

# Bash script to push changes to GitHub

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse arguments
COMMIT_MESSAGE=""
BRANCH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--message)
            COMMIT_MESSAGE="$2"
            shift 2
            ;;
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-m|--message MESSAGE] [-b|--branch BRANCH]"
            echo ""
            echo "Options:"
            echo "  -m, --message MESSAGE  Commit message (will prompt if not provided)"
            echo "  -b, --branch BRANCH    Branch to push to (default: current branch)"
            echo "  -h, --help            Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}=== GitHub Push Script ===${NC}"
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: Git is not installed or not in PATH${NC}"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

# Get current branch if not specified
if [ -z "$BRANCH" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

echo -e "${YELLOW}Current branch: $BRANCH${NC}"
echo ""

# Check if there are changes
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}No changes to commit${NC}"
    echo ""
    read -p "Do you want to push anyway? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 0
    fi
fi

# Show status
echo -e "${CYAN}Current status:${NC}"
git status --short
echo ""

# Get commit message if not provided
if [ -z "$COMMIT_MESSAGE" ]; then
    read -p "Enter commit message: " COMMIT_MESSAGE
    if [ -z "$COMMIT_MESSAGE" ]; then
        echo -e "${RED}Error: Commit message cannot be empty${NC}"
        exit 1
    fi
fi

# Stage all changes
echo -e "${YELLOW}Staging all changes...${NC}"
git add .

# Commit changes
echo -e "${YELLOW}Committing changes...${NC}"
git commit -m "$COMMIT_MESSAGE"

echo -e "${GREEN}✓ Changes committed successfully${NC}"
echo ""

# Push to remote
echo -e "${YELLOW}Pushing to origin/$BRANCH...${NC}"
if ! git push origin "$BRANCH" 2>/dev/null; then
    echo -e "${YELLOW}Attempting to set upstream branch...${NC}"
    git push --set-upstream origin "$BRANCH"
fi

echo -e "${GREEN}✓ Successfully pushed to GitHub!${NC}"
echo ""

# Show latest commit
echo -e "${CYAN}Latest commit:${NC}"
git log -1 --oneline

