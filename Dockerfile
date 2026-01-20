FROM alpine:latest

WORKDIR /app

ENV LANG=C.UTF-8 \
    PATH="/root/.local/bin:${PATH}" \
    PYTHONPATH=/app/src

# Install packages and uv in one layer, remove git after uv install (not needed at runtime)
RUN apk add --no-cache bash curl tini coreutils && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/sbin/tini", "--"]

# Copy dependency files first for better layer caching
COPY .python-version pyproject.toml uv.lock* ./

# Create venv and install dependencies (without installing the project package)
RUN uv venv && uv sync --no-install-project

# Copy source code (after dependencies for better caching)
COPY src ./src

# Remove installed package if exists to force using source code
RUN rm -rf /app/.venv/lib/python*/site-packages/mcp_google_sheets* 2>/dev/null || true

# CMD will be overridden in docker-compose.yml to use sleep infinity
CMD ["uv", "run", "python", "-m", "mcp_google_sheets", "--transport", "stdio"]
