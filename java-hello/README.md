# Java 21 DevSecOps Sample Application (`java-hello`)

A production-ready reference application demonstrating modern DevSecOps practices:
- **Build & Dependency Management:** Maven
- **Language / Runtime:** Java 21 (Eclipse Temurin)
- **Unit Testing:** JUnit 5
- **Code Coverage:** JaCoCo (XML report for SonarQube)
- **Code Style & Linting:** Checkstyle (Google Java Style)
- **Bug & Vulnerability Detection:** SpotBugs
- **Software Composition Analysis (SCA):** OWASP Dependency-Check
- **Code Quality & Security Gate:** SonarQube
- **Secret Scanning:** Gitleaks
- **Containerization:** Multi-stage Dockerfile with non-root security (`appuser`, UID 10001)
- **Container Image Vulnerability Scanning:** Trivy

---

## Project Structure

```
java-hello/
├── src/
│   ├── main/java/com/example/App.java
│   └── test/java/com/example/AppTest.java
├── pom.xml
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
- JDK 21 installed (`java -version`)
- Maven 3.9+ installed (`mvn -version`)
- Docker Desktop installed & running (`docker version`)
- Trivy CLI installed (`trivy --version`) (Optional for local scan)

### 2. Build & Test Locally
Run compilation, test suite, JaCoCo coverage report, Checkstyle, and SpotBugs:
```bash
mvn clean verify
```

Run the generated JAR directly:
```bash
java -jar target/java-hello-1.0.0.jar
```
*Expected Output:*
```text
Hello from Java!
```

### 3. Checkstyle & SpotBugs Manual Checks
```bash
# Checkstyle check
mvn checkstyle:check

# SpotBugs static analysis
mvn spotbugs:check
```

---

## Docker Build & Run

### 1. Build the Docker Image
```bash
docker build -t java-hello:local .
```

### 2. Run the Container
```bash
docker run --rm java-hello:local
```
*Expected Output:*
```text
Hello from Java!
```

### 3. Security Verification (Non-root user check)
Verify that the container runs as non-root user `10001`:
```bash
docker run --rm java-hello:local whoami
```

---

## Security Scanning Locally

### 1. Gitleaks (Secret Detection)
```bash
docker run --rm -v "${PWD}:/repo" zricethezav/gitleaks:latest dir /repo
```

### 2. Trivy Filesystem Scan
```bash
trivy fs --config trivy.yaml .
```

### 3. Trivy Docker Image Scan
```bash
trivy image --severity HIGH,CRITICAL java-hello:local
```

---

## CI/CD Pipeline (GitHub Actions)

When pushed to GitHub, `.github/workflows/ci.yml` executes:
1. **Source Checkout** (with full git history for SonarQube & Gitleaks)
2. **JDK 21 Setup** with automatic Maven caching
3. **Compile, Unit Test & Coverage generation** via `mvn clean verify`
4. **OWASP Dependency Check** for vulnerable Maven artifacts
5. **SonarQube Quality Gate Scan**
6. **Gitleaks Secret Scan**
7. **Docker Build**
8. **Trivy Vulnerability Scan** of the final Docker image

### Required GitHub Secrets & Variables (for SonarQube)
- Secret: `SONAR_TOKEN`
- Variable: `SONAR_HOST_URL` (if self-hosted SonarQube)
- Variable: `SONAR_ORGANIZATION` (if SonarQube Cloud)
- Variable: `SONAR_PROJECT_KEY` (defaults to `java-hello`)

---

## Troubleshooting Guide

| Issue | Root Cause | Solution |
| :--- | :--- | :--- |
| `java: invalid source release 21` | Maven is using an older JDK (e.g., JDK 11 or 17). | Verify `java -version` and set `JAVA_HOME` to JDK 21. |
| Checkstyle violations | Code formatting deviates from Google Java Style. | Run `mvn checkstyle:check` to see line numbers; format code. |
| JaCoCo report missing | `mvn test` was run instead of `mvn verify`. | JaCoCo generates XML during the `verify` lifecycle phase. |
| Docker build fails on `mvn dependency:go-offline` | Network proxy or repository unreachable. | Handled gracefully with fallback in Dockerfile. |
| Trivy reports high/critical OS package vulnerability | Outdated base image. | Update base image `eclipse-temurin:21-jre` to latest digest. |
