#!/bin/bash

set -x

echo "===== RAILWAY DEPLOYMENT: STARTUP SEQUENCE INITIATED ====="
echo "Current date and time: $(date)"
echo "Container environment: $(uname -a)"
echo "Container hostname: $(hostname)"
echo "Container IP addresses: $(hostname -I || echo 'Command not available')"
echo "Container network interfaces:"
ip addr show || echo "ip command not available"

echo "===== QDRANT EXECUTABLE VERIFICATION ====="
echo "Qdrant executable location: $(which qdrant || echo 'Not found in PATH')"
echo "Checking for Qdrant executable at /qdrant/qdrant: $(ls -la /qdrant/qdrant 2>/dev/null || echo 'Not found')"
echo "Checking for entrypoint script: $(ls -la /qdrant/entrypoint.sh 2>/dev/null || echo 'Not found')"
echo "Checking Qdrant directory contents:"
ls -la /qdrant/ || echo "Directory not found"

echo "===== PROCESS VERIFICATION ====="
echo "Running processes:"
ps aux || echo "ps command not available"
echo "Listening ports:"
netstat -tulpn || echo "netstat command not available" 
ss -tulpn || echo "ss command not available"

echo "===== WAITING FOR QDRANT TO START ====="
for i in {1..12}; do
  echo "Waiting for Qdrant to start... Attempt $i of 12"
  sleep 5
done

echo "===== COMPREHENSIVE HEALTHCHECK TESTING ====="
ENDPOINTS=("/healthz" "/" "/dashboard" "/metrics" "/status" "/health" "/ready" "/live")

for endpoint in "${ENDPOINTS[@]}"; do
  echo "===== TESTING ENDPOINT: $endpoint ====="
  
  echo "Testing with curl verbose:"
  HEALTH_RESPONSE=$(curl -s -v http://localhost:6333${endpoint} 2>&1)
  HEALTH_STATUS=$?
  
  echo "Curl exit code: $HEALTH_STATUS"
  echo "Response details:"
  echo "$HEALTH_RESPONSE"
  
  echo "Testing with wget:"
  wget -O- -q http://localhost:6333${endpoint} || echo "wget failed with exit code $?"
  
  echo "Testing with Accept header:"
  curl -s -v -H "Accept: application/json" http://localhost:6333${endpoint} || echo "Failed with Accept header"
  
  echo "-----------------------------------"
done

echo "===== TESTING RAILWAY HEALTHCHECK CONFIGURATION ====="
echo "Railway healthcheck path: /healthz"
echo "Testing exact Railway healthcheck configuration:"
curl -s -v http://localhost:6333/healthz 2>&1
echo "Exit code: $?"

echo "===== COLLECTION INITIALIZATION ====="
echo "Starting collection initialization process..."
python /scripts/init_collections.py

echo "===== STARTUP COMPLETE ====="
echo "Initialization complete. Qdrant is ready to use."
echo "Dashboard available at http://localhost:6333/dashboard"
echo "API available at http://localhost:6333"
echo "Current date and time: $(date)"

set +x
