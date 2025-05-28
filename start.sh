#!/bin/bash

docker-compose up -d

echo "Waiting for Qdrant to start..."
until curl -s -f http://localhost:6333/healthz > /dev/null; do
  sleep 2
done
echo "Qdrant is running!"

read -p "Do you want to initialize collections? (y/n): " init_collections
if [[ $init_collections == "y" || $init_collections == "Y" ]]; then
  echo "Initializing collections..."
  docker-compose -f docker-compose.init.yml up --build init-collections
  docker-compose -f docker-compose.init.yml rm -f init-collections
fi

echo "Qdrant is ready to use at http://localhost:6333"
echo "Dashboard available at http://localhost:6333/dashboard"
