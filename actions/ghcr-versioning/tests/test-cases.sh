#!/bin/bash
set -euo pipefail

# Configuration
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Setup test environment
setup_git() {
  git -C "$TEMP_DIR" init -q
  git -C "$TEMP_DIR" config user.name "TestBot"
  git -C "$TEMP_DIR" config user.email "test@example.com"
  git -C "$TEMP_DIR" commit -m "Initial commit" --allow-empty -q
}

# Test runner
run_test() {
  local branch=$1
  local commit_msg=$2
  local expected=$3
  
  echo "🔍 Testing: branch=$branch | msg=$commit_msg"
  
  export GITHUB_REF="refs/heads/$branch"
  export GITHUB_EVENT_HEAD_COMMIT_MESSAGE="$commit_msg"
  
  output=$(node ../action.yml 2>&1 | tee /dev/stderr)
  
  if [[ ! "$output" =~ $expected ]]; then
    echo -e "\n❌ FAIL: Expected pattern '$expected' not found"
    return 1
  else
    echo -e "\n✅ PASS"
  fi
}

# Main execution
setup_git

echo -e "\n=== Running Versioning Action Tests ===\n"

run_test "staging" "[MAJOR] Breaking change" "staging-v1.0.0-rc.0"
run_test "staging" "[MINOR] New feature" "staging-v0.1.0-rc.0" 
run_test "staging" "Patch fix" "staging-v0.0.1-rc.0"
run_test "main" "Release prod" "v0.0.1"

echo -e "\nAll tests passed successfully!"