#!/usr/bin/env bash
# Run a built sample-component-golang image and smoke-test HTTP (/, Accept-Language).
#
# Usage: verify-docker-smoke.sh <image_ref> <container_suffix>
# Example: verify-docker-smoke.sh sample-component-golang:latest latest
#
# Requires: docker, curl
set -euo pipefail

IMAGE="${1:?image ref required (e.g. sample-component-golang:latest)}"
SUFFIX="${2:?container suffix required (e.g. latest or demo-vulnerable)}"

name="srv-${SUFFIX}"
host_port="${HOST_PORT:-18080}"

docker rm -f "$name" 2>/dev/null || true
docker run -d --name "$name" -p "${host_port}:8080" "$IMAGE"

cleanup() {
  docker rm -f "$name" 2>/dev/null || true
}
trap cleanup EXIT

: > /tmp/sample-component-golang-smoke-body.txt
for _ in $(seq 1 60); do
  if curl -sf --max-time 2 "http://127.0.0.1:${host_port}/" -o /tmp/sample-component-golang-smoke-body.txt 2>/dev/null; then
    break
  fi
  sleep 1
done

if [[ ! -s /tmp/sample-component-golang-smoke-body.txt ]]; then
  echo "Server did not respond in time" >&2
  docker logs "$name" >&2 || true
  exit 1
fi

if ! grep -q 'Hello World' /tmp/sample-component-golang-smoke-body.txt; then
  echo "Expected body to contain Hello World; got:" >&2
  cat /tmp/sample-component-golang-smoke-body.txt >&2
  docker logs "$name" >&2 || true
  exit 1
fi

echo "=== GET / (default) ==="
cat /tmp/sample-component-golang-smoke-body.txt

curl -sf --max-time 2 -H 'Accept-Language: fr' "http://127.0.0.1:${host_port}/" -o /tmp/sample-component-golang-smoke-lang.txt
echo "=== GET / (Accept-Language: fr) ==="
cat /tmp/sample-component-golang-smoke-lang.txt

if ! grep -q 'lang=' /tmp/sample-component-golang-smoke-lang.txt; then
  echo "Expected Accept-Language response to include lang=" >&2
  docker logs "$name" >&2 || true
  exit 1
fi

trap - EXIT
docker rm -f "$name"

echo "verify-docker-smoke: OK for $IMAGE"
