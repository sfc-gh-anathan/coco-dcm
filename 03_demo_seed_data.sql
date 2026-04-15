--------------------------------------------------------------------
-- DCM vs dbt Demo — Full Setup Script
-- Run this AFTER the full DCM workflow:
--   1. snow sql -f dcm_project/pre_deploy.sql   (prerequisites)
--   2. snow dcm deploy ...                       (creates infra)
--   3. snow sql -f dcm_project/post_deploy.sql   (streams, etc.)
-- Then run THIS script to seed sample data.
--------------------------------------------------------------------

USE WAREHOUSE DAILY_WH_XS;

--------------------------------------------------------------------
-- 2. After DCM deploy: verify infrastructure exists
--------------------------------------------------------------------

SHOW SCHEMAS IN DATABASE DBT_DCM_DEMO;
SHOW TABLES IN SCHEMA DBT_DCM_DEMO.RAW_DEV;

--------------------------------------------------------------------
-- 3. Seed sample data — Paychex clients
--------------------------------------------------------------------

TRUNCATE TABLE IF EXISTS DBT_DCM_DEMO.RAW_DEV.CLIENTS;

INSERT INTO DBT_DCM_DEMO.RAW_DEV.CLIENTS
    (CLIENT_ID, CLIENT_NAME, REGION, EMPLOYEE_COUNT, PLAN_TYPE, ONBOARDED_AT)
VALUES
    (1, 'Northeast Manufacturing Co', 'NORTHEAST', 450,  'ENTERPRISE',  '2020-03-15'),
    (2, 'Sunshine Dental Group',      'SOUTHEAST', 85,   'ESSENTIALS',  '2021-06-01'),
    (3, 'Great Lakes Logistics',      'MIDWEST',   220,  'SELECT',      '2019-11-20'),
    (4, 'Pacific Rim Tech',           'WEST',      1200, 'ENTERPRISE',  '2018-01-10'),
    (5, 'Lone Star Services',         'SOUTH',     310,  'SELECT',      '2022-02-28'),
    (6, 'Empire State Media',         'NORTHEAST', 95,   'ESSENTIALS',  '2023-01-15'),
    (7, 'Rocky Mountain Builders',    'WEST',      175,  'SELECT',      '2021-09-01'),
    (8, 'Bayou Restaurants LLC',      'SOUTH',     60,   'ESSENTIALS',  '2023-07-12');

--------------------------------------------------------------------
-- 4. Seed sample data — Paychex payroll runs
--------------------------------------------------------------------

TRUNCATE TABLE IF EXISTS DBT_DCM_DEMO.RAW_DEV.PAYROLL_RUNS;

INSERT INTO DBT_DCM_DEMO.RAW_DEV.PAYROLL_RUNS
    (PAYROLL_RUN_ID, CLIENT_ID, RUN_DATE, PAY_PERIOD_START, PAY_PERIOD_END,
     TOTAL_GROSS_PAY, TOTAL_NET_PAY, CHECK_COUNT, STATUS, PROCESSED_AT)
VALUES
    (1001, 1, '2026-03-15', '2026-03-01', '2026-03-15', 825000.00,  612500.00,  450,  'COMPLETED', '2026-03-15 14:30:00'),
    (1002, 1, '2026-03-31', '2026-03-16', '2026-03-31', 830000.00,  615000.00,  450,  'COMPLETED', '2026-03-31 14:30:00'),
    (1003, 2, '2026-03-15', '2026-03-01', '2026-03-15', 195000.00,  148000.00,  85,   'COMPLETED', '2026-03-15 10:00:00'),
    (1004, 2, '2026-03-31', '2026-03-16', '2026-03-31', 195000.00,  148000.00,  85,   'COMPLETED', '2026-03-31 10:00:00'),
    (1005, 3, '2026-03-15', '2026-03-01', '2026-03-15', 520000.00,  390000.00,  220,  'COMPLETED', '2026-03-15 12:00:00'),
    (1006, 3, '2026-03-31', '2026-03-16', '2026-03-31', 525000.00,  393000.00,  220,  'COMPLETED', '2026-03-31 12:00:00'),
    (1007, 4, '2026-03-15', '2026-03-01', '2026-03-15', 3200000.00, 2400000.00, 1200, 'COMPLETED', '2026-03-15 16:00:00'),
    (1008, 4, '2026-03-31', '2026-03-16', '2026-03-31', 3250000.00, 2430000.00, 1200, 'COMPLETED', '2026-03-31 16:00:00'),
    (1009, 5, '2026-03-15', '2026-03-01', '2026-03-15', 680000.00,  510000.00,  310,  'COMPLETED', '2026-03-15 11:00:00'),
    (1010, 5, '2026-03-31', '2026-03-16', '2026-03-31', 685000.00,  513000.00,  310,  'COMPLETED', '2026-03-31 11:00:00'),
    (1011, 6, '2026-03-31', '2026-03-16', '2026-03-31', 215000.00,  162000.00,  95,   'COMPLETED', '2026-03-31 09:00:00'),
    (1012, 7, '2026-03-31', '2026-03-16', '2026-03-31', 380000.00,  285000.00,  175,  'COMPLETED', '2026-03-31 13:00:00'),
    (1013, 8, '2026-03-31', '2026-03-16', '2026-03-31', 105000.00,  79000.00,   60,   'PENDING',   '2026-03-31 15:00:00'),
    (1014, 1, '2026-04-15', '2026-04-01', '2026-04-15', 835000.00,  620000.00,  452,  'COMPLETED', '2026-04-15 14:30:00');

--------------------------------------------------------------------
-- 5. Quick sanity check
--------------------------------------------------------------------

SELECT 'CLIENTS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM DBT_DCM_DEMO.RAW_DEV.CLIENTS
UNION ALL
SELECT 'PAYROLL_RUNS', COUNT(*) FROM DBT_DCM_DEMO.RAW_DEV.PAYROLL_RUNS;

--------------------------------------------------------------------
-- 6. Verify post-deploy objects (streams from post_deploy.sql)
--------------------------------------------------------------------

SHOW STREAMS IN SCHEMA DBT_DCM_DEMO.RAW_DEV;

--------------------------------------------------------------------
-- 7. Cleanup (run after demo is complete)
--------------------------------------------------------------------

-- DROP DATABASE IF EXISTS DBT_DCM_DEMO;
