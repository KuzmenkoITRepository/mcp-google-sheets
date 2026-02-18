FROM python:3.11-slim

WORKDIR /app

ENV LANG=C.UTF-8 \
    PYTHONPATH=/app/src

# Copy source first so module is available via PYTHONPATH in runtime.
COPY src ./src

# Install runtime dependencies directly (without uv) to avoid flaky external installer.
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        "mcp>=1.5.0" \
        "google-auth>=2.28.1" \
        "google-auth-oauthlib>=1.2.0" \
        "google-api-python-client>=2.117.0"

# CMD will be overridden in docker-compose.yml to use sleep infinity.
CMD ["python3", "-m", "mcp_google_sheets.server", "--transport", "stdio"]
