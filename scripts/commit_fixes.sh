#!/bin/bash

echo "📤 Committing Pipeline Fixes"
echo "============================"

git add .github/workflows/minimal-ci.yml
git add conf/github_actions.config
git add modules/
git add scripts/

git commit -m "Critical pipeline fixes:

- Fix malformed container URLs in modules  
- Add minimal GitHub Actions CI workflow
- Optimize GitHub Actions configuration
- Reduce resource requirements for CI
- Add validation and commit scripts

This should resolve the GitHub Actions failures."

echo "✅ Changes committed. Run 'git push origin dev' to deploy fixes."
