# Agent Guidelines for sample-component-golang-updater

## Project Overview

A minimal Go HTTP server used as a **sample component** for testing
[Konflux](https://github.com/konflux-ci/konflux-ci). See `README.md` for
user-facing docs, `go.mod` for the module path and dependencies, and `main.go`
for the full application source.

## Updater / Mirror Relationship

This repository is the **updater** — the single source of truth. A GitHub
Actions workflow (see `.github/workflows/`) mirrors content to the public
[konflux-ci/sample-component-golang](https://github.com/konflux-ci/sample-component-golang),
which is what end-users fork before Konflux onboarding. The mirrored
repository is used by [konflux-ci/konflux-ci](https://github.com/konflux-ci/konflux-ci)
for onboarding demos and CI testing.

**All changes must be made in this repository.** The public sample is
overwritten on each mirror run.

## Development

- No `Makefile` — build and run with standard Go tooling.
- Run locally: `go run main.go`
- Container build: `docker build -t sample-component-golang .`

## Verifying Changes

```bash
gofmt -l .                # must produce no output
go vet ./...              # must pass
go build ./...            # must compile
go test ./...             # run if tests exist
docker build -t sample-component-golang .   # image must build
bash .github/scripts/verify-docker-smoke.sh sample-component-golang:latest latest  # HTTP smoke test
```

## Things to Avoid

- **Do not edit the public sample** (`konflux-ci/sample-component-golang`)
directly — the mirror will overwrite your changes.
- **Do not bump `demo/cve-onboarding/` fixtures** — they are frozen
intentionally. See `demo/cve-onboarding/README.md`.
- **Do not change `metadata.namespace` in Tekton PipelineRuns** — see the
  comments at the top of the `.tekton/` YAML files.
- **Do not remove the Renovate `demo/**` exclusion** — see the `description`
  field in `renovate.json`.

