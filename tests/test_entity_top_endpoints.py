from fastapi.testclient import TestClient

from app.main import app, get_entity_record_repository


class FakeEntityRecordRepository:
    def __init__(self) -> None:
        self.calls = []

    def list_top(
        self,
        collection_name: str,
        sort_field: str,
        sort_direction: int,
        limit: int,
    ) -> list[dict]:
        self.calls.append(
            {
                "collection_name": collection_name,
                "sort_field": sort_field,
                "sort_direction": sort_direction,
                "limit": limit,
            }
        )
        return [{"_id": "doc-1", "value": 42}]


def test_insurance_poc_claims_top_defaults_to_recent_twenty() -> None:
    repository = FakeEntityRecordRepository()
    app.dependency_overrides[get_entity_record_repository] = lambda: repository
    client = TestClient(app)

    response = client.get("/insurance-poc/claims/top")

    app.dependency_overrides.clear()
    assert response.status_code == 200
    assert response.json() == {
        "entity": "insurance_poc_claims",
        "count": 20,
        "sortBy": "ingestedAt",
        "sortOrder": "desc",
        "items": [{"id": "doc-1", "value": 42}],
    }
    assert repository.calls == [
        {
            "collection_name": "insurance_poc_claims",
            "sort_field": "ingestedAt",
            "sort_direction": -1,
            "limit": 20,
        }
    ]


def test_insurance_poc_claims_top_accepts_count_and_sort_column() -> None:
    repository = FakeEntityRecordRepository()
    app.dependency_overrides[get_entity_record_repository] = lambda: repository
    client = TestClient(app)

    response = client.get(
        "/insurance-poc/claims/top",
        params={
            "count": 2,
            "sort_by": "financials.claim_amount_inr",
            "sort_order": "asc",
        },
    )

    app.dependency_overrides.clear()
    assert response.status_code == 200
    assert response.json()["count"] == 2
    assert response.json()["sortBy"] == "financials.claim_amount_inr"
    assert response.json()["sortOrder"] == "asc"
    assert repository.calls[0] == {
        "collection_name": "insurance_poc_claims",
        "sort_field": "financials.claim_amount_inr",
        "sort_direction": 1,
        "limit": 2,
    }


def test_sample_claimants_top_uses_created_at_by_default() -> None:
    repository = FakeEntityRecordRepository()
    app.dependency_overrides[get_entity_record_repository] = lambda: repository
    client = TestClient(app)

    response = client.get("/sample-claimants/top")

    app.dependency_overrides.clear()
    assert response.status_code == 200
    assert response.json()["entity"] == "sample_claimants"
    assert response.json()["sortBy"] == "CreatedAt"
    assert repository.calls[0]["collection_name"] == "sample_claimants"
    assert repository.calls[0]["sort_field"] == "CreatedAt"
