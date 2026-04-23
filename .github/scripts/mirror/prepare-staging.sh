#!/usr/bin/env bash
# Build a staging directory: copy updater repo (excluding mirror internals), move .tekton → pipelines,
# strip namespaces then set default-tenant on PipelineRuns, rewrite output-image params,
# rename pipeline files, sanitize public metadata.
# Writes GitHub Actions output staging_dir.
#
# Required env in Actions: GITHUB_WORKSPACE, GITHUB_OUTPUT
# Optional: MIRROR_INTERNAL_OUTPUT_IMAGE_PREFIX
set -euo pipefail

ROOT="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE must be set}"
cd "$ROOT"

STAGING="$(mktemp -d)"
echo "staging_dir=$STAGING" >>"${GITHUB_OUTPUT}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy repo without git metadata and without this workflow's mirror-only assets (they must not land on the public sample).
rsync -a \
  --exclude=.git \
  --exclude=.github/workflows/mirror-to-sample-component-golang.yaml \
  --exclude=.github/scripts/mirror/ \
  --exclude=.github/scripts/create-or-update-issue.sh \
  "${ROOT}/" "${STAGING}/"

pushd "$STAGING" >/dev/null
bash "${SCRIPT_DIR}/move-tekton-to-pipelines.sh" "$STAGING"
bash "${SCRIPT_DIR}/strip-tekton-namespaces.sh" "${STAGING}/pipelines"
bash "${SCRIPT_DIR}/rewrite-output-images.sh" "${STAGING}/pipelines"
bash "${SCRIPT_DIR}/rename-pipelines-for-public-sample-component-golang.sh" "$STAGING"
bash "${SCRIPT_DIR}/sanitize-sample-component-golang-pipeline-metadata.sh" "${STAGING}/pipelines"
popd >/dev/null

echo "prepare-staging: staging tree at $STAGING"
