#!/usr/bin/env bash
# Move Konflux-generated PipelineRuns from .tekton/ into pipelines/ (sample-repo layout).
# Usage: move-tekton-to-pipelines.sh <repo_root>
set -euo pipefail

ROOT="${1:?repo root required}"
cd "$ROOT"

if [[ ! -d .tekton ]]; then
  echo "move-tekton-to-pipelines: no .tekton directory at $ROOT" >&2
  exit 1
fi

mkdir -p pipelines

mapfile -t tekton_files < <(find .tekton -type f \( -name '*.yaml' -o -name '*.yml' \) | sort)

if [[ ${#tekton_files[@]} -eq 0 ]]; then
  echo "move-tekton-to-pipelines: no YAML files under .tekton" >&2
  exit 1
fi

for f in "${tekton_files[@]}"; do
  base="$(basename "$f")"
  dest="pipelines/${base}"
  echo "Moving $f -> $dest"
  mv -f "$f" "$dest"
done

rm -rf .tekton
echo "move-tekton-to-pipelines: done"
