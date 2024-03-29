ARG BUILD_ARG_GO_VERSION=1.22
ARG BUILD_ARG_ALPINE_VERSION=3.19
FROM golang:${BUILD_ARG_GO_VERSION}-alpine${BUILD_ARG_ALPINE_VERSION} AS builder
RUN apk add --update --no-cache curl ca-certificates

WORKDIR /src

COPY . .

RUN curl "https://raw.githubusercontent.com/grpc/grpc-go/master/examples/helloworld/greeter_client/main.go" -o main.go

RUN go mod tidy && go build -ldflags "-s -w" -o greeter

FROM alpine:${BUILD_ARG_ALPINE_VERSION}
WORKDIR /
ENV USER=greeter
ENV UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"
RUN apk add --update --no-cache tzdata curl

COPY --from=builder /src/greeter .

USER greeter:greeter

ENTRYPOINT ["/greeter"]
