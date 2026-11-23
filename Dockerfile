FROM python:3.10-slim AS base

# Builder stage
FROM base AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN GRPC_HEALTH_PROBE_VERSION=v0.4.19 && \
    curl -fsSL -o /grpc_health_probe \
      https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /grpc_health_probe

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir "setuptools==80.9.0" wheel
RUN pip install --no-cache-dir --no-build-isolation -r requirements.txt

# Runtime stage
FROM base AS runtime

ENV PYTHONUNBUFFERED=1
ENV PORT=8080

WORKDIR /emailservice

COPY --from=builder /usr/local/lib/python3.10/ /usr/local/lib/python3.10/
COPY --from=builder /grpc_health_probe /bin/grpc_health_probe

COPY . .

EXPOSE 8080
ENTRYPOINT ["python", "email_server.py"]
