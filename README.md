# Sample Golang Component for Testing Konflux

This is an example Golang component for testing [Konflux](https://github.com/konflux-ci/konflux-ci).

## What It Does

The component is a minimal HTTP server written in Go. It listens on port `8080` (configurable via the `PORT` environment variable) and responds with `Hello World!` on the root path. It uses the `Accept-Language` header to detect the client's preferred language via [`golang.org/x/text`](https://pkg.go.dev/golang.org/x/text).

The root **`go.mod` / `go.sum`** use a **current** `golang.org/x/text` release so day-to-day builds and the mirror to the public sample do not carry known CVEs in that module. Frozen **vulnerable** copies for demos live under [`demo/cve-onboarding/`](demo/cve-onboarding/) (see below). They are saved as `go.mod.cve` / `go.sum.cve` so that syft does not pick them up in the SBOM.

## Demonstrating CVE detection during onboarding

To show what Konflux onboarding looks like when a dependency has known CVEs (for example in recordings, workshops, or screenshots):

1. **Replace the root module files** with the saved vulnerable snapshots (from the repository root):

   ```bash
   cp demo/cve-onboarding/go.mod.cve go.mod
   cp demo/cve-onboarding/go.sum.cve go.sum
   ```

2. **Commit and push** (or open a PR) so Konflux runs dependency and security checks against **`golang.org/x/text` v0.3.6**. You should see findings tied to that version (for example CVE-2021-38561, CVE-2022-32149).

3. When you are done, **restore patched dependencies** at the repository root:

   ```bash
   go get golang.org/x/text@latest
   go mod tidy
   ```

   Commit the updated `go.mod` and `go.sum`. That returns the tree to the same style of dependency versions as before the demo.

The same **`demo/cve-onboarding/`** tree is **included in the mirror** to [konflux-ci/sample-component-golang](https://github.com/konflux-ci/sample-component-golang), so users who only fork the public repo still have the vulnerable snapshots and can run the **`cp`** steps above from their clone.

## Updater and public sample (`sample-component-golang-updater` ↔ `sample-component-golang`)

Konflux maintains two related repositories:

| Repository | Role |
|------------|------|
| [konflux-ci/sample-component-golang-updater](https://github.com/konflux-ci/sample-component-golang-updater) | **Updater** — onboarded to Konflux (Mintmaker, builds, `.tekton/` pipelines). This is where day-to-day changes belong. |
| [konflux-ci/sample-component-golang](https://github.com/konflux-ci/sample-component-golang) | **Public sample** — intended to look like a repo users fork **before** Konflux onboarding (no `.tekton/` in the default tree). Content is produced by mirroring from the updater. |

### Where to make changes

**Make changes in [konflux-ci/sample-component-golang-updater](https://github.com/konflux-ci/sample-component-golang-updater)**, not in `konflux-ci/sample-component-golang` directly.

Pull requests, pipeline tweaks, application source, and documentation updates should target the updater. The mirror overwrites `konflux-ci/sample-component-golang` on each successful run, so edits made only on the public repo would be lost.

### What the mirror does

When changes land on the default branch of the updater, a GitHub Actions workflow:

1. Copies the repository to a staging tree (excluding the entire **`.github/`** directory—workflows, scripts, and all other GitHub metadata), including **`demo/`** so the public sample ships CVE walkthrough fixtures. A successful push also **removes** any `.github/` paths that existed on the public repo from an earlier mirror but are no longer present in the staging tree (see `push-to-target.sh` `rsync --delete`).
2. Moves Konflux-generated `.tekton/` definitions into `pipelines/` (the layout expected for the public sample).
3. Removes `metadata.namespace` from Tekton YAML under `pipelines/`, then sets `metadata.namespace: default-tenant` on each `PipelineRun` so copies users paste into a fork match the Kind demo tenant namespace (`default-tenant` in the Konflux CI docs).
4. Rewrites `output-image` parameters from Konflux `quay.io/redhat-user-workloads/...` values to the internal-registry style used in the sample (`registry-service.kind-registry/sample-component-golang:…`).
5. Renames Konflux pipeline files to `pipelines/sample-component-pull-request.yaml` and `pipelines/sample-component-push.yaml`.
6. Replaces the `main` branch of [konflux-ci/sample-component-golang](https://github.com/konflux-ci/sample-component-golang) with that staging tree (using credentials from repository secrets).

If the workflow fails, an issue is opened on the updater repository for investigation.

### Forking for your own Konflux

Fork [konflux-ci/sample-component-golang](https://github.com/konflux-ci/sample-component-golang) when you want a clean sample without Konflux metadata yet. For collaboration on the upstream Konflux sample itself, use the updater repository as described above.

## Running Locally

```bash
go run main.go
```

Then visit [http://localhost:8080](http://localhost:8080).
