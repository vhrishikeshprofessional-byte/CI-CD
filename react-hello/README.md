# React DevSecOps Sample Application (`react-hello`)

A production-ready reference single-page application demonstrating modern frontend DevSecOps practices:

- **Build Tool:** Vite
- **UI Library:** React 18
- **Testing:** Vitest & React Testing Library (jsdom environment)
- **Code Coverage:** Vitest v8 coverage provider (generates `coverage/lcov.info` for SonarQube)
- **Linting:** ESLint with Flat Config (`eslint.config.js`)
- **Formatting:** Prettier
- **Dependency Vulnerability Scanning:** `npm audit`
- **Code Quality & Security Gate:** SonarQube
- **Secret Scanning:** Gitleaks
- **Containerization:** Multi-stage Docker build served via non-root, hardened Nginx (`nginxinc/nginx-unprivileged:stable-alpine`) on port 8080
- **Container Image Vulnerability Scanning:** Trivy

---

## Project Structure

```
react-hello/
├── src/
│   ├── App.jsx
│   ├── App.test.jsx
│   ├── main.jsx
│   └── setupTests.js
├── index.html
├── vite.config.js
├── package.json
├── eslint.config.js
├── .prettierrc
├── nginx.conf
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

### 1. Install Dependencies

```bash
npm install
```

### 2. Code Quality & Format Checks

```bash
# Run ESLint
npm run lint

# Check formatting with Prettier
npm run format:check

# Auto-format code if needed
npm run format
```

### 3. Run Unit Tests & Generate Coverage

```bash
# Run unit tests in headless mode
npm run test

# Run tests with coverage output
npm run test:coverage
```

### 4. Build & Preview

```bash
# Production bundle build to dist/
npm run build

# Start local development server
npm run dev
```

---

## Docker Build & Run

### 1. Build the Docker Image

```bash
docker build -t react-hello:local .
```

### 2. Run the Container

```bash
docker run --rm -p 8080:8080 react-hello:local
```

Open [http://localhost:8080](http://localhost:8080) in your browser.

### 3. Non-Root Security Verification

Verify that Nginx runs as non-root user `101`:

```bash
docker run --rm react-hello:local id
```

---

## Security Scanning Locally

### 1. Gitleaks

```bash
docker run --rm -v "${PWD}:/repo" zricethezav/gitleaks:latest dir /repo
```

### 2. Trivy Image Scan

```bash
trivy image --severity HIGH,CRITICAL react-hello:local
```

---

## Troubleshooting Guide

| Issue                          | Root Cause                                                         | Solution                                                                    |
| :----------------------------- | :----------------------------------------------------------------- | :-------------------------------------------------------------------------- |
| `npm ci` fails                 | `package-lock.json` is missing or out of sync with `package.json`. | Run `npm install` locally and commit `package-lock.json`.                   |
| ESLint fails on JSX or globals | Outdated ESLint or missing plugin configuration.                   | Configuration is updated to flat config supporting JSX and browser globals. |
| Port 8080 already in use       | Another service is using port 8080.                                | Bind to a different host port: `docker run -p 8081:8080 react-hello:local`. |
| Vitest coverage empty          | `@vitest/coverage-v8` not installed.                               | Included in `devDependencies`. Run `npm run test:coverage`.                 |
