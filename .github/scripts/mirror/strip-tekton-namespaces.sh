#!/usr/bin/env bash
# Remove metadata.namespace from Tekton YAML files (PipelineRun, Pipeline, Task, ...).
# Usage: strip-tekton-namespaces.sh <dir>
# Requires: yq (https://github.com/mikefarah/yq)
set -euo pipefail

DIR="${1:?directory required}"

mapfile -t files < <(find "$DIR" -type f \( -name '*.yaml' -o -name '*.yml' \) | sort)

for f in "${files[@]}"; do
  kind="$(yq -r '.kind // ""' "$f" 2>/dev/null || echo "")"
  case "$kind" in
    PipelineRun|Pipeline|Task|TaskRun|CustomRun)
      echo "strip-namespace: $f ($kind)"
      yq -i 'del(.metadata.namespace)' "$f"
      ;;
    *)
      # Still strip for other Tekton API kinds if apiVersion is tekton.dev
      av="$(yq -r '.apiVersion // ""' "$f" 2>/dev/null || echo "")"
      if [[ "$av" == tekton.dev/* ]]; then
        echo "strip-namespace: $f (apiVersion $av)"
        yq -i 'del(.metadata.namespace)' "$f"
      fi
      ;;
  esac
done

echo "strip-tekton-namespaces: done"
