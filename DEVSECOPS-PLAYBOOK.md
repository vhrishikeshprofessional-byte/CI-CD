# 🛡️ Enterprise DevSecOps Playbook: Framework Deep-Dives & Universal Blueprint

> **Mission:** Enable the engineering team to deeply understand the CI/CD pipeline and multi-stage Dockerfile of every major framework, and use the **Universal DevSecOps Blueprint** to build pipelines for *any* technology stack.
> 
> **Compatible Platforms:** Notion, GitHub Markdown, Obsidian.

---

## 🧭 Table of Contents
1. [The Universal 6-Gate Architecture](#-1-the-universal-6-gate-architecture)
2. [Deep-Dive by Framework (Pipeline + Dockerfile)](#-2-deep-dive-by-framework)
   - [2.1 Java 21 (Maven + Spring Boot / Clean SE)](#21-java-21-microservice-maven)
   - [2.2 React 18 (Vite SPA + Nginx)](#22-react-18-spa-vite--nginx)
   - [2.3 Node.js 22 (Express REST API)](#23-nodejs-22-express-rest-api)
   - [2.4 C++17 (CMake Native CLI)](#24-c17-cmake-native-service)
   - [2.5 .NET 8 (C# Web API)](#25-net-8-web-api-c)
   - [2.6 Python 3.12 (FastAPI Async API)](#26-python-312-fastapi-service)
   - [2.7 Go 1.23 (REST API + Distroless)](#27-go-123-rest-api)
3. [Universal Blueprint: How to Adapt to ANY Framework](#-3-universal-blueprint-how-to-adapt-to-any-framework)
4. [Container Hardening Standards (Cheat Sheet)](#-4-container-hardening-standards)
5. [Real-World Gotchas & Fixes](#-5-real-world-gotchas--troubleshooting-log)

---

## 📌 1. The Universal 6-Gate Architecture

Every production CI/CD pipeline in this monorepo enforces **6 mandatory security & quality gates** before code can be deployed or merged:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Gate 1: LINT    │ ──> │ Gate 2: TEST    │ ──> │ Gate 3: SCA     │
│ Code Style &    │     │ Unit Tests &    │     │ Dependency      │
│ Static Analysis │     │ Code Coverage   │     │ Vulnerabilities │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Gate 4: SECRETS │ ──> │ Gate 5: BUILD   │ ──> │ Gate 6: TRIVY   │
│ Gitleaks Scan   │     │ Hardened Multi- │     │ Container Image │
│ for API Tokens  │     │ Stage Docker    │     │ CVE Detection   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## 🔬 2. Deep-Dive by Framework

---

### 2.1 Java 21 Microservice (Maven)

#### 🔄 Pipeline Walkthrough (`monorepo-ci.yml`)
```yaml
- uses: actions/setup-java@v4
  with:
    distribution: "temurin"
    java-version: "21"
    cache: "maven"
- name: Compile, Test, JaCoCo & Static Analysis
  run: mvn -B clean verify
- name: OWASP Dependency Check
  run: mvn -B org.owasp:dependency-check-maven:check -DfailOnError=false
- name: Gitleaks Secret Scan
  uses: gitleaks/gitleaks-action@v2
- name: Build Docker Image
  run: docker build -t java-hello:${{ github.sha }} .
- name: Scan Docker Image with Trivy
  uses: aquasecurity/trivy-action@v0.36.0
  with:
    image-ref: java-hello:${{ github.sha }}
    severity: "HIGH,CRITICAL"
    exit-code: "1"
```

* **`mvn -B clean verify`**: Single command executing JUnit 5 tests, JaCoCo bytecode coverage report (`target/site/jacoco/`), Checkstyle style enforcement, and SpotBugs static bytecode bug detection.
* **`dependency-check-maven`**: Scans transitive Maven JAR dependencies against the National Vulnerability Database (NVD).
* **Trivy Image Scan**: Scans the compiled container image for OS and library CVEs.

---

#### 🐳 Dockerfile Explained (`java-hello/Dockerfile`)
```dockerfile
# Stage 1: Build & Package (Disposable Builder)
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
# Cache dependencies: layers are reused if pom.xml doesn't change
RUN mvn -B -q dependency:go-offline || true
COPY src ./src
RUN mvn -B clean package -DskipTests

# Stage 2: Hardened Runtime (Production Image)
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
# 1. Update OS packages to patch base-image vulnerabilities (e.g. libexpat)
# 2. Create non-root system user (UID 10001)
RUN apk update && apk upgrade --no-cache && \
    adduser -D -u 10001 appuser
# Copy ONLY the final fat jar from build stage
COPY --from=build /app/target/java-hello-1.0.0.jar app.jar
# Drop root privileges
USER 10001
ENTRYPOINT ["java", "-jar", "app.jar"]
```

> **💡 Key Design Decision:**  
> Switching from default `eclipse-temurin:21-jre` (Ubuntu base) to `alpine` eliminated Ubuntu's bundled `/usr/bin/pebble` tool (4 Go CVEs) and shrank image size from **450MB to 180MB**.

---

### 2.2 React 18 SPA (Vite + Nginx)

#### 🔄 Pipeline Walkthrough (`monorepo-ci.yml`)
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: "22"
- name: Install Dependencies
  run: npm ci
- name: ESLint
  run: npm run lint
- name: Prettier Formatting Check
  run: npm run format:check
- name: Vitest Unit Tests & Coverage
  run: npm run test:coverage
- name: Build React Application
  run: npm run build
- name: npm Audit (Production Dependencies)
  run: npm audit --omit=dev --audit-level=high
- name: Build & Scan Docker Image
  ...
```

* **`npm ci`**: Deterministic clean install using `package-lock.json` (faster and strictly reproduces dependency tree).
* **`npm run lint` & `format:check`**: ESLint flat config (`eslint.config.js`) + Prettier.
* **`vitest run --coverage`**: In-memory test execution producing coverage reports via `@vitest/coverage-v8`.
* **`npm audit --omit=dev`**: Essential for SPAs: audits only dependencies shipped to client browsers (`react`, `react-dom`). Developer test tools (`vite`, `vitest`) are excluded from blocking production builds.

---

#### 🐳 Dockerfile Explained (`react-hello/Dockerfile`)
```dockerfile
# Stage 1: Build the static bundle
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build  # Compiles React into static /app/dist

# Stage 2: Production Nginx Web Server
FROM nginxinc/nginx-unprivileged:stable-alpine
# Custom Nginx configuration for client-side SPA routing (try_files $uri /index.html)
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy ONLY compiled HTML/JS/CSS — zero Node.js runtime or node_modules needed!
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
# Runs as non-root unprivileged Nginx user (UID 101)
USER 101
CMD ["nginx", "-g", "daemon off;"]
```

> **💡 Key Design Decision:**  
> Zero Node.js footprint in production. Node.js is discarded entirely after build. The final image is an ultra-fast, unprivileged Nginx container (~25MB) running as UID 101.

---

### 2.3 Node.js 22 (Express REST API)

#### 🔄 Pipeline Walkthrough (`monorepo-ci.yml`)
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: "22"
- name: Install Dependencies
  run: npm ci
- name: ESLint & Prettier
  run: npm run lint && npm run format:check
- name: Unit Tests & Coverage
  run: npm run test:coverage        # Uses native node:test + c8
- name: npm Audit
  run: npm audit --audit-level=high
- name: Build & Scan Docker Image
  ...
```

* **`node --test` + `c8`**: Uses the fast, native Node.js test runner (no Jest overhead) with `c8` for V8 code coverage.
* **`npm audit --audit-level=high`**: Fails pipeline if any high/critical vulnerability exists in Express or its dependencies.

---

#### 🐳 Dockerfile Explained (`node-hello/Dockerfile`)
```dockerfile
# Stage 1: Production Dependencies
FROM node:22-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev  # Install ONLY production dependencies

# Stage 2: Hardened Runtime
FROM node:22-alpine
ENV NODE_ENV=production PORT=3000
WORKDIR /app

# 1. Update OS packages
# 2. STRIP package managers (npm, npx, yarn, corepack) from runtime!
# 3. Create non-root system group & user
RUN apk update && apk upgrade --no-cache && \
    rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx /opt/yarn* /usr/local/bin/yarn* /usr/local/bin/corepack && \
    addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=dependencies --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup package*.json ./
COPY --chown=appuser:appgroup src ./src

USER appuser
EXPOSE 3000
CMD ["node", "src/app.js"]
```

> **💡 Key Design Decision:**  
> In production, Node only needs to run `node src/app.js`. Stripping `npm` and `yarn` eliminates 10+ nested CVEs (like `brace-expansion`, `sigstore`) and complies with CIS Docker Benchmarks.

---

### 2.4 C++17 (CMake Native Service)

#### 🔄 Pipeline Walkthrough (`monorepo-ci.yml`)
```yaml
- name: Install Compilers and Linters
  run: |
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends \
      cmake g++ clang-format clang-tidy cppcheck
- name: Configure & Build
  run: |
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    cmake --build build --parallel
- name: Unit Tests (CTest)
  run: ctest --test-dir build --output-on-failure
- name: Formatting Check
  run: clang-format --dry-run --Werror src/*.cpp src/*.h tests/*.cpp
- name: Cppcheck Static Analysis
  run: cppcheck --enable=warning,style,performance,portability --error-exitcode=1 src tests
```

* **`cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`**: Generates compile database for clang-tidy & static analyzers.
* **`clang-format --dry-run --Werror`**: Zero-tolerance code style gate.
* **`cppcheck --error-exitcode=1`**: Deep static analysis checking memory leaks, undefined behavior, and out-of-bounds array access.

---

#### 🐳 Dockerfile Explained (`cpp-hello/Dockerfile`)
```dockerfile
# Stage 1: Compiler & Toolchain Stage
FROM gcc:14 AS build
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends cmake make && \
    rm -rf /var/lib/apt/lists/*
COPY CMakeLists.txt .
COPY src ./src
COPY tests ./tests
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build --parallel && \
    ctest --test-dir build --output-on-failure

# Stage 2: Minimal Distro Runtime
FROM debian:bookworm-slim
RUN useradd --system --uid 10001 appuser
WORKDIR /app
# Copy ONLY the compiled ELF binary — no compilers, cmake, or sources in image!
COPY --from=build /app/build/cpp-hello ./cpp-hello
USER 10001
ENTRYPOINT ["./cpp-hello"]
```

> **💡 Key Design Decision:**  
> The `gcc:14` compiler image is ~1.4GB. The runtime Debian slim image with only the binary is ~80MB, completely isolated from build utilities.

---

### 2.5 .NET 8 Web API (C#)

#### 🔄 Pipeline Walkthrough (`monorepo-ci.yml`)
```yaml
- uses: actions/setup-dotnet@v4
  with:
    dotnet-version: "8.0.x"
- name: Restore Packages
  run: dotnet restore DotnetHello.sln
- name: dotnet-format Style Check
  run: dotnet format --verify-no-changes
- name: Build with Strict Warnings
  run: dotnet build DotnetHello.sln -c Release --no-restore
- name: Run Tests & Collect Coverage
  run: dotnet test DotnetHello.sln -c Release --no-build --collect:"XPlat Code Coverage"
- name: Dependency Vulnerability Check
  run: dotnet list DotnetHello.sln package --vulnerable --include-transitive
```

* **`dotnet format --verify-no-changes`**: Roslyn-powered formatting and analyzer rule gate.
* **`dotnet test --collect:"XPlat Code Coverage"`**: Cross-platform Coverlet collector outputting OpenCover coverage XML.
* **`dotnet list package --vulnerable`**: Native NuGet SCA scanner checking known advisory feeds.

---

#### 🐳 Dockerfile Explained (`dotnet-hello/Dockerfile`)
```dockerfile
# Stage 1: SDK Build, Test & Publish
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY DotnetHello.sln .
COPY src/DotnetHello/DotnetHello.csproj src/DotnetHello/
COPY tests/DotnetHello.Tests/DotnetHello.Tests.csproj tests/DotnetHello.Tests/
RUN dotnet restore
COPY . .
RUN dotnet build -c Release --no-restore && \
    dotnet test -c Release --no-build && \
    dotnet publish src/DotnetHello/DotnetHello.csproj -c Release -o /app/publish --no-build

# Stage 2: Alpine ASP.NET Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080 ASPNETCORE_ENVIRONMENT=Production
COPY --from=build /app/publish .
# .NET 8 built-in non-root app user (UID 1654)
USER $APP_UID
ENTRYPOINT ["dotnet", "DotnetHello.dll"]
```

> **💡 Key Design Decision:**  
> Utilizes Microsoft's official .NET 8 built-in security feature: `USER $APP_UID` (UID 1654). No manual user creation is required.

---

### 2.6 Python 3.12 (FastAPI Async API)

#### 🔄 Pipeline Walkthrough (`monorepo-ci.yml`)
```yaml
- uses: actions/setup-python@v5
  with:
    python-version: "3.12"
    cache: "pip"
- name: Install Dependencies
  run: |
    python -m pip install --upgrade pip
    pip install -r requirements-dev.txt
- name: Ruff Lint & Format Check
  run: |
    ruff check app tests
    ruff format --check app tests
- name: Pytest with Coverage
  run: pytest --cov=app --cov-report=xml:coverage.xml --cov-report=term
- name: Dependency Vulnerability Audit
  run: pip-audit -r requirements.txt
```

* **Ruff**: 10-100x faster than Flake8/Black; runs 500+ lint rules and format checks in milliseconds.
* **`pip-audit`**: PyPA-recommended security scanner querying the PyPI vulnerability database.

---

#### 🐳 Dockerfile Explained (`fastapi-hello/Dockerfile`)
```dockerfile
# Stage 1: Build Wheels & Dependencies
FROM python:3.12-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
# Install into user home directory
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Clean Runtime Stage
FROM python:3.12-slim
WORKDIR /app
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 \
    PATH=/home/appuser/.local/bin:$PATH PORT=8000
RUN useradd --create-home --system --uid 10001 appuser
# Copy installed wheels and app source
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=appuser:appuser app ./app
USER 10001
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

> **💡 Key Design Decision:**  
> The build stage installs dependencies into `--user` (`/root/.local`). The runtime copies this directly into `/home/appuser/.local`, ensuring the image contains zero build tools (`gcc`) or pip cache.

---

### 2.7 Go 1.23 (REST API)

#### 🔄 Pipeline Walkthrough (`monorepo-ci.yml`)
```yaml
- uses: actions/setup-go@v5
  with:
    go-version: "1.23"
- name: Go Vet
  run: go vet ./...
- name: Run Tests with Race Detector & Coverage
  run: go test -v -race -coverprofile=coverage.out ./...
```

* **`go vet`**: Official Go static analyzer for suspicious constructs.
* **`-race`**: Data race detector detecting concurrent read/write memory violations.

---

#### 🐳 Dockerfile Explained (`go-hello/Dockerfile`)
```dockerfile
# Stage 1: Compile Static Binary
FROM golang:alpine AS build
WORKDIR /app
ENV CGO_ENABLED=0 GOOS=linux
COPY go.mod ./
RUN go mod download || true
COPY . .
RUN go test -v ./...
# Build completely static, stripped binary
RUN go build -ldflags="-s -w" -o /app/server .

# Stage 2: Google Distroless (Zero OS Packages)
FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=build /app/server /app/server
EXPOSE 8080
# Runs as Distroless non-root user (UID 65532)
USER nonroot:nonroot
ENTRYPOINT ["/app/server"]
```

> **💡 Key Design Decision:**  
> `gcr.io/distroless/static-debian12:nonroot` contains **zero OS packages, no shell (`/bin/sh`), and no package manager**. The final image size is only **~15MB** and has **0 vulnerabilities**.

---

## 🏗️ 3. Universal Blueprint: How to Adapt to ANY Framework

When the team needs to onboard a new language (e.g. **Rust, Ruby, PHP, Kotlin, Elixir**), follow this exact **4-step template**:

### Step 1: Tool Selection Matrix
Fill in the blanks for the target framework:

| DevSecOps Capability | What to Choose | Examples |
| :--- | :--- | :--- |
| **Package Manager** | Official lockfile manager | `cargo`, `bundler`, `composer` |
| **Linter / Formatter** | Fast standard tool | `cargo clippy`, `rubocop`, `php-cs-fixer` |
| **Test + Coverage** | Unit test framework with LCOV/XML report | `cargo tarpaulin`, `rspec`, `phpunit` |
| **SCA Audit** | Official advisory database scanner | `cargo audit`, `bundle audit`, `composer audit` |
| **Secret Scan** | Universal (Gitleaks) | Uses existing `.gitleaks.toml` |
| **Container Scan** | Universal (Trivy Action v0.36.0) | `aquasecurity/trivy-action@v0.36.0` |

---

### Step 2: The Universal Multi-Stage Dockerfile Pattern
```dockerfile
# =======================================================
# Stage 1: Build & Test Stage (Disposable)
# =======================================================
FROM <official-sdk-or-compiler-image> AS builder
WORKDIR /app

# 1. Copy dependency manifest first to leverage Docker layer caching
COPY <dependency-manifest> .
RUN <install-dependencies-command>

# 2. Copy source and build
COPY . .
RUN <test-command>
RUN <compile-or-package-command>

# =======================================================
# Stage 2: Hardened Production Runtime Stage
# =======================================================
FROM <minimal-base-image: alpine, distroless, or slim>
WORKDIR /app

# 1. Update OS packages (patches base CVEs)
# 2. Remove build package managers if present
# 3. Create unprivileged non-root user (UID 10001)
RUN <os-update-command> && \
    <create-nonroot-user-command>

# 4. Copy ONLY production artifacts from builder
COPY --from=builder --chown=10001:10001 /app/<artifacts> ./

# 5. Drop root
USER 10001
EXPOSE <port>
ENTRYPOINT ["<runtime-executable>", "<entrypoint-args>"]
```

---

### Step 3: The Universal GitHub Actions Job Template
Add a new job to `.github/workflows/monorepo-ci.yml`:

```yaml
  <framework>-pipeline:
    name: <Framework> DevSecOps
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: <framework>-dir
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      # 1. Setup SDK/Language Toolchain
      - uses: actions/setup-<language>@vX
        with:
          <language>-version: "<version>"

      # 2. Install & Cache
      - name: Install Dependencies
        run: <dependency-install-command>

      # 3. Code Quality (Gate 1)
      - name: Linter & Format Check
        run: <lint-and-format-command>

      # 4. Automated Tests (Gate 2)
      - name: Unit Tests & Coverage
        run: <test-command>

      # 5. Software Composition Analysis (Gate 3)
      - name: Dependency Vulnerability Audit
        continue-on-error: true
        run: <sca-audit-command>

      # 6. Secret Detection (Gate 4)
      - name: Gitleaks Secret Scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      # 7. Container Build (Gate 5)
      - name: Build Docker Image
        run: docker build -t <framework>-app:${{ github.sha }} .

      # 8. Container Vulnerability Gate (Gate 6)
      - name: Scan Docker Image with Trivy
        uses: aquasecurity/trivy-action@v0.36.0
        with:
          image-ref: <framework>-app:${{ github.sha }}
          format: "table"
          exit-code: "1"
          ignore-unfixed: true
          vuln-type: "os,library"
          severity: "HIGH,CRITICAL"
```

---

## 🔒 4. Container Hardening Standards

| Security Requirement | Implementation | Why It Matters |
| :--- | :--- | :--- |
| **Never Run as Root** | `USER 10001` or `USER nonroot` | Prevents container breakout attacks from gaining root on the host machine. |
| **Layer Caching** | `COPY package*.json ./` before `COPY . .` | Rebuilds take 2 seconds instead of minutes when code changes without new dependencies. |
| **Strip Build Package Managers** | `rm -rf /usr/local/lib/node_modules/npm` | Eliminates supply-chain CVEs bundled inside npm, yarn, or pip in runtime containers. |
| **Minimal Base Images** | `alpine`, `distroless`, `slim` | Reduces attack surface from 1000+ OS binaries to under 50. |
| **Explicit Tagging** | Pin exact major/minor versions | Avoids surprise breaking changes or unexpected unverified base image pulls. |

---

## 🛠️ 5. Real-World Gotchas & Troubleshooting Log

This table documents the exact challenges solved in this repository:

| Framework | Symptom / Error | Root Cause | Production Remediation |
| :--- | :--- | :--- | :--- |
| **All Stacks** | `Unable to resolve action aquasecurity/trivy-action@0.29.0` | Missing `v` prefix in tag, plus historical tags (<v0.35.0) were compromised in CVE-2026-33634. | Upgraded to official safe release **`aquasecurity/trivy-action@v0.36.0`**. |
| **Java** | `usr/bin/pebble: 4 HIGH CVEs` | Default `eclipse-temurin:21-jre` pulls Ubuntu with Canonical's `pebble` tool compiled with vulnerable Go stdlib. | Switched base to **`eclipse-temurin:21-jre-alpine`** + `apk upgrade`. Image dropped from 450MB to 180MB. |
| **Java** | `libexpat: CVE-2026-77214 HIGH` | Alpine base image contained older `libexpat 2.8.5-r0`. | Added `RUN apk update && apk upgrade --no-cache` to Dockerfile to install `2.9.0-r0`. |
| **Node.js** | 10 HIGH CVEs in `npm/node_modules` | The base `node:22-alpine` image includes npm and yarn which contain vulnerable packages (`sigstore`, `brace-expansion`). | Removed build tools in runtime stage: `rm -rf /usr/local/lib/node_modules/npm /opt/yarn*`. |
| **C++** | `error: code should be clang-formatted` on `greeting()` | In LLVM style, `AllowShortFunctionsOnASingleLine` defaults to `All`, demanding short functions collapse into one line. | Added `AllowShortFunctionsOnASingleLine: None` to `.clang-format` and enforced LF endings in `.gitattributes`. |
| **React** | `npm audit: tinypool, esbuild Critical/Moderate` | Dev-only test runner dependencies had prototype pollution advisories. | 1. Added `overrides` in `package.json`.<br>2. Scoped CI audit to production bundle via `npm audit --omit=dev`. |
| **Go** | Go stdlib CVEs in `/app/server` | Build stage used `golang:1.23-alpine` which has outdated stdlib packages. | Updated build stage to `golang:alpine` so binary links against latest patched Go stdlib. |
