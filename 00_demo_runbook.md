# DCM vs dbt Demo Runbook — Paychex Payroll Analytics

## Overview

This demo shows how DCM and dbt work together with clear ownership boundaries:
- **DCM** = Infrastructure (the containers and rules — schemas, tables, warehouses, roles, DQ monitors)
- **dbt** = Transformations (the business logic that fills those containers — cleaning, joining, aggregating data)

Think of it this way: DCM builds the empty rooms and sets the house rules. dbt moves in and arranges everything inside them.

Database: `DBT_DCM_DEMO` | Warehouse: `DAILY_WH_XS`

---

## Architecture Diagram

```
┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
  TERRAFORM LAYER — Account-level resources
│ Network policies, storage integrations, resource monitors,         │
  account parameters, cross-cloud replication
└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        SNOWFLAKE ACCOUNT                            │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                   DBT_DCM_DEMO (database)                   │    │
│  │                                                             │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │    │
│  │  │     RAW      │  │   STAGING    │  │    MARTS     │      │    │
│  │  │              │  │              │  │              │      │    │
│  │  │  CLIENTS     │  │ stg_clients  │  │ fct_payroll  │      │    │
│  │  │  PAYROLL_    │  │ stg_payroll_ │  │ _volume_by_  │      │    │
│  │  │  RUNS        │  │ runs         │  │ region       │      │    │
│  │  │              │  │              │  │              │      │    │
│  │  │  + 5 DQ      │  │  + 8 dbt     │  │              │      │    │
│  │  │  expectations│  │  tests       │  │              │      │    │
│  │  └──────┬───────┘  └──────┬───────┘  └──────────────┘      │    │
│  │         │                 │                                 │    │
│  │         │   source()      │   ref()                         │    │
│  │         └────────►────────┘────────►─────────┘              │    │
│  │                                                             │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                     │
│  ┌───────────────────┐                                              │
│  │  DAILY_WH_XS      │  ◄── dbt runs here                          │
│  └───────────────────┘                                              │
│                                                                     │
│  ┌───────────────────────────────────────────────┐                  │
│  │  DBT_DCM_DEMO.PROJECTS.PAYCHEX_INFRA          │                  │
│  │  (DCM project object — tracks deployed state)  │                  │
│  └───────────────────────────────────────────────┘                  │
└─────────────────────────────────────────────────────────────────────┘

TOOL OWNERSHIP:
  Terraform:   account-level (above the database line)
  DCM:         all 3 schemas, RAW tables, warehouse, DQ expectations
  dbt:         views INSIDE staging + marts (the SQL logic), dbt tests
  GitHub:      version control, PR review, CI/CD automation

  Note: DCM creates the STAGING and MARTS schemas (the containers).
  dbt creates the views inside them (the transformation logic).
  Both tools own different parts of the same database.
```

---

## Data Flow

```
  Paychex Source Systems
  (Snowpipe / connector / manual load)
         │
         ▼
  ┌──────────────────────────────────────┐
  │  RAW.CLIENTS / RAW.PAYROLL_RUNS      │   DCM owns structure + DQ
  │                                      │   expectations fire on change
  │  DQ checks:                          │   (null_count, duplicate_count,
  │  ✓ CLIENT_ID not null + unique       │    min >= 0)
  │  ✓ PAYROLL_RUN_ID not null           │
  │  ✓ TOTAL_GROSS_PAY not null + >= 0   │
  └──────────────┬───────────────────────┘
                 │
                 │  dbt source()
                 ▼
  ┌──────────────────────────────────────┐
  │  STAGING.stg_clients                 │   dbt cleans + standardizes
  │  STAGING.stg_payroll_runs            │   (UPPER, TRIM, computed cols)
  │                                      │
  │  dbt tests:                          │   dbt tests guard output
  │  ✓ unique + not_null on IDs          │   (uniqueness, accepted_values)
  │  ✓ accepted_values on STATUS         │
  │  ✓ not_null on REGION                │
  └──────────────┬───────────────────────┘
                 │
                 │  dbt ref()
                 ▼
  ┌──────────────────────────────────────┐
  │  MARTS.fct_payroll_volume_by_region  │   dbt aggregates for business
  │                                      │   (JOIN, GROUP BY, SUM, AVG)
  │  Grain: region + plan_type + month   │
  │  Metrics: runs, checks, gross, net   │   dbt tests: not_null on
  │                                      │   REGION + TOTAL_GROSS_PAYROLL
  └──────────────────────────────────────┘
                 │
                 ▼
        Dashboards / Analysts / BI Tools
```

**Key insight:** Data quality is checked at TWO boundaries:
1. **Entering RAW** — DCM expectations (structural contract)
2. **Leaving STAGING** — dbt tests (transformation contract)

If bad data enters RAW, Snowflake's DMF engine catches it (DCM set up those monitors). If a dbt model introduces a bug, dbt tests catch it.

---

## FAQ: "Why Not Just Use One Tool?"

### "Why can't DCM do everything?"

DCM is declarative infrastructure. It excels at:
- Creating/altering databases, schemas, tables, roles, grants
- Drift detection (plan shows what changed outside your definitions)
- Data quality expectations on raw tables

But it **cannot**:
- Build a transformation DAG with dependencies (`ref()`, `source()`)
- Run tests on derived/computed data
- Generate documentation and lineage graphs
- Manage incremental materializations or snapshots

**Bottom line:** DCM builds the house. It doesn't arrange the furniture.

### "Why can't dbt do everything?"

dbt is a transformation framework. It excels at:
- SQL transformations with dependency management
- Testing, documentation, and lineage
- Incremental models, snapshots, seeds

But it **cannot**:
- Create databases or schemas (it expects them to exist)
- Create or manage roles, grants, or RBAC
- Define warehouses or compute resources
- Detect drift (if someone changes a table outside dbt, dbt doesn't know)
- Set data quality expectations on tables it doesn't own

**Bottom line:** dbt arranges the furniture. It doesn't build the house.

### "What about Terraform?"

Terraform is still useful for **account-level** things that sit above any single database:
- Network policies
- Storage integrations
- Resource monitors
- Account parameters
- Cross-cloud replication config

If you already have Terraform for multi-cloud infra, keep it for that layer. Use DCM for everything inside Snowflake (databases down to tables). Don't manage the same object in both.

```
  Terraform  ──►  Account-level (network, integrations, monitors)
  DCM        ──►  Database-level (schemas, tables, roles, grants, DQ)
  dbt        ──►  Data-level (transformations, tests, docs)
```

---

## Prerequisites

Run `dcm_project/pre_deploy.sql` to create the database and project schema.

---

## PART 1: DCM — Build the Infrastructure

### Step 1: Show the DCM project structure

**Value:** DCM projects are simple — a manifest and definition files. No agents, no plugins.

```
dcm_project/
├── manifest.yml                          -- targets, variables
└── sources/definitions/
    ├── infrastructure.sql                -- schemas
    ├── tables.sql                        -- raw table structures
    └── expectations.sql                  -- data quality rules
```

Walk through each file briefly:
- `manifest.yml` — points at the Snowflake project object, defines DEV target
- `infrastructure.sql` — 3 schemas: RAW, STAGING, MARTS
- `tables.sql` — CLIENTS and PAYROLL_RUNS with Paychex-relevant columns
- `expectations.sql` — 5 data quality rules (no nulls on IDs, no negative pay, etc.)


### Step 2: Plan (preview what DCM will do)

**Action:** In the workspace, click the **Plan** button (or ask Cortex Code to run plan).

> CLI equivalent: `snow dcm plan --project-dir /dcm_project --target DEV`

**What to say:** "Plan is like a dry run. It compares our definitions to what exists in Snowflake and shows what it would create, alter, or drop. Nothing changes yet."

**Expected output:** The plan UI shows a list of CREATE operations:
- CREATE SCHEMA DBT_DCM_DEMO.RAW_DEV, STAGING_DEV, MARTS_DEV
- CREATE WAREHOUSE PAYCHEX_WH_DEV (XSMALL)
- CREATE TABLE DBT_DCM_DEMO.RAW_DEV.CLIENTS
- CREATE TABLE DBT_DCM_DEMO.RAW_DEV.PAYROLL_RUNS
- ATTACH 5 data metric functions

Click on any row to expand and see the details (columns, properties, DMFs).


### Step 3: Deploy

**Action:** In the workspace, click the **Deploy** button (or ask Cortex Code to run deploy).

> CLI equivalent: `snow dcm deploy --project-dir /dcm_project --target DEV`

**What to say:** "Now we apply. DCM creates everything declaratively — if we run deploy again with no changes, it does nothing. Idempotent."

**Expected output:** All objects created successfully. Zero errors.


### Step 4: Verify in Snowflake

**Command (SQL):** Run in a Snowsight worksheet:
```sql
SHOW SCHEMAS IN DATABASE DBT_DCM_DEMO;
SHOW TABLES IN SCHEMA DBT_DCM_DEMO.RAW_DEV;
```

**Expected output:** RAW_DEV, STAGING_DEV, MARTS_DEV schemas exist. CLIENTS and PAYROLL_RUNS tables exist.


### Step 5: Seed sample data

**What to say:** "In production, data would flow in via Snowpipe or a connector. For the demo, we'll insert some Paychex-style records."

**Command:** Run `03_demo_seed_data.sql` in a Snowsight worksheet

**Expected output:** 8 clients inserted. 14 payroll runs inserted.


---

## PART 1b: DCM Catches Drift

**Transition line:** "What happens when someone makes a change directly in Snowflake, outside of DCM? Let's simulate that."


### Step 5b: Simulate a rogue change

**What to say:** "Imagine a well-meaning DBA adds a column directly in Snowflake — maybe during an incident, or just to 'quickly test something.' This happens all the time."

**Command:** Run `04_simulate_drift.sql` in a Snowsight worksheet, or run:
```sql
ALTER TABLE DBT_DCM_DEMO.RAW_DEV.PAYROLL_RUNS ADD COLUMN TEMP_NOTES VARCHAR(500);
```

**Expected output:** Statement executed successfully.

Now the live table has a column that doesn't exist in our DCM definitions. This is **drift**.


### Step 5c: DCM detects the drift

**Action:** Click **Plan** again in the workspace (or ask Cortex Code).

**What to say:** "We haven't changed any of our definition files. But watch what plan shows us."

**Expected output:** The plan UI shows **1 ALTER** on PAYROLL_RUNS — click to expand and see the `TEMP_NOTES` column flagged for removal.

**Key talking point:** "This is the power of declarative infrastructure. DCM treats your definition files as the source of truth. Anything that exists in Snowflake but not in your definitions is drift — and plan surfaces it before anything happens."


### Step 5d: Fix the drift

You have two choices (talk through both):

**Option A — Remove the rogue column (enforce the definition):**
Click **Deploy** in the workspace. This drops `TEMP_NOTES` and brings Snowflake back in sync with your definitions.

**Option B — Adopt the column (update the definition):**
Edit `dcm_project/sources/definitions/tables.sql` — add `TEMP_NOTES VARCHAR(500)` to the PAYROLL_RUNS table. Then click **Plan** again — it shows zero changes, definitions match reality.

**What to say:** "Either way, you're making a deliberate decision. No silent drift. No mystery columns. For this demo, let's remove it — our definitions are the source of truth."

**Action:** Click **Deploy** to enforce the definition.

**Expected output:** Deploy succeeds. The rogue column is gone. Snowflake matches our definitions exactly.


### Step 5e: Prove it's clean

**Command (SQL):**
```sql
DESCRIBE TABLE DBT_DCM_DEMO.RAW_DEV.PAYROLL_RUNS;
```

**Expected output:** The original columns only — no `TEMP_NOTES`. Back in sync.


---

## PART 2: dbt — Transform the Data

**Transition line:** "DCM built the foundation. Now dbt takes over for transformations — it reads from the RAW tables DCM created and builds analytics-ready models."


### Step 6: Show the dbt project structure

```
dbt_project/
├── dbt_project.yml           -- project config
├── profiles.yml              -- Snowflake connection (warehouse: DAILY_WH_XS)
├── macros/
│   └── generate_schema_name.sql  -- routes models to correct schemas
└── models/
    ├── staging/
    │   ├── sources.yml            -- points at DCM's raw tables
    │   ├── schema.yml             -- tests on staged data
    │   ├── stg_clients.sql        -- clean + standardize clients
    │   └── stg_payroll_runs.sql   -- clean + compute deductions
    └── marts/
        ├── schema.yml             -- tests on mart
        └── fct_payroll_volume_by_region.sql  -- the business metric
```

Key callouts:
- `sources.yml` bridges DCM and dbt — it tells dbt "these raw tables exist, DCM manages them"
- Staging models clean data (UPPER, TRIM, computed columns like TOTAL_DEDUCTIONS)
- Mart model aggregates by region and plan type — what a Paychex ops team would use


### Step 7: Run dbt models

**Command:**
```bash
dbt run --project-dir /dbt_project
```

**What to say:** "dbt compiles the Jinja SQL, resolves the ref() and source() dependencies, and runs them in the right order: staging first, then marts."

**Expected output:**
```
1 of 3 OK created sql view model STAGING.stg_clients
2 of 3 OK created sql view model STAGING.stg_payroll_runs
3 of 3 OK created sql view model MARTS.fct_payroll_volume_by_region

Completed successfully. PASS=3 WARN=0 ERROR=0 SKIP=0 TOTAL=3
```


### Step 8: Run dbt tests

**Command:**
```bash
dbt test --project-dir /dbt_project
```

**What to say:** "dbt tests guard the transformed output — uniqueness, not-null, accepted values. This complements DCM's data quality expectations on the raw input."

**Expected output:**
```
PASS not_null_stg_clients_CLIENT_ID
PASS unique_stg_clients_CLIENT_ID
PASS not_null_stg_clients_REGION
PASS not_null_stg_payroll_runs_PAYROLL_RUN_ID
PASS unique_stg_payroll_runs_PAYROLL_RUN_ID
PASS accepted_values_stg_payroll_runs_STATUS (PENDING, COMPLETED, FAILED, CANCELLED)
PASS not_null_fct_payroll_volume_by_region_REGION
PASS not_null_fct_payroll_volume_by_region_TOTAL_GROSS_PAYROLL

Done. PASS=8 WARN=0 ERROR=0 SKIP=0 TOTAL=8
```


### Step 9: Query the final result

**Command (SQL):**
```sql
SELECT * FROM DBT_DCM_DEMO.MARTS.FCT_PAYROLL_VOLUME_BY_REGION
ORDER BY PAYROLL_MONTH, REGION;
```

**What to say:** "This is the business-ready output — monthly payroll volume by region and plan type. Built from raw data that DCM manages, transformed by dbt."

**Expected output:** 8 rows showing March and April 2026 payroll volumes across NORTHEAST, SOUTHEAST, MIDWEST, WEST, and SOUTH regions with ENTERPRISE, SELECT, and ESSENTIALS plan types.


---

## PART 3: Cortex Code — Add a Column End-to-End

**Transition line:** "Now let's see what happens when the business asks for a change — add a PAYMENT_METHOD column to track how payroll runs are paid. And let's have Cortex Code do it for us, end to end."

**Why this is impressive:**
- Shows AI-assisted infrastructure changes with a safety net (plan before deploy)
- Demonstrates the full DCM → dbt lifecycle in one shot
- Proves the tools work together seamlessly — not just in theory

**Prompt:** 
************************
"Add a PAYMENT_METHOD VARCHAR(50) column to the PAYROLL_RUNS table in DCM, deploy it, update the dbt staging model, and rerun dbt."
************************

After Cortex Code finishes, backfill data and query:

```sql
UPDATE DBT_DCM_DEMO.RAW_DEV.PAYROLL_RUNS 
SET PAYMENT_METHOD = CASE MOD(PAYROLL_RUN_ID, 3)
    WHEN 0 THEN 'ACH'
    WHEN 1 THEN 'CHECK'
    WHEN 2 THEN 'WIRE'
END;

SELECT PAYROLL_RUN_ID, PAYMENT_METHOD FROM DBT_DCM_DEMO.STAGING_DEV.STG_PAYROLL_RUNS ORDER BY PAYROLL_RUN_ID;
```

**Closing line:** "From schema change to deployed column to data flowing through — all without leaving Snowsight. DCM handled the infrastructure, dbt handled the transformation, and Cortex Code orchestrated both."


---

## PART 4 (Optional Slide): GitHub Automation

If asked "how does this get automated?":

- Push both `dcm_project/` and `dbt_project/` to a GitHub repo
- A GitHub Actions workflow runs the same commands on PR (plan + test) and on merge (deploy)
- Same commands, just triggered by git instead of typed manually

**Key line:** "GitHub doesn't replace DCM or dbt. It automates the same plan-review-deploy cycle we just walked through."


---

## Ownership Cheat Sheet

| Layer | Tool | What It Owns | Example |
|-------|------|-------------|--------|
| Account-level | Terraform | Network policies, integrations, monitors | Things above any single database |
| Containers + rules | DCM | Schemas, RAW tables, warehouse, DQ monitors | The empty rooms + house rules |
| Business logic | dbt | Views inside STAGING + MARTS, tests, docs | The SQL that transforms data |
| Automation | GitHub | CI/CD pipeline, PR review | Triggers the same commands on merge |

**Rule:** Never manage the same object in two tools.
