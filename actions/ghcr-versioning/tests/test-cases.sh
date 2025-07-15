#!/bin/bash
set -euo pipefail

# Setup temporary repo
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

setup_git() {
  git -C "$TEMP_DIR" init -q
  git -C "$TEMP_DIR" config user.name "TestBot"
  git -C "$TEMP_DIR" config user.email "test@example.com"
  git -C "$TEMP_DIR" commit -m "Initial commit" --allow-empty -q
}

# Run versioning logic with controlled env
run_test() {
  local branch=$1
  local commit_msg=$2
  local expected=$3

  echo "🔍 Testing: branch=$branch | msg=$commit_msg"

  pushd "$TEMP_DIR" > /dev/null

  export COMMIT_MESSAGE="$commit_msg"
  export CURRENT_BRANCH="$branch"
  export STAGING_BRANCH="staging"
  export PROD_BRANCH="main"
  export PROD_PREFIX="v"
  export STAGING_PREFIX="staging-v"
  export MAJOR_TRIGGER="[MAJOR]"
  export MINOR_TRIGGER="[MINOR]"
  export RC_SUFFIX="-rc."
  export FALLBACK_VERSION="0.0.0"
  export DOCKER_REPOSITORY="monorg/monimage"

  output=$(bash ../src/calculate-version.sh 2>&1 | tee /dev/stderr)

  if [[ "$output" =~ $expected ]]; then
    echo -e "✅ PASS: matched $expected\n"
  else
    echo -e "❌ FAIL: expected $expected\n"
    exit 1
  fi

  popd > /dev/null
}

# Run
setup_git
echo -e "\n=== 🧪 Running Versioning Tests ===\n"

run_test "staging" "[MAJOR] Breaking change" "staging-v1.0.0-rc.0"
run_test "staging" "[MINOR] New feature" "staging-v0.1.0-rc.0"
run_test "staging" "Simple patch" "staging-v0.0.1-rc.0"
run_test "main" "Release prod" "v0.0.1"

echo -e "\n🎉 All tests passed!"
