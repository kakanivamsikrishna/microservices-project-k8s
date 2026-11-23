FROM python:3.11-slim

# Install curl (needed to download the probe) and any other deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Download and install grpc_health_probe into /bin
RUN GRPC_HEALTH_PROBE_VERSION=v0.4.19 && \
    curl -fsSL -o /bin/grpc_health_probe \
        https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

# ---- rest of your original Dockerfile ----
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

ENV PORT=8080
EXPOSE 8080
CMD ["python", "recommendationserver.py"]
