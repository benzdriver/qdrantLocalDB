FROM python:3.10-slim

WORKDIR /app

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY scripts/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy initialization script
COPY scripts/ /scripts/
RUN chmod +x /scripts/init_collections.py

# Default command keeps container running
CMD ["tail", "-f", "/dev/null"]
