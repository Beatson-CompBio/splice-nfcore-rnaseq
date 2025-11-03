#!/bin/bash

echo "🔍 Verifying GitHub Actions Setup"
echo "================================"

error_count=0

# Check workflow files
workflows=(
    ".github/workflows/ci.yml"
    ".github/workflows/ci-all-branches.yml"
    ".github/workflows/manual-trigger.yml"
    ".github/workflows/validate-quick.yml"
)

echo "📁 Checking workflow files:"
for workflow in "${workflows[@]}"; do
    if [ -f "$workflow" ]; then
        echo "  ✅ $workflow"
        # Validate YAML syntax
        if python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>/dev/null; then
            echo "    ✅ Valid YAML syntax"
        else
            echo "    ❌ Invalid YAML syntax"
            ((error_count++))
        fi
    else
        echo "  ❌ $workflow (missing)"
        ((error_count++))
    fi
done

# Check configuration files
configs=(
    "conf/github_actions.config"
    "conf/independent.config"
)

echo ""
echo "⚙️  Checking configuration files:"
for config in "${configs[@]}"; do
    if [ -f "$config" ]; then
        echo "  ✅ $config"
    else
        echo "  ❌ $config (missing)"
        ((error_count++))
    fi
done

# Check for deprecated actions
echo ""
echo "🔍 Checking for deprecated GitHub Actions:"
if grep -r "upload-artifact@v3" .github/workflows/ >/dev/null 2>&1; then
    echo "  ❌ Found deprecated upload-artifact@v3"
    ((error_count++))
else
    echo "  ✅ No deprecated upload-artifact found"
fi

if grep -r "setup-nextflow@v1" .github/workflows/ >/dev/null 2>&1; then
    echo "  ❌ Found deprecated setup-nextflow@v1"
    ((error_count++))
else
    echo "  ✅ No deprecated setup-nextflow found"
fi

echo ""
if [ $error_count -eq 0 ]; then
    echo "🎉 All checks passed! GitHub Actions setup is ready."
    echo ""
    echo "📋 Next steps:"
    echo "1. Commit the changes:"
    echo "   git add .github/workflows/ conf/ scripts/"
    echo "   git commit -m 'Add GitHub Actions CI/CD setup with v4 artifacts'"
    echo "   git push origin $(git branch --show-current)"
    echo ""
    echo "2. Check Actions tab: https://github.com/$(git config remote.origin.url | sed 's/.*github.com[:/]//; s/\.git$//')/actions"
else
    echo "❌ Found $error_count errors. Please fix them before committing."
fi
