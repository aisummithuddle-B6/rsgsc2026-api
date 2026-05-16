from app.schema_documents import build_entity_schema_documents
from scripts.upsert_entity_schema_documents import normalize_mongodb_connection_string


def test_builds_one_document_per_sql_table() -> None:
    sql = """
    CREATE TABLE core.Claim (
        ClaimId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Claim PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
        TenantId UNIQUEIDENTIFIER NOT NULL,
        ClaimNumber NVARCHAR(100) NOT NULL,
        Status NVARCHAR(30) NOT NULL,
        CONSTRAINT UQ_Claim_Tenant_ClaimNumber UNIQUE (TenantId, ClaimNumber)
    );
    GO
    CREATE TABLE sec.[User] (
        UserId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_User PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
        UserName NVARCHAR(100) NOT NULL
    );
    GO
    """

    documents = build_entity_schema_documents(sql, "schema.sql")

    assert [document["_id"] for document in documents] == ["core.Claim", "sec.User"]
    assert documents[0]["primaryKey"] == "ClaimId"
    assert documents[0]["columns"][2] == {
        "name": "ClaimNumber",
        "type": "NVARCHAR(100)",
        "nullable": False,
    }
    assert documents[0]["uniqueConstraints"] == [
        {
            "name": "UQ_Claim_Tenant_ClaimNumber",
            "columns": ["TenantId", "ClaimNumber"],
        }
    ]
    assert documents[1]["schemaName"] == "sec"
    assert documents[1]["entityName"] == "User"


def test_extracts_foreign_key_metadata() -> None:
    sql = """
    CREATE TABLE ref.Organization (
        OrganizationId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Organization PRIMARY KEY,
        TenantId UNIQUEIDENTIFIER NOT NULL,
        CONSTRAINT FK_Organization_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId)
    );
    GO
    """

    documents = build_entity_schema_documents(sql, "schema.sql")

    assert documents[0]["foreignKeys"] == [
        {
            "name": "FK_Organization_Tenant",
            "columns": ["TenantId"],
            "referencedTable": "cfg.Tenant",
            "referencedColumns": ["TenantId"],
        }
    ]


def test_normalizes_reserved_characters_in_mongodb_credentials() -> None:
    connection_string = "mongodb+srv://user:p@#@example.mongodb.net/?tls=true"

    normalized = normalize_mongodb_connection_string(connection_string)

    assert normalized == "mongodb+srv://user:p%40%23@example.mongodb.net/?tls=true"
