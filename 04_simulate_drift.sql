--------------------------------------------------------------------
-- Simulate a rogue change — run this AFTER deploy + seed
-- This adds a column directly in Snowflake, outside of DCM.
-- Then run plan again to see DCM detect the drift.
--------------------------------------------------------------------

ALTER TABLE DBT_DCM_DEMO.RAW_DEV.PAYROLL_RUNS ADD COLUMN TEMP_NOTES VARCHAR(500);
