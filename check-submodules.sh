#!/bin/bash
set -e

# We use 'git submodule foreach' to run a check inside every submodule
# The script returns 1 (failure) if any submodule fails the check.

git submodule foreach '
    # 1. Read the branch name from the superproject .gitmodules file
    # "$toplevel" refers to the root of the superproject
    # "$name" is the name of the submodule
    BRANCH=$(git config -f "$toplevel/.gitmodules" submodule."$name".branch || echo "")

    # 2. If no branch is configured, skip this submodule
    if [ -z "$BRANCH" ]; then
        echo "ℹ️  Skipping $name: No branch specified in .gitmodules"
    else
        echo "🔍 Checking $name: Must be on branch $BRANCH..."

        # 3. Ensure we have the latest info from origin regarding that branch
        # We suppress output to keep logs clean
        git fetch origin "$BRANCH" --quiet

        # 4. The Magic Trick: git merge-base --is-ancestor
        # Checks if current commit ($sha1) is an ancestor of origin/$BRANCH
        if git merge-base --is-ancestor "$sha1" "origin/$BRANCH"; then
            echo "✅ OK: Commit $sha1 belongs to $BRANCH"
        else
            echo "❌ ERROR: Submodule $path is pointing to $sha1"
            echo "          This commit is NOT reachable from origin/$BRANCH"
            echo "          Fix: Run \"git submodule update --remote $path\""
            exit 1
        fi
    fi
'
