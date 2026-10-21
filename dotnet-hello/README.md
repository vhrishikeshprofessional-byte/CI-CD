# .NET 8 DevSecOps Sample Application (`dotnet-hello`)

A production-ready reference ASP.NET Core Minimal API demonstrating modern .NET DevSecOps practices:
- **Framework:** .NET 8.0 Minimal API (C# 12)
- **Unit & Integration Testing:** xUnit & `Microsoft.AspNetCore.Mvc.Testing`
- **Code Coverage:** Coverlet (OpenCover format for SonarQube)
- **Code Style & Formatting:** `dotnet format` with `.editorconfig`
- **Static Analysis & Roslyn Analyzers:** `TreatWarningsAsErrors=true` & `EnforceCodeStyleInBuild=true`
- **Software Composition Analysis (SCA):** `dotnet list package --vulnerable`
- **Code Quality & Security Gate:** SonarQube
- **Secret Scanning:** Gitleaks
- **Containerization:** Multi-stage Dockerfile using Alpine runtime with non-root security (`USER $APP_UID`, UID 1654)
- **Container Image Vulnerability Scanning:** Trivy

---

## Project Structure

```
dotnet-hello/
├── src/
│   └── DotnetHello/
│       ├── Program.cs
│       └── DotnetHello.csproj
├── tests/
│   └── DotnetHello.Tests/
│       ├── UnitTest1.cs
│       └── DotnetHello.Tests.csproj
├── DotnetHello.sln
├── .editorconfig
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
- .NET 8 SDK installed (`dotnet --version`)
- Docker Desktop installed & running (`docker version`)

### 2. Restore, Format & Build
```bash
# Restore NuGet packages
dotnet restore

# Verify formatting
dotnet format --verify-no-changes

# Auto-fix formatting
dotnet format

# Build with strict compiler flags
dotnet build -c Release
```

### 3. Run Unit & Integration Tests
```bash
dotnet test -c Release --collect:"XPlat Code Coverage"
```

### 4. Run Application Locally
```bash
dotnet run --project src/DotnetHello/DotnetHello.csproj
```
Endpoints:
- `http://localhost:5000/` -> `{"message":"Hello from .NET 8 Web API!","timestamp":"..."}`
- `http://localhost:5000/health` -> `{"status":"Healthy"}`

---

## Docker Build & Run

### 1. Build Docker Image
```bash
docker build -t dotnet-hello:local .
```

### 2. Run Container
```bash
docker run --rm -p 8080:8080 dotnet-hello:local
```
Open [http://localhost:8080](http://localhost:8080) in your browser.

### 3. Non-Root Security Verification
```bash
docker run --rm dotnet-hello:local id
# Output: uid=1654(app) gid=1654(app)
```

---

## Security Scanning Locally

### 1. SCA Vulnerability Scan
```bash
dotnet list package --vulnerable --include-transitive
```

### 2. Gitleaks Secret Detection
```bash
docker run --rm -v "${PWD}:/repo" zricethezav/gitleaks:latest dir /repo
```

### 3. Trivy Container Image Scan
```bash
trivy image --severity HIGH,CRITICAL dotnet-hello:local
```

---

## Troubleshooting Guide

| Issue | Root Cause | Solution |
| :--- | :--- | :--- |
| `CS0103 Program not found` | Top-level statements program class visibility. | Ensure `public partial class Program { }` is present at the end of `Program.cs`. |
| `dotnet format` fails | Indentation or style violation according to `.editorconfig`. | Run `dotnet format` to apply formatting automatically. |
| Test coverage XML missing | Coverlet collector format not specified. | Use `--collect:"XPlat Code Coverage"`. |
| Port 8080 conflict | Host port already in use. | Run with `-p 8085:8080`. |
