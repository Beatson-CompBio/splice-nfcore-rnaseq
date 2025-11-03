#!/bin/bash
# verify_containers.sh - Test all container definitions

echo "🔍 Verifying container definitions..."

# Check for any remaining Seqera containers
echo "🕵️  Checking for remaining Seqera containers..."
remaining_seqera=$(grep -r "seqera\.io\|wave\." --include="*.nf" . | wc -l)

if [ "$remaining_seqera" -eq 0 ]; then
    echo "  ✅ No Seqera containers found"
else
    echo "  ❌ Found $remaining_seqera references to Seqera containers:"
    grep -r "seqera\.io\|wave\." --include="*.nf" .
fi

# Find all container definitions
echo ""
echo "📋 Current container definitions:"
grep -r "container ['\"]" --include="*.nf" modules/ | head -10 | while IFS=: read -r file line; do
    container=$(echo "$line" | sed "s/.*container ['\"]//; s/['\"].*//" | head -1)
    echo "  📦 $container"
done

echo ""
echo "🏁 Container verification complete"
