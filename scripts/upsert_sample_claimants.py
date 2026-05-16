from pymongo import MongoClient, ReplaceOne

from app.core.config import get_settings
from app.sample_claimants import build_sample_claimant_documents
from scripts.upsert_entity_schema_documents import normalize_mongodb_connection_string


COLLECTION_NAME = "sample_claimants"


def main() -> None:
    settings = get_settings()
    if not settings.has_documentdb_connection:
        raise RuntimeError("AZURE_DOCUMENTDB_CONNECTION_STRING is not configured.")

    documents = build_sample_claimant_documents()
    operations = [
        ReplaceOne({"_id": document["_id"]}, document, upsert=True)
        for document in documents
    ]

    with MongoClient(
        normalize_mongodb_connection_string(settings.azure_documentdb_connection_string),
        serverSelectionTimeoutMS=10000,
    ) as client:
        collection = client[settings.azure_documentdb_database_name][COLLECTION_NAME]
        result = collection.bulk_write(operations)
        total = result.upserted_count + result.modified_count + result.matched_count

        print(
            f"Upserted sample claimants into "
            f"{settings.azure_documentdb_database_name}.{COLLECTION_NAME}: "
            f"{total} documents processed."
        )
        print(f"Inserted: {result.upserted_count}")
        print(f"Modified: {result.modified_count}")
        print(f"Matched existing: {result.matched_count}")


if __name__ == "__main__":
    main()
