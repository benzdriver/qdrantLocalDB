FROM qdrant/qdrant:latest

# Install curl and Python for initialization scripts
RUN apt-get update && \
    apt-get install -y curl python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy initialization scripts
COPY scripts/requirements.txt /scripts/
RUN pip3 install --no-cache-dir -r /scripts/requirements.txt

COPY scripts/init_collections.py /scripts/
COPY scripts/railway_init.sh /scripts/
RUN chmod +x /scripts/railway_init.sh

# Expose Qdrant ports
EXPOSE 6333 6334

# Set healthcheck
HEALTHCHECK --interval=10s --timeout=5s --start-period=40s --retries=5 \
  CMD curl -f http://localhost:6333/healthz || exit 1

# The default CMD from the qdrant image will be used
