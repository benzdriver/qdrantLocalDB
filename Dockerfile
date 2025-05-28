FROM qdrant/qdrant:latest

# Expose Qdrant ports
EXPOSE 6333 6334

# Set healthcheck
HEALTHCHECK --interval=10s --timeout=5s --start-period=40s --retries=5 \
  CMD curl -f http://localhost:6333/healthz || exit 1

# The default CMD from the qdrant image will be used
