--------------------------------------------------------------------
-- Demo Reset Script
-- Run this to tear down everything and start the demo fresh.
-- After running this, only pre_deploy.sql is needed before
-- the live demo begins.
--------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE SNOW_INTELLIGENCE_DEMO_WH;

--------------------------------------------------------------------
-- 1. Drop the entire database (removes all DCM + dbt objects)
--------------------------------------------------------------------

DROP DATABASE IF EXISTS DBT_DCM_DEMO;

--------------------------------------------------------------------
-- 2. Verify clean state
--------------------------------------------------------------------

SHOW DATABASES LIKE 'DBT_DCM_DEMO';

--------------------------------------------------------------------
-- 3. MANUAL STEP: Delete cached DCM artifacts
--    In Snowsight file explorer, right-click and delete:
--      dcm_project/out/
--------------------------------------------------------------------

deliberate error to remind to delete files in workspace;
--------------------------------------------------------------------
-- Done. Now run 02_pre_deploy_snowsight.sql to recreate
-- prerequisites, then start the demo from PART 1 of DEMO_RUNBOOK.md.
--------------------------------------------------------------------
