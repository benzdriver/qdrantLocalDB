# Qdrant Vector Database for Railway

This repository contains a dockerized Qdrant vector database configured for easy deployment on Railway.

## Features

- Pre-configured Qdrant vector database
- Automatic collection initialization
- Railway deployment ready
- Dashboard access for monitoring

## Resource Requirements

Memory usage depends on the number and dimension of vectors:
- Formula: `Memory = Number of vectors × Vector dimension × 4 bytes × 1.5`
- For 1536-dimensional vectors (OpenAI embeddings):
  - 10,000 vectors: ~92MB RAM
  - 100,000 vectors: ~920MB RAM
  - 1,000,000 vectors: ~9.2GB RAM

## Local Development

### Prerequisites

- Docker and Docker Compose

### Running Locally

1. Clone this repository
2. Run the start script:
   ```
   ./start.sh
   ```
3. Access the Qdrant dashboard at http://localhost:6333/dashboard

## Railway Deployment

1. Fork or clone this repository
2. Connect it to your Railway project
3. Deploy using the Railway dashboard
4. Access your Qdrant instance at:
   - Dashboard: https://your-project-name.up.railway.app/dashboard
   - API: https://your-project-name.up.railway.app

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| QDRANT_ALLOW_RECOVERY_MODE | Enable recovery mode | true |
| QDRANT_TELEMETRY_DISABLED | Disable telemetry | true |

## Collections

The following collections are automatically created:
- `canonical_queries`: For storing canonical queries
- `conversations`: For conversation history
- `documents`: For document knowledge base
- `merged_knowledge`: For merged knowledge points

## Accessing the API

```python
from qdrant_client import QdrantClient

# Local development
client = QdrantClient(host="localhost", port=6333)

# Railway deployment
client = QdrantClient(url="https://your-project-name.up.railway.app")
```

## Health Checks

The service includes a health check endpoint at `/healthz` that returns a 200 OK response when the service is healthy.
