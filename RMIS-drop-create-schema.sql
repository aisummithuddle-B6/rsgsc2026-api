SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*
RMIS platform schema
Drop-and-create DDL for SQL Server / LocalDB.
Logical module schemas are used here. Tenant-specific physical schemas can be registered in cfg.TenantSchemaRegistry.
*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'cfg') EXEC('CREATE SCHEMA cfg');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'sec') EXEC('CREATE SCHEMA sec');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ref') EXEC('CREATE SCHEMA ref');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ing') EXEC('CREATE SCHEMA ing');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'core') EXEC('CREATE SCHEMA core');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'wf') EXEC('CREATE SCHEMA wf');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ai') EXEC('CREATE SCHEMA ai');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'rpt') EXEC('CREATE SCHEMA rpt');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'testcfg') EXEC('CREATE SCHEMA testcfg');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ext') EXEC('CREATE SCHEMA ext');
GO

DROP TABLE IF EXISTS ext.MMSEARecord;
GO
DROP TABLE IF EXISTS ext.Bond;
GO
DROP TABLE IF EXISTS ext.LitigationMatter;
GO
DROP TABLE IF EXISTS ext.Contract;
GO
DROP TABLE IF EXISTS ext.Vehicle;
GO
DROP TABLE IF EXISTS ext.Asset;
GO
DROP TABLE IF EXISTS testcfg.UserImportRow;
GO
DROP TABLE IF EXISTS testcfg.UserImportBatch;
GO
DROP TABLE IF EXISTS testcfg.TestDataSchedule;
GO
DROP TABLE IF EXISTS testcfg.TestDataRun;
GO
DROP TABLE IF EXISTS testcfg.TestDataFile;
GO
DROP TABLE IF EXISTS testcfg.TestDataSet;
GO
DROP TABLE IF EXISTS rpt.ReportRecipient;
GO
DROP TABLE IF EXISTS rpt.ReportRun;
GO
DROP TABLE IF EXISTS rpt.ReportDefinition;
GO
DROP TABLE IF EXISTS rpt.DashboardDefinition;
GO
DROP TABLE IF EXISTS ai.Recommendation;
GO
DROP TABLE IF EXISTS ai.RiskScore;
GO
DROP TABLE IF EXISTS ai.AIReview;
GO
DROP TABLE IF EXISTS ai.ExtractedField;
GO
DROP TABLE IF EXISTS ai.ExtractionResult;
GO
DROP TABLE IF EXISTS wf.WorkflowEvent;
GO
DROP TABLE IF EXISTS wf.Notification;
GO
DROP TABLE IF EXISTS wf.SLAEvent;
GO
DROP TABLE IF EXISTS wf.TaskComment;
GO
DROP TABLE IF EXISTS wf.Task;
GO
DROP TABLE IF EXISTS wf.WorkflowStep;
GO
DROP TABLE IF EXISTS wf.WorkflowDefinition;
GO
DROP TABLE IF EXISTS core.OshaCase;
GO
DROP TABLE IF EXISTS core.ReserveTransaction;
GO
DROP TABLE IF EXISTS core.Payment;
GO
DROP TABLE IF EXISTS core.Reserve;
GO
DROP TABLE IF EXISTS core.Note;
GO
DROP TABLE IF EXISTS core.ClaimDocument;
GO
DROP TABLE IF EXISTS core.IncidentDocument;
GO
DROP TABLE IF EXISTS core.Document;
GO
DROP TABLE IF EXISTS core.Claim;
GO
DROP TABLE IF EXISTS core.Claimant;
GO
DROP TABLE IF EXISTS core.Incident;
GO
DROP TABLE IF EXISTS core.Exposure;
GO
DROP TABLE IF EXISTS core.Coverage;
GO
DROP TABLE IF EXISTS core.Policy;
GO
DROP TABLE IF EXISTS ing.MappingDecision;
GO
DROP TABLE IF EXISTS ing.MappingSuggestion;
GO
DROP TABLE IF EXISTS ing.MappingRule;
GO
DROP TABLE IF EXISTS ing.StagingValidationIssue;
GO
DROP TABLE IF EXISTS ing.StagingValidationRun;
GO
DROP TABLE IF EXISTS ing.StagingColumnDefinition;
GO
DROP TABLE IF EXISTS ing.StagingSchemaDefinition;
GO
DROP TABLE IF EXISTS ing.SchemaValidationResult;
GO
DROP TABLE IF EXISTS ing.TemplateColumnDefinition;
GO
DROP TABLE IF EXISTS ing.TemplateSchema;
GO
DROP TABLE IF EXISTS ing.FileProcessingEvent;
GO
DROP TABLE IF EXISTS ing.SourceFile;
GO
DROP TABLE IF EXISTS ing.IngestionJob;
GO
DROP TABLE IF EXISTS ing.IngestionEndpoint;
GO
DROP TABLE IF EXISTS ing.IngestionSource;
GO
DROP TABLE IF EXISTS cfg.CustomFieldValue;
GO
DROP TABLE IF EXISTS cfg.TenantCustomField;
GO
DROP TABLE IF EXISTS cfg.TenantFieldConfig;
GO
DROP TABLE IF EXISTS sec.UserPermission;
GO
DROP TABLE IF EXISTS sec.UserRole;
GO
DROP TABLE IF EXISTS sec.RolePermission;
GO
DROP TABLE IF EXISTS sec.Permission;
GO
DROP TABLE IF EXISTS sec.Role;
GO
DROP TABLE IF EXISTS sec.[User];
GO
DROP TABLE IF EXISTS cfg.TenantSchemaRegistry;
GO
DROP TABLE IF EXISTS ref.Location;
GO
DROP TABLE IF EXISTS ref.Organization;
GO
DROP TABLE IF EXISTS cfg.Tenant;
GO

CREATE TABLE cfg.Tenant (
    TenantId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Tenant PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantCode NVARCHAR(50) NOT NULL,
    TenantName NVARCHAR(200) NOT NULL,
    TenantType NVARCHAR(50) NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_Tenant_Status DEFAULT ('Active'),
    DefaultTimeZone NVARCHAR(100) NULL,
    DefaultCurrencyCode CHAR(3) NULL,
    TenantSchemaName NVARCHAR(128) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Tenant_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CreatedBy NVARCHAR(100) NULL,
    UpdatedAt DATETIME2(0) NULL,
    UpdatedBy NVARCHAR(100) NULL,
    CONSTRAINT UQ_Tenant_TenantCode UNIQUE (TenantCode)
);
GO

CREATE TABLE ref.Organization (
    OrganizationId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Organization PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrganizationCode NVARCHAR(50) NULL,
    OrganizationName NVARCHAR(200) NOT NULL,
    Industry NVARCHAR(100) NULL,
    HierarchyPath NVARCHAR(500) NULL,
    ParentOrganizationId UNIQUEIDENTIFIER NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_Organization_Status DEFAULT ('Active'),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Organization_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt DATETIME2(0) NULL,
    CONSTRAINT FK_Organization_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Organization_Parent FOREIGN KEY (ParentOrganizationId) REFERENCES ref.Organization (OrganizationId)
);
GO

CREATE TABLE ref.Location (
    LocationId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Location PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrganizationId UNIQUEIDENTIFIER NOT NULL,
    LocationCode NVARCHAR(50) NULL,
    LocationName NVARCHAR(200) NOT NULL,
    AddressLine1 NVARCHAR(200) NULL,
    AddressLine2 NVARCHAR(200) NULL,
    City NVARCHAR(100) NULL,
    StateProvince NVARCHAR(100) NULL,
    PostalCode NVARCHAR(30) NULL,
    CountryCode NVARCHAR(10) NULL,
    Latitude DECIMAL(9,6) NULL,
    Longitude DECIMAL(9,6) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Location_IsActive DEFAULT (1),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Location_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Location_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Location_Organization FOREIGN KEY (OrganizationId) REFERENCES ref.Organization (OrganizationId)
);
GO

CREATE TABLE cfg.TenantSchemaRegistry (
    TenantSchemaRegistryId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_TenantSchemaRegistry PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    SchemaPurpose NVARCHAR(50) NOT NULL,
    SchemaName NVARCHAR(128) NOT NULL,
    TablePrefix NVARCHAR(50) NULL,
    IsProvisioned BIT NOT NULL CONSTRAINT DF_TenantSchemaRegistry_IsProvisioned DEFAULT (0),
    ProvisionedAt DATETIME2(0) NULL,
    Notes NVARCHAR(500) NULL,
    CONSTRAINT FK_TenantSchemaRegistry_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT UQ_TenantSchemaRegistry UNIQUE (TenantId, SchemaPurpose, SchemaName)
);
GO

CREATE TABLE sec.[User] (
    UserId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_User PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrganizationId UNIQUEIDENTIFIER NULL,
    UserName NVARCHAR(100) NOT NULL,
    DisplayName NVARCHAR(200) NOT NULL,
    Email NVARCHAR(256) NOT NULL,
    PhoneNumber NVARCHAR(50) NULL,
    PersonaType NVARCHAR(50) NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_User_Status DEFAULT ('Active'),
    PasswordHash NVARCHAR(500) NULL,
    LastLoginAt DATETIME2(0) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_User_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt DATETIME2(0) NULL,
    CONSTRAINT FK_User_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_User_Organization FOREIGN KEY (OrganizationId) REFERENCES ref.Organization (OrganizationId),
    CONSTRAINT UQ_User_Tenant_UserName UNIQUE (TenantId, UserName),
    CONSTRAINT UQ_User_Tenant_Email UNIQUE (TenantId, Email)
);
GO

CREATE TABLE sec.Role (
    RoleId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Role PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    RoleCode NVARCHAR(50) NOT NULL,
    RoleName NVARCHAR(150) NOT NULL,
    IsSystemRole BIT NOT NULL CONSTRAINT DF_Role_IsSystemRole DEFAULT (0),
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_Role_Status DEFAULT ('Active'),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Role_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Role_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT UQ_Role_Tenant_RoleCode UNIQUE (TenantId, RoleCode)
);
GO

CREATE TABLE sec.Permission (
    PermissionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Permission PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    PermissionCode NVARCHAR(100) NOT NULL,
    PermissionName NVARCHAR(200) NOT NULL,
    ModuleName NVARCHAR(100) NULL,
    Description NVARCHAR(500) NULL,
    CONSTRAINT UQ_Permission_Code UNIQUE (PermissionCode)
);
GO

CREATE TABLE sec.RolePermission (
    RolePermissionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_RolePermission PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    RoleId UNIQUEIDENTIFIER NOT NULL,
    PermissionId UNIQUEIDENTIFIER NOT NULL,
    GrantType NVARCHAR(20) NOT NULL CONSTRAINT DF_RolePermission_GrantType DEFAULT ('Allow'),
    CONSTRAINT FK_RolePermission_Role FOREIGN KEY (RoleId) REFERENCES sec.Role (RoleId),
    CONSTRAINT FK_RolePermission_Permission FOREIGN KEY (PermissionId) REFERENCES sec.Permission (PermissionId),
    CONSTRAINT UQ_RolePermission UNIQUE (RoleId, PermissionId)
);
GO

CREATE TABLE sec.UserRole (
    UserRoleId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_UserRole PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    RoleId UNIQUEIDENTIFIER NOT NULL,
    AssignedAt DATETIME2(0) NOT NULL CONSTRAINT DF_UserRole_AssignedAt DEFAULT (SYSUTCDATETIME()),
    AssignedByUserId UNIQUEIDENTIFIER NULL,
    CONSTRAINT FK_UserRole_User FOREIGN KEY (UserId) REFERENCES sec.[User] (UserId),
    CONSTRAINT FK_UserRole_Role FOREIGN KEY (RoleId) REFERENCES sec.Role (RoleId),
    CONSTRAINT FK_UserRole_AssignedBy FOREIGN KEY (AssignedByUserId) REFERENCES sec.[User] (UserId),
    CONSTRAINT UQ_UserRole UNIQUE (UserId, RoleId)
);
GO

CREATE TABLE sec.UserPermission (
    UserPermissionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_UserPermission PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    PermissionId UNIQUEIDENTIFIER NOT NULL,
    GrantType NVARCHAR(20) NOT NULL,
    EffectiveFrom DATETIME2(0) NULL,
    EffectiveTo DATETIME2(0) NULL,
    CONSTRAINT FK_UserPermission_User FOREIGN KEY (UserId) REFERENCES sec.[User] (UserId),
    CONSTRAINT FK_UserPermission_Permission FOREIGN KEY (PermissionId) REFERENCES sec.Permission (PermissionId),
    CONSTRAINT UQ_UserPermission UNIQUE (UserId, PermissionId)
);
GO

CREATE TABLE cfg.TenantFieldConfig (
    TenantFieldConfigId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_TenantFieldConfig PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    EntityName NVARCHAR(100) NOT NULL,
    SystemFieldName NVARCHAR(100) NOT NULL,
    DisplayName NVARCHAR(200) NOT NULL,
    IsVisible BIT NOT NULL CONSTRAINT DF_TenantFieldConfig_IsVisible DEFAULT (1),
    IsRequired BIT NOT NULL CONSTRAINT DF_TenantFieldConfig_IsRequired DEFAULT (0),
    DisplayOrder INT NULL,
    HelpText NVARCHAR(500) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_TenantFieldConfig_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_TenantFieldConfig_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT UQ_TenantFieldConfig UNIQUE (TenantId, EntityName, SystemFieldName)
);
GO

CREATE TABLE cfg.TenantCustomField (
    TenantCustomFieldId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_TenantCustomField PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    EntityName NVARCHAR(100) NOT NULL,
    FieldName NVARCHAR(100) NOT NULL,
    DisplayName NVARCHAR(200) NOT NULL,
    DataType NVARCHAR(50) NOT NULL,
    DefaultValue NVARCHAR(500) NULL,
    ValidationRule NVARCHAR(1000) NULL,
    IsRequired BIT NOT NULL CONSTRAINT DF_TenantCustomField_IsRequired DEFAULT (0),
    IsSearchable BIT NOT NULL CONSTRAINT DF_TenantCustomField_IsSearchable DEFAULT (0),
    IsActive BIT NOT NULL CONSTRAINT DF_TenantCustomField_IsActive DEFAULT (1),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_TenantCustomField_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_TenantCustomField_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT UQ_TenantCustomField UNIQUE (TenantId, EntityName, FieldName)
);
GO

CREATE TABLE cfg.CustomFieldValue (
    CustomFieldValueId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_CustomFieldValue PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantCustomFieldId UNIQUEIDENTIFIER NOT NULL,
    TenantId UNIQUEIDENTIFIER NOT NULL,
    RelatedEntityType NVARCHAR(100) NOT NULL,
    RelatedEntityId UNIQUEIDENTIFIER NOT NULL,
    FieldValue NVARCHAR(MAX) NULL,
    ValueNumber DECIMAL(18,4) NULL,
    ValueDate DATETIME2(0) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_CustomFieldValue_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt DATETIME2(0) NULL,
    CONSTRAINT FK_CustomFieldValue_CustomField FOREIGN KEY (TenantCustomFieldId) REFERENCES cfg.TenantCustomField (TenantCustomFieldId),
    CONSTRAINT FK_CustomFieldValue_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId)
);
GO

CREATE TABLE ing.IngestionSource (
    IngestionSourceId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_IngestionSource PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    SourceCode NVARCHAR(50) NOT NULL,
    SourceName NVARCHAR(150) NOT NULL,
    SourceType NVARCHAR(50) NOT NULL,
    Description NVARCHAR(500) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_IngestionSource_IsActive DEFAULT (1),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_IngestionSource_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_IngestionSource_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT UQ_IngestionSource UNIQUE (TenantId, SourceCode)
);
GO

CREATE TABLE ing.IngestionEndpoint (
    IngestionEndpointId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_IngestionEndpoint PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    IngestionSourceId UNIQUEIDENTIFIER NOT NULL,
    EndpointName NVARCHAR(150) NOT NULL,
    ChannelType NVARCHAR(50) NOT NULL,
    EndpointUri NVARCHAR(500) NULL,
    IncomingPath NVARCHAR(500) NULL,
    ProcessedPath NVARCHAR(500) NULL,
    ErrorPath NVARCHAR(500) NULL,
    FilePattern NVARCHAR(200) NULL,
    PollingIntervalMinutes INT NULL,
    ConnectionMetadata NVARCHAR(MAX) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_IngestionEndpoint_IsActive DEFAULT (1),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_IngestionEndpoint_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_IngestionEndpoint_Source FOREIGN KEY (IngestionSourceId) REFERENCES ing.IngestionSource (IngestionSourceId)
);
GO

CREATE TABLE ing.IngestionJob (
    IngestionJobId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_IngestionJob PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    IngestionSourceId UNIQUEIDENTIFIER NOT NULL,
    IngestionEndpointId UNIQUEIDENTIFIER NULL,
    JobType NVARCHAR(50) NOT NULL,
    TriggerType NVARCHAR(50) NOT NULL,
    RequestedByUserId UNIQUEIDENTIFIER NULL,
    JobStatus NVARCHAR(30) NOT NULL,
    ScheduledFor DATETIME2(0) NULL,
    StartedAt DATETIME2(0) NULL,
    CompletedAt DATETIME2(0) NULL,
    SummaryMessage NVARCHAR(1000) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_IngestionJob_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_IngestionJob_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_IngestionJob_Source FOREIGN KEY (IngestionSourceId) REFERENCES ing.IngestionSource (IngestionSourceId),
    CONSTRAINT FK_IngestionJob_Endpoint FOREIGN KEY (IngestionEndpointId) REFERENCES ing.IngestionEndpoint (IngestionEndpointId),
    CONSTRAINT FK_IngestionJob_RequestedBy FOREIGN KEY (RequestedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE ing.SourceFile (
    SourceFileId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_SourceFile PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    IngestionJobId UNIQUEIDENTIFIER NULL,
    IngestionSourceId UNIQUEIDENTIFIER NOT NULL,
    IngestionEndpointId UNIQUEIDENTIFIER NULL,
    SourceSystem NVARCHAR(100) NULL,
    SourceChannel NVARCHAR(50) NULL,
    SourceLocation NVARCHAR(500) NULL,
    SourceFileName NVARCHAR(260) NOT NULL,
    SourceFileType NVARCHAR(20) NULL,
    FileHash NVARCHAR(256) NULL,
    FileSizeBytes BIGINT NULL,
    SourceReceivedAt DATETIME2(0) NULL,
    ProcessingStatus NVARCHAR(30) NOT NULL,
    ProcessingMessage NVARCHAR(1000) NULL,
    ProcessedAt DATETIME2(0) NULL,
    ArchivedLocation NVARCHAR(500) NULL,
    IsDuplicate BIT NOT NULL CONSTRAINT DF_SourceFile_IsDuplicate DEFAULT (0),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_SourceFile_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_SourceFile_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_SourceFile_Job FOREIGN KEY (IngestionJobId) REFERENCES ing.IngestionJob (IngestionJobId),
    CONSTRAINT FK_SourceFile_Source FOREIGN KEY (IngestionSourceId) REFERENCES ing.IngestionSource (IngestionSourceId),
    CONSTRAINT FK_SourceFile_Endpoint FOREIGN KEY (IngestionEndpointId) REFERENCES ing.IngestionEndpoint (IngestionEndpointId)
);
GO

CREATE TABLE ing.FileProcessingEvent (
    FileProcessingEventId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_FileProcessingEvent PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    SourceFileId UNIQUEIDENTIFIER NOT NULL,
    EventType NVARCHAR(50) NOT NULL,
    EventStatus NVARCHAR(30) NOT NULL,
    EventMessage NVARCHAR(1000) NULL,
    EventAt DATETIME2(0) NOT NULL CONSTRAINT DF_FileProcessingEvent_EventAt DEFAULT (SYSUTCDATETIME()),
    PerformedByUserId UNIQUEIDENTIFIER NULL,
    EventData NVARCHAR(MAX) NULL,
    CONSTRAINT FK_FileProcessingEvent_SourceFile FOREIGN KEY (SourceFileId) REFERENCES ing.SourceFile (SourceFileId),
    CONSTRAINT FK_FileProcessingEvent_User FOREIGN KEY (PerformedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE ing.TemplateSchema (
    TemplateSchemaId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_TemplateSchema PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NULL,
    TemplateCode NVARCHAR(50) NOT NULL,
    TemplateName NVARCHAR(200) NOT NULL,
    TemplateVersion NVARCHAR(50) NOT NULL,
    SchemaType NVARCHAR(50) NOT NULL,
    EntityTarget NVARCHAR(100) NULL,
    ExpectedFileType NVARCHAR(20) NULL,
    IsSystemTemplate BIT NOT NULL CONSTRAINT DF_TemplateSchema_IsSystemTemplate DEFAULT (0),
    IsActive BIT NOT NULL CONSTRAINT DF_TemplateSchema_IsActive DEFAULT (1),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_TemplateSchema_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_TemplateSchema_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId)
);
GO

CREATE TABLE ing.TemplateColumnDefinition (
    TemplateColumnDefinitionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_TemplateColumnDefinition PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TemplateSchemaId UNIQUEIDENTIFIER NOT NULL,
    ColumnName NVARCHAR(128) NOT NULL,
    DataType NVARCHAR(50) NULL,
    IsRequired BIT NOT NULL CONSTRAINT DF_TemplateColumnDefinition_IsRequired DEFAULT (0),
    MaxLength INT NULL,
    SortOrder INT NULL,
    ValidationRule NVARCHAR(1000) NULL,
    CONSTRAINT FK_TemplateColumnDefinition_Template FOREIGN KEY (TemplateSchemaId) REFERENCES ing.TemplateSchema (TemplateSchemaId)
);
GO

CREATE TABLE ing.SchemaValidationResult (
    SchemaValidationResultId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_SchemaValidationResult PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    SourceFileId UNIQUEIDENTIFIER NOT NULL,
    TemplateSchemaId UNIQUEIDENTIFIER NULL,
    SchemaMatchStatus NVARCHAR(30) NOT NULL,
    DetectedColumns NVARCHAR(MAX) NULL,
    ValidationMessage NVARCHAR(2000) NULL,
    WarningCount INT NOT NULL CONSTRAINT DF_SchemaValidationResult_WarningCount DEFAULT (0),
    ErrorCount INT NOT NULL CONSTRAINT DF_SchemaValidationResult_ErrorCount DEFAULT (0),
    ValidatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_SchemaValidationResult_ValidatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_SchemaValidationResult_SourceFile FOREIGN KEY (SourceFileId) REFERENCES ing.SourceFile (SourceFileId),
    CONSTRAINT FK_SchemaValidationResult_Template FOREIGN KEY (TemplateSchemaId) REFERENCES ing.TemplateSchema (TemplateSchemaId)
);
GO

CREATE TABLE ing.StagingSchemaDefinition (
    StagingSchemaDefinitionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_StagingSchemaDefinition PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    SchemaCode NVARCHAR(50) NOT NULL,
    SchemaName NVARCHAR(200) NOT NULL,
    SchemaVersion NVARCHAR(50) NOT NULL,
    EntityTarget NVARCHAR(100) NOT NULL,
    PhysicalSchemaName NVARCHAR(128) NULL,
    PhysicalTableName NVARCHAR(128) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_StagingSchemaDefinition_IsActive DEFAULT (1),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_StagingSchemaDefinition_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_StagingSchemaDefinition_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT UQ_StagingSchemaDefinition UNIQUE (TenantId, SchemaCode, SchemaVersion)
);
GO

CREATE TABLE ing.StagingColumnDefinition (
    StagingColumnDefinitionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_StagingColumnDefinition PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    StagingSchemaDefinitionId UNIQUEIDENTIFIER NOT NULL,
    ColumnName NVARCHAR(128) NOT NULL,
    DataType NVARCHAR(50) NOT NULL,
    IsRequired BIT NOT NULL CONSTRAINT DF_StagingColumnDefinition_IsRequired DEFAULT (0),
    MaxLength INT NULL,
    AllowNull BIT NOT NULL CONSTRAINT DF_StagingColumnDefinition_AllowNull DEFAULT (1),
    CodeSetName NVARCHAR(100) NULL,
    SortOrder INT NULL,
    CONSTRAINT FK_StagingColumnDefinition_StagingSchema FOREIGN KEY (StagingSchemaDefinitionId) REFERENCES ing.StagingSchemaDefinition (StagingSchemaDefinitionId)
);
GO

CREATE TABLE ing.StagingValidationRun (
    StagingValidationRunId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_StagingValidationRun PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    SourceFileId UNIQUEIDENTIFIER NOT NULL,
    StagingSchemaDefinitionId UNIQUEIDENTIFIER NOT NULL,
    ValidationMode NVARCHAR(20) NOT NULL,
    ValidationStatus NVARCHAR(30) NOT NULL,
    ErrorCount INT NOT NULL CONSTRAINT DF_StagingValidationRun_ErrorCount DEFAULT (0),
    WarningCount INT NOT NULL CONSTRAINT DF_StagingValidationRun_WarningCount DEFAULT (0),
    ValidationReport NVARCHAR(MAX) NULL,
    ValidatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_StagingValidationRun_ValidatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_StagingValidationRun_SourceFile FOREIGN KEY (SourceFileId) REFERENCES ing.SourceFile (SourceFileId),
    CONSTRAINT FK_StagingValidationRun_StagingSchema FOREIGN KEY (StagingSchemaDefinitionId) REFERENCES ing.StagingSchemaDefinition (StagingSchemaDefinitionId)
);
GO

CREATE TABLE ing.StagingValidationIssue (
    StagingValidationIssueId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_StagingValidationIssue PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    StagingValidationRunId UNIQUEIDENTIFIER NOT NULL,
    IssueLevel NVARCHAR(20) NOT NULL,
    RowNumber INT NULL,
    ColumnName NVARCHAR(128) NULL,
    IssueCode NVARCHAR(50) NULL,
    IssueMessage NVARCHAR(1000) NOT NULL,
    SuggestedResolution NVARCHAR(1000) NULL,
    CONSTRAINT FK_StagingValidationIssue_Run FOREIGN KEY (StagingValidationRunId) REFERENCES ing.StagingValidationRun (StagingValidationRunId)
);
GO

CREATE TABLE ing.MappingRule (
    MappingRuleId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_MappingRule PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    IngestionSourceId UNIQUEIDENTIFIER NULL,
    TemplateSchemaId UNIQUEIDENTIFIER NULL,
    StagingSchemaDefinitionId UNIQUEIDENTIFIER NULL,
    SourceColumnName NVARCHAR(128) NOT NULL,
    TargetColumnName NVARCHAR(128) NOT NULL,
    MappingRuleSource NVARCHAR(50) NOT NULL,
    IsApproved BIT NOT NULL CONSTRAINT DF_MappingRule_IsApproved DEFAULT (0),
    ApprovedByUserId UNIQUEIDENTIFIER NULL,
    ApprovedAt DATETIME2(0) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_MappingRule_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_MappingRule_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_MappingRule_Source FOREIGN KEY (IngestionSourceId) REFERENCES ing.IngestionSource (IngestionSourceId),
    CONSTRAINT FK_MappingRule_Template FOREIGN KEY (TemplateSchemaId) REFERENCES ing.TemplateSchema (TemplateSchemaId),
    CONSTRAINT FK_MappingRule_StagingSchema FOREIGN KEY (StagingSchemaDefinitionId) REFERENCES ing.StagingSchemaDefinition (StagingSchemaDefinitionId),
    CONSTRAINT FK_MappingRule_ApprovedBy FOREIGN KEY (ApprovedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE ing.MappingSuggestion (
    MappingSuggestionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_MappingSuggestion PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    SourceFileId UNIQUEIDENTIFIER NOT NULL,
    StagingSchemaDefinitionId UNIQUEIDENTIFIER NOT NULL,
    SourceColumnName NVARCHAR(128) NOT NULL,
    SuggestedTargetColumn NVARCHAR(128) NULL,
    ConfidenceScore DECIMAL(5,2) NULL,
    MappingRationale NVARCHAR(1000) NULL,
    AmbiguityFlag BIT NOT NULL CONSTRAINT DF_MappingSuggestion_AmbiguityFlag DEFAULT (0),
    SuggestedAt DATETIME2(0) NOT NULL CONSTRAINT DF_MappingSuggestion_SuggestedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_MappingSuggestion_SourceFile FOREIGN KEY (SourceFileId) REFERENCES ing.SourceFile (SourceFileId),
    CONSTRAINT FK_MappingSuggestion_StagingSchema FOREIGN KEY (StagingSchemaDefinitionId) REFERENCES ing.StagingSchemaDefinition (StagingSchemaDefinitionId)
);
GO

CREATE TABLE ing.MappingDecision (
    MappingDecisionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_MappingDecision PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    MappingSuggestionId UNIQUEIDENTIFIER NOT NULL,
    DecisionStatus NVARCHAR(20) NOT NULL,
    FinalTargetColumn NVARCHAR(128) NULL,
    DecidedByUserId UNIQUEIDENTIFIER NULL,
    DecidedAt DATETIME2(0) NOT NULL CONSTRAINT DF_MappingDecision_DecidedAt DEFAULT (SYSUTCDATETIME()),
    DecisionNotes NVARCHAR(1000) NULL,
    CONSTRAINT FK_MappingDecision_Suggestion FOREIGN KEY (MappingSuggestionId) REFERENCES ing.MappingSuggestion (MappingSuggestionId),
    CONSTRAINT FK_MappingDecision_User FOREIGN KEY (DecidedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE core.Policy (
    PolicyId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Policy PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrganizationId UNIQUEIDENTIFIER NOT NULL,
    PolicyNumber NVARCHAR(100) NOT NULL,
    PolicyType NVARCHAR(100) NULL,
    CarrierName NVARCHAR(200) NULL,
    EffectiveDate DATE NULL,
    ExpirationDate DATE NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_Policy_Status DEFAULT ('Active'),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Policy_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt DATETIME2(0) NULL,
    CONSTRAINT FK_Policy_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Policy_Organization FOREIGN KEY (OrganizationId) REFERENCES ref.Organization (OrganizationId),
    CONSTRAINT UQ_Policy_Tenant_PolicyNumber UNIQUE (TenantId, PolicyNumber)
);
GO

CREATE TABLE core.Coverage (
    CoverageId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Coverage PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    PolicyId UNIQUEIDENTIFIER NOT NULL,
    CoverageType NVARCHAR(100) NOT NULL,
    LimitAmount DECIMAL(18,2) NULL,
    DeductibleAmount DECIMAL(18,2) NULL,
    AttachmentPointAmount DECIMAL(18,2) NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_Coverage_Status DEFAULT ('Active'),
    CONSTRAINT FK_Coverage_Policy FOREIGN KEY (PolicyId) REFERENCES core.Policy (PolicyId)
);
GO

CREATE TABLE core.Exposure (
    ExposureId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Exposure PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    PolicyId UNIQUEIDENTIFIER NOT NULL,
    ExposureType NVARCHAR(100) NOT NULL,
    ExposureValue DECIMAL(18,2) NULL,
    Units NVARCHAR(50) NULL,
    EffectiveFrom DATE NULL,
    EffectiveTo DATE NULL,
    CONSTRAINT FK_Exposure_Policy FOREIGN KEY (PolicyId) REFERENCES core.Policy (PolicyId)
);
GO

CREATE TABLE core.Incident (
    IncidentId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Incident PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrganizationId UNIQUEIDENTIFIER NOT NULL,
    LocationId UNIQUEIDENTIFIER NULL,
    IncidentNumber NVARCHAR(100) NOT NULL,
    IncidentDate DATE NULL,
    ReportedDate DATE NULL,
    IncidentType NVARCHAR(100) NULL,
    Status NVARCHAR(30) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    RootCause NVARCHAR(500) NULL,
    SeverityLevel NVARCHAR(50) NULL,
    CreatedByUserId UNIQUEIDENTIFIER NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Incident_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt DATETIME2(0) NULL,
    CONSTRAINT FK_Incident_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Incident_Organization FOREIGN KEY (OrganizationId) REFERENCES ref.Organization (OrganizationId),
    CONSTRAINT FK_Incident_Location FOREIGN KEY (LocationId) REFERENCES ref.Location (LocationId),
    CONSTRAINT FK_Incident_CreatedBy FOREIGN KEY (CreatedByUserId) REFERENCES sec.[User] (UserId),
    CONSTRAINT UQ_Incident_Tenant_IncidentNumber UNIQUE (TenantId, IncidentNumber)
);
GO

CREATE TABLE core.Claimant (
    ClaimantId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Claimant PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrganizationId UNIQUEIDENTIFIER NULL,
    ClaimantType NVARCHAR(50) NULL,
    FirstName NVARCHAR(100) NULL,
    LastName NVARCHAR(100) NULL,
    FullName NVARCHAR(200) NOT NULL,
    Email NVARCHAR(256) NULL,
    PhoneNumber NVARCHAR(50) NULL,
    EmployeeId NVARCHAR(50) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Claimant_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Claimant_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Claimant_Organization FOREIGN KEY (OrganizationId) REFERENCES ref.Organization (OrganizationId)
);
GO

CREATE TABLE core.Claim (
    ClaimId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Claim PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrganizationId UNIQUEIDENTIFIER NOT NULL,
    LocationId UNIQUEIDENTIFIER NULL,
    PolicyId UNIQUEIDENTIFIER NULL,
    IncidentId UNIQUEIDENTIFIER NULL,
    ClaimantId UNIQUEIDENTIFIER NULL,
    ClaimNumber NVARCHAR(100) NOT NULL,
    ClaimType NVARCHAR(100) NULL,
    Status NVARCHAR(30) NOT NULL,
    LossDate DATE NULL,
    ReportedDate DATE NULL,
    Description NVARCHAR(MAX) NULL,
    CauseDescription NVARCHAR(500) NULL,
    CurrentReserveAmount DECIMAL(18,2) NULL,
    TotalPaidAmount DECIMAL(18,2) NULL,
    AssignedUserId UNIQUEIDENTIFIER NULL,
    CreatedByUserId UNIQUEIDENTIFIER NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Claim_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt DATETIME2(0) NULL,
    ClosedAt DATETIME2(0) NULL,
    CONSTRAINT FK_Claim_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Claim_Organization FOREIGN KEY (OrganizationId) REFERENCES ref.Organization (OrganizationId),
    CONSTRAINT FK_Claim_Location FOREIGN KEY (LocationId) REFERENCES ref.Location (LocationId),
    CONSTRAINT FK_Claim_Policy FOREIGN KEY (PolicyId) REFERENCES core.Policy (PolicyId),
    CONSTRAINT FK_Claim_Incident FOREIGN KEY (IncidentId) REFERENCES core.Incident (IncidentId),
    CONSTRAINT FK_Claim_Claimant FOREIGN KEY (ClaimantId) REFERENCES core.Claimant (ClaimantId),
    CONSTRAINT FK_Claim_AssignedUser FOREIGN KEY (AssignedUserId) REFERENCES sec.[User] (UserId),
    CONSTRAINT FK_Claim_CreatedBy FOREIGN KEY (CreatedByUserId) REFERENCES sec.[User] (UserId),
    CONSTRAINT UQ_Claim_Tenant_ClaimNumber UNIQUE (TenantId, ClaimNumber)
);
GO

CREATE TABLE core.Document (
    DocumentId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Document PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    SourceFileId UNIQUEIDENTIFIER NULL,
    SourceType NVARCHAR(50) NULL,
    FileName NVARCHAR(260) NOT NULL,
    OriginalPath NVARCHAR(500) NULL,
    StoredPath NVARCHAR(500) NULL,
    MimeType NVARCHAR(100) NULL,
    FileSizeBytes BIGINT NULL,
    UploadedByUserId UNIQUEIDENTIFIER NULL,
    UploadedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Document_UploadedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Document_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Document_SourceFile FOREIGN KEY (SourceFileId) REFERENCES ing.SourceFile (SourceFileId),
    CONSTRAINT FK_Document_UploadedBy FOREIGN KEY (UploadedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE core.ClaimDocument (
    ClaimDocumentId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ClaimDocument PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    ClaimId UNIQUEIDENTIFIER NOT NULL,
    DocumentId UNIQUEIDENTIFIER NOT NULL,
    DocumentCategory NVARCHAR(100) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_ClaimDocument_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_ClaimDocument_Claim FOREIGN KEY (ClaimId) REFERENCES core.Claim (ClaimId),
    CONSTRAINT FK_ClaimDocument_Document FOREIGN KEY (DocumentId) REFERENCES core.Document (DocumentId),
    CONSTRAINT UQ_ClaimDocument UNIQUE (ClaimId, DocumentId)
);
GO

CREATE TABLE core.IncidentDocument (
    IncidentDocumentId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_IncidentDocument PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    IncidentId UNIQUEIDENTIFIER NOT NULL,
    DocumentId UNIQUEIDENTIFIER NOT NULL,
    DocumentCategory NVARCHAR(100) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_IncidentDocument_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_IncidentDocument_Incident FOREIGN KEY (IncidentId) REFERENCES core.Incident (IncidentId),
    CONSTRAINT FK_IncidentDocument_Document FOREIGN KEY (DocumentId) REFERENCES core.Document (DocumentId),
    CONSTRAINT UQ_IncidentDocument UNIQUE (IncidentId, DocumentId)
);
GO

CREATE TABLE core.Note (
    NoteId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Note PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    ClaimId UNIQUEIDENTIFIER NULL,
    IncidentId UNIQUEIDENTIFIER NULL,
    CreatedByUserId UNIQUEIDENTIFIER NOT NULL,
    NoteType NVARCHAR(50) NULL,
    NoteText NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Note_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Note_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Note_Claim FOREIGN KEY (ClaimId) REFERENCES core.Claim (ClaimId),
    CONSTRAINT FK_Note_Incident FOREIGN KEY (IncidentId) REFERENCES core.Incident (IncidentId),
    CONSTRAINT FK_Note_User FOREIGN KEY (CreatedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE core.Reserve (
    ReserveId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Reserve PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    ClaimId UNIQUEIDENTIFIER NOT NULL,
    ReserveType NVARCHAR(100) NOT NULL,
    CurrentReserveAmount DECIMAL(18,2) NOT NULL,
    CurrencyCode CHAR(3) NULL,
    LastUpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Reserve_LastUpdatedAt DEFAULT (SYSUTCDATETIME()),
    LastUpdatedByUserId UNIQUEIDENTIFIER NULL,
    CONSTRAINT FK_Reserve_Claim FOREIGN KEY (ClaimId) REFERENCES core.Claim (ClaimId),
    CONSTRAINT FK_Reserve_LastUpdatedBy FOREIGN KEY (LastUpdatedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE core.ReserveTransaction (
    ReserveTransactionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ReserveTransaction PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    ReserveId UNIQUEIDENTIFIER NOT NULL,
    ClaimId UNIQUEIDENTIFIER NOT NULL,
    TransactionType NVARCHAR(50) NOT NULL,
    TransactionAmount DECIMAL(18,2) NOT NULL,
    PreviousReserveAmount DECIMAL(18,2) NULL,
    NewReserveAmount DECIMAL(18,2) NULL,
    EffectiveDate DATE NULL,
    EnteredByUserId UNIQUEIDENTIFIER NULL,
    EnteredAt DATETIME2(0) NOT NULL CONSTRAINT DF_ReserveTransaction_EnteredAt DEFAULT (SYSUTCDATETIME()),
    Notes NVARCHAR(1000) NULL,
    CONSTRAINT FK_ReserveTransaction_Reserve FOREIGN KEY (ReserveId) REFERENCES core.Reserve (ReserveId),
    CONSTRAINT FK_ReserveTransaction_Claim FOREIGN KEY (ClaimId) REFERENCES core.Claim (ClaimId),
    CONSTRAINT FK_ReserveTransaction_User FOREIGN KEY (EnteredByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE core.Payment (
    PaymentId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Payment PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    ClaimId UNIQUEIDENTIFIER NOT NULL,
    PaymentType NVARCHAR(100) NULL,
    PaymentStatus NVARCHAR(30) NOT NULL,
    PaymentAmount DECIMAL(18,2) NOT NULL,
    PaymentDate DATE NULL,
    PayeeName NVARCHAR(200) NULL,
    ReferenceNumber NVARCHAR(100) NULL,
    EnteredByUserId UNIQUEIDENTIFIER NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Payment_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Payment_Claim FOREIGN KEY (ClaimId) REFERENCES core.Claim (ClaimId),
    CONSTRAINT FK_Payment_User FOREIGN KEY (EnteredByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE core.OshaCase (
    OshaCaseId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_OshaCase PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    IncidentId UNIQUEIDENTIFIER NOT NULL,
    CaseNumber NVARCHAR(100) NOT NULL,
    EstablishmentName NVARCHAR(200) NULL,
    RecordableFlag BIT NOT NULL CONSTRAINT DF_OshaCase_RecordableFlag DEFAULT (0),
    AwayFromWorkDays INT NULL,
    RestrictedDutyDays INT NULL,
    InjuryType NVARCHAR(100) NULL,
    PrivacyCaseFlag BIT NOT NULL CONSTRAINT DF_OshaCase_PrivacyCaseFlag DEFAULT (0),
    ReportYear INT NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_OshaCase_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_OshaCase_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_OshaCase_Incident FOREIGN KEY (IncidentId) REFERENCES core.Incident (IncidentId),
    CONSTRAINT UQ_OshaCase_Tenant_CaseNumber UNIQUE (TenantId, CaseNumber)
);
GO

CREATE TABLE ai.ExtractionResult (
    ExtractionResultId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ExtractionResult PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    DocumentId UNIQUEIDENTIFIER NOT NULL,
    ModelName NVARCHAR(150) NOT NULL,
    ModelVersion NVARCHAR(50) NULL,
    ConfidenceScore DECIMAL(5,2) NULL,
    ClassificationLabel NVARCHAR(100) NULL,
    ExtractedAt DATETIME2(0) NOT NULL CONSTRAINT DF_ExtractionResult_ExtractedAt DEFAULT (SYSUTCDATETIME()),
    RawOutputJson NVARCHAR(MAX) NULL,
    CONSTRAINT FK_ExtractionResult_Document FOREIGN KEY (DocumentId) REFERENCES core.Document (DocumentId)
);
GO

CREATE TABLE ai.ExtractedField (
    ExtractedFieldId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ExtractedField PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    ExtractionResultId UNIQUEIDENTIFIER NOT NULL,
    FieldName NVARCHAR(128) NOT NULL,
    FieldValue NVARCHAR(MAX) NULL,
    NormalizedValue NVARCHAR(MAX) NULL,
    ConfidenceScore DECIMAL(5,2) NULL,
    SourcePageNumber INT NULL,
    SourceCoordinates NVARCHAR(200) NULL,
    CONSTRAINT FK_ExtractedField_ExtractionResult FOREIGN KEY (ExtractionResultId) REFERENCES ai.ExtractionResult (ExtractionResultId)
);
GO

CREATE TABLE ai.AIReview (
    AIReviewId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_AIReview PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    DocumentId UNIQUEIDENTIFIER NULL,
    ClaimId UNIQUEIDENTIFIER NULL,
    IncidentId UNIQUEIDENTIFIER NULL,
    ReviewType NVARCHAR(100) NOT NULL,
    Summary NVARCHAR(MAX) NULL,
    Recommendation NVARCHAR(MAX) NULL,
    ConfidenceScore DECIMAL(5,2) NULL,
    MissingDataFlag BIT NOT NULL CONSTRAINT DF_AIReview_MissingDataFlag DEFAULT (0),
    AnomalyFlag BIT NOT NULL CONSTRAINT DF_AIReview_AnomalyFlag DEFAULT (0),
    ReviewedAt DATETIME2(0) NOT NULL CONSTRAINT DF_AIReview_ReviewedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_AIReview_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_AIReview_Document FOREIGN KEY (DocumentId) REFERENCES core.Document (DocumentId),
    CONSTRAINT FK_AIReview_Claim FOREIGN KEY (ClaimId) REFERENCES core.Claim (ClaimId),
    CONSTRAINT FK_AIReview_Incident FOREIGN KEY (IncidentId) REFERENCES core.Incident (IncidentId)
);
GO

CREATE TABLE ai.RiskScore (
    RiskScoreId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_RiskScore PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    RelatedEntityType NVARCHAR(100) NOT NULL,
    RelatedEntityId UNIQUEIDENTIFIER NOT NULL,
    ScoreType NVARCHAR(50) NOT NULL,
    ScoreValue DECIMAL(9,4) NOT NULL,
    RiskBand NVARCHAR(30) NULL,
    ModelName NVARCHAR(150) NULL,
    ModelVersion NVARCHAR(50) NULL,
    ScoreReason NVARCHAR(1000) NULL,
    ScoredAt DATETIME2(0) NOT NULL CONSTRAINT DF_RiskScore_ScoredAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_RiskScore_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId)
);
GO

CREATE TABLE ai.Recommendation (
    RecommendationId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Recommendation PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    RelatedEntityType NVARCHAR(100) NOT NULL,
    RelatedEntityId UNIQUEIDENTIFIER NOT NULL,
    RecommendationType NVARCHAR(100) NOT NULL,
    RecommendationText NVARCHAR(MAX) NOT NULL,
    PriorityLevel NVARCHAR(30) NULL,
    GeneratedBy NVARCHAR(100) NULL,
    GeneratedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Recommendation_GeneratedAt DEFAULT (SYSUTCDATETIME()),
    AcceptedByUserId UNIQUEIDENTIFIER NULL,
    AcceptedAt DATETIME2(0) NULL,
    CONSTRAINT FK_Recommendation_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Recommendation_AcceptedBy FOREIGN KEY (AcceptedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE wf.WorkflowDefinition (
    WorkflowDefinitionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_WorkflowDefinition PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    WorkflowCode NVARCHAR(50) NOT NULL,
    WorkflowName NVARCHAR(200) NOT NULL,
    EntityType NVARCHAR(100) NOT NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_WorkflowDefinition_Status DEFAULT ('Active'),
    DefinitionJson NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_WorkflowDefinition_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_WorkflowDefinition_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT UQ_WorkflowDefinition UNIQUE (TenantId, WorkflowCode)
);
GO

CREATE TABLE wf.WorkflowStep (
    WorkflowStepId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_WorkflowStep PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    WorkflowDefinitionId UNIQUEIDENTIFIER NOT NULL,
    StepCode NVARCHAR(50) NOT NULL,
    StepName NVARCHAR(200) NOT NULL,
    StepOrder INT NOT NULL,
    StepType NVARCHAR(50) NULL,
    AssignedRoleCode NVARCHAR(50) NULL,
    SlaHours INT NULL,
    RuleExpression NVARCHAR(MAX) NULL,
    CONSTRAINT FK_WorkflowStep_Definition FOREIGN KEY (WorkflowDefinitionId) REFERENCES wf.WorkflowDefinition (WorkflowDefinitionId),
    CONSTRAINT UQ_WorkflowStep UNIQUE (WorkflowDefinitionId, StepCode)
);
GO

CREATE TABLE wf.Task (
    TaskId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Task PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    WorkflowDefinitionId UNIQUEIDENTIFIER NULL,
    WorkflowStepId UNIQUEIDENTIFIER NULL,
    RelatedEntityType NVARCHAR(100) NOT NULL,
    RelatedEntityId UNIQUEIDENTIFIER NOT NULL,
    TaskType NVARCHAR(100) NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Status NVARCHAR(30) NOT NULL,
    Priority NVARCHAR(30) NULL,
    AssignedUserId UNIQUEIDENTIFIER NULL,
    AssignedRoleId UNIQUEIDENTIFIER NULL,
    DueDate DATETIME2(0) NULL,
    StartedAt DATETIME2(0) NULL,
    CompletedAt DATETIME2(0) NULL,
    CreatedByUserId UNIQUEIDENTIFIER NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Task_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Task_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Task_WorkflowDefinition FOREIGN KEY (WorkflowDefinitionId) REFERENCES wf.WorkflowDefinition (WorkflowDefinitionId),
    CONSTRAINT FK_Task_WorkflowStep FOREIGN KEY (WorkflowStepId) REFERENCES wf.WorkflowStep (WorkflowStepId),
    CONSTRAINT FK_Task_AssignedUser FOREIGN KEY (AssignedUserId) REFERENCES sec.[User] (UserId),
    CONSTRAINT FK_Task_AssignedRole FOREIGN KEY (AssignedRoleId) REFERENCES sec.Role (RoleId),
    CONSTRAINT FK_Task_CreatedBy FOREIGN KEY (CreatedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE wf.TaskComment (
    TaskCommentId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_TaskComment PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TaskId UNIQUEIDENTIFIER NOT NULL,
    CommentText NVARCHAR(MAX) NOT NULL,
    CreatedByUserId UNIQUEIDENTIFIER NOT NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_TaskComment_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_TaskComment_Task FOREIGN KEY (TaskId) REFERENCES wf.Task (TaskId),
    CONSTRAINT FK_TaskComment_User FOREIGN KEY (CreatedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE wf.SLAEvent (
    SLAEventId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_SLAEvent PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TaskId UNIQUEIDENTIFIER NOT NULL,
    EventType NVARCHAR(50) NOT NULL,
    TargetAt DATETIME2(0) NULL,
    OccurredAt DATETIME2(0) NOT NULL CONSTRAINT DF_SLAEvent_OccurredAt DEFAULT (SYSUTCDATETIME()),
    EventStatus NVARCHAR(30) NOT NULL,
    Notes NVARCHAR(1000) NULL,
    CONSTRAINT FK_SLAEvent_Task FOREIGN KEY (TaskId) REFERENCES wf.Task (TaskId)
);
GO

CREATE TABLE wf.Notification (
    NotificationId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Notification PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    RelatedEntityType NVARCHAR(100) NULL,
    RelatedEntityId UNIQUEIDENTIFIER NULL,
    RecipientUserId UNIQUEIDENTIFIER NULL,
    RecipientEmail NVARCHAR(256) NULL,
    ChannelType NVARCHAR(30) NOT NULL,
    Subject NVARCHAR(300) NULL,
    MessageBody NVARCHAR(MAX) NULL,
    DeliveryStatus NVARCHAR(30) NOT NULL,
    SentAt DATETIME2(0) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Notification_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Notification_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Notification_User FOREIGN KEY (RecipientUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE wf.WorkflowEvent (
    WorkflowEventId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_WorkflowEvent PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    RelatedEntityType NVARCHAR(100) NOT NULL,
    RelatedEntityId UNIQUEIDENTIFIER NOT NULL,
    ClaimId UNIQUEIDENTIFIER NULL,
    PerformedByUserId UNIQUEIDENTIFIER NULL,
    EventType NVARCHAR(100) NOT NULL,
    Outcome NVARCHAR(100) NULL,
    EventTime DATETIME2(0) NOT NULL CONSTRAINT DF_WorkflowEvent_EventTime DEFAULT (SYSUTCDATETIME()),
    EventData NVARCHAR(MAX) NULL,
    CONSTRAINT FK_WorkflowEvent_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_WorkflowEvent_Claim FOREIGN KEY (ClaimId) REFERENCES core.Claim (ClaimId),
    CONSTRAINT FK_WorkflowEvent_User FOREIGN KEY (PerformedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE rpt.DashboardDefinition (
    DashboardDefinitionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_DashboardDefinition PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NULL,
    DashboardCode NVARCHAR(50) NOT NULL,
    DashboardName NVARCHAR(200) NOT NULL,
    AudienceType NVARCHAR(50) NULL,
    DefinitionJson NVARCHAR(MAX) NULL,
    IsSystemDashboard BIT NOT NULL CONSTRAINT DF_DashboardDefinition_IsSystemDashboard DEFAULT (0),
    IsActive BIT NOT NULL CONSTRAINT DF_DashboardDefinition_IsActive DEFAULT (1),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_DashboardDefinition_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_DashboardDefinition_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId)
);
GO

CREATE TABLE rpt.ReportDefinition (
    ReportDefinitionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ReportDefinition PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NULL,
    DashboardDefinitionId UNIQUEIDENTIFIER NULL,
    ReportCode NVARCHAR(50) NOT NULL,
    ReportName NVARCHAR(200) NOT NULL,
    ReportType NVARCHAR(50) NOT NULL,
    RegulatoryReportType NVARCHAR(100) NULL,
    ReportQueryDefinition NVARCHAR(MAX) NULL,
    FilterDefinitionJson NVARCHAR(MAX) NULL,
    OutputFormat NVARCHAR(30) NULL,
    ScheduleCron NVARCHAR(100) NULL,
    IsScheduled BIT NOT NULL CONSTRAINT DF_ReportDefinition_IsScheduled DEFAULT (0),
    IsSystemReport BIT NOT NULL CONSTRAINT DF_ReportDefinition_IsSystemReport DEFAULT (0),
    IsActive BIT NOT NULL CONSTRAINT DF_ReportDefinition_IsActive DEFAULT (1),
    CreatedByUserId UNIQUEIDENTIFIER NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_ReportDefinition_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_ReportDefinition_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_ReportDefinition_Dashboard FOREIGN KEY (DashboardDefinitionId) REFERENCES rpt.DashboardDefinition (DashboardDefinitionId),
    CONSTRAINT FK_ReportDefinition_CreatedBy FOREIGN KEY (CreatedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE rpt.ReportRecipient (
    ReportRecipientId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ReportRecipient PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    ReportDefinitionId UNIQUEIDENTIFIER NOT NULL,
    RecipientType NVARCHAR(30) NOT NULL,
    UserId UNIQUEIDENTIFIER NULL,
    EmailAddress NVARCHAR(256) NULL,
    DeliveryChannel NVARCHAR(30) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_ReportRecipient_IsActive DEFAULT (1),
    CONSTRAINT FK_ReportRecipient_ReportDefinition FOREIGN KEY (ReportDefinitionId) REFERENCES rpt.ReportDefinition (ReportDefinitionId),
    CONSTRAINT FK_ReportRecipient_User FOREIGN KEY (UserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE rpt.ReportRun (
    ReportRunId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ReportRun PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    ReportDefinitionId UNIQUEIDENTIFIER NOT NULL,
    RequestedByUserId UNIQUEIDENTIFIER NULL,
    RunType NVARCHAR(30) NOT NULL,
    RunStatus NVARCHAR(30) NOT NULL,
    StartedAt DATETIME2(0) NULL,
    CompletedAt DATETIME2(0) NULL,
    OutputLocation NVARCHAR(500) NULL,
    OutputFormat NVARCHAR(30) NULL,
    SummaryMessage NVARCHAR(1000) NULL,
    OutputRowCount INT NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_ReportRun_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_ReportRun_ReportDefinition FOREIGN KEY (ReportDefinitionId) REFERENCES rpt.ReportDefinition (ReportDefinitionId),
    CONSTRAINT FK_ReportRun_RequestedBy FOREIGN KEY (RequestedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE testcfg.TestDataSet (
    TestDataSetId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_TestDataSet PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    DataSetCode NVARCHAR(50) NOT NULL,
    DataSetName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    EntityCoverage NVARCHAR(500) NULL,
    VersionLabel NVARCHAR(50) NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_TestDataSet_Status DEFAULT ('Draft'),
    CreatedByUserId UNIQUEIDENTIFIER NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_TestDataSet_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_TestDataSet_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_TestDataSet_CreatedBy FOREIGN KEY (CreatedByUserId) REFERENCES sec.[User] (UserId),
    CONSTRAINT UQ_TestDataSet UNIQUE (TenantId, DataSetCode)
);
GO

CREATE TABLE testcfg.TestDataFile (
    TestDataFileId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_TestDataFile PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TestDataSetId UNIQUEIDENTIFIER NOT NULL,
    EntityName NVARCHAR(100) NOT NULL,
    TemplateSchemaId UNIQUEIDENTIFIER NULL,
    StagingSchemaDefinitionId UNIQUEIDENTIFIER NULL,
    FileName NVARCHAR(260) NOT NULL,
    FilePath NVARCHAR(500) NULL,
    FileType NVARCHAR(20) NULL,
    ExecutionOrder INT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_TestDataFile_IsActive DEFAULT (1),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_TestDataFile_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_TestDataFile_TestDataSet FOREIGN KEY (TestDataSetId) REFERENCES testcfg.TestDataSet (TestDataSetId),
    CONSTRAINT FK_TestDataFile_Template FOREIGN KEY (TemplateSchemaId) REFERENCES ing.TemplateSchema (TemplateSchemaId),
    CONSTRAINT FK_TestDataFile_StagingSchema FOREIGN KEY (StagingSchemaDefinitionId) REFERENCES ing.StagingSchemaDefinition (StagingSchemaDefinitionId)
);
GO

CREATE TABLE testcfg.TestDataRun (
    TestDataRunId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_TestDataRun PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TestDataSetId UNIQUEIDENTIFIER NOT NULL,
    IngestionJobId UNIQUEIDENTIFIER NULL,
    TriggerType NVARCHAR(30) NOT NULL,
    RunStatus NVARCHAR(30) NOT NULL,
    StartedAt DATETIME2(0) NULL,
    CompletedAt DATETIME2(0) NULL,
    RequestedByUserId UNIQUEIDENTIFIER NULL,
    ResultSummary NVARCHAR(1000) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_TestDataRun_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_TestDataRun_TestDataSet FOREIGN KEY (TestDataSetId) REFERENCES testcfg.TestDataSet (TestDataSetId),
    CONSTRAINT FK_TestDataRun_IngestionJob FOREIGN KEY (IngestionJobId) REFERENCES ing.IngestionJob (IngestionJobId),
    CONSTRAINT FK_TestDataRun_RequestedBy FOREIGN KEY (RequestedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE testcfg.TestDataSchedule (
    TestDataScheduleId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_TestDataSchedule PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TestDataSetId UNIQUEIDENTIFIER NOT NULL,
    ScheduleName NVARCHAR(200) NOT NULL,
    ScheduleCron NVARCHAR(100) NOT NULL,
    TimeZoneName NVARCHAR(100) NULL,
    NextRunAt DATETIME2(0) NULL,
    LastRunAt DATETIME2(0) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_TestDataSchedule_IsActive DEFAULT (1),
    CreatedByUserId UNIQUEIDENTIFIER NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_TestDataSchedule_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_TestDataSchedule_TestDataSet FOREIGN KEY (TestDataSetId) REFERENCES testcfg.TestDataSet (TestDataSetId),
    CONSTRAINT FK_TestDataSchedule_CreatedBy FOREIGN KEY (CreatedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE testcfg.UserImportBatch (
    UserImportBatchId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_UserImportBatch PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    BatchName NVARCHAR(200) NOT NULL,
    SourceFileName NVARCHAR(260) NULL,
    ImportStatus NVARCHAR(30) NOT NULL,
    RequestedByUserId UNIQUEIDENTIFIER NULL,
    StartedAt DATETIME2(0) NULL,
    CompletedAt DATETIME2(0) NULL,
    SummaryMessage NVARCHAR(1000) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_UserImportBatch_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_UserImportBatch_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_UserImportBatch_RequestedBy FOREIGN KEY (RequestedByUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE testcfg.UserImportRow (
    UserImportRowId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_UserImportRow PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    UserImportBatchId UNIQUEIDENTIFIER NOT NULL,
    RowNumber INT NOT NULL,
    UserName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(256) NOT NULL,
    DisplayName NVARCHAR(200) NOT NULL,
    PersonaType NVARCHAR(50) NULL,
    RoleCode NVARCHAR(50) NULL,
    ImportStatus NVARCHAR(30) NOT NULL,
    ValidationMessage NVARCHAR(1000) NULL,
    CreatedUserId UNIQUEIDENTIFIER NULL,
    CONSTRAINT FK_UserImportRow_Batch FOREIGN KEY (UserImportBatchId) REFERENCES testcfg.UserImportBatch (UserImportBatchId),
    CONSTRAINT FK_UserImportRow_CreatedUser FOREIGN KEY (CreatedUserId) REFERENCES sec.[User] (UserId)
);
GO

CREATE TABLE ext.Asset (
    AssetId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Asset PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrganizationId UNIQUEIDENTIFIER NULL,
    AssetCode NVARCHAR(50) NULL,
    AssetName NVARCHAR(200) NOT NULL,
    AssetType NVARCHAR(100) NULL,
    Status NVARCHAR(30) NOT NULL,
    LocationId UNIQUEIDENTIFIER NULL,
    ValueAmount DECIMAL(18,2) NULL,
    AcquiredDate DATE NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Asset_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Asset_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Asset_Organization FOREIGN KEY (OrganizationId) REFERENCES ref.Organization (OrganizationId),
    CONSTRAINT FK_Asset_Location FOREIGN KEY (LocationId) REFERENCES ref.Location (LocationId)
);
GO

CREATE TABLE ext.Vehicle (
    VehicleId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Vehicle PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    AssetId UNIQUEIDENTIFIER NULL,
    VehicleNumber NVARCHAR(50) NULL,
    Vin NVARCHAR(100) NULL,
    LicensePlate NVARCHAR(50) NULL,
    Make NVARCHAR(100) NULL,
    Model NVARCHAR(100) NULL,
    ModelYear INT NULL,
    Status NVARCHAR(30) NOT NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Vehicle_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Vehicle_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Vehicle_Asset FOREIGN KEY (AssetId) REFERENCES ext.Asset (AssetId)
);
GO

CREATE TABLE ext.Contract (
    ContractId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Contract PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrganizationId UNIQUEIDENTIFIER NULL,
    ContractNumber NVARCHAR(100) NULL,
    ContractName NVARCHAR(200) NOT NULL,
    CounterpartyName NVARCHAR(200) NULL,
    EffectiveDate DATE NULL,
    ExpirationDate DATE NULL,
    Status NVARCHAR(30) NOT NULL,
    ContractValue DECIMAL(18,2) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Contract_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Contract_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_Contract_Organization FOREIGN KEY (OrganizationId) REFERENCES ref.Organization (OrganizationId)
);
GO

CREATE TABLE ext.LitigationMatter (
    LitigationMatterId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_LitigationMatter PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    ClaimId UNIQUEIDENTIFIER NULL,
    IncidentId UNIQUEIDENTIFIER NULL,
    MatterNumber NVARCHAR(100) NULL,
    MatterName NVARCHAR(200) NOT NULL,
    CourtName NVARCHAR(200) NULL,
    OpposingParty NVARCHAR(200) NULL,
    CounselName NVARCHAR(200) NULL,
    Status NVARCHAR(30) NOT NULL,
    FiledDate DATE NULL,
    ClosedDate DATE NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_LitigationMatter_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_LitigationMatter_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_LitigationMatter_Claim FOREIGN KEY (ClaimId) REFERENCES core.Claim (ClaimId),
    CONSTRAINT FK_LitigationMatter_Incident FOREIGN KEY (IncidentId) REFERENCES core.Incident (IncidentId)
);
GO

CREATE TABLE ext.Bond (
    BondId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Bond PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    BondNumber NVARCHAR(100) NOT NULL,
    BondType NVARCHAR(100) NULL,
    PrincipalName NVARCHAR(200) NULL,
    SuretyName NVARCHAR(200) NULL,
    ObligeeName NVARCHAR(200) NULL,
    BondAmount DECIMAL(18,2) NULL,
    EffectiveDate DATE NULL,
    ExpirationDate DATE NULL,
    Status NVARCHAR(30) NOT NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Bond_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Bond_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT UQ_Bond_Tenant_BondNumber UNIQUE (TenantId, BondNumber)
);
GO

CREATE TABLE ext.MMSEARecord (
    MMSEARecordId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_MMSEARecord PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    ClaimId UNIQUEIDENTIFIER NULL,
    ReportingEntity NVARCHAR(200) NULL,
    RecordNumber NVARCHAR(100) NOT NULL,
    ReportingQuarter NVARCHAR(20) NULL,
    SubmissionStatus NVARCHAR(30) NOT NULL,
    ResponseCode NVARCHAR(50) NULL,
    InjuryType NVARCHAR(100) NULL,
    SubmittedAt DATETIME2(0) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_MMSEARecord_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_MMSEARecord_Tenant FOREIGN KEY (TenantId) REFERENCES cfg.Tenant (TenantId),
    CONSTRAINT FK_MMSEARecord_Claim FOREIGN KEY (ClaimId) REFERENCES core.Claim (ClaimId),
    CONSTRAINT UQ_MMSEARecord_Tenant_RecordNumber UNIQUE (TenantId, RecordNumber)
);
GO

CREATE INDEX IX_Claim_Tenant_Status ON core.Claim (TenantId, Status);
GO
CREATE INDEX IX_Claim_Tenant_LossDate ON core.Claim (TenantId, LossDate);
GO
CREATE INDEX IX_Incident_Tenant_Status ON core.Incident (TenantId, Status);
GO
CREATE INDEX IX_SourceFile_Tenant_Status ON ing.SourceFile (TenantId, ProcessingStatus);
GO
CREATE INDEX IX_Task_Tenant_Status ON wf.Task (TenantId, Status);
GO
CREATE INDEX IX_RiskScore_Tenant_Entity ON ai.RiskScore (TenantId, RelatedEntityType, RelatedEntityId);
GO
CREATE INDEX IX_ReportRun_Status ON rpt.ReportRun (RunStatus, StartedAt);
GO
