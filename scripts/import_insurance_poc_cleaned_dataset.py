from datetime import UTC, datetime
from pathlib import Path

from pymongo import MongoClient, ReplaceOne

from app.core.config import get_settings
from app.insurance_poc_import import (
    CLAIMS_COLLECTION,
    ENTITY_SCHEMAS_COLLECTION,
    SOURCE_WORKBOOK,
    build_cleaned_dataset_entity_schema_document,
    get_cleaned_dataset_headers_and_count,
    iter_cleaned_dataset_documents,
)
from scripts.upsert_entity_schema_documents import normalize_mongodb_connection_string


BATCH_SIZE = 500


def main() -> None:
    settings = get_settings()
    if not settings.has_documentdb_connection:
        raise RuntimeError("AZURE_DOCUMENTDB_CONNECTION_STRING is not configured.")

    workbook_path = Path(SOURCE_WORKBOOK)
    if not workbook_path.exists():
        raise FileNotFoundError(workbook_path)

    ingested_at = datetime.now(UTC).isoformat()
    import_batch_id = f"insurance-poc-cleaned-dataset-{ingested_at}"
    headers, row_count = get_cleaned_dataset_headers_and_count(workbook_path)
    schema_document = build_cleaned_dataset_entity_schema_document(
        headers=headers,
        source_workbook=SOURCE_WORKBOOK,
        row_count=row_count,
        ingested_at=ingested_at,
    )

    with MongoClient(
        normalize_mongodb_connection_string(settings.azure_documentdb_connection_string),
        serverSelectionTimeoutMS=10000,
    ) as client:
        database = client[settings.azure_documentdb_database_name]
        database[ENTITY_SCHEMAS_COLLECTION].replace_one(
            {"_id": schema_document["_id"]},
            schema_document,
            upsert=True,
        )

        claims = database[CLAIMS_COLLECTION]
        processed = 0
        operations: list[ReplaceOne] = []

        for document in iter_cleaned_dataset_documents(
            workbook_path=workbook_path,
            import_batch_id=import_batch_id,
            ingested_at=ingested_at,
        ):
            operations.append(ReplaceOne({"_id": document["_id"]}, document, upsert=True))
            if len(operations) >= BATCH_SIZE:
                claims.bulk_write(operations)
                processed += len(operations)
                operations = []

        if operations:
            claims.bulk_write(operations)
            processed += len(operations)

    print(f"Imported schema document into {ENTITY_SCHEMAS_COLLECTION}.")
    print(f"Imported {processed} cleaned dataset rows into {CLAIMS_COLLECTION}.")
    print(f"Import batch: {import_batch_id}")


if __name__ == "__main__":
    main()
