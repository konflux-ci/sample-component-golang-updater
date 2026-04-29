FROM registry.access.redhat.com/ubi10/go-toolset@sha256:64b0eccf291e6e060009846eb1131babf4bc653fb77fc7b53ff3550b5cc611f2 AS builder

WORKDIR /workspace

COPY --chmod=644 go.mod go.mod
COPY --chmod=644 go.sum go.sum
COPY --chmod=644 main.go main.go

RUN go mod download

RUN CGO_ENABLED=0 go build -o /opt/app-root/sample-component-golang main.go

FROM registry.access.redhat.com/ubi10/ubi-minimal@sha256:2a4785f399dc7ae2f3ca85f68bac0ccac47f3e73464a47c21e4f7ae46b55a053

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
