#!/usr/bin/env bash
set -euo pipefail

CURRENT_BRANCH="${CURRENT_BRANCH:-}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-}"
PROD_BRANCH="${PROD_BRANCH:-main}"
STAGING_BRANCH="${STAGING_BRANCH:-staging}"
PROD_PREFIX="${PROD_PREFIX:-v}"
STAGING_PREFIX="${STAGING_PREFIX:-staging-v}"
MAJOR_TRIGGER="${MAJOR_TRIGGER:-[MAJOR]}"
MINOR_TRIGGER="${MINOR_TRIGGER:-[MINOR]}"
RC_SUFFIX="${RC_SUFFIX:--rc.}"
FALLBACK_VERSION="${FALLBACK_VERSION:-0.0.0}"
DOCKER_REPOSITORY="${DOCKER_REPOSITORY:-ghcr.io/undefined/repo}"

if [[ "$COMMIT_MESSAGE" == *"$MAJOR_TRIGGER"* ]]; then
  bump_type="major"
elif [[ "$COMMIT_MESSAGE" == *"$MINOR_TRIGGER"* ]]; then
  bump_type="minor"
else
  bump_type="patch"
fi

MAIN_TAG=$(git describe --tags --match "${PROD_PREFIX}*" --abbrev=0 2>/dev/null || echo "${PROD_PREFIX}${FALLBACK_VERSION}")
STAGING_TAG=$(git describe --tags --match "${STAGING_PREFIX}*" --abbrev=0 2>/dev/null || echo "${STAGING_PREFIX}${FALLBACK_VERSION}${RC_SUFFIX}0")

MAIN_VERSION=${MAIN_TAG#${PROD_PREFIX}}
STAGING_BASE=${STAGING_TAG#${STAGING_PREFIX}}
STAGING_BASE=${STAGING_BASE%${RC_SUFFIX}*}
STAGING_RC=${STAGING_TAG#*${RC_SUFFIX}}
STAGING_RC=${STAGING_RC:-0}

if [[ "$CURRENT_BRANCH" == "$STAGING_BRANCH" ]]; then
  # STAGING BRANCH
  IFS='.' read -r major minor patch <<< "$MAIN_VERSION"
  case "$bump_type" in
    major)
      NEW_VERSION="${STAGING_PREFIX}$((major + 1)).0.0${RC_SUFFIX}0"
      ;;
    minor)
      NEW_VERSION="${STAGING_PREFIX}${major}.$((minor + 1)).0${RC_SUFFIX}0"
      ;;
    *)
      if [[ "$STAGING_BASE" == "$MAIN_VERSION" ]]; then
        NEW_VERSION="${STAGING_PREFIX}${STAGING_BASE}${RC_SUFFIX}$((STAGING_RC + 1))"
      else
        NEW_VERSION="${STAGING_PREFIX}${major}.${minor}.$((patch + 1))${RC_SUFFIX}0"
      fi
      ;;
  esac
  echo "image_tag=ghcr.io/${DOCKER_REPOSITORY}:${NEW_VERSION}" >> $GITHUB_OUTPUT
  echo "additional_tag=ghcr.io/${DOCKER_REPOSITORY}:staging-latest" >> $GITHUB_OUTPUT
else
  # PRODUCTION BRANCH
  NEW_VERSION="${PROD_PREFIX}${STAGING_BASE}"
  echo "image_tag=ghcr.io/${DOCKER_REPOSITORY}:${NEW_VERSION}" >> $GITHUB_OUTPUT
  echo "additional_tag=ghcr.io/${DOCKER_REPOSITORY}:latest" >> $GITHUB_OUTPUT
fi

echo "new_version=${NEW_VERSION}" >> $GITHUB_OUTPUT

if git rev-parse -q --verify "refs/tags/${NEW_VERSION}" >/dev/null; then
  echo "::error::Tag ${NEW_VERSION} already exists!"
  exit 1
fi
