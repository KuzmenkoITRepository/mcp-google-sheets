FROM alpine:latest

WORKDIR /app
# Set environment variables for non-interactive installs and minimal locale
ENV LANG=C.UTF-8

# Update and install basic packages
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        bash \
        curl \
        tini \
        coreutils \
        git

# Set tini as the init system to handle PID 1
ENTRYPOINT ["/sbin/tini", "--"]

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Ensure uv is on PATH
ENV PATH="/root/.local/bin:${PATH}"

# Copy project files needed for dependency installation
COPY .python-version .
COPY pyproject.toml .
COPY uv.lock* ./

# Create venv and install dependencies (without installing the project package)
RUN uv venv && uv sync --no-install-project

# Copy source code and README (after dependencies are installed for better caching)
COPY src ./src
COPY README.md ./

# Remove installed package if exists to force using source code (do this after copying src for better caching)
RUN rm -rf /app/.venv/lib/python*/site-packages/mcp_google_sheets* 2>/dev/null || true

# Set PYTHONPATH to include src directory
ENV PYTHONPATH=/app/src

# CMD will be overridden in docker-compose.yml to use sleep infinity
# Default command for direct usage (not via docker exec):
CMD ["uv", "run", "python", "-m", "mcp_google_sheets", "--transport", "stdio"]
