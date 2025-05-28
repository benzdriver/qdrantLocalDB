#!/usr/bin/env python3
"""
Initialize Qdrant collections for the Smart Immigration Assistant.
"""

import os
import datetime
from qdrant_client import QdrantClient
from qdrant_client.http import models

CANONICAL_COLLECTION = os.environ.get("CANONICAL_COLLECTION", "canonical_queries")
CONVERSATION_COLLECTION = os.environ.get("CONVERSATION_COLLECTION", "conversations")
DOCUMENT_COLLECTION = os.environ.get("DOCUMENT_COLLECTION", "documents")
MERGED_COLLECTION = os.environ.get("MERGED_COLLECTION", "merged_knowledge")

VECTOR_SIZE = int(os.environ.get("VECTOR_SIZE", 1536))

def init_collections():
    """Initialize all required collections"""
    client = QdrantClient(host="localhost", port=6333)
    
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

if __name__ == "__main__":
    init_collections()
