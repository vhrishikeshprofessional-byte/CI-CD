# C++ DevSecOps Sample Application (`cpp-hello`)

A production-ready reference C++ CLI application demonstrating modern systems DevSecOps practices:
- **Build System:** CMake 3.20+ with C++17
- **Compiler Flags:** Strict warning flags enabled (`-Wall -Wextra -Wpedantic -Werror`)
- **Unit Testing:** CTest test harness
- **Formatting:** `clang-format` (LLVM style)
- **Static Analysis & Linting:** `cppcheck` & `clang-tidy`
- **Code Quality & Security Gate:** SonarQube with `compile_commands.json`
- **Secret Scanning:** Gitleaks
- **Containerization:** Multi-stage GCC build with non-root Debian runtime (`appuser`, UID 10001)
- **Container Image Vulnerability Scanning:** Trivy

---

## Project Structure

```
cpp-hello/
├── src/
│   ├── greeting.h
│   ├── greeting.cpp
│   └── main.cpp
├── tests/
│   └── test_main.cpp
├── CMakeLists.txt
├── .clang-format
├── .clang-tidy
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

### 1. Prerequisites (Ubuntu / Debian / WSL)
```bash
sudo apt-get update && sudo apt-get install -y cmake g++ clang-format clang-tidy cppcheck
```

### 2. Configure, Build & Test
```bash
# Configure with compilation database export
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# Compile in parallel
cmake --build build --parallel

# Run tests
ctest --test-dir build --output-on-failure

# Execute the binary
./build/cpp-hello
# Output: Hello from C++!
```

### 3. Code Style & Static Analysis
```bash
# Formatting check
clang-format --dry-run --Werror src/*.cpp src/*.h tests/*.cpp

# Auto-format
clang-format -i src/*.cpp src/*.h tests/*.cpp

# Cppcheck
cppcheck --enable=warning,style,performance,portability --error-exitcode=1 src tests

# Clang-tidy
clang-tidy -p build src/main.cpp src/greeting.cpp
```

---

## Docker Build & Run

### 1. Build Docker Image
```bash
docker build -t cpp-hello:local .
```

### 2. Run Container
```bash
docker run --rm cpp-hello:local
# Output: Hello from C++!
```

### 3. Non-Root Security Verification
```bash
docker run --rm cpp-hello:local id
# Output: uid=10001(appuser) gid=10001(appuser)
```

---

## Security Scanning Locally

### 1. Gitleaks Secret Detection
```bash
docker run --rm -v "${PWD}:/repo" zricethezav/gitleaks:latest dir /repo
```

### 2. Trivy Image Scan
```bash
trivy image --severity HIGH,CRITICAL cpp-hello:local
```

---

## Troubleshooting Guide

| Issue | Root Cause | Solution |
| :--- | :--- | :--- |
| `clang-tidy` cannot find compile commands | Missing `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`. | Rerun cmake configure with compilation database export enabled. |
| Strict compiler warnings fail build | Unused parameter or sign comparison. | Fix code warnings or add explicit casts. |
| Docker runtime fails to execute binary | Dynamic library missing in slim base image. | Ensure standard C++ runtime or statically link libraries. |
