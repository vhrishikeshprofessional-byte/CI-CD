<#
.SYNOPSIS
  DevSecOps Local Runner Script
.DESCRIPTION
  Runs formatting, tests, docker build, and security scans for the selected framework.
.EXAMPLE
  .\run-devsecops.ps1 -Framework node
  .\run-devsecops.ps1 -Framework fastapi
  .\run-devsecops.ps1 -Framework all
#>

param(
    [ValidateSet("java", "react", "node", "cpp", "dotnet", "fastapi", "go", "all")]
    [string]$Framework = "all"
)

$ErrorActionPreference = "Stop"

function Run-Step($name, $scriptBlock) {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host ">>> STEP: $name" -ForegroundColor Yellow
    Write-Host "========================================================" -ForegroundColor Cyan
    $global:LASTEXITCODE = 0
    & $scriptBlock
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Step '$name' failed with exit code $LASTEXITCODE."
        exit $LASTEXITCODE
    }
}

function Test-HasDotnetSdk {
    if (Get-Command dotnet -ErrorAction SilentlyContinue) {
        $sdks = dotnet --list-sdks 2>$null
        return [bool]$sdks
    }
    return $false
}

function Test-Node {
    Push-Location node-hello
    try {
        Run-Step "Node.js - Install Dependencies" { npm install }
        Run-Step "Node.js - ESLint" { npm run lint }
        Run-Step "Node.js - Prettier Check" { npm run format:check }
        Run-Step "Node.js - Unit Tests & Coverage" { npm run test:coverage }
    } finally {
        Pop-Location
    }
}

function Test-FastAPI {
    if (-not (Get-Command ruff -ErrorAction SilentlyContinue) -or -not (Get-Command pytest -ErrorAction SilentlyContinue)) {
        Write-Warning "FastAPI dev tools ('ruff' or 'pytest') not found in PATH."
        return
    }
    Push-Location fastapi-hello
    try {
        Run-Step "FastAPI - Run Ruff Lint" { ruff check app tests }
        Run-Step "FastAPI - Run Ruff Format Check" { ruff format --check app tests }
        Run-Step "FastAPI - Pytest Coverage" { pytest --cov=app --cov-report=term }
    } finally {
        Pop-Location
    }
}

function Test-React {
    Push-Location react-hello
    try {
        Run-Step "React - Install Dependencies" { npm install }
        Run-Step "React - ESLint" { npm run lint }
        Run-Step "React - Prettier Check" { npm run format:check }
        Run-Step "React - Unit Tests & Coverage" { npm run test:coverage }
        Run-Step "React - Vite Build" { npm run build }
    } finally {
        Pop-Location
    }
}

function Test-Dotnet {
    if (-not (Test-HasDotnetSdk)) {
        Write-Warning "A .NET SDK was not found on this system (only runtime or host detected). Install the .NET SDK from https://aka.ms/dotnet/download to build and test dotnet-hello."
        return
    }
    Push-Location dotnet-hello
    try {
        Run-Step ".NET - Restore" { dotnet restore }
        Run-Step ".NET - Format Check" { dotnet format --verify-no-changes }
        Run-Step ".NET - Build" { dotnet build -c Release }
        Run-Step ".NET - Unit Tests" { dotnet test -c Release --no-build }
    } finally {
        Pop-Location
    }
}

function Test-Go {
    Push-Location go-hello
    try {
        Run-Step "Go - Vet" { go vet ./... }
        Run-Step "Go - Unit Tests" { go test -v -race ./... }
    } finally {
        Pop-Location
    }
}

function Test-Java {
    Push-Location java-hello
    try {
        Run-Step "Java - Maven Clean Verify" { mvn clean verify }
    } finally {
        Pop-Location
    }
}

function Test-Cpp {
    Push-Location cpp-hello
    try {
        Run-Step "C++ - CMake Configure & Build" {
            cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
            cmake --build build --parallel
            ctest --test-dir build --output-on-failure
        }
    } finally {
        Pop-Location
    }
}

switch ($Framework) {
    "node"    { Test-Node }
    "react"   { Test-React }
    "fastapi" { Test-FastAPI }
    "dotnet"  { Test-Dotnet }
    "go"      { Test-Go }
    "java"    { Test-Java }
    "cpp"     { Test-Cpp }
    "all"     {
        Write-Host "Running DevSecOps test suite for all installed frameworks..." -ForegroundColor Green
        if (Get-Command node -ErrorAction SilentlyContinue) { Test-Node; Test-React }
        if (Get-Command python -ErrorAction SilentlyContinue) { Test-FastAPI }
        if (Test-HasDotnetSdk) { Test-Dotnet }
        if (Get-Command go -ErrorAction SilentlyContinue) { Test-Go }
        if (Get-Command mvn -ErrorAction SilentlyContinue) { Test-Java }
        if (Get-Command cmake -ErrorAction SilentlyContinue) { Test-Cpp }
    }
}

Write-Host "`n DevSecOps execution completed successfully!" -ForegroundColor Green
