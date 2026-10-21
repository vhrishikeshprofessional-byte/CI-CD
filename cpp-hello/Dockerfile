# Build stage
FROM gcc:14 AS build
WORKDIR /app

# Install build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    make \
    && rm -rf /var/lib/apt/lists/*

COPY CMakeLists.txt .
COPY src ./src
COPY tests ./tests

RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build --parallel
RUN ctest --test-dir build --output-on-failure

# Production runtime stage
FROM debian:bookworm-slim
RUN useradd --system --uid 10001 appuser
WORKDIR /app

COPY --from=build /app/build/cpp-hello ./cpp-hello
USER 10001
ENTRYPOINT ["./cpp-hello"]
