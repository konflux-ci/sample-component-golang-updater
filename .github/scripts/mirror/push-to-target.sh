#!/usr/bin/env bash
# Clone mirror target, replace tree with staged content, commit and push main.
#
# Required env:
#   GIT_TOKEN              PAT or GitHub App installation token (repo write on target)
#   TARGET_REPOSITORY      e.g. konflux-ci/sample-component-golang
#   STAGING_DIR            directory whose contents replace the target working tree
#   GITHUB_SHA             commit SHA from updater (for commit message)
# Optional:
#   TARGET_BRANCH          default main
#   GIT_USER_NAME / GIT_USER_EMAIL for commit attribution
#   GITHUB_REPOSITORY      source repo (e.g. konflux-ci/sample-component-golang-updater); set automatically in Actions
set -euo pipefail

: "${GIT_TOKEN:?GIT_TOKEN is required}"
: "${TARGET_REPOSITORY:?TARGET_REPOSITORY is required}"
: "${STAGING_DIR:?STAGING_DIR is required}"
: "${GITHUB_SHA:?GITHUB_SHA is required}"

TARGET_BRANCH="${TARGET_BRANCH:-main}"
GIT_USER_NAME="${GIT_USER_NAME:-github-actions[bot]}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-41898282+github-actions[bot]@users.noreply.github.com}"
SOURCE_REPO="${GITHUB_REPOSITORY:-konflux-ci/sample-component-golang-updater}"

if [[ ! -d "$STAGING_DIR" ]]; then
  echo "push-to-target: STAGING_DIR is not a directory: $STAGING_DIR" >&2
  exit 1
fi

WORKDIR="$(mktemp -d)"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

CLONE="$WORKDIR/target"
git clone --depth 1 "https://x-access-token:${GIT_TOKEN}@github.com/${TARGET_REPOSITORY}.git" "$CLONE"
cd "$CLONE"
git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

git checkout "$TARGET_BRANCH"

rsync -a --delete \
  --exclude=.git \
  "${STAGING_DIR}/" ./

# Stage everything first: untracked new files from rsync do not appear in `git diff`
# (tracked vs index) until added; only the index vs HEAD reflects the full mirror delta.
git add -A

if git diff --cached --quiet; then
  echo "push-to-target: no changes compared to ${TARGET_REPOSITORY} ${TARGET_BRANCH}; nothing to push"
  exit 0
fi

git commit -m "Mirror from ${SOURCE_REPO}@${GITHUB_SHA:0:12}"

git push origin "HEAD:${TARGET_BRANCH}"

echo "push-to-target: pushed to ${TARGET_REPOSITORY} ${TARGET_BRANCH}"
