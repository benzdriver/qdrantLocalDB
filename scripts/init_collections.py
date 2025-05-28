#!/usr/bin/env python3
"""
Initialize Qdrant collections for the Smart Immigration Assistant.
"""

import os
import datetime
from qdrant_client import QdrantClient, models

CANONICAL_COLLECTION = "canonical_queries"
CONVERSATION_COLLECTION = "conversations"
DOCUMENT_COLLECTION = "documents"
MERGED_COLLECTION = "merged_knowledge"

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
                vectors_config=models.VectorParams(
                    size=VECTOR_SIZE,
                    distance=models.Distance.COSINE
                ),
                metadata={
                    "description": description,
                    "created_at": datetime.datetime.utcnow().isoformat()
                }
            )
            print(f"✅ Created collection: {name}")
        else:
            print(f"ℹ️ Collection already exists: {name}")

if __name__ == "__main__":
    init_collections()
