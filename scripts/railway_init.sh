#!/bin/bash

echo "Waiting for Qdrant to start..."
for i in {1..30}; do
  if curl -s -f http://localhost:6333/healthz > /dev/null; then
    echo "Qdrant is running!"
    break
  fi
  echo "Attempt $i: Waiting for Qdrant to start..."
  sleep 5
done

echo "Initializing collections..."
python /scripts/init_collections.py

echo "Initialization complete. Qdrant is ready to use."
echo "Dashboard available at http://localhost:6333/dashboard"
