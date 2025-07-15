#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_test() {
  local branch=$1
  local commit_msg=$2
  local expected=$3

  echo "🔍 Testing: branch=$branch | msg=$commit_msg"

  # Recréation du repo temporaire propre à chaque test
  TEMP_DIR=$(mktemp -d)
  git -C "$TEMP_DIR" init -q
  git -C "$TEMP_DIR" config user.name "TestBot"
  git -C "$TEMP_DIR" config user.email "test@example.com"
  git -C "$TEMP_DIR" commit --allow-empty -m "Initial commit" -q
  git -C "$TEMP_DIR" tag -a "v0.0.0" -m "Initial version"
  git -C "$TEMP_DIR" tag -a "staging-v0.0.0-rc.1" -m "Initial staging version"

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
  export GITHUB_OUTPUT="/dev/stdout"
  export TEMP_DIR

  pushd "$TEMP_DIR" > /dev/null

  output=$(bash "$SCRIPT_DIR/../src/calculate-version.sh")

  popd > /dev/null

  if [[ "$output" =~ $expected ]]; then
    echo -e "✅ PASS: matched $expected\n"
  else
    echo -e "❌ FAIL: expected $expected\n but got:\n$output\n"
    rm -rf "$TEMP_DIR"
    exit 1
  fi

  rm -rf "$TEMP_DIR"
}

echo -e "\n=== 🧪 Running Versioning Tests ===\n"

run_test "staging" "[MAJOR] Breaking change" "staging-v1.0.0-rc.0"
run_test "staging" "[MINOR] New feature" "staging-v0.1.0-rc.0"
run_test "staging" "Simple patch" "staging-v0.0.0-rc.2"
run_test "main" "Release prod" "v0.0.1"

echo -e "\n🎉 All tests passed!"

