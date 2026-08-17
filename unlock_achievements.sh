#!/bin/zsh

# This script automates creating and merging PRs to help unlock GitHub achievements like "Pull Shark" and "YOLO".
# Prerequisites:
# 1. You must have the GitHub CLI (gh) installed. (run `brew install gh`)
# 2. You must be authenticated: `gh auth login`
# 3. This repository must be created on GitHub and set as the origin remote.

# Number of PRs to create (You need 2 for the first Pull Shark tier, 16 for the second)
# Feel free to change this number!
NUM_PRS=2

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first (e.g., using 'brew install gh')."
    exit 1
fi

# Check GitHub authentication
echo "Checking GitHub authentication..."
if ! gh auth status &> /dev/null; then
    echo "❌ You are not authenticated with GitHub CLI. Please run 'gh auth login' first."
    exit 1
fi

# Determine the default branch (main or master)
DEFAULT_BRANCH=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
if [ -z "$DEFAULT_BRANCH" ]; then
    DEFAULT_BRANCH=$(git branch --show-current)
    if [ -z "$DEFAULT_BRANCH" ]; then
        echo "❌ Cannot determine default branch. Make sure this is a Git repository with an initial commit."
        exit 1
    fi
fi

echo "Using default branch: $DEFAULT_BRANCH"

git checkout $DEFAULT_BRANCH
git pull origin $DEFAULT_BRANCH 2>/dev/null || true

for i in {1..$NUM_PRS}; do
    echo "----------------------------------------"
    echo "🚀 Starting PR #$i"
    
    BRANCH_NAME="achieve-pr-$i-$(date +%s)"
    
    # Create and checkout a new branch
    git checkout -b $BRANCH_NAME
    
    # Make a dummy change
    echo "Achievement unlock step $i on $(date)" >> github_achievements_log.txt
    git add github_achievements_log.txt
    git commit -m "chore: unlock achievement step $i"
    
    # Push the branch to GitHub
    echo "Pushing branch $BRANCH_NAME..."
    git push -u origin $BRANCH_NAME
    
    # Create the Pull Request (Contributes to Pull Shark)
    echo "Creating Pull Request..."
    gh pr create \
        --title "Unlock achievement step $i" \
        --body "Automated PR to unlock GitHub achievements like Pull Shark and YOLO." \
        --head $BRANCH_NAME \
        --base $DEFAULT_BRANCH
    
    # Merge the Pull Request without review (Contributes to YOLO)
    echo "Merging Pull Request (YOLO)..."
    gh pr merge $BRANCH_NAME --merge --delete-branch
    
    echo "✅ PR #$i merged successfully."
    
    # Switch back to the default branch and pull latest changes
    git checkout $DEFAULT_BRANCH
    git pull origin $DEFAULT_BRANCH
    
    # Small delay to avoid API rate limits
    sleep 3
done

echo "----------------------------------------"
echo "🎉 Done! It might take a few minutes for GitHub to process the achievements and show them on your profile."
