from app.sample_claimants import build_sample_claimant_documents


def test_builds_five_claimants_with_ten_claims_each() -> None:
    documents = build_sample_claimant_documents()

    assert len(documents) == 5
    assert [document["_id"] for document in documents] == [
        "sample.claimant.001",
        "sample.claimant.002",
        "sample.claimant.003",
        "sample.claimant.004",
        "sample.claimant.005",
    ]
    assert [document["FullName"] for document in documents] == [
        "Maya Reynolds",
        "Ethan Brooks",
        "Sophia Carter",
        "Noah Mitchell",
        "Olivia Bennett",
    ]
    assert all(len(document["claims"]) == 10 for document in documents)


def test_claim_records_are_linked_to_parent_claimant() -> None:
    documents = build_sample_claimant_documents()
    first_claimant = documents[0]
    first_claim = first_claimant["claims"][0]

    assert first_claim["ClaimantId"] == first_claimant["ClaimantId"]
    assert first_claim["ClaimId"] == "sample.claim.001.001"
    assert first_claim["ClaimNumber"] == "CLM-SAMPLE-001-001"
    assert first_claim["Status"] in {"Open", "In Review", "Closed", "Pending"}
    assert first_claim["CurrentReserveAmount"] >= first_claim["TotalPaidAmount"]
