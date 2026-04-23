# Sample Golang Component for Testing Konflux

This is an example Golang component for testing [Konflux](https://github.com/konflux-ci).

## What It Does

The component is a minimal HTTP server written in Go. It listens on port `8080` (configurable via the `PORT` environment variable) and responds with `Hello World!` on the root path. It uses the `Accept-Language` header to detect the client's preferred language via `golang.org/x/text`.

## Dependency with a Known CVE

This component intentionally includes `golang.org/x/text` at version **v0.3.6**, which has the following known vulnerabilities:

| CVE | Severity | Description |
|---|---|---|
| CVE-2021-38561 | High (7.5) | Out-of-bounds read in `language.ParseAcceptLanguage` |
| CVE-2022-32149 | High (7.5) | Denial of service via crafted `Accept-Language` header |

This is useful for demonstrating that Konflux can detect CVEs in application dependencies.

### Fixing the CVEs

To resolve the vulnerabilities, upgrade `golang.org/x/text` to version **v0.3.8** or later:

```bash
go get golang.org/x/text@latest
go mod tidy
```

After upgrading, rebuild the component and push the changes. Konflux will verify that the CVEs are no longer present.

## Running Locally

```bash
go run main.go
```

Then visit [http://localhost:8080](http://localhost:8080).
