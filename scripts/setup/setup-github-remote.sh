#!/bin/bash

# setup-github-remote.sh
# Run this after creating the GitHub repository

echo "🔧 Engineering Governance Framework - GitHub Setup"
echo "=================================================="
echo ""
echo "This script will set up the GitHub remote for your governance repository."
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "❌ Error: Git repository not initialized."
    echo "   Run: git init"
    exit 1
fi

# Prompt for GitHub username
read -p "Enter your GitHub username: " USERNAME

# Prompt for repository name (default: engineering-governance)
read -p "Enter repository name [engineering-governance]: " REPO_NAME
REPO_NAME=${REPO_NAME:-engineering-governance}

# Construct GitHub URL
GITHUB_URL="https://github.com/${USERNAME}/${REPO_NAME}.git"

echo ""
echo "GitHub URL: $GITHUB_URL"
echo ""

# Confirm
read -p "Is this correct? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "❌ Cancelled."
    exit 1
fi

# Add remote
git remote add origin "$GITHUB_URL"

# Rename branch to main (if needed)
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "master" ]; then
    git branch -M main
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "-----------"
echo "1. Create repository on GitHub:"
echo "   https://github.com/new"
echo "   Name: $REPO_NAME"
echo "   Description: Portable reasoning governance layer for AI-assisted development"
echo "   (Do NOT initialize with README, .gitignore, or license)"
echo ""
echo "2. Push to GitHub:"
echo "   git push -u origin main"
echo ""
echo "3. Verify:"
echo "   open https://github.com/${USERNAME}/${REPO_NAME}"
echo ""

# Offer to create repository via gh CLI if available
if command -v gh &> /dev/null; then
    echo "💡 GitHub CLI detected! Want me to create the repository automatically?"
    read -p "Create via gh? (y/n): " CREATE_VIA_GH
    
    if [ "$CREATE_VIA_GH" = "y" ]; then
        gh repo create "$REPO_NAME" \
            --public \
            --description "Portable reasoning governance layer for AI-assisted development" \
            --source=. \
            --push
        
        echo ""
        echo "🎉 Repository created and pushed!"
        echo "   https://github.com/${USERNAME}/${REPO_NAME}"
    fi
fi
