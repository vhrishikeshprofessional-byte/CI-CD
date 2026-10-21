# 🚀 Complete DevSecOps Reference Guide: Java, React, Node.js, C++, .NET 8, FastAPI & Go

> Production-ready reference implementation demonstrating automated CI/CD pipelines, code quality gates, static application security testing (SAST), software composition analysis (SCA), container hardening, secret scanning, and vulnerability detection using **GitHub Actions**, **SonarQube**, **Trivy**, **Gitleaks**, and **Docker**.

---

## 1. Applications & Tool Ecosystem

This repository contains **7 complete, functional sample applications** built with industry-standard frameworks, each packaged with its own multi-stage non-root Dockerfile, test suite, linters, and CI/CD workflow:

| Application | Directory | Framework / Stack | Build / Test Tools | Code Quality & SAST | Container Hardening |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Java** | [`java-hello/`](file:///d:/Kumar_sir/CI-CD/java-hello) | Java 21 + Maven | JUnit 5, JaCoCo | Checkstyle, SpotBugs, OWASP | `eclipse-temurin:21-jre`, UID 10001 |
| **React** | [`react-hello/`](file:///d:/Kumar_sir/CI-CD/react-hello) | React 18 + Vite | Vitest, Testing Lib | ESLint Flat Config, Prettier | `nginx-unprivileged:alpine`, UID 101 |
| **Node.js** | [`node-hello/`](file:///d:/Kumar_sir/CI-CD/node-hello) | Express.js + Node 22 | `node:test`, `c8`, Supertest | ESLint, Prettier, `npm audit` | `node:22-alpine`, non-root `appuser` |
| **C++** | [`cpp-hello/`](file:///d:/Kumar_sir/CI-CD/cpp-hello) | C++17 + CMake | CTest, strict flags | `clang-format`, `clang-tidy`, `cppcheck` | `debian:bookworm-slim`, UID 10001 |
| **.NET** | [`dotnet-hello/`](file:///d:/Kumar_sir/CI-CD/dotnet-hello) | .NET 8 Web API (C#) | xUnit, Coverlet | `dotnet format`, Roslyn, SCA | `aspnet:8.0-alpine`, `USER $APP_UID` |
| **FastAPI** | [`fastapi-hello/`](file:///d:/Kumar_sir/CI-CD/fastapi-hello) | Python 3.12 + FastAPI | Pytest, HTTPX, `pytest-cov` | Ruff (linter + formatter), `pip-audit`| `python:3.12-slim`, UID 10001 |
| **Go** | [`go-hello/`](file:///d:/Kumar_sir/CI-CD/go-hello) | Go 1.23 REST API | `testing` (`-race`), cover | `golangci-lint`, `go vet`, `govulncheck`| `distroless/static:nonroot`, UID 65532 |

---

## 2. Repository Structure

```
CI-CD/
├── .github/
│   └── workflows/
│       └── monorepo-ci.yml           # Unified monorepo CI workflow orchestrator
├── .gitleaks.toml                     # Global secret detection configuration
├── docker-compose.yml                 # Local SonarQube LTS + PostgreSQL environment
├── run-devsecops.ps1                  # PowerShell automation runner for local testing
├── run-devsecops.sh                   # Bash automation runner for local testing
├── java-hello/                        # Java 21 + Maven microservice
│   ├── src/main/java/com/example/App.java
│   ├── src/test/java/com/example/AppTest.java
│   ├── pom.xml
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── sonar-project.properties
│   ├── trivy.yaml
│   ├── .github/workflows/ci.yml
│   └── README.md
├── react-hello/                       # React 18 + Vite SPA
│   ├── src/App.jsx, App.test.jsx, main.jsx, setupTests.js
│   ├── index.html, vite.config.js, package.json
│   ├── eslint.config.js, .prettierrc, nginx.conf
│   ├── Dockerfile, .dockerignore, sonar-project.properties, trivy.yaml
│   ├── .github/workflows/ci.yml
│   └── README.md
├── node-hello/                        # Node.js 22 + Express API
│   ├── src/app.js
│   ├── test/app.test.js
│   ├── package.json, eslint.config.js, .prettierrc
│   ├── Dockerfile, .dockerignore, sonar-project.properties, trivy.yaml
│   ├── .github/workflows/ci.yml
│   └── README.md
├── cpp-hello/                         # C++17 + CMake Native CLI
│   ├── src/greeting.h, greeting.cpp, main.cpp
│   ├── tests/test_main.cpp, CMakeLists.txt
│   ├── .clang-format, .clang-tidy
│   ├── Dockerfile, .dockerignore, sonar-project.properties, trivy.yaml
│   ├── .github/workflows/ci.yml
│   └── README.md
├── dotnet-hello/                      # .NET 8 Web API
│   ├── src/DotnetHello/ (Program.cs, DotnetHello.csproj)
│   ├── tests/DotnetHello.Tests/ (UnitTest1.cs, DotnetHello.Tests.csproj)
│   ├── DotnetHello.sln, .editorconfig
│   ├── Dockerfile, .dockerignore, sonar-project.properties, trivy.yaml
│   ├── .github/workflows/ci.yml
│   └── README.md
├── fastapi-hello/                     # Python 3.12 + FastAPI REST API
│   ├── app/ (main.py, __init__.py)
│   ├── tests/ (test_main.py, __init__.py)
│   ├── requirements.txt, requirements-dev.txt, ruff.toml
│   ├── Dockerfile, .dockerignore, sonar-project.properties, trivy.yaml
│   ├── .github/workflows/ci.yml
│   └── README.md
├── go-hello/                          # Go 1.23 Cloud-Native REST API
│   ├── main.go, main_test.go, go.mod, .golangci.yml
│   ├── Dockerfile, .dockerignore, sonar-project.properties, trivy.yaml
│   ├── .github/workflows/ci.yml
│   └── README.md
└── README.md
```

---

## 3. The Complete DevSecOps Pipeline Order

Each pipeline strictly enforces the following linear verification sequence:

1. **Developer Push / PR**: Triggered automatically on `push` and `pull_request` to `main` and `develop`.
2. **Checkout Source Code**: Uses `actions/checkout` with `fetch-depth: 0` (required for accurate SonarQube blame and Gitleaks git history analysis).
3. **Environment Setup & Dependency Caching**: Caches Maven, npm, NuGet, pip, and Go modules to ensure high-speed builds.
4. **Code Formatting Checks**: Validates style rules using Prettier, Google Java Style, Ruff, Clang-Format, or `dotnet-format`.
5. **Static Code Analysis (SAST) & Linting**: Runs ESLint, SpotBugs, Checkstyle, Clang-Tidy, Cppcheck, Ruff, and GolangCI-Lint.
6. **Automated Unit Testing & Code Coverage**: Executes test suites and exports standard coverage formats (LCOV, JaCoCo XML, OpenCover XML, or Go coverage).
7. **Software Composition Analysis (SCA)**: Scans external dependencies for known CVEs using `npm audit`, OWASP Dependency-Check, `pip-audit`, `dotnet list --vulnerable`, and `govulncheck`.
8. **SonarQube Analysis**: Evaluates maintainability, cognitive complexity, security hotspots, and code coverage against the Quality Gate.
9. **Secret Detection (Gitleaks)**: Scans commits, environment variables, and repository history to ensure zero secrets or API tokens are leaked.
10. **Container Build**: Builds minimal, multi-stage, non-root Docker images.
11. **Container Security Scan (Trivy)**: Scans the built container image for operating system package vulnerabilities and library CVEs (`HIGH`, `CRITICAL`).
12. **Registry Publishing & CD (Continuous Deployment)**: Once all checks pass, publish immutable SHA-tagged images to container registries and deploy.

---

## 4. Local Execution & Testing Guide

You can run quality and security checks locally on your development workstation using the language CLIs, Docker, or the provided automation scripts:

### Using Automation Runner Scripts
```powershell
# On Windows (PowerShell):
.\run-devsecops.ps1 -Framework node
.\run-devsecops.ps1 -Framework fastapi
.\run-devsecops.ps1 -Framework all
```
```bash
# On Linux / macOS / Git Bash:
chmod +x run-devsecops.sh
./run-devsecops.sh node
./run-devsecops.sh all
```

### Manual Commands Per Application

#### 1. Java 21 (`java-hello`)
```bash
cd java-hello
mvn clean verify                                # Compile, test, JaCoCo coverage, SpotBugs, Checkstyle
java -jar target/java-hello-1.0.0.jar            # Run executable JAR
docker build -t java-hello:local .               # Build non-root container
docker run --rm java-hello:local                # Execute container
```

#### 2. React (`react-hello`)
```bash
cd react-hello
npm install
npm run lint                                    # ESLint flat config
npm run format:check                            # Prettier check
npm run test:coverage                           # Vitest with coverage report
npm run build                                   # Production Vite build
docker build -t react-hello:local .              # Build unprivileged Nginx image
docker run --rm -p 8080:8080 react-hello:local  # Access at http://localhost:8080
```

#### 3. Node.js (`node-hello`)
```bash
cd node-hello
npm install
npm run lint                                    # ESLint
npm run format:check                            # Prettier check
npm run test:coverage                           # Native node:test runner + c8 coverage
npm start                                       # Start Express server on port 3000
docker build -t node-hello:local .
docker run --rm -p 3000:3000 node-hello:local   # Access at http://localhost:3000
```

#### 4. C++ (`cpp-hello`)
```bash
cd cpp-hello
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build --parallel
ctest --test-dir build --output-on-failure       # Run unit tests
clang-format --dry-run --Werror src/*.cpp tests/*.cpp
cppcheck --enable=warning,style,performance,portability --error-exitcode=1 src tests
./build/cpp-hello                               # Run CLI binary
docker build -t cpp-hello:local .
docker run --rm cpp-hello:local
```

#### 5. .NET 8 (`dotnet-hello`)
```bash
cd dotnet-hello
dotnet restore
dotnet format --verify-no-changes               # Code style enforcement
dotnet build -c Release                         # Strict Roslyn build
dotnet test -c Release --collect:"XPlat Code Coverage"
dotnet run --project src/DotnetHello/DotnetHello.csproj
docker build -t dotnet-hello:local .
docker run --rm -p 8080:8080 dotnet-hello:local # Access at http://localhost:8080
```

#### 6. FastAPI (`fastapi-hello`)
```bash
cd fastapi-hello
pip install -r requirements-dev.txt
ruff check app tests                            # Fast linting
ruff format --check app tests                   # Format check
pytest --cov=app --cov-report=term              # Tests and coverage
uvicorn app.main:app --port 8000                # Access at http://localhost:8000/docs
docker build -t fastapi-hello:local .
docker run --rm -p 8000:8000 fastapi-hello:local
```

#### 7. Go (`go-hello`)
```bash
cd go-hello
go vet ./...
go test -v -race -coverprofile=coverage.out ./...
go run main.go                                  # Access at http://localhost:8080
docker build -t go-hello:local .                # Distroless static build
docker run --rm -p 8080:8080 go-hello:local
```
 
---

## 5. Security Scanning Guide (Trivy & Gitleaks)

### Trivy Container Vulnerability Scanning
To scan any local container image for `HIGH` and `CRITICAL` vulnerabilities with Trivy CLI:
```bash
# Scan container image:
trivy image --severity HIGH,CRITICAL java-hello:local
trivy image --severity HIGH,CRITICAL react-hello:local
trivy image --severity HIGH,CRITICAL node-hello:local
trivy image --severity HIGH,CRITICAL cpp-hello:local
trivy image --severity HIGH,CRITICAL dotnet-hello:local
trivy image --severity HIGH,CRITICAL fastapi-hello:local
trivy image --severity HIGH,CRITICAL go-hello:local

# Scan filesystem for misconfigurations and dependency CVEs:
trivy fs --config java-hello/trivy.yaml java-hello/
```

### Gitleaks Secret Scanning
Run Gitleaks via Docker to detect any committed API keys, tokens, or credentials:
```bash
docker run --rm -v "${PWD}:/repo" zricethezav/gitleaks:latest dir /repo
```

---

## 6. SonarQube Integration

### Running SonarQube Locally
A ready-to-use Docker Compose configuration is included:
```bash
docker compose up -d
```
Access the local SonarQube server at [http://localhost:9000](http://localhost:9000) (Default login: `admin` / `admin`).

### Configuring GitHub Actions Secrets & Variables
When pushing to GitHub, configure these in **Repository Settings → Secrets and variables → Actions**:

| Name | Type | Value | Description |
| :--- | :--- | :--- | :--- |
| `SONAR_TOKEN` | **Secret** | `squ_...` | User analysis token generated in SonarQube |
| `SONAR_HOST_URL` | **Variable** | `https://sonarqube.yourdomain.com` | SonarQube server URL (omit if using SonarQube Cloud) |
| `SONAR_ORGANIZATION`| **Variable** | `your-org-key` | Required when using SonarCloud |
| `SONAR_PROJECT_KEY` | **Variable** | `project-name` | Optional custom project key override |

---

## 7. Troubleshooting Matrix

| Problem | Root Cause | Solution |
| :--- | :--- | :--- |
| `Docker daemon error` | Docker Desktop is not running or WSL engine is stopped. | Start Docker Desktop and verify `docker info`. |
| `npm ci fails: Lockfile missing` | `package-lock.json` has not been generated yet. | Run `npm install` locally and commit `package-lock.json`. |
| `ESLint flat config errors` | Using legacy `.eslintrc` syntax with ESLint 9+. | Use `eslint.config.js` with module syntax as configured. |
| `JaCoCo coverage 0% in Sonar` | Ran `mvn test` instead of `mvn verify`. | JaCoCo generates the XML report during the `verify` phase. |
| `C++ clang-tidy missing compile commands` | CMake build directory omitted compilation database. | Pass `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` to CMake. |
| `.NET format verification fails` | Formatting does not adhere to `.editorconfig`. | Run `dotnet format` locally to auto-format code. |
| `FastAPI uvicorn not found in Docker` | Non-root `appuser` cannot access local bin directory. | Ensure `PATH=/home/appuser/.local/bin:$PATH` is set. |
| `Go race detector failure` | Data race detected during concurrent access. | Ensure synchronized state access using `sync.Mutex` or channels. |
| `G112: Potential Slowloris attack (gosec)` | Go HTTP server created without `ReadHeaderTimeout`. | Explicitly define `ReadHeaderTimeout` on `http.Server`. |
| `Trivy exits with code 1` | Unfixed or fixable HIGH/CRITICAL CVEs found. | Update base image tags or dependencies to the latest patch release. |
