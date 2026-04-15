--------------------------------------------------------------------
-- Post-Deploy Script
-- Runs AFTER snow dcm deploy
-- Use for: streams, alerts, file formats, external stages,
-- semantic views, or any objects that depend on DEFINE'd entities.
--------------------------------------------------------------------

CREATE STREAM IF NOT EXISTS DBT_DCM_DEMO.RAW_DEV.CLIENTS_STREAM
    ON TABLE DBT_DCM_DEMO.RAW_DEV.CLIENTS
    SHOW_INITIAL_ROWS = TRUE;

CREATE STREAM IF NOT EXISTS DBT_DCM_DEMO.RAW_DEV.PAYROLL_RUNS_STREAM
    ON TABLE DBT_DCM_DEMO.RAW_DEV.PAYROLL_RUNS
    SHOW_INITIAL_ROWS = TRUE;
