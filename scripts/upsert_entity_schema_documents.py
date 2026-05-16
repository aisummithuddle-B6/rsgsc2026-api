from pathlib import Path
from pymongo import MongoClient, ReplaceOne

from app.core.config import get_settings
from app.core.documentdb import normalize_mongodb_connection_string
from app.schema_documents import build_entity_schema_documents_from_file


SCHEMA_FILE = Path("RMIS-drop-create-schema.sql")
COLLECTION_NAME = "entity_schemas"


def main() -> None:
    settings = get_settings()
    if not settings.has_documentdb_connection:
        raise RuntimeError("AZURE_DOCUMENTDB_CONNECTION_STRING is not configured.")

    documents = build_entity_schema_documents_from_file(SCHEMA_FILE)
    operations = [
        ReplaceOne({"_id": document["_id"]}, document, upsert=True)
        for document in documents
    ]

    with MongoClient(
        normalize_mongodb_connection_string(settings.azure_documentdb_connection_string),
        serverSelectionTimeoutMS=10000,
    ) as client:
        database = client[settings.azure_documentdb_database_name]
        collection = database[COLLECTION_NAME]
        result = collection.bulk_write(operations)
        total = result.upserted_count + result.modified_count + result.matched_count

        print(
            f"Upserted schema metadata into {settings.azure_documentdb_database_name}."
            f"{COLLECTION_NAME}: {total} documents processed."
        )
        print(f"Inserted: {result.upserted_count}")
        print(f"Modified: {result.modified_count}")
        print(f"Matched existing: {result.matched_count}")


if __name__ == "__main__":
    main()
