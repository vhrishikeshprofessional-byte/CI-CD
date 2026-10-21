# Go DevSecOps Sample Application (`go-hello`)

A production-ready reference Go REST API demonstrating modern cloud-native DevSecOps practices:
- **Language / Runtime:** Go 1.23
- **Framework:** Standard Library `net/http` with timeout hardening against Slowloris attacks
- **Unit Testing:** Go standard `testing` package with race condition detector (`-race`)
- **Code Coverage:** `go test -coverprofile=coverage.out`
- **Linting & Code Quality:** `golangci-lint` & `go vet`
- **Security Flaw Static Analysis:** `gosec`
- **Software Composition Analysis (SCA):** `govulncheck` (Official Go Vulnerability DB)
- **Code Quality & Security Gate:** SonarQube
- **Secret Scanning:** Gitleaks
- **Containerization:** Multi-stage Docker build to Distroless static non-root (`gcr.io/distroless/static-debian12:nonroot`)
- **Container Image Vulnerability Scanning:** Trivy

---

## Project Structure

```
go-hello/
├── main.go
├── main_test.go
├── go.mod
├── .golangci.yml
├── Dockerfile
├── .dockerignore
├── sonar-project.properties
├── trivy.yaml
├── .github/
│   └── workflows/
│       └── ci.yml
└── README.md
```

---

## Local Development & Verification

### 1. Prerequisites
- Go 1.22+ installed (`go version`)
- Docker Desktop installed & running (`docker version`)

### 2. Linting & Testing
```bash
# Go vet
go vet ./...

# Run unit tests with race detection and coverage
go test -v -race -coverprofile=coverage.out ./...

# Run golangci-lint (if installed)
golangci-lint run
```

### 3. Run Locally
```bash
go run main.go
```
Endpoints:
- `http://localhost:8080/` -> `{"message":"Hello from Go!","timestamp":"..."}`
- `http://localhost:8080/health` -> `{"status":"healthy"}`

---

## Docker Build & Run

### 1. Build Docker Image
```bash
docker build -t go-hello:local .
```

### 2. Run Container
```bash
docker run --rm -p 8080:8080 go-hello:local
```
Open [http://localhost:8080](http://localhost:8080) in your browser.

### 3. Non-Root Security Verification
```bash
docker run --rm go-hello:local id
# Output: uid=65532(nonroot) gid=65532(nonroot)
```

---

## Security Scanning Locally

### 1. Go Official Vulnerability Scan
```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
```

### 2. Gitleaks Secret Detection
```bash
docker run --rm -v "${PWD}:/repo" zricethezav/gitleaks:latest dir /repo
```

### 3. Trivy Container Image Scan
```bash
trivy image --severity HIGH,CRITICAL go-hello:local
```

---

## Troubleshooting Guide

| Issue | Root Cause | Solution |
| :--- | :--- | :--- |
| `gosec: G112 (CWE-400)` | HTTP server missing `ReadHeaderTimeout`. | `ReadHeaderTimeout: 5 * time.Second` is configured in `main.go`. |
| Distroless container cannot run binary | Binary was compiled with dynamic CGO dependencies. | Compile with `CGO_ENABLED=0` as configured in the Dockerfile. |
| Test failures under `-race` | Concurrency data race detected. | Inspect race report line numbers and protect shared memory with mutex. |
