# Multi-stage build producing a static Go binary on a scratch (empty) base
# image — no shell, no OS packages, no libc.  Runs as non-root (UID 65532).
#
# The Go module path (github.com/konflux-ci/sample-component-golang) intentionally
# matches the public mirror repo, not this updater repo.
FROM registry.access.redhat.com/hi/go@sha256:98f7834045393dc0d08ee670dcf069e2ea842c485ae6561bdee26a1a642a8ab1 AS builder

WORKDIR /workspace

COPY --chmod=644 go.mod go.mod
COPY --chmod=644 go.sum go.sum
COPY --chmod=644 main.go main.go

RUN go mod download

RUN CGO_ENABLED=0 go build -o /opt/app-root/sample-component-golang main.go

FROM scratch

COPY --from=builder /opt/app-root/sample-component-golang /sample-component-golang

EXPOSE 8080
USER 65532:65532

LABEL name="Sample Component Golang"
LABEL description="Sample component written in Golang"
LABEL summary="Sample component written in Golang"
LABEL io.k8s.description="Sample component written in Golang"
LABEL io.k8s.display-name="sample-component-golang"
LABEL version="1.0.0"
LABEL release="1"
LABEL vendor="Red Hat, Inc."
LABEL distribution-scope="public"
LABEL url="https://github.com/konflux-ci/sample-component-golang"
LABEL maintainer="Konflux CI"
LABEL com.redhat.component="sample-component-golang"

CMD ["/sample-component-golang"]
