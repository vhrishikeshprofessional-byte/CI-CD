# FastAPI DevSecOps Sample Application (`fastapi-hello`)

A production-ready reference FastAPI REST API demonstrating modern Python DevSecOps practices:
- **Framework:** FastAPI with Uvicorn ASGI server
- **Language / Runtime:** Python 3.12
- **Testing:** `pytest` & HTTPX `TestClient`
- **Code Coverage:** `pytest-cov` (generates `coverage.xml` for SonarQube)
- **Linting & Code Formatting:** Ruff (ultra-fast linter & formatter replacing Flake8, Black, and isort)
- **Software Composition Analysis (SCA):** `pip-audit`
- **Code Quality & Security Gate:** SonarQube
- **Secret Scanning:** Gitleaks
- **Containerization:** Multi-stage Docker build using `python:3.12-slim` with non-root security (`appuser`, UID 10001)
- **Container Image Vulnerability Scanning:** Trivy

---

## Project Structure

```
fastapi-hello/
├── app/
│   ├── __init__.py
│   └── main.py
├── tests/
│   ├── __init__.py
│   └── test_main.py
├── requirements.txt
├── requirements-dev.txt
├── ruff.toml
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
- Python 3.11+ installed (`python --version`)
- Docker Desktop installed & running (`docker version`)

### 2. Set Up Virtual Environment & Install Dependencies
```bash
python -m venv .venv

# On Linux/macOS:
source .venv/bin/activate
# On Windows (PowerShell):
.venv\Scripts\Activate.ps1

pip install --upgrade pip
pip install -r requirements-dev.txt
```

### 3. Linting, Formatting & Testing
```bash
# Lint code with Ruff
ruff check app tests

# Auto-fix linting issues
ruff check --fix app tests

# Check formatting
ruff format --check app tests

# Auto-format
ruff format app tests

# Run test suite with coverage
pytest --cov=app --cov-report=xml:coverage.xml --cov-report=term
```

### 4. Run Locally
```bash
uvicorn app.main:app --reload --port 8000
```
Endpoints:
- `http://localhost:8000/` -> `{"message":"Hello from FastAPI!","timestamp":"..."}`
- `http://localhost:8000/health` -> `{"status":"healthy"}`
- `http://localhost:8000/docs` -> Interactive Swagger UI documentation

---

## Docker Build & Run

### 1. Build Docker Image
```bash
docker build -t fastapi-hello:local .
```

### 2. Run Container
```bash
docker run --rm -p 8000:8000 fastapi-hello:local
```
Open [http://localhost:8000](http://localhost:8000) or [http://localhost:8000/docs](http://localhost:8000/docs).

### 3. Non-Root Security Verification
```bash
docker run --rm fastapi-hello:local id
# Output: uid=10001(appuser) gid=10001(appuser)
```

---

## Security Scanning Locally

### 1. Python Package Vulnerability Scan
```bash
pip-audit -r requirements.txt
```

### 2. Gitleaks Secret Detection
```bash
docker run --rm -v "${PWD}:/repo" zricethezav/gitleaks:latest dir /repo
```

### 3. Trivy Container Image Scan
```bash
trivy image --severity HIGH,CRITICAL fastapi-hello:local
```

---

## Troubleshooting Guide

| Issue | Root Cause | Solution |
| :--- | :--- | :--- |
| `pip-audit` network errors | PyPI OSV/NVD vulnerability API rate-limit. | Retry command or cache database locally. |
| Ruff formatting failure | Inconsistent quotes or indentation. | Run `ruff format app tests`. |
| Docker container fails with `command not found: uvicorn` | `PATH` missing user-installed python bin. | Dockerfile sets `PATH=/home/appuser/.local/bin:$PATH`. |
| Port 8000 conflict | Another service running on port 8000. | Start container on alternate port: `-p 8005:8000`. |
