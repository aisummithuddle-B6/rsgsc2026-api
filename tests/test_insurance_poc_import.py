from app.insurance_poc_import import (
    build_cleaned_dataset_entity_schema_document,
    build_claim_document,
)


def test_builds_grouped_claim_document_from_cleaned_dataset_row() -> None:
    row = {
        "age": 62,
        "gender": "Male",
        "is_senior_citizen": True,
        "vulnerable_category": "PwD",
        "ped_type": "Hypertension_Diabetes",
        "continuous_coverage_months": 100,
        "claim_amount_inr": 157290,
        "settled_amount_inr": 61485,
        "fraud_indicator": False,
        "investigation_triggered": False,
        "claim_status": "Approved",
        "rejection_reason": "N/A",
    }

    document = build_claim_document(
        row=row,
        source_row=2,
        import_batch_id="test-batch",
        ingested_at="2026-05-16T10:00:00+00:00",
    )

    assert document["_id"] == "insurance-poc.cleaned-dataset.000002"
    assert document["sourceSheet"] == "cleaned dataset"
    assert document["sourceRow"] == 2
    assert document["claimant"] == {
        "age": 62,
        "gender": "Male",
        "is_senior_citizen": True,
        "vulnerable_category": "PwD",
        "ped_type": "Hypertension_Diabetes",
    }
    assert document["financials"]["claim_amount_inr"] == 157290
    assert document["fraudRisk"]["fraud_indicator"] is False
    assert document["settlement"]["claim_status"] == "Approved"


def test_builds_entity_schema_document_for_cleaned_dataset() -> None:
    headers = ["age", "gender", "claim_amount_inr", "claim_status"]

    document = build_cleaned_dataset_entity_schema_document(
        headers=headers,
        source_workbook="insurance test for POC dataset.xlsx",
        row_count=15000,
        ingested_at="2026-05-16T10:00:00+00:00",
    )

    assert document["_id"] == "insurance_poc.cleaned_dataset"
    assert document["entityName"] == "cleaned_dataset"
    assert document["sourceSheet"] == "cleaned dataset"
    assert document["rowCount"] == 15000
    assert document["columns"] == [
        {"name": "age", "ordinal": 1},
        {"name": "gender", "ordinal": 2},
        {"name": "claim_amount_inr", "ordinal": 3},
        {"name": "claim_status", "ordinal": 4},
    ]
