#!/bin/bash
## Author: Aurélien Pisu
## allow to validation editorconfig and format 
set -eo pipefail

# default value to use 
CUSTOM_LINTERS_PATH=".github/linters/custom-linters"
FILE_EXTENSIONS="java"
SUPER_LINTER_IMAGE="github/super-linter:latest"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
REMOTE_NAME=$1

echo "CUSTOM_LINTERS_PATH=$CUSTOM_LINTERS_PATH"
echo "FILE_EXTENSIONS=$FILE_EXTENSIONS"
echo "SUPER_LINTER_IMAGE=$SUPER_LINTER_IMAGE"
echo "CURRENT_BRANCH=$CURRENT_BRANCH"
echo "REMOTE_NAME=$REMOTE_NAME"


# check if remote branche exists and if it's the case determine the delta to list only changed files
# Determine changed files relative to remote branch
if git show-ref --verify --quiet "refs/remotes/$REMOTE_NAME/$CURRENT_BRANCH"; then
	echo "remote branche exists"
	# Fetch latest from remote to ensure comparison is up to date
	git fetch "$REMOTE_NAME" "$CURRENT_BRANCH"
    	# Remote branch exists: diff against it
    	CHANGED_FILES=$(git diff --name-only "refs/remotes/$REMOTE_NAME/$CURRENT_BRANCH...HEAD" \
                    | grep -E "$FILE_EXTENSIONS" || true)
else
	echo "remote branche not exists"
    	# Remote branch does NOT exist: lint staged files
    	echo "Remote branch does not exist. Linting all staged files..."
    	CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM \
                    | grep -E "$FILE_EXTENSIONS" || true)
fi


# Exit if no files to lint
if [ -z "$CHANGED_FILES" ]; then
    	echo "No changed files to lint."
    	exit 0
fi

echo "Linting the following changed files:"
echo "$CHANGED_FILES"

# Run Super-Linter with custom linters
echo "run linter"
docker run --rm \
    -e RUN_LOCAL=true \
    -e VALIDATE_CUSTOM_LINTERS=true \
    -e CUSTOM_LINTERS_PATH="$CUSTOM_LINTERS_PATH" \
    -v "$(pwd)":/tmp/lint \
    $SUPER_LINTER_IMAGE \
    --filter-files "$CHANGED_FILES"

# Exit code
if [ $? -ne 0 ]; then
    	echo "Linting failed. Please fix errors before pushing."
    	exit 1
fi

echo "All lint checks passed."
exit 0

