from datetime import UTC, datetime

from fastapi import FastAPI

app = FastAPI(
    title="FastAPI DevSecOps Hello API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url=None,
)


@app.get("/")
def read_root():
    """Return greeting message and timestamp."""
    return {
        "message": "Hello from FastAPI!",
        "timestamp": datetime.now(UTC).isoformat(),
    }


@app.get("/health")
def read_health():
    """Health check endpoint for liveness / readiness probes."""
    return {"status": "healthy"}
