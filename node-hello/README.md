# Node.js DevSecOps Sample Application (`node-hello`)

A production-ready reference Express REST API demonstrating modern Node.js DevSecOps practices:

- **Runtime:** Node.js 22 LTS
- **Framework:** Express.js
- **Testing:** Node.js native test runner (`node:test`, `node:assert/strict`) & Supertest
- **Code Coverage:** `c8` (V8 coverage engine generating `coverage/lcov.info` for SonarQube)
- **Linting:** ESLint with modern flat config (`eslint.config.js`)
- **Formatting:** Prettier
- **Dependency Vulnerability Scanning:** `npm audit`
- **Code Quality & Security Gate:** SonarQube
- **Secret Scanning:** Gitleaks
- **Containerization:** Multi-stage Dockerfile with non-root security (`appuser:appgroup`)
- **Container Image Vulnerability Scanning:** Trivy

---

## Project Structure

```
node-hello/
├── src/
│   └── app.js
├── test/
│   └── app.test.js
├── package.json
├── eslint.config.js
├── .prettierrc
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

### 2. Linting & Formatting

```bash
# Check code style with ESLint
npm run lint

# Check formatting with Prettier
npm run format:check

# Auto-format files
npm run format
```

### 3. Run Unit Tests & Coverage

```bash
# Run unit tests
npm test

# Run tests and generate LCOV coverage report
npm run test:coverage
```

### 4. Run Application Locally

```bash
npm start
```

Test endpoints:

- `http://localhost:3000/` -> `{"message":"Hello from Node.js!","timestamp":"..."}`
- `http://localhost:3000/health` -> `{"status":"healthy"}`

---

## Docker Build & Run

### 1. Build Docker Image

```bash
docker build -t node-hello:local .
```

### 2. Run Container

```bash
docker run --rm -p 3000:3000 node-hello:local
```

### 3. Non-Root Security Verification

```bash
docker run --rm node-hello:local whoami
# Output: appuser
```

---

## Security Scanning Locally

### 1. Gitleaks Secret Detection

```bash
docker run --rm -v "${PWD}:/repo" zricethezav/gitleaks:latest dir /repo
```

### 2. Trivy Image Scan

```bash
trivy image --severity HIGH,CRITICAL node-hello:local
```

---

## Troubleshooting Guide

| Issue                     | Root Cause                                  | Solution                                                                                          |
| :------------------------ | :------------------------------------------ | :------------------------------------------------------------------------------------------------ |
| `npm ci` fails            | `package-lock.json` missing or out of sync. | Run `npm install` and commit `package-lock.json`.                                                 |
| Port 3000 in use          | Another service is using port 3000.         | Start with custom port: `PORT=3001 npm start` or `-p 3001:3000`.                                  |
| ESLint error on `require` | Missing CommonJS / Node globals.            | Ensure `languageOptions.sourceType: 'commonjs'` and `globals.node` are set in `eslint.config.js`. |
