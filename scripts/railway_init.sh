#!/bin/bash

echo "===== RAILWAY DEPLOYMENT: STARTUP SEQUENCE INITIATED ====="
echo "Current date and time: $(date)"
echo "Container environment: $(uname -a)"
echo "Qdrant executable location: $(which qdrant || echo 'Not found in PATH')"
echo "Checking for Qdrant executable at /qdrant/qdrant: $(ls -la /qdrant/qdrant 2>/dev/null || echo 'Not found')"
echo "Checking for entrypoint script: $(ls -la /qdrant/entrypoint.sh 2>/dev/null || echo 'Not found')"
echo "Checking Qdrant service status..."

echo "===== HEALTHCHECK MONITORING ====="
for i in {1..30}; do
  echo "Healthcheck attempt $i of 30..."
  HEALTH_RESPONSE=$(curl -s -v http://localhost:6333/healthz 2>&1)
  HEALTH_STATUS=$?
  
  echo "Curl exit code: $HEALTH_STATUS"
  echo "Response details: $HEALTH_RESPONSE"
  
  if [ $HEALTH_STATUS -eq 0 ]; then
    echo "✅ HEALTHCHECK PASSED: Qdrant is running!"
    break
  else
    echo "⏳ HEALTHCHECK PENDING: Waiting for Qdrant to start..."
    echo "Sleeping for 5 seconds before next attempt..."
    sleep 5
  fi
done

echo "===== COLLECTION INITIALIZATION ====="
echo "Starting collection initialization process..."
python /scripts/init_collections.py

echo "===== STARTUP COMPLETE ====="
echo "Initialization complete. Qdrant is ready to use."
echo "Dashboard available at http://localhost:6333/dashboard"
echo "API available at http://localhost:6333"
echo "Current date and time: $(date)"
