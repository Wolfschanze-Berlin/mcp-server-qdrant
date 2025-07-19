FROM python:3.11-slim

WORKDIR /app

# Install uv for package management
RUN pip install --no-cache-dir uv

# Copy the project files
COPY pyproject.toml uv.lock README.md LICENSE ./
COPY src/ ./src/

# Install dependencies and build the package
RUN uv sync --frozen && \
    uv build && \
    uv pip install --system --no-cache-dir dist/*.whl && \
    rm -rf .venv dist

# Expose the default port for SSE transport
EXPOSE 8000

# Set environment variables with defaults that can be overridden at runtime
# Note: QDRANT_API_KEY should be provided at runtime for security
ENV QDRANT_URL=""
ENV COLLECTION_NAME="default-collection"
ENV EMBEDDING_MODEL="sentence-transformers/all-MiniLM-L6-v2"

# Set FastMCP host to bind to all interfaces in container
ENV FASTMCP_HOST="0.0.0.0"

# Run the server with SSE transport
CMD ["mcp-server-qdrant", "--transport", "sse"]
