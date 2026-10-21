#!/usr/bin/env bash
set -euo pipefail

FRAMEWORK="${1:-all}"

echo_step() {
  echo -e "\n\033[1;36m========================================================\033[0m"
  echo -e "\033[1;33m>>> STEP: $1\033[0m"
  echo -e "\033[1;36m========================================================\033[0m"
}

test_node() {
  (
    cd node-hello
    echo_step "Node.js: Install dependencies"
    npm install
    echo_step "Node.js: ESLint"
    npm run lint
    echo_step "Node.js: Prettier formatting check"
    npm run format:check
    echo_step "Node.js: Unit tests & coverage"
    npm run test:coverage
  )
}

test_react() {
  (
    cd react-hello
    echo_step "React: Install dependencies"
    npm install
    echo_step "React: ESLint"
    npm run lint
    echo_step "React: Prettier formatting check"
    npm run format:check
    echo_step "React: Vitest unit tests"
    npm run test:coverage
    echo_step "React: Production build"
    npm run build
  )
}

test_fastapi() {
  (
    cd fastapi-hello
    echo_step "FastAPI: Ruff lint"
    ruff check app tests
    echo_step "FastAPI: Ruff format check"
    ruff format --check app tests
    echo_step "FastAPI: Pytest with coverage"
    pytest --cov=app --cov-report=term
  )
}

test_dotnet() {
  if ! command -v dotnet >/dev/null 2>&1 || [ -z "$(dotnet --list-sdks 2>/dev/null)" ]; then
    echo -e "\033[1;33m>>> .NET SDK not found. Install from https://aka.ms/dotnet/download\033[0m"
    return 0
  fi
  (
    cd dotnet-hello
    echo_step ".NET: Restore"
    dotnet restore
    echo_step ".NET: Format check"
    dotnet format --verify-no-changes
    echo_step ".NET: Build"
    dotnet build -c Release
    echo_step ".NET: Tests"
    dotnet test -c Release --no-build
  )
}

test_go() {
  (
    cd go-hello
    echo_step "Go: Vet"
    go vet ./...
    echo_step "Go: Tests with race detector"
    go test -v -race ./...
  )
}

test_java() {
  (
    cd java-hello
    echo_step "Java: Maven clean verify"
    mvn clean verify
  )
}

test_cpp() {
  (
    cd cpp-hello
    echo_step "C++: CMake configure, build & CTest"
    cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    cmake --build build --parallel
    ctest --test-dir build --output-on-failure
  )
}

case "$FRAMEWORK" in
  node) test_node ;;
  react) test_react ;;
  fastapi) test_fastapi ;;
  dotnet) test_dotnet ;;
  go) test_go ;;
  java) test_java ;;
  cpp) test_cpp ;;
  all)
    command -v node >/dev/null 2>&1 && { test_node; test_react; }
    command -v ruff >/dev/null 2>&1 && test_fastapi
    command -v dotnet >/dev/null 2>&1 && test_dotnet
    command -v go >/dev/null 2>&1 && test_go
    command -v mvn >/dev/null 2>&1 && test_java
    command -v cmake >/dev/null 2>&1 && test_cpp
    ;;
  *)
    echo "Unknown framework: $FRAMEWORK. Valid options: node, react, fastapi, dotnet, go, java, cpp, all"
    exit 1
    ;;
esac

echo -e "\n\033[1;32m DevSecOps validation completed!\033[0m"
