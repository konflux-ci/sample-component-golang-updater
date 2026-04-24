#!/usr/bin/env bash
# Rewrite PipelineRun spec.params output-image values from Konflux
# quay.io/redhat-user-workloads/<tenant>/<app>/<component>:<tag> to the internal-registry style used in
# konflux-ci/sample-component-golang/pipelines (registry-service.kind-registry/sample-component-golang:<tag>).
#
# Usage: rewrite-output-images.sh <pipelines_dir>
# Env:
#   MIRROR_INTERNAL_OUTPUT_IMAGE_PREFIX  default: registry-service.kind-registry/sample-component-golang
# Requires: mikefarah yq (https://github.com/mikefarah/yq) — installed to /usr/local/bin/yq in CI.
set -euo pipefail

PIPES="${1:?pipelines directory required}"
PREFIX="${MIRROR_INTERNAL_OUTPUT_IMAGE_PREFIX:-registry-service.kind-registry/sample-component-golang}"
export PREFIX

mapfile -t files < <(find "$PIPES" -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) | sort)

for f in "${files[@]}"; do
  kind="$(yq -r '.kind // ""' "$f" 2>/dev/null || echo "")"
  [[ "$kind" == "PipelineRun" ]] || continue

  current="$(yq -r '.spec.params[]? | select(.name == "output-image") | .value // ""' "$f" 2>/dev/null || true)"
  [[ "$current" =~ ^quay.io/redhat-user-workloads/ ]] || continue

  echo "rewrite-output-images: $f"
  yq -i '(.spec.params[] | select(.name == "output-image") | .value) |= sub("^quay.io/redhat-user-workloads/[^/]+/[^/]+/[^:]+"; strenv(PREFIX))' "$f"
done

echo "rewrite-output-images: done (prefix=$PREFIX)"
