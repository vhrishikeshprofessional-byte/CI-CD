# Build stage
FROM golang:1.23-alpine AS build
WORKDIR /app

# Compile statically linked binary without CGO
ENV CGO_ENABLED=0 \
    GOOS=linux

COPY go.mod ./
RUN go mod download || true

COPY . .
RUN go test -v ./...
RUN go build -ldflags="-s -w" -o /app/server .

# Production runtime stage (Distroless static nonroot)
FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app

COPY --from=build /app/server /app/server

EXPOSE 8080
USER nonroot:nonroot

ENTRYPOINT ["/app/server"]
