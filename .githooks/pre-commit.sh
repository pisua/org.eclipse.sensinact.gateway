#!/bin/bash
## Author: Aurélien Pisu
## Pre-commit hook: validate editorconfig, format, and run Super-Linter
set -eo pipefail

# Configuration
CUSTOM_LINTERS_PATH=".github/linters/custom-linters"
FILE_EXTENSIONS="java"
SUPER_LINTER_IMAGE="github/super-linter:latest"

echo "CUSTOM_LINTERS_PATH=$CUSTOM_LINTERS_PATH"
echo "FILE_EXTENSIONS=$FILE_EXTENSIONS"
echo "SUPER_LINTER_IMAGE=$SUPER_LINTER_IMAGE"

# Get staged files for commit
CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E "$FILE_EXTENSIONS" || true)

# Exit if no files to lint
if [ -z "$CHANGED_FILES" ]; then
    echo "No staged files to lint."
    exit 0
fi

echo "Linting the following staged files:"
echo "$CHANGED_FILES"

# Run Super-Linter with custom linters
docker run --rm \
    -e RUN_LOCAL=true \
    -e VALIDATE_CUSTOM_LINTERS=true \
    -e CUSTOM_LINTERS_PATH="$CUSTOM_LINTERS_PATH" \
    -v "$(pwd)":/tmp/lint \
    $SUPER_LINTER_IMAGE \
    --filter-files "$CHANGED_FILES"

# Exit code handling
if [ $? -ne 0 ]; then
    echo "Linting failed. Please fix errors before committing."
    exit 1
fi

echo "All lint checks passed."
exit 0

