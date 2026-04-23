#!/usr/bin/env bash
# Konflux names PipelineRuns sample-component-golang-updater-*.yaml; public konflux-ci/sample-component-golang uses
# sample-component-pull-request.yaml / sample-component-push.yaml. Rename so the mirror matches the public sample.
# Usage: rename-pipelines-for-public-sample-component-golang.sh <repo_root>
set -euo pipefail

ROOT="${1:?repo root required}"
PIPES="${ROOT}/pipelines"

if [[ ! -d "$PIPES" ]]; then
  exit 0
fi

pr_src="${PIPES}/sample-component-golang-updater-pull-request.yaml"
push_src="${PIPES}/sample-component-golang-updater-push.yaml"

if [[ ! -f "$pr_src" ]] || [[ ! -f "$push_src" ]]; then
  echo "rename-pipelines-for-public-sample-component-golang: expected Konflux files missing; skipping rename"
  exit 0
fi

mv -f "$pr_src" "${PIPES}/sample-component-pull-request.yaml"
mv -f "$push_src" "${PIPES}/sample-component-push.yaml"
echo "rename-pipelines-for-public-sample-component-golang: Konflux pipelines -> sample-component-pull-request.yaml, sample-component-push.yaml"
