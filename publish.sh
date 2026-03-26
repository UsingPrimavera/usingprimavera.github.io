#!/usr/bin/env bash
# publish.sh — Build and deploy usingprimavera.com to GitHub Pages (master branch)
#
# Usage: ./publish.sh [commit message]
# Example: ./publish.sh "Release: 2026-03-26"
#
# What this does:
#   1. Cleans previous build
#   2. Builds production site
#   3. Commits _site/ contents to master branch
#   4. Pushes master to GitHub Pages
#
# Requirements:
#   - Run from the repo root (source branch)
#   - _site/ must be a git repo tracking master (already configured)
#   - SSH key must be loaded for github.com

set -euo pipefail

COMMIT_MSG="${1:-Release: $(date +%Y-%m-%d)}"

echo "==> Cleaning previous build..."
bundle exec jekyll clean

echo "==> Building production site..."
JEKYLL_ENV=production bundle exec jekyll build

echo "==> Publishing to master branch..."
cd _site
git add .
git commit -m "$COMMIT_MSG" || echo "Nothing new to commit in _site/"
git push origin master

echo ""
echo "✓ Published: $COMMIT_MSG"
echo "  Live at: https://usingprimavera.com"
