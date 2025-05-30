#!/bin/bash


set -x

echo "===== DIAGNOSTIC SCRIPT STARTED: $(date) ====="
echo "Hostname: $(hostname)"
echo "Environment: $(uname -a)"

echo "===== SYSTEM INFORMATION ====="
echo "CPU Info:"
cat /proc/cpuinfo | grep "model name" | head -1
echo "Memory Info:"
free -h
echo "Disk Space:"
df -h
echo "Network Interfaces:"
ip addr show

echo "===== PROCESS INFORMATION ====="
echo "Running processes:"
ps aux | grep -E 'qdrant|entrypoint'
echo "Process tree:"
pstree -p
echo "Open files by Qdrant process:"
lsof -p $(pgrep -f qdrant) 2>/dev/null || echo "No Qdrant process found"

echo "===== NETWORK DIAGNOSTICS ====="
echo "Listening ports:"
netstat -tulpn || ss -tulpn
echo "Established connections:"
netstat -an | grep ESTABLISHED || ss -an | grep ESTABLISHED
echo "DNS resolution:"
cat /etc/resolv.conf
echo "Testing DNS:"
nslookup google.com || echo "nslookup failed"
echo "Testing internet connectivity:"
ping -c 3 8.8.8.8 || echo "ping failed"
curl -s https://api.ipify.org && echo " <- External IP"

echo "===== QDRANT SERVICE STATUS ====="
echo "Qdrant executable:"
which qdrant || echo "Qdrant not in PATH"
echo "Qdrant directory contents:"
ls -la /qdrant/ 2>/dev/null || echo "Directory not found"
echo "Entrypoint script:"
cat /qdrant/entrypoint.sh 2>/dev/null || echo "Entrypoint script not found"
echo "Qdrant config:"
cat /qdrant/config/config.yaml 2>/dev/null || echo "Config not found"
echo "Qdrant logs:"
find /var/log -name "*qdrant*" -exec cat {} \; 2>/dev/null || echo "No Qdrant logs found"

echo "===== HEALTHCHECK ENDPOINT TESTING ====="

ENDPOINTS=("/" "/dashboard" "/healthz" "/collections" "/metrics" "/status" "/ready" "/live")

for endpoint in "${ENDPOINTS[@]}"; do
  echo "===== TESTING ENDPOINT: $endpoint ====="
  
  echo "Testing with curl (default):"
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:6333${endpoint} || echo "curl failed with exit code $?"
  
  echo "Testing with curl (verbose):"
  curl -v http://localhost:6333${endpoint} 2>&1 || echo "curl verbose failed with exit code $?"
  
  echo "Testing with Accept: application/json header:"
  curl -s -H "Accept: application/json" http://localhost:6333${endpoint} || echo "curl with Accept header failed"
  
  echo "Testing with User-Agent: Railway-Healthcheck header:"
  curl -s -H "User-Agent: Railway-Healthcheck" http://localhost:6333${endpoint} || echo "curl with User-Agent header failed"
  
  echo "Testing with wget:"
  wget -q -O- http://localhost:6333${endpoint} || echo "wget failed with exit code $?"
  
  echo "Testing with 5s timeout:"
  curl -s --max-time 5 http://localhost:6333${endpoint} || echo "curl with 5s timeout failed"
  
  echo "Testing with 30s timeout:"
  curl -s --max-time 30 http://localhost:6333${endpoint} || echo "curl with 30s timeout failed"
  
  echo "-----------------------------------"
done

echo "===== SIMULATING RAILWAY HEALTHCHECK ====="
echo "Testing with Railway's expected configuration:"
curl -s -v -H "User-Agent: Railway-Healthcheck" http://localhost:6333/dashboard 2>&1
echo "Exit code: $?"

echo "Testing with HTTPS (should fail locally):"
curl -s -k https://localhost:6333/dashboard || echo "HTTPS test failed as expected"

echo "===== FIREWALL AND NETWORK CHECKS ====="
iptables -L 2>/dev/null || echo "iptables not available"
echo "Traceroute to localhost:"
traceroute localhost 2>/dev/null || echo "traceroute not available"

echo "===== ERROR LOGS ====="
echo "System logs related to Qdrant:"
journalctl | grep -i "qdrant\|error\|failed\|denied" 2>/dev/null || echo "journalctl not available"
echo "Docker logs (if running in Docker):"
docker logs $(docker ps -q --filter name=qdrant) 2>/dev/null || echo "No Docker container found or Docker not available"

echo "===== STORAGE PERMISSIONS ====="
echo "Storage directory permissions:"
ls -la /qdrant/storage/ 2>/dev/null || echo "Storage directory not found"
echo "Storage directory ownership:"
stat -c "%U:%G" /qdrant/storage/ 2>/dev/null || echo "stat command failed"

echo "===== DIAGNOSTIC SCRIPT COMPLETED: $(date) ====="
