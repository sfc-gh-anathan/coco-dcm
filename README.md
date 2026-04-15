# Paychex Payroll Infrastructure (DCM Project)

Snowflake Database Change Management (DCM) project that provisions and manages the infrastructure for Paychex payroll analytics.

## What It Manages

- **Schemas**: `RAW`, `STAGING`, `MARTS` (with managed access)
- **Tables**: `CLIENTS`, `PAYROLL_RUNS` with change tracking enabled
- **Warehouse**: `PAYCHEX_WH` (sized per environment)
- **Data Quality**: Data metric functions for null checks, uniqueness, and value constraints
- **Streams**: CDC streams on `CLIENTS` and `PAYROLL_RUNS` (post-deploy)

## Project Structure

```
dcm_project/
├── manifest.yml                  # Targets, templating, and project config
├── pre_deploy.sql                # Runs before deploy (database/schema setup)
├── post_deploy.sql               # Runs after deploy (streams)
├── sources/definitions/
│   ├── infrastructure.sql        # Schemas and warehouses
│   ├── tables.sql                # Table definitions
│   └── expectations.sql          # Data quality expectations
└── out/                          # Generated plan/analyze output
```

## Environments

| Target | Schema Suffix | Warehouse Size | Retention |
|--------|--------------|----------------|-----------|
| DEV    | `_DEV`       | XSMALL         | 1 day     |
| PROD   | `_PROD`      | MEDIUM         | 90 days   |

## Usage

```bash
# Analyze dependencies
snow dcm analyze --project-dir dcm_project

# Plan changes
snow dcm plan --project-dir dcm_project --target DEV

# Deploy
snow dcm deploy --project-dir dcm_project --target DEV
```
