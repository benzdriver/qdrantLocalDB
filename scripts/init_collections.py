#!/usr/bin/env python3
"""
Initialize Qdrant collections for the Smart Immigration Assistant.
"""

import os
import time
import datetime
import requests
from qdrant_client import QdrantClient
from qdrant_client.http import models
from qdrant_client.http.exceptions import UnexpectedResponse

CANONICAL_COLLECTION = os.environ.get("CANONICAL_COLLECTION", "canonical_queries")
CONVERSATION_COLLECTION = os.environ.get("CONVERSATION_COLLECTION", "conversations")
DOCUMENT_COLLECTION = os.environ.get("DOCUMENT_COLLECTION", "documents")
MERGED_COLLECTION = os.environ.get("MERGED_COLLECTION", "merged_knowledge")

VECTOR_SIZE = int(os.environ.get("VECTOR_SIZE", 1536))

QDRANT_HOST = os.environ.get("QDRANT_HOST", "localhost")
QDRANT_PORT = int(os.environ.get("QDRANT_PORT", 6333))
MAX_RETRIES = 10
RETRY_DELAY = 3  # seconds

def wait_for_qdrant():
    """Wait for Qdrant to be ready"""
    print(f"Waiting for Qdrant at {QDRANT_HOST}:{QDRANT_PORT}...")
    
    for attempt in range(MAX_RETRIES):
        try:
            response = requests.get(f"http://{QDRANT_HOST}:{QDRANT_PORT}/healthz")
            if response.status_code == 200:
                print("✅ Qdrant is ready!")
                return True
        except requests.exceptions.ConnectionError:
            pass
        
        print(f"Waiting for Qdrant to start (attempt {attempt+1}/{MAX_RETRIES})...")
        time.sleep(RETRY_DELAY)
    
    print("❌ Failed to connect to Qdrant after multiple attempts")
    return False

def init_collections():
    """Initialize all required collections"""
    if not wait_for_qdrant():
        return False
    
    try:
        client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)
        
        collections = [
            (CANONICAL_COLLECTION, "Canonical queries collection for query reuse"),
            (CONVERSATION_COLLECTION, "Conversation history collection"),
            (DOCUMENT_COLLECTION, "Document knowledge base collection"),
            (MERGED_COLLECTION, "Merged knowledge points collection")
        ]
        
        for name, description in collections:
            if not client.collection_exists(name):
                client.create_collection(
                    collection_name=name,
                    vectors_config={
                        "default": models.VectorParams(
                            size=VECTOR_SIZE,
                            distance=models.Distance.COSINE,
                            on_disk=False  # Store vectors in RAM for better performance
                        )
                    },
                    optimizers_config=models.OptimizersConfigDiff(
                        indexing_threshold=20000  # Indexing threshold for better performance
                    ),
                    metadata={
                        "description": description,
                        "created_at": datetime.datetime.utcnow().isoformat(),
                        "vector_size": VECTOR_SIZE
                    }
                )
                print(f"✅ Created collection: {name}")
            else:
                print(f"ℹ️ Collection already exists: {name}")
        
        return True
    except UnexpectedResponse as e:
        print(f"❌ Error initializing collections: {e}")
        return False

if __name__ == "__main__":
    success = init_collections()
    if not success:
        exit(1)  # Exit with error code if initialization failed
